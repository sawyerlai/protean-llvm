# PROT-Prefix Execution Counter PIN Tool — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a PIN tool that counts runtime execution frequency of PROT-prefixed (`0x36`) instructions in a compiled binary, reporting a global total and a per-function breakdown sorted by count descending.

**Architecture:** A single-file PIN tool (`prot_count.cpp`) instruments BBLs at image-load time — counting static `0x36` first-byte occurrences per BBL and inserting one `BBL_InsertCall` per BBL that adds the static count to a per-function counter. At program exit the counters are sorted and printed to stdout.

**Tech Stack:** Intel PIN 3.x (C++ PIN API), C++17, GNU make.

---

## File Map

| File | Action | Responsibility |
|---|---|---|
| `pintool/prot_count.cpp` | Create | Sole PIN tool source: globals, analysis callback, image-load callback, fini output |
| `pintool/Makefile` | Create | Builds `obj-intel64/prot_count.so` against `$(PIN_ROOT)` |
| `pintool/test/test_target.c` | Create | Small C binary with a known-call-count function for smoke testing |
| `pintool/test/run_test.sh` | Create | Shell smoke test: compiles target, runs PIN, checks output format and non-zero count |
| `pintool/README.md` | Create | Build and usage instructions |

---

### Task 1: Scaffold — Makefile and minimal compilable tool

**Files:**
- Create: `pintool/Makefile`
- Create: `pintool/prot_count.cpp`

- [ ] **Step 1: Create `pintool/Makefile`**

```makefile
PIN_ROOT ?= $(error Set PIN_ROOT to your PIN installation directory)

include $(PIN_ROOT)/source/tools/Config/makefile.config
TOOL_ROOTS := prot_count
include $(PIN_ROOT)/source/tools/Config/makefile.rules
```

- [ ] **Step 2: Create `pintool/prot_count.cpp` skeleton**

```cpp
#include "pin.H"
#include <iostream>
#include <map>
#include <set>
#include <vector>
#include <algorithm>
#include <iomanip>

using namespace std;

int main(int argc, char *argv[]) {
    PIN_InitSymbols();
    if (PIN_Init(argc, argv))
        return 1;
    PIN_StartProgram();
    return 0;
}
```

- [ ] **Step 3: Build the skeleton**

```bash
cd pintool
make PIN_ROOT=/path/to/pin
```

Expected: `obj-intel64/prot_count.so` created with no errors.

- [ ] **Step 4: Commit**

```bash
git add pintool/Makefile pintool/prot_count.cpp
git commit -m "feat: add pintool scaffold"
```

---

### Task 2: Test target binary

**Files:**
- Create: `pintool/test/test_target.c`

- [ ] **Step 1: Create the test target**

```c
#include <stdio.h>

volatile int sink = 0;

/* Called exactly 3 times from main — lets us verify:
   PIN count for secret_work == static PROT count * 3 */
void secret_work(int n) {
    int i;
    for (i = 0; i < n; i++)
        sink += i * i;
}

int main(void) {
    secret_work(3);
    secret_work(3);
    secret_work(3);
    return 0;
}
```

- [ ] **Step 2: Compile with SBOX mode (guarantees non-zero PROT count)**

```bash
/path/to/build/bin/clang -mllvm --x86-ptex=sbox -O1 \
    -o pintool/test/test_target pintool/test/test_target.c
```

- [ ] **Step 3: Confirm PROT bytes appear in the binary**

```bash
objdump -d pintool/test/test_target | grep -c "36 "
```

Expected: a non-zero count (confirms `0x36` bytes are present in the disassembly).

- [ ] **Step 4: Commit**

```bash
git add pintool/test/test_target.c
git commit -m "test: add pintool test target"
```

---

### Task 3: Test script (write the failing test first)

**Files:**
- Create: `pintool/test/run_test.sh`

- [ ] **Step 1: Create the test script**

```bash
#!/usr/bin/env bash
set -e

PINTOOL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PIN="${PIN_ROOT:?Set PIN_ROOT to your PIN installation directory}/pin"
TOOL="${PINTOOL_DIR}/obj-intel64/prot_count.so"
TARGET="${PINTOOL_DIR}/test/test_target"

if [ ! -f "$TOOL" ]; then
    echo "FAIL: tool not built at $TOOL"
    exit 1
fi

if [ ! -f "$TARGET" ]; then
    echo "FAIL: test target not found at $TARGET (run Task 2 first)"
    exit 1
fi

OUTPUT=$("$PIN" -t "$TOOL" -- "$TARGET" 2>/dev/null)

if ! echo "$OUTPUT" | grep -q "=== PROT prefix execution counts ==="; then
    echo "FAIL: missing header in output"
    echo "$OUTPUT"
    exit 1
fi

if ! echo "$OUTPUT" | grep -q "^Total:"; then
    echo "FAIL: missing Total: line"
    echo "$OUTPUT"
    exit 1
fi

if ! echo "$OUTPUT" | grep -q "secret_work"; then
    echo "FAIL: secret_work not found in per-function output"
    echo "$OUTPUT"
    exit 1
fi

TOTAL=$(echo "$OUTPUT" | grep "^Total:" | awk '{print $2}')
if [ "$TOTAL" -le 0 ] 2>/dev/null; then
    echo "FAIL: total count is 0"
    exit 1
fi

echo "PASS: total=$TOTAL"
echo "---"
echo "$OUTPUT"
```

- [ ] **Step 2: Make it executable**

```bash
chmod +x pintool/test/run_test.sh
```

- [ ] **Step 3: Run to confirm it fails (tool is still a stub)**

```bash
PIN_ROOT=/path/to/pin pintool/test/run_test.sh
```

Expected: `FAIL: missing header in output` (the stub tool prints nothing).

- [ ] **Step 4: Commit**

```bash
git add pintool/test/run_test.sh
git commit -m "test: add pintool smoke test script"
```

---

### Task 4: Globals, analysis callback, and fini output

**Files:**
- Modify: `pintool/prot_count.cpp`

- [ ] **Step 1: Replace `pintool/prot_count.cpp` with the version that includes globals, `CountProt`, and `Fini`**

```cpp
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

// Analysis callback: invoked once per BBL execution for BBLs that contain
// at least one PROT-prefixed instruction. N is the static count of
// PROT-prefixed instructions in this BBL (computed once at instrumentation time).
VOID CountProt(const string *FuncName, UINT64 N) {
    PIN_GetLock(&FuncCountLock, PIN_GetTid());
    FuncCounts[*FuncName] += N;
    TotalCount += N;
    PIN_ReleaseLock(&FuncCountLock);
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
    PIN_AddFiniFunction(Fini, 0);
    PIN_StartProgram();
    return 0;
}
```

- [ ] **Step 2: Build**

```bash
cd pintool && make PIN_ROOT=/path/to/pin
```

Expected: builds cleanly.

- [ ] **Step 3: Commit**

```bash
git add pintool/prot_count.cpp
git commit -m "feat: add CountProt analysis callback and Fini output"
```

---

### Task 5: Image-load callback and BBL instrumentation

**Files:**
- Modify: `pintool/prot_count.cpp`

- [ ] **Step 1: Replace `pintool/prot_count.cpp` with the complete final version**

```cpp
#include "pin.H"
#include <iostream>
#include <map>
#include <set>
#include <vector>
#include <algorithm>
#include <iomanip>

using namespace std;

static map<string, UINT64> FuncCounts;
static PIN_LOCK FuncCountLock;
static UINT64 TotalCount = 0;
static set<string> InternedNames;

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
    IMG_AddInstrumentFunction(ImageLoad, 0);
    PIN_AddFiniFunction(Fini, 0);
    PIN_StartProgram();
    return 0;
}
```

- [ ] **Step 3: Build**

```bash
cd pintool && make PIN_ROOT=/path/to/pin
```

Expected: builds cleanly.

- [ ] **Step 4: Run the test script**

```bash
PIN_ROOT=/path/to/pin pintool/test/run_test.sh
```

Expected: `PASS: total=<N>` where N > 0, followed by the full output with `secret_work` in the per-function table.

- [ ] **Step 5: Commit**

```bash
git add pintool/prot_count.cpp
git commit -m "feat: add ImageLoad callback and BBL PROT instrumentation"
```

---

### Task 6: README

**Files:**
- Create: `pintool/README.md`

- [ ] **Step 1: Create `pintool/README.md`**

```markdown
# prot_count — PROT-Prefix Execution Counter

PIN tool that measures runtime execution frequency of PROT-prefixed (`0x36`)
instructions in binaries compiled by the ProtCC/Protean LLVM passes.

## Build

Requires [Intel PIN 3.x](https://www.intel.com/content/www/us/en/developer/articles/tool/pin-a-dynamic-binary-instrumentation-tool.html).

    cd pintool
    make PIN_ROOT=/path/to/pin-3.x
    # produces: obj-intel64/prot_count.so

## Usage

    # Compile your target with a PTeX mode
    clang -mllvm --x86-ptex=ct -O1 -o my_binary my_source.c

    # Run under PIN
    pin -t pintool/obj-intel64/prot_count.so -- ./my_binary [args]

    # Redirect output to a file
    pin -t pintool/obj-intel64/prot_count.so -- ./my_binary [args] > counts.txt

## Output format

    === PROT prefix execution counts ===
    Total:  1234567

    Per-function (descending):
      aes_encrypt                              987654
      aes_key_schedule                          45678
      main                                       1235

- **Total**: sum of PROT-prefixed instruction executions across the whole run.
- **Per-function**: executions within each function, sorted descending.

## Notes

- Only the main executable is instrumented; shared libraries are excluded.
- Detection works because ProtCC always emits `0x36` as the first byte of a
  PROT-prefixed instruction (`X86MCCodeEmitter.cpp:1291`).
- Use `--x86-ptex=sbox` to guarantee non-zero counts for any binary (sandbox
  mode prefixes every eligible instruction).
```

- [ ] **Step 2: Commit**

```bash
git add pintool/README.md
git commit -m "docs: add pintool README"
```
