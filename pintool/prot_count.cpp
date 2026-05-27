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
