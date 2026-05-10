# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Guidelines for Coding
Whenever you write a new line or block of code, start it with a comment that says "Sawz edit" so I can find it later. Never delete lines of code that you didn't personally write, simply comment them out.

## Project Orientation

This is a fork of LLVM containing the Protean/ProtCC extensions — a Spectre mitigation system.
The fork introduces a `PROT` instruction prefix: a `PROT`-prefixed instruction marks its output
register as protected (secret); an unprefixed instruction marks its output as unprotected (public).
Hardware tracks a per-register protection set (ProtSet) updated by these prefixes. The compiler
passes (collectively **PTeX**) automatically insert `PROT` prefixes based on dataflow analysis
over Machine IR.

Five operating modes, selected via `--x86-ptex=<mode>` (alias: `--protean=<mode>`):

- **SBOX/ARCH** (sandbox): blanket protection; the default.
- **NCT/UNR** (unrestricted): no constant-time requirement; registers protectable freely.
- **CT** (constant-time): forward + backward dataflow computes `past-leaked` and `bound-to-leak`
  sets; PROT-prefixes defs in neither set; inserts identity moves at CFG edges where a register
  newly becomes bound-to-leak.
- **CTS** (static constant-time): Serberus-style secrecy typing; PROT-prefixes secretly-typed defs.
- **RAND**: randomly PROT-prefixed (for experiments).

We are trying to make headway specifically for the PROT-prefix numbers in CTS and CT,
we have another method of finding publicness under more relaxed constraints than the tool currently provides, so we will use that to seed more registers as public in LLVM before forwarding the publicness to MIR and running the Protean passes there to propagate.

## Repo Layout — PTeX-Specific Code

**Core analysis** (`llvm/lib/Target/X86/PTeX/`):

- `PTeX.cpp/.h` — main pass class `X86PTeX`; pass registration; PROT insertion; `declassifyBlockEntries()` (identity-move insertion at CFG edges); unconditional `errs()` debug output
- `PTeXAnalysis.cpp/.h` — `init()` orchestrates all publicness seeding via `init*` sub-functions; forward/backward dispatch
- `PTeXAnalysis_CTS.cpp` — CTS-mode analysis
- `ForwardAnalysis.cpp/.h` — computes `past-leaked` (forward dataflow, intersection at joins)
- `BackwardAnalysis_CT.cpp/.h` / `BackwardAnalysis_CTS.cpp/.h` — computes `bound-to-leak` per mode
- `Flags.cpp/.h` — `PTeXMode` enum and `getPTeXMode()` overloads
- `PublicPhysRegs.cpp/.h` — physical-register publicness bitvector
- `BranchAnalysis.cpp/.h`, `StackAnalysis.cpp/.h` — auxiliary analyses
- `Hoist.cpp/.h`, `Sink.cpp/.h`, `Rotate.cpp/.h`, `Reload.cpp/.h` — optimization passes repositioning instructions relative to prefix boundaries
- `Util.cpp/.h`, `DataFlowAnalysis.h` — shared utilities

**X86 target-level project files:**

- `llvm/lib/Target/X86/X86AnnotatePublic.cpp` — `X86AnnotatePointers` stats pass; gold-standard pattern for new `MachineFunctionPass`es (see Conventions)
- `llvm/lib/Target/X86/X86MCInstLowerPTeX.cpp/.h` — PROT prefix byte emission during MC lowering
- `llvm/lib/Target/X86/X86LLSCTUtil.cpp/.h` — utility shared with LLSCT
- `llvm/lib/Target/X86/X86TargetMachine.cpp` — modified upstream file; inserts PTeX passes at three pipeline stages

**Upstream LLVM modifications** (non-X86):

- `llvm/include/llvm/CodeGen/MachineInstr.h` — three custom `MIFlag` bits: `TPEPrivM = 1 << 17`, `TPEPubM = 1 << 18`, `AnnotatePointerLoad = 1 << 19` (around line 118)
- `llvm/include/llvm/CodeGen/MachineOperand.h` — custom `isPublic()` / `setIsPublic()` per-operand publicness API (around line 458)

## Pass Pipeline

PTeX passes are inserted at three points in `X86TargetMachine.cpp`:

| Stage | Pass(es) | Notes |
|---|---|---|
| `addPreRegAlloc` | `X86PTeX(Instrument=false)`, `X86AnnotatePointers` | **PTEX-EXPERIMENTAL** — currently LLT printing only; operands are still vregs |
| `addPostRegAlloc` | `X86PTeX(Instrument=true)`, `X86AnnotatePointers` | **Stage 1** — main analysis + PROT prefix insertion; vregs replaced by physregs |
| `addPreEmitPass` | `X86PTeX(Instrument=false)` | **Stage 2** — cleanup/re-verification; source TODO warns late-inserted instructions may be missed |

`Instrument=false` runs the full analysis but skips prefix insertion. `Instrument=true` inserts.

Pass declarations live in `llvm/lib/Target/X86/X86.h` (`createX86PTeXPass`, `createX86AnnotatePointersPass`,
`initializeX86PTeXPass`, `initializeX86AnnotatePointersPass`). Both are initialized in the
`X86TargetMachine` constructor via `initializeX86PTeXPass(PR)` / `initializeX86AnnotatePointersPass(PR)`.

## Conceptual Primer

**IR vregs and MIR vregs are entirely different namespaces.** The mapping exists only transiently
inside `FunctionLoweringInfo::ValueMap` during `X86ISelDAGToDAG::Select()`. After that, the
IR→MIR vreg correlation is gone. Any IR-level annotation that must influence MIR must do its
IR↔MIR correlation _inside_ `Select()`.

**One IR instruction does not map to one MachineInstr.** After legalization, combining, and
selection, an IR instruction can become zero MIs (folded into an addressing mode), one, or many.
Per-instruction attribution of publicness must be encoded structurally — flags, pseudos, operand
bits — not by instruction identity.

**`PTeXAnalysis` runs post-regalloc.** Only physical registers exist at that point. Anything that
needs to influence `init()` must be encoded in structures visible at that stage: `MachineInstr`
flags (e.g., `TPEPubM`), `MachineOperand::isPublic()`, or `MachineMemOperand` attributes.
Pre-regalloc side-tables containing vreg references are meaningless by then unless explicitly
translated during regalloc.

**Pseudo instructions** are MIs with no real opcode. They participate in liveness, regalloc, and
scheduling like real MIs but emit no bytes. A _meta_ pseudo survives the entire pipeline and is
erased just before emission. LLVM uses pseudos extensively: `KILL`, `IMPLICIT_DEF`, `DBG_VALUE`,
`COPY`, target-specific tail-call return pseudos, etc.

**Dataflow semantics:** `past-leaked(P)` = leaked on _every_ path from entry to P (forward
dataflow, intersection at joins). `bound-to-leak(P)` = leaked on _every_ path from P to exit
(backward, also intersection). `Public(P) = past-leaked(P) ∪ bound-to-leak(P)`. The analysis is
path-sensitive — CFG siblings are independent. CT mode inserts identity moves at block entries
where a register newly enters `bound-to-leak` (handled by `X86PTeX::declassifyBlockEntries` in
`PTeX.cpp`).

## Key Files to Read First

- `llvm/lib/Target/X86/PTeX/PTeXAnalysis.cpp` — `init()` (~line 309) is the analysis entry point; each `init*` sub-function seeds one publicness category
- `llvm/lib/Target/X86/PTeX/PTeX.cpp` — `X86PTeX::runOnMachineFunction()` is the pass entry; `declassifyBlockEntries()` (~line 999) handles identity-move insertion
- `llvm/lib/Target/X86/X86AnnotatePublic.cpp` — read before writing any new pass; canonical pass-registration pattern
- `llvm/lib/Target/X86/X86TargetMachine.cpp` — three regions matter: the `addPreRegAlloc`, `addPostRegAlloc`, `addPreEmitPass` overrides
- `llvm/lib/Target/X86/PTeX/Flags.h` — `PTeXMode` enum, all mode aliases, `getPTeXMode()` overloads
- `llvm/include/llvm/CodeGen/MachineInstr.h` — custom `MIFlag` bits around line 118
- `llvm/include/llvm/CodeGen/MachineOperand.h` — `isPublic()` / `setIsPublic()` around line 458
- `llvm/lib/Target/X86/X86MCInstLowerPTeX.cpp` — PROT prefix byte emission logic

## In-Progress Feature: Public-Register Annotation Pipeline

**Status: planned / in-progress. None of this infrastructure exists yet.**

An external analysis tool (knowledge-frontier-style, à la Declassiflow) produces statements of the
form "at IR block B, virtual register `%V` holds a public value." The goal is to thread that
block-granular information through the IR→MIR lowering pipeline so `PTeXAnalysis::init()` can seed
publicness at the right program point.

Planned four-step design:

1. **IR pass** — reads the tool's output, attaches `!protean.public` metadata, and inserts
   `call void @llvm.protean.markpublic(<ty> %V)` at the SSA-correct position in block B: at
   `B`'s start if `%V` is live-in, or immediately after `%V`'s def if `%V` is defined in B.

2. **Selector hook** in `X86ISelDAGToDAG.cpp` `Select()` — a new
   `case Intrinsic::protean_markpublic` under the existing `ISD::INTRINSIC_VOID` switch (~line 4872).
   Records `(current MBB, vreg of operand)` in a new `ProteanMachineFunctionInfo` side-table, then
   calls `ReplaceNode(N, N->getOperand(0).getNode())` to consume the intrinsic with zero MC emission.
   This is the **only** point where the IR vreg and the corresponding MIR vreg are simultaneously
   accessible.

3. **`PublicAnnotationsPass`** — new `MachineFunctionPass` registered in `addPreRegAlloc` ahead of
   the existing PTeX passes. Reads the MFI side-table; for each `(MBB, vreg)` inserts a
   `PUBLIC_SEED` pseudo with the vreg as an implicit-use operand carrying `TPEPubM` — at
   `MBB->begin()` if the vreg is a live-in, or at
   `std::next(MRI.getVRegDef(vreg)->getIterator())` if the def is in `MBB`. After regalloc the
   vreg operand is rewritten to the correct physreg automatically.

4. **`PUBLIC_SEED` pseudo** — new opcode in an X86 `.td` file (likely `X86InstrCompiler.td` or a
   new `X86InstrPTeX.td`), marked `isPseudo = 1, isMeta = 1, hasNoSchedulingInfo = 1`. A cleanup
   step in `addPreEmitPass` (or appended to the Stage 2 PTeX run) erases all `PUBLIC_SEED` pseudos
   before emission.

The `IR intrinsic → selector hook → MIR pseudo` structure is deliberate: IR and MIR vreg namespaces
are disjoint, the correlation exists only inside `Select()`, and after regalloc the vreg→physreg
mapping is gone. Carrying the vreg as an operand on the pseudo lets regalloc rewrite it automatically.

## Known Issues / Cleanup Targets

- **`PTeXAnalysis::initPublicInstr`** (PTeXAnalysis.cpp ~line 221): when `TPEPubM` is set, marks
  _all_ operands public including uses — should mark only defs. Marked `// TODO: Remove?`.
- **`X86PTeX::declassifyBlockEntries`** (PTeX.cpp ~line 999): block-local identity-move insertion
  for registers newly entering `bound-to-leak`. Two separate `LivePhysRegs` liveness passes (one for
  dead-reg pruning, one for super-register pruning) are noted with `// TODO: Combine with above.`
- **`errs()` output in production paths**: PTeX.cpp prints before/after function dumps (lines ~392–421)
  and register-overlap diagnostics (~838–841) via `errs()`, unconditionally, without `-debug` gating.
- **`PTEX-FIXME` at PTeXAnalysis.cpp line 198**: `MI.mayLoadOrStore()` noted as too aggressive.

## Build and Test

No custom build scripts exist. Standard LLVM CMake + Ninja workflow:

```bash
# Configure (X86 only, debug, with clang)
cmake -G Ninja -S llvm -B build \
  -DLLVM_TARGETS_TO_BUILD=X86 \
  -DCMAKE_BUILD_TYPE=Debug \
  -DLLVM_ENABLE_PROJECTS="clang"

# Build llc and clang
ninja -C build llc clang
```

Binaries land in `build/bin/`. TODO: confirm build directory name if building from scratch for the
first time.

**Run all PTeX lit tests:**
```bash
llvm-lit llvm/test/CodeGen/X86/ptex/
```

**Run a single test:**
```bash
llvm-lit llvm/test/CodeGen/X86/ptex/branch-pred.ll
```

Tests live in `llvm/test/CodeGen/X86/ptex/` and use two invocation patterns:
- `.ll` files: `llc %s --x86-ptex=<mode> --filetype=obj -o %t.o; objdump -d -Mintel ... | FileCheck %s`
- `.c` files: `clang %s -mllvm --x86-ptex=<mode> -o %t.o -c; objdump ... | FileCheck %s`

## Conventions

When adding a new `MachineFunctionPass`, follow `X86AnnotatePublic.cpp` as the template:
- Define the class in a `.cpp` file; use `INITIALIZE_PASS_BEGIN` / `INITIALIZE_PASS_END` with a
  string key matching `PASS_KEY`.
- Provide a `createX86<Name>Pass()` factory and declare `initializeX86<Name>Pass(PassRegistry &)`
  in `X86.h`.
- Call the initializer in the `X86TargetMachine` constructor and add the pass to the appropriate
  pipeline hook.
- The codebase modifies **only** the SelectionDAG selector (`X86ISelDAGToDAG.cpp`) for intrinsic
  handling. `X86FastISel`, `X86InstructionSelector` (GlobalISel), and `X86ISelLowering.cpp` are
  deliberately untouched. Selector modification is the justified exception for the
  `protean_markpublic` intrinsic, not the general pattern.

## Where I'm Actively Working

Work in progress on the public-register annotation pipeline:

- `llvm/lib/Target/X86/X86ISelDAGToDAG.cpp` — adding `Intrinsic::protean_markpublic` handler under `ISD::INTRINSIC_VOID`
- `llvm/lib/Target/X86/X86TargetMachine.cpp` — registering `PublicAnnotationsPass` in `addPreRegAlloc`
- `llvm/lib/Target/X86/PTeX/PTeXAnalysis.cpp` — fixing `initPublicInstr`; eventually retiring the block-local declassify approach in `declassifyBlockEntries`
- `<new>` `llvm/lib/Target/X86/PTeX/PublicAnnotationsPass.cpp` — the new `MachineFunctionPass`
- `<new>` `llvm/lib/Target/X86/PTeX/ProteanMachineFunctionInfo.h/.cpp` — `MachineFunctionInfo` subclass holding the `(MBB, vreg)` side-table
- `<new>` `PUBLIC_SEED` opcode — likely in `llvm/lib/Target/X86/X86InstrCompiler.td` or a new `llvm/lib/Target/X86/X86InstrPTeX.td`
- `<new>` IR-level pass reading the external tool's output and inserting `@llvm.protean.markpublic` calls — location TBD, likely `llvm/lib/Target/X86/PTeX/` or `llvm/lib/Transforms/`

## Search Scoping

Default grep/explore targets: `llvm/lib/Target/X86/PTeX/`, `llvm/lib/Target/X86/X86AnnotatePublic.cpp`,
`llvm/lib/Target/X86/X86MCInstLowerPTeX.cpp`, `llvm/lib/Target/X86/X86ISelDAGToDAG.cpp`,
`llvm/lib/Target/X86/X86TargetMachine.cpp`, `llvm/include/llvm/CodeGen/MachineInstr.h`,
`llvm/include/llvm/CodeGen/MachineOperand.h`.

Search the broader LLVM tree only when explicitly directed (e.g., "look in
`llvm/lib/CodeGen/SelectionDAG/` for how SelectionDAG lowers intrinsics" or "find pseudo-instruction
patterns in AArch64"). The repo is a full LLVM checkout — the vast majority is unmodified upstream
code irrelevant to this work.

