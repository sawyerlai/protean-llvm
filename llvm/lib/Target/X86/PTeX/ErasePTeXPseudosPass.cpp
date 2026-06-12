// ErasePTeXPseudosPass — MachineFunctionPass that runs in
// addPreEmitPass. Erases all PUBLIC_SEED meta-pseudos before code emission so
// they do not reach the MC layer. PUBLIC_SEED pseudos are inserted by
// PublicAnnotationsPass in addPreRegAlloc and carry TPEPubM so that
// PTeXAnalysis::initPublicInstr seeds the resulting physreg as public in Stage 1.
// By addPreEmitPass they have served their purpose and must be removed.

#include "X86.h"
#include "X86InstrInfo.h"
#include "llvm/CodeGen/MachineFunctionPass.h"

#define PASS_KEY "x86-erase-ptex-pseudos"
#define DEBUG_TYPE PASS_KEY

using namespace llvm;

namespace {

class X86ErasePTeXPseudos final : public MachineFunctionPass {
public:
  static char ID;
  X86ErasePTeXPseudos() : MachineFunctionPass(ID) {}

  bool runOnMachineFunction(MachineFunction &MF) override;

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.setPreservesCFG();
    MachineFunctionPass::getAnalysisUsage(AU);
  }
};

} // namespace

char X86ErasePTeXPseudos::ID = 0;

bool X86ErasePTeXPseudos::runOnMachineFunction(MachineFunction &MF) {
  // walk every instruction; erase PUBLIC_SEED pseudos in place.
  bool Changed = false;
  for (MachineBasicBlock &MBB : MF) {
    for (MachineBasicBlock::iterator MI = MBB.begin(), E = MBB.end(); MI != E;) {
      MachineBasicBlock::iterator Next = std::next(MI);
      if (MI->getOpcode() == X86::PUBLIC_SEED) {
        MI->eraseFromParent();
        Changed = true;
      }
      MI = Next;
    }
  }
  return Changed;
}

// pass registration following the X86AnnotatePublic.cpp pattern.
INITIALIZE_PASS_BEGIN(X86ErasePTeXPseudos, PASS_KEY "-pass",
                      "X86 Protean Erase PTeX Pseudos pass", false, false)
INITIALIZE_PASS_END(X86ErasePTeXPseudos, PASS_KEY "-pass",
                    "X86 Protean Erase PTeX Pseudos pass", false, false)

FunctionPass *llvm::createX86ErasePTeXPseudosPass() {
  return new X86ErasePTeXPseudos();
}
