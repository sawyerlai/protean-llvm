// ProteanMachineFunctionInfo — extends X86MachineFunctionInfo
// to hold the per-function side table of IR vregs that the Protean IR pass has
// marked public. SelectionDAGBuilder populates this during instruction selection
// (the only point where the IR Value -> MIR vreg mapping exists).
// PublicAnnotationsPass reads it in addPreRegAlloc to insert PUBLIC_SEED pseudos.

#ifndef LLVM_LIB_TARGET_X86_PTEX_PROTEANMACHINEFUNCTIONINFO_H
#define LLVM_LIB_TARGET_X86_PTEX_PROTEANMACHINEFUNCTIONINFO_H

#include "X86MachineFunctionInfo.h"
#include "llvm/ADT/DenseSet.h"
#include "llvm/CodeGen/Register.h"

namespace llvm {

// Subclass of X86MachineFunctionInfo that adds a DenseSet of
// pre-allocated vregs annotated as public at the IR level.
// createMachineFunctionInfo() in X86TargetMachine.cpp is updated to
// instantiate this class instead of X86MachineFunctionInfo directly.
class ProteanMachineFunctionInfo : public X86MachineFunctionInfo {
  DenseSet<Register> PublicVRegs;

public:
  ProteanMachineFunctionInfo() = default;
  ProteanMachineFunctionInfo(const Function &F, const TargetSubtargetInfo *STI)
      : X86MachineFunctionInfo(F, STI) {}

  ProteanMachineFunctionInfo(const ProteanMachineFunctionInfo &) = default;

  MachineFunctionInfo *
  clone(BumpPtrAllocator &Allocator, MachineFunction &DestMF,
        const DenseMap<MachineBasicBlock *, MachineBasicBlock *> &Src2DstMBB)
      const override {
    return ProteanMachineFunctionInfo::create<ProteanMachineFunctionInfo>(
        Allocator, *this);
  }

  // Called by SelectionDAGBuilder when it visits @llvm.protean.markpublic.
  void addPublicAnnotation(Register VReg) override {
    PublicVRegs.insert(VReg);
  }

  const DenseSet<Register> &getPublicVRegs() const { return PublicVRegs; }
};

} // namespace llvm

#endif // LLVM_LIB_TARGET_X86_PTEX_PROTEANMACHINEFUNCTIONINFO_H
