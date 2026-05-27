# PIN Tool: PROT-Prefix Execution Counter

**Date:** 2026-05-26
**Status:** Approved for implementation

## Goal

Measure the runtime execution frequency of PROT-prefixed instructions in binaries compiled by the Protean/ProtCC LLVM passes. "PROT-prefixed" means the instruction was annotated by the PTeX pass and emitted with the `0x36` prefix byte (SS segment override, repurposed by ProtCC).

Output: total PROT-prefixed instruction executions for a full program run, plus a per-function breakdown sorted by count descending.

## Detection Anchor

The PROT prefix is emitted as byte `0x36` at the very start of the instruction encoding, before any REX or opcode bytes. This is unconditional — see `X86MCCodeEmitter.cpp:1291`:

```cpp
if (MI.getFlags() & X86::IP_TPE_PRIVM) {
    emitByte(0x36, CB);
}
```

A raw first-byte check of `0x36` is sufficient and correct for all instructions in this codebase.

## Approach: BBL-level callbacks with static PROT count

At image load time, for each basic block (BBL):
1. Count the number of instructions in the BBL whose first raw byte is `0x36` (static count N, computed once).
2. If N > 0, insert a single `BBL_InsertCall` that atomically adds N to the owning function's counter.
3. Also add N to a global total counter.

All instructions in a BBL execute the same number of times by definition, so this produces the same result as per-instruction callbacks but with one callback per BBL execution instead of one per PROT instruction execution — lower overhead, correct result.

## Repo Layout

```
pintool/
  prot_count.cpp      # PIN tool source
  Makefile            # builds against $(PIN_ROOT)
  README.md           # usage instructions
```

No changes to the LLVM source. This is a standalone measurement layer.

## Data Structures

```cpp
// Per-function PROT execution counts
std::map<std::string, uint64_t> FuncCounts;
PIN_LOCK FuncCountLock;

// Global total
uint64_t TotalCount = 0;
```

The lock is needed for thread safety if the target binary is multi-threaded. For single-threaded test functions it is a no-op cost.

## Instrumentation Flow

### Image load callback (`IMG_AddInstrumentFunction`)
```
for each RTN in image:
  for each BBL in RTN:
    N = 0
    for each INS in BBL:
      read first byte via PIN_SafeCopy
      if byte == 0x36: N++
    if N > 0:
      insert BBL_InsertCall(bbl, analysis_fn, N, rtn_name)
```

Only instrument images where the image path does not start with `/usr/` — this excludes libc/libm/etc. and keeps output focused on the target binary.

### Analysis function (called at runtime per BBL execution)
```cpp
void CountProt(const std::string *FuncName, uint64_t N) {
    PIN_GetLock(&FuncCountLock, 0);
    FuncCounts[*FuncName] += N;
    TotalCount += N;
    PIN_ReleaseLock(&FuncCountLock);
}
```

### Fini callback
Print total, then per-function table sorted by count descending:
```
=== PROT prefix execution counts ===
Total:  1234567

Per-function (descending):
  aes_encrypt       987654
  aes_key_schedule   45678
  memcpy              1235
```

## Build

The Makefile uses PIN's standard `makefile.rules` pattern:

```makefile
PIN_ROOT ?= $(error Set PIN_ROOT to your PIN installation)
include $(PIN_ROOT)/source/tools/Config/makefile.config
include $(PIN_ROOT)/source/tools/Config/makefile.default.rules
```

Build:
```bash
cd pintool
make PIN_ROOT=/path/to/pin
# produces obj-intel64/prot_count.so
```

## Usage

```bash
# Compile target with ProtCC
clang -mllvm --x86-ptex=ct -o my_binary my_source.c -c

# Run under PIN
pin -t pintool/obj-intel64/prot_count.so -- ./my_binary [args]

# Redirect output
pin -t pintool/obj-intel64/prot_count.so -- ./my_binary [args] > counts.txt
```

## Constraints

- Target: user's own test binaries only (not shared libraries).
- PIN version: Intel PIN 3.x (tested interface; uses `IMG_AddInstrumentFunction`, `RTN_Name`, `BBL_InsertCall`).
- Architecture: x86-64 only (matches the Protean target).
- Thread safety: lock-guarded counters handle multi-threaded targets, but target functions in scope are single-threaded test functions.
