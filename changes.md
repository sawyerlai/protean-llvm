# Protean Public-Register Annotation Pipeline — Change Log

All edits are marked with `// Sawz edit` comments in source. Deletions are commented out, not removed.

## Status key
- [x] done
- [ ] pending

---

## 1. `llvm/include/llvm/IR/Intrinsics.td`
**Status:** [x]
**Change:** Added `int_protean_markpublic` — void intrinsic taking one `llvm_anyint_ty` argument,
`[IntrNoMem, IntrWillReturn]`. Inserted after `int_sideeffect`. Build system auto-generates
`Intrinsic::protean_markpublic` into `include/llvm/IR/Intrinsics.h`.

---

## 2. `llvm/include/llvm/CodeGen/MachineFunction.h`
**Status:** [x]
**Change:** Added `virtual void addPublicAnnotation(Register) {}` (no-op default) to the
`MachineFunctionInfo` base struct. Lets `SelectionDAGBuilder` call it without a layering violation.

---

## 3. `llvm/lib/Target/X86/PTeX/ProteanMachineFunctionInfo.h` (new file)
**Status:** [x]
**Change:** New class `ProteanMachineFunctionInfo : public X86MachineFunctionInfo`.
Holds `DenseSet<Register> PublicVRegs`. Overrides `addPublicAnnotation(Register)`.
Provides `getPublicVRegs() const`.

---

## 4. `llvm/lib/Target/X86/X86TargetMachine.cpp`
**Status:** [x]
**Change (createMachineFunctionInfo):** Now instantiates `ProteanMachineFunctionInfo`; old
`X86MachineFunctionInfo` line commented out.
**Change (constructor):** Added `initializeX86PublicAnnotationsPass(PR)` and
`initializeX86ErasePTeXPseudosPass(PR)`.
**Change (addPreRegAlloc):** Added `createX86PublicAnnotationsPass()` before the experimental PTeX pass.
**Change (addPreEmitPass):** Added `createX86ErasePTeXPseudosPass()` after Stage 2 PTeX pass.

---

## 5. `llvm/lib/CodeGen/SelectionDAG/SelectionDAGBuilder.cpp`
**Status:** [x]
**Change:** Added `case Intrinsic::protean_markpublic:` to the `switch (Intrinsic)` in
`visitIntrinsicCall` (~line 5952). Looks up `FuncInfo.ValueMap` for the argument Value, then calls
`FuncInfo.MF->getInfo<MachineFunctionInfo>()->addPublicAnnotation(VReg)`. Returns early with no SDNode.

---

## 6. `llvm/lib/Target/X86/X86InstrCompiler.td`
**Status:** [x]
**Change:** Added `PUBLIC_SEED` pseudo at end of file: `isPseudo=1, isMeta=1, hasSideEffects=0,
mayLoad=0, mayStore=0, hasNoSchedulingInfo=1`, single `GR64:$reg` input (implicit-use at runtime).

---

## 7. `llvm/lib/Target/X86/PTeX/PublicAnnotationsPass.cpp` (new file)
**Status:** [x]
**Change:** `X86PublicAnnotations` MachineFunctionPass. Reads `ProteanMachineFunctionInfo::getPublicVRegs()`,
finds each vreg's def MachineInstr (or entry block), inserts a `PUBLIC_SEED` pseudo with
`RegState::Implicit` + `TPEPubM` flag. Registered as `createX86PublicAnnotationsPass()`.

---

## 8. `llvm/lib/Target/X86/PTeX/ErasePTeXPseudosPass.cpp` (new file)
**Status:** [x]
**Change:** `X86ErasePTeXPseudos` MachineFunctionPass. Walks all MBBs, erases every
`PUBLIC_SEED` opcode. Registered as `createX86ErasePTeXPseudosPass()`. Runs in `addPreEmitPass`.

---

## 9. `llvm/lib/Target/X86/X86.h`
**Status:** [x]
**Change:** Declared `createX86PublicAnnotationsPass()`, `initializeX86PublicAnnotationsPass()`,
`createX86ErasePTeXPseudosPass()`, `initializeX86ErasePTeXPseudosPass()`.

---

## 10. `llvm/lib/Target/X86/PTeX/PTeXAnalysis.cpp`
**Status:** [x]
**Change:** Fixed `initPublicInstr` (~line 221): added `MO.isDef()` guard. Old loop (marking all
operands including uses) commented out; new loop only marks def operands public.

---

## 11. `llvm/lib/Target/X86/CMakeLists.txt`
**Status:** [x]
**Change:** Added `PTeX/PublicAnnotationsPass.cpp` and `PTeX/ErasePTeXPseudosPass.cpp` to the
X86 target source list so CMake picks them up.

---

## Notes
- **IR entry point**: `@llvm.protean.markpublic` calls are inserted manually into the IR before
  it is passed to the compiler. No IR-level pass is needed. The pipeline is complete as implemented.
