# Change Reference — Protean Public-Register Annotation Pipeline

This document summarizes the changes made to this repository for reviewers familiar with the codebase. It covers what changed, why, and where to find it.

---

## What Was Added

An end-to-end pipeline that lets an external analysis tool (Declassiflow) seed public-register information into PTeXAnalysis. Without this, PTeX's internal dataflow can only determine publicness from patterns it recognizes itself; values that are public for program-specific semantic reasons get PROT-prefixed unnecessarily. The pipeline threads block-granular publicness annotations from LLVM IR all the way through to post-regalloc physreg seeding in `PTeXAnalysis::init()`.

---

## Pipeline Overview

```
Declassiflow YAML
      │
      ▼
annotate_ll.py          inserts @llvm.protean.markpublic calls into .ll
      │
      ▼
SelectionDAGBuilder     consumes the intrinsic; records (MBB, vreg) in side-table
      │
      ▼
PublicAnnotationsPass   pre-regalloc; inserts PUBLIC_SEED pseudo with vreg implicit-use
      │
      ▼
Register Allocator      rewrites vreg → physreg on PUBLIC_SEED operand automatically
      │
      ▼
PTeXAnalysis::init()    reads TPEPubM flag on PUBLIC_SEED; seeds physreg as public
      │
      ▼
ErasePTeXPseudosPass    pre-emit; deletes all PUBLIC_SEED pseudos before MC emission
```

---

## Changed Files

### New files

`llvm/lib/Target/X86/PTeX/ProteanMachineFunctionInfo.h`
Subclass of `X86MachineFunctionInfo` holding a `DenseSet<Register>` of vregs annotated public during iSel. `createMachineFunctionInfo` in `X86TargetMachine.cpp` now instantiates this instead of `X86MachineFunctionInfo` directly.

`llvm/lib/Target/X86/PTeX/PublicAnnotationsPass.cpp`
`MachineFunctionPass` (`x86-public-annotations`). Runs in `addPreRegAlloc`. Reads the side-table; inserts `PUBLIC_SEED` pseudo after each vreg's def (or after the trailing phi group if the def is a phi). Guards against null `getVRegDef` for DCE'd values.

`llvm/lib/Target/X86/PTeX/ErasePTeXPseudosPass.cpp`
`MachineFunctionPass` (`x86-erase-ptex-pseudos`). Runs in `addPreEmitPass`. Walks all instructions and erases any with opcode `X86::PUBLIC_SEED`.

`declassiflow/annotate_ll.py`
Python script: reads Declassiflow YAML (`knowledge_frontier` phase) + input `.ll`, produces annotated `.ll` with `@llvm.protean.markpublic` calls inserted after each public register's SSA def.

`declassiflow/test_annotate_ll.py`
60-test `unittest` suite for `annotate_ll.py`.

`testing_flow/test_changes.md`
Log of all bugs found and fixed during stress-test development.

---

### Modified files

`llvm/include/llvm/IR/Intrinsics.td` — line ~1701
Added `int_protean_markpublic` intrinsic after `int_sideeffect`. Uses `llvm_any_ty` so ptr arguments don't require a `ptrtoint` cast.

`llvm/include/llvm/CodeGen/MachineFunction.h` — line ~101
Added `virtual void addPublicAnnotation(Register) {}` to `MachineFunctionInfo`. No-op default; overridden by `ProteanMachineFunctionInfo`. Keeps `SelectionDAGBuilder` target-agnostic.

`llvm/lib/CodeGen/SelectionDAG/SelectionDAGBuilder.cpp` — line ~5958
Added `case Intrinsic::protean_markpublic` under `ISD::INTRINSIC_VOID`. Looks up the IR value in `FuncInfo.ValueMap`, calls `addPublicAnnotation` with the MIR vreg, returns without emitting any SDNode. This is the only point where IR and MIR vreg namespaces are simultaneously accessible.

`llvm/lib/Target/X86/X86InstrCompiler.td` — line ~2209
Added `PUBLIC_SEED` pseudo-instruction definition. `isPseudo=1, isMeta=1, hasNoSchedulingInfo=1`, no explicit operands.

`llvm/lib/Target/X86/X86.h` — lines ~173 and ~216
Added factory declarations `createX86PublicAnnotationsPass()`, `createX86ErasePTeXPseudosPass()` and initializer declarations `initializeX86PublicAnnotationsPass`, `initializeX86ErasePTeXPseudosPass`.

`llvm/lib/Target/X86/X86TargetMachine.cpp` — lines ~20, ~112, ~441, ~546, ~619
(1) Includes `PTeX/ProteanMachineFunctionInfo.h`. (2) Registers both new passes in the constructor. (3) `createMachineFunctionInfo` returns `ProteanMachineFunctionInfo` instead of `X86MachineFunctionInfo`. (4) Adds `PublicAnnotationsPass` to `addPreRegAlloc`. (5) Adds `ErasePTeXPseudosPass` to `addPreEmitPass`.

`llvm/lib/Target/X86/PTeX/PTeXAnalysis.cpp` — line ~224
Comment clarification on `initPublicInstr`: explains why all operands (not just defs) are marked — PUBLIC_SEED carries the physreg as an implicit use, so a def-only guard would miss it. Logic is unchanged.

`testing_flow/gen_ir.py`
Capped shift constants to 63 in `gen_conditional` and `gen_loop`. Shifts ≥ 64 on `i64` produce poison, DCE the function body, and leave vregs in the side-table with no `getVRegDef`, crashing `LiveVariables`.

`testing_flow/inject_annotations.py`
(1) Added `RE_ANY_PHI` and changed phi-flush condition to suppress on any phi type (not just integer phis) — fixes IR verifier failure when `phi ptr` appeared between integer phis. (2) Added `RE_INT_CONV` to read conversion op result types from after the `to` keyword — fixes type mismatch on `trunc`/`sext`/`zext`/`bitcast`.

`testing_flow/run_tests.sh`
Added `CORPUS_TOL` (default 5) oracle slack for corpus/csmith inputs to absorb regalloc noise. Added `SRC_TYPE` tracking per iteration. Fixed exit-code-1-on-success bug.

---

## Testing

```bash
# annotator unit tests (no build required)
python3 declassiflow/test_annotate_ll.py -v

# end-to-end stress test (requires built llc)
cd testing_flow && bash run_tests.sh 100 0.3 cts
```

Stress test oracle: annotated output must have ≤ `base_ss + TOL` PROT-prefixed instructions, where `TOL=0` for gen_ir.py inputs and `TOL=CORPUS_TOL` (default 5) for corpus/csmith inputs.
