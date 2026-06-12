#include "pin.H"
#include <iostream>
#include <map>
#include <set>
#include <vector>
#include <algorithm>
#include <iomanip>
#include <cstring>
#include <elf.h>

using namespace std;

// knob for specifying the target binary by filename substring.
KNOB<string> KnobTarget(KNOB_MODE_WRITEONCE, "pintool",
    "tgt", "", "Filename substring of the binary to instrument (e.g. test64)");

// address range of the target binary, set at image load time.
static ADDRINT g_target_lo = 0;
static ADDRINT g_target_hi = 0;

// Per-function PROT execution counts, keyed by function name.
static map<string, UINT64> FuncCounts;
static PIN_LOCK FuncCountLock;
static UINT64 TotalCount = 0;

static set<string> InternedNames;


struct ExecSegment {
    ADDRINT       runtime_start;
    ADDRINT       runtime_end;
    vector<UINT8> data;  // data[i] == byte at runtime address runtime_start + i
};
static vector<ExecSegment> g_exec_segs;

static bool ElfReadByte(ADDRINT addr, UINT8 *out) {
    for (const auto &seg : g_exec_segs) {
        if (addr >= seg.runtime_start && addr < seg.runtime_end) {
            *out = seg.data[addr - seg.runtime_start];
            return true;
        }
    }
    return false;
}

// we have to get the ELF file from disk and parse it ourselves because PIN_SafeCopy 
// doesn't work for execute-only pages
static void ParseELFSegments(const string &path, ADDRINT img_lo) {
    FILE *f = fopen(path.c_str(), "rb");
    if (!f) {
        cerr << "[ELF] Cannot open " << path << "\n";
        return;
    }

    Elf64_Ehdr ehdr;
    if (fread(&ehdr, sizeof(ehdr), 1, f) != 1 ||
        memcmp(ehdr.e_ident, ELFMAG, SELFMAG) != 0 ||
        ehdr.e_ident[EI_CLASS] != ELFCLASS64) {
        cerr << "[ELF] Not a valid 64-bit ELF: " << path << "\n";
        fclose(f);
        return;
    }

    uint64_t min_vaddr = UINT64_MAX;
    fseek(f, (long)ehdr.e_phoff, SEEK_SET);
    for (int i = 0; i < ehdr.e_phnum; ++i) {
        Elf64_Phdr phdr;
        if (fread(&phdr, sizeof(phdr), 1, f) != 1) break;
        if (phdr.p_type == PT_LOAD && phdr.p_vaddr < min_vaddr)
            min_vaddr = phdr.p_vaddr;
    }
    if (min_vaddr == UINT64_MAX) {
        cerr << "[ELF] No PT_LOAD segments found\n";
        fclose(f);
        return;
    }
    ADDRINT bias = img_lo - (ADDRINT)min_vaddr;

    fseek(f, (long)ehdr.e_phoff, SEEK_SET);
    for (int i = 0; i < ehdr.e_phnum; ++i) {
        Elf64_Phdr phdr;
        if (fread(&phdr, sizeof(phdr), 1, f) != 1) break;
        if (phdr.p_type != PT_LOAD || !(phdr.p_flags & PF_X) || phdr.p_filesz == 0)
            continue;

        ExecSegment seg;
        seg.runtime_start = (ADDRINT)phdr.p_vaddr + bias;
        seg.runtime_end   = seg.runtime_start + (ADDRINT)phdr.p_filesz;
        seg.data.resize(phdr.p_filesz);

        long saved = ftell(f);
        fseek(f, (long)phdr.p_offset, SEEK_SET);
        size_t got = fread(seg.data.data(), 1, phdr.p_filesz, f);
        fseek(f, saved, SEEK_SET);

        if (got != phdr.p_filesz) {
            cerr << "[ELF] Short read on exec segment ("
                 << got << " / " << phdr.p_filesz << " bytes)\n";
        } else {
            cerr << "[ELF] Cached exec segment ["
                 << hex << seg.runtime_start << ", " << seg.runtime_end
                 << ") " << dec << phdr.p_filesz << " bytes\n";
            g_exec_segs.push_back(move(seg));
        }
    }

    fclose(f);
}

static UINT64 CountProtInBBL(BBL bbl) {
    UINT64 n = 0;
    for (INS ins = BBL_InsHead(bbl); INS_Valid(ins); ins = INS_Next(ins)) {
        UINT8 byte = 0;
        if (ElfReadByte(INS_Address(ins), &byte) && byte == 0x36)
            ++n;
    }
    return n;
}

VOID CountProt(const string *FuncName, UINT64 N) {
    PIN_GetLock(&FuncCountLock, PIN_GetTid());
    FuncCounts[*FuncName] += N;
    TotalCount += N;
    PIN_ReleaseLock(&FuncCountLock);
}

VOID Trace(TRACE trace, VOID *v) {
    for (BBL bbl = TRACE_BblHead(trace); BBL_Valid(bbl); bbl = BBL_Next(bbl)) {
        INS head = BBL_InsHead(bbl);
        if (!INS_Valid(head)) continue;

        ADDRINT head_addr = INS_Address(head);
        if (g_target_lo != 0 &&
            (head_addr < g_target_lo || head_addr >= g_target_hi)) continue;

        RTN rtn = INS_Rtn(head);
        const string func_name = RTN_Valid(rtn) ? RTN_Name(rtn) : "unknown";

        // count 0x36 prefix at INS_Address of each instruction
        UINT64 n = CountProtInBBL(bbl);
        if (n > 0) {
            const string &interned = *InternedNames.insert(func_name).first;
            BBL_InsertCall(bbl, IPOINT_BEFORE,
                           reinterpret_cast<AFUNPTR>(CountProt),
                           IARG_PTR, &interned,
                           IARG_UINT64, n,
                           IARG_END);
        }
    }
}

VOID ImageLoad(IMG img, VOID *v) {
    const string name = IMG_Name(img);
    cerr << "[IMG] " << name
         << " isMain=" << IMG_IsMainExecutable(img)
         << " lo=" << hex << IMG_LowAddress(img)
         << " hi=" << IMG_HighAddress(img) << "\n";
    if (!KnobTarget.Value().empty() &&
        name.find(KnobTarget.Value()) != string::npos) {
        g_target_lo = IMG_LowAddress(img);
        g_target_hi = IMG_HighAddress(img);
        cerr << "[IMG] target matched: " << name << "\n";
        ParseELFSegments(name, IMG_LowAddress(img));
    }
}

VOID Fini(INT32 code, VOID *v) {
    vector<pair<string, UINT64>> sorted(FuncCounts.begin(), FuncCounts.end());
    sort(sorted.begin(), sorted.end(),
         [](const auto &a, const auto &b) { return a.second > b.second; });
    cout << "=== PROT prefix execution counts (v8) ===\n";
    cout << "Total:  " << TotalCount << "\n\n";
    cout << "Per-function (descending):\n";
    for (const auto &[name, count] : sorted)
        cout << "  " << left << setw(40) << name << count << "\n";
}

int main(int argc, char *argv[]) {
    PIN_InitSymbols();
    if (PIN_Init(argc, argv))
        return 1;
    PIN_InitLock(&FuncCountLock);
    IMG_AddInstrumentFunction(ImageLoad, 0);
    TRACE_AddInstrumentFunction(Trace, 0);
    PIN_AddFiniFunction(Fini, 0);
    PIN_StartProgram();
    return 0;
}
