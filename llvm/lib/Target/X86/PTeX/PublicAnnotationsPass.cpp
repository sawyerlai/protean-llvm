// PublicAnnotationsPass — MachineFunctionPass that runs in
// addPreRegAlloc. Reads the ProteanMachineFunctionInfo side table of IR-annotated
// public vregs and inserts a PUBLIC_SEED pseudo for each one at the correct
// position in the MBB (after the def if local, at block entry if live-in).
// The pseudo carries the vreg as an implicit-use with TPEPubM set so that
// PTeXAnalysis::initPublicInstr marks the resulting physreg public in Stage 1.

#include "ProteanMachineFunctionInfo.h"

#include "X86.h"
#include "X86InstrInfo.h"
#include "X86Subtarget.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/TargetInstrInfo.h"
#include "llvm/CodeGen/TargetSubtargetInfo.h"
#include "llvm/Pass.h"

#define PASS_KEY "x86-public-annotations"
#define DEBUG_TYPE PASS_KEY

using namespace llvm;

namespace {

class X86PublicAnnotations final : public MachineFunctionPass {
public:
  static char ID;
  X86PublicAnnotations() : MachineFunctionPass(ID) {}

  bool runOnMachineFunction(MachineFunction &MF) override;

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.setPreservesCFG();
    MachineFunctionPass::getAnalysisUsage(AU);
  }
};

} // namespace

char X86PublicAnnotations::ID = 0;

bool X86PublicAnnotations::runOnMachineFunction(MachineFunction &MF) {
  // retrieve the set of public vregs recorded during iSel
  auto *PMFI = MF.getInfo<ProteanMachineFunctionInfo>();
  if (!PMFI || PMFI->getPublicVRegs().empty())
    return false;

  const TargetInstrInfo *TII = MF.getSubtarget().getInstrInfo();
  MachineRegisterInfo &MRI = MF.getRegInfo();
  bool Changed = false;

  for (Register VReg : PMFI->getPublicVRegs()) {
    MachineInstr *DefMI = MRI.getVRegDef(VReg);

    // skip vregs with no definition -- IR value was DCE'd by the selector (e.g. poison from an out-of-range shift)
    // or when the selector recorded an invalid vreg in the side-table.
    if (!DefMI)
      continue;

    MachineBasicBlock *MBB = DefMI->getParent();
    MachineBasicBlock::iterator InsertPoint = std::next(DefMI->getIterator());

    // LLVM requires all PHI instructions to precede all non-PHI instructions in a block 
    if (DefMI->isPHI()) {
      while (InsertPoint != MBB->end() && InsertPoint->isPHI())
        ++InsertPoint;
    }

    // build the PUBLIC_SEED pseudo with VReg as an implicit use
    // setFlag(TPEPubM) is set so PTeXAnalysis::initPublicInstr picks it up
    MachineInstr *Seed =
        BuildMI(*MBB, InsertPoint, DebugLoc(), TII->get(X86::PUBLIC_SEED))
            .addReg(VReg, RegState::Implicit)
            .getInstr();
    Seed->setFlag(MachineInstr::TPEPubM);
    Changed = true;
  }

  return Changed;
}

INITIALIZE_PASS_BEGIN(X86PublicAnnotations, PASS_KEY "-pass",
                      "X86 Protean Public Annotations pass", false, false)
INITIALIZE_PASS_END(X86PublicAnnotations, PASS_KEY "-pass",
                    "X86 Protean Public Annotations pass", false, false)

FunctionPass *llvm::createX86PublicAnnotationsPass() {
  return new X86PublicAnnotations();
}
