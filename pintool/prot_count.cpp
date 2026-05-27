#include "pin.H"
#include <iostream>
#include <map>
#include <set>
#include <vector>
#include <algorithm>
#include <iomanip>

using namespace std;

// Per-function PROT execution counts, keyed by function name.
static map<string, UINT64> FuncCounts;
static PIN_LOCK FuncCountLock;
static UINT64 TotalCount = 0;

// Interned function name strings. Pointers into this set are passed to
// BBL_InsertCall and must outlive the program run — this set ensures that.
static set<string> InternedNames;

// Sawz edit
// Returns the number of PROT-prefixed instructions in bbl.
// PROT is always emitted as a leading 0x36 byte (X86MCCodeEmitter.cpp:1291).
static UINT64 CountProtInBBL(BBL bbl) {
    UINT64 n = 0;
    for (INS ins = BBL_InsHead(bbl); INS_Valid(ins); ins = INS_Next(ins)) {
        UINT8 byte = 0;
        if (PIN_SafeCopy(&byte,
                         reinterpret_cast<const VOID *>(INS_Address(ins)),
                         1) == 1
            && byte == 0x36)
            ++n;
    }
    return n;
}

// Analysis callback: invoked once per BBL execution for BBLs that contain
// at least one PROT-prefixed instruction. N is the static count of
// PROT-prefixed instructions in this BBL (computed once at instrumentation time).
VOID CountProt(const string *FuncName, UINT64 N) {
    PIN_GetLock(&FuncCountLock, PIN_GetTid());
    FuncCounts[*FuncName] += N;
    TotalCount += N;
    PIN_ReleaseLock(&FuncCountLock);
}

// Sawz edit
VOID ImageLoad(IMG img, VOID *v) {
    // Only instrument the main executable; skip libc, libm, and other DSOs.
    if (!IMG_IsMainExecutable(img))
        return;

    for (SEC sec = IMG_SecHead(img); SEC_Valid(sec); sec = SEC_Next(sec)) {
        for (RTN rtn = SEC_RtnHead(sec); RTN_Valid(rtn); rtn = RTN_Next(rtn)) {
            RTN_Open(rtn);
            // Intern the name so the pointer stays valid for the process lifetime.
            const string &interned =
                *InternedNames.insert(RTN_Name(rtn)).first;

            for (BBL bbl = RTN_BblHead(rtn); BBL_Valid(bbl); bbl = BBL_Next(bbl)) {
                UINT64 n = CountProtInBBL(bbl);
                if (n > 0) {
                    BBL_InsertCall(bbl, IPOINT_BEFORE,
                                   reinterpret_cast<AFUNPTR>(CountProt),
                                   IARG_PTR, &interned,
                                   IARG_UINT64, n,
                                   IARG_END);
                }
            }
            RTN_Close(rtn);
        }
    }
}

VOID Fini(INT32 code, VOID *v) {
    vector<pair<string, UINT64>> sorted(FuncCounts.begin(), FuncCounts.end());
    sort(sorted.begin(), sorted.end(),
         [](const auto &a, const auto &b) { return a.second > b.second; });

    cout << "=== PROT prefix execution counts ===\n";
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
    // Sawz edit
    IMG_AddInstrumentFunction(ImageLoad, 0);
    PIN_AddFiniFunction(Fini, 0);
    PIN_StartProgram();
    return 0;
}
