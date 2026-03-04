#include "PTeX/PTeXAnalysis.h"

#include <array>

#include "X86.h"
#include "llvm/CodeGen/TargetSubtargetInfo.h"
#include "llvm/CodeGen/LivePhysRegs.h"
#include "llvm/IR/GlobalValue.h"
#include "llvm/IR/Function.h"
#include "llvm/CodeGen/TargetInstrInfo.h"
#include "X86RegisterInfo.h"
#include "X86Subtarget.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "PTeX/PublicPhysRegs.h"
#include "PTeX/ForwardAnalysis.h"
#include "PTeX/Util.h"
#include "PTeX/BranchAnalysis.h"
#include "PTeX/StackAnalysis.h"
#include "PTeX/PTeX.h"
#include "PTeX/BackwardAnalysis_CT.h"
#include "PTeX/BackwardAnalysis_CTS.h"

using namespace llvm;
using llvm::X86::PublicPhysRegs;
using llvm::X86::PTeXAnalysis;

#define PASS_KEY "x86-ptex"
#define DEBUG_TYPE PASS_KEY

static cl::opt<bool> AnalyzeBranches {
  PASS_KEY "-analyze-branches",
  cl::desc("[PTeX] Analyze branches"),
  cl::init(true),
  cl::Hidden,
};

static cl::opt<bool> SimpleAnalysis {
  PASS_KEY "-simple",
  cl::init(false),
  cl::Hidden,
  cl::desc("[PTeX] Simple analysis: run forward and backward passes individually, and then merge results"),
};

void PTeXAnalysis::initTransmittedUses(MachineInstr &MI) {
  if (MI.isCall())
    markOpPublic(MI.getOperand(0));

  if (MI.isBranch())
    markAllOpsPublic(MI);

  const int MemIdx = X86::getMemRefBeginIdx(MI);
  if (MI.mayLoadOrStore() && MemIdx >= 0) {
    markOpPublic(MI.getOperand(MemIdx + X86::AddrBaseReg));
    markOpPublic(MI.getOperand(MemIdx + X86::AddrIndexReg));
  }
}

void PTeXAnalysis::initPointerLoadsOrStores(MachineInstr &MI) {
  if (!X86::UnprotectAllPointers)
    return;
  for (MachineMemOperand *MMO : MI.memoperands())
    if (MMO->getType().isPointer())
      markAllOpsPublic(MI);
}

void PTeXAnalysis::initMachineMemOperands(MachineInstr &MI) {
  for (MachineMemOperand *MMO : MI.memoperands()) {
    if (MMO->getType().isPointer() && X86::UnprotectAllPointers) {
      // If it's pointer-typed, unprotect it.
      markAllOpsPublic(MI);
      LLVM_DEBUG(dbgs() << __func__ << ": marking public due to MMO pointer type: " << MI);
    } else if (const PseudoSourceValue *Ptr = MMO->getPseudoValue()) {
      switch (Ptr->kind()) {
      case PseudoSourceValue::GOT:
      case PseudoSourceValue::JumpTable:
      case PseudoSourceValue::ConstantPool:
      case PseudoSourceValue::GlobalValueCallEntry:
      case PseudoSourceValue::ExternalSymbolCallEntry:
        markAllOpsPublic(MI);
        LLVM_DEBUG(dbgs() << __func__ << ": marking public due to PSV: " << MI);
        break;
      }
    }
  }
}

void PTeXAnalysis::initAlwaysPublicRegs(MachineInstr &MI) {
  const TargetRegisterInfo &TRI = *MI.getParent()->getParent()->getSubtarget().getRegisterInfo();
  for (MachineOperand &MO : MI.operands())
    if (MO.isReg() && regAlwaysPublic(MO.getReg(), TRI) && !MO.isUndef() && MO.getReg() != X86::NoRegister)
      MO.setIsPublic();
}

void PTeXAnalysis::initFrameSetupAndDestroy(MachineInstr &MI) {
  if (!(MI.getFlag(MachineInstr::FrameSetup) ||
        MI.getFlag(MachineInstr::FrameDestroy)))
    return;

  if (getPTeXMode(MI) == NCT) {
    switch (MI.getOpcode()) {
    case X86::ADJCALLSTACKUP64:
    case X86::ADJCALLSTACKDOWN64:
    case X86::CFI_INSTRUCTION:
    case X86::MOV64rr:
    case X86::SUB64ri32:
    case X86::ADD64ri32:
    case X86::LEA64r:
    case X86::AND64ri32:
      break;
    case X86::PUSH64r:
    case X86::POP64r:
      return;
    default:
#if 0
      llvm::errs() << "unhandled frame setup/destroy opcode: " << MI;
      std::abort();
#else
      break;
#endif
    }
  }
  
  markAllOpsPublic(MI);
}

void PTeXAnalysis::initPointerCallArgs(MachineInstr &MI) {
  if (!MI.isCall() || !X86::UnprotectAllPointers)
    return;

  const auto &CSI = MF.getCallSitesInfo();
  const auto CSIIt = CSI.find(&MI);
  if (CSIIt == CSI.end()) {
    LLVM_DEBUG(dbgs() << "Call has no callsite info, skipping: " << MI);
    return;
  }

  const TargetInstrInfo *TII = MI.getParent()->getParent()->getSubtarget().getInstrInfo();
  const MachineOperand &CalleeMO = TII->getCalleeOperand(MI);
  if (!CalleeMO.isGlobal()) {
    LLVM_DEBUG(dbgs() << "Callee operand is not global, skipping: " << MI);
    return;
  }

  const Function *CalleeFunc = dyn_cast<Function>(CalleeMO.getGlobal());
  if (!CalleeFunc) {
    LLVM_DEBUG(dbgs() << "Skipping non-function callee: " << MI);
    return;
  }

  const auto &ArgRegPairs = CSIIt->second.ArgRegPairs;
  if (CalleeFunc->isVarArg()) {
    LLVM_DEBUG(dbgs() << "Skipping variadic function call: " << MI);
    return;
  }

  // Mark arguments public.
  for (const auto &Pair : ArgRegPairs) {
    const Argument *Arg = CalleeFunc->getArg(Pair.ArgNo);
    MachineOperand *MO = MI.findRegisterUseOperand(Pair.Reg);

    const auto Log = [&] (StringRef msg) {
      LLVM_DEBUG(dbgs() << __func__ << ": " << msg << ": " << *Arg << " :: " << *MO << " :: " << MI);
    };

    if (!Arg->getType()->isPointerTy()) {
      Log("not marking non-pointer call argument public");
      continue;
    }

    assert(MO && "Call doesn't use argument!");
    assert(MO->getReg() == Pair.Reg && "Call argument register mismatch!");
    assert(MO->isUse());

    if (MO->isUndef()) {
      Log("not marking undef call argument public");
      continue;
    }

    Log("marking pointer call argument public");
    markOpPublic(*MO);
  }

  // Mark pointer-typed return values public.
  // Don't need to do anything fancy here because pointers will always be passed
  // in RAX.
  if (CalleeFunc->getReturnType()->isPointerTy())
    for (MachineOperand &MO : MI.operands())
      if (MO.isReg() && MO.isDef() && MO.isImplicit())
        markOpPublic(MO);
}

void PTeXAnalysis::initPointerTypes(MachineInstr &MI) {
  if (!X86::UnprotectAllPointers)
    return;

  const MachineRegisterInfo &MRI = MF.getRegInfo();
  for (MachineOperand &MO : MI.operands()) {
    // PTEX-FIXME: MI.mayLoadOrStore() is too aggressive.
    // We do care about stores that have a pointer operand.
    if (MO.isReg() && !MO.isImplicit() && MRI.getType(MO.getReg()).isPointer() &&
        (MO.isDef() || (MO.isUse() && !MI.mayLoadOrStore()))) {
      markOpPublic(MO);
      LLVM_DEBUG(dbgs() << "PTeX.LLT: marking instruction operand '" << MO << "' public: " << MI);
    }
  }
}

void PTeXAnalysis::initPointerReturnValue(MachineInstr &MI) {
  if (!MI.isReturn() || !X86::UnprotectAllPointers)
    return;

  if (!MF.getFunction().getReturnType()->isPointerTy())
    return;

  for (MachineOperand &MO : MI.operands())
    if (MO.isReg() && MO.isUse() && !MO.isUndef())
      markOpPublic(MO);
}

// TODO: Remove?
void PTeXAnalysis::initPublicInstr(MachineInstr &MI) {
  if (MI.getFlag(MachineInstr::TPEPubM))
    for (MachineOperand &MO : MI.operands())
      if (MO.isReg() && !MO.isUndef())
        markOpPublic(MO);
}

void PTeXAnalysis::initGOTLoads(MachineInstr &MI) {
  if (!MI.mayLoad())
    return;

  // Are any operands x86-gotpcrel GlobalAddresses?
  const bool HasGotpcrelMO = llvm::any_of(MI.operands(), [] (const MachineOperand &MO) {
    return MO.getTargetFlags() == X86II::MO_GOTPCREL;
  });
  if (!HasGotpcrelMO)
    return;

  markAllOpsPublic(MI);
}

static bool analyzeMemAccess(MachineInstr &MI, Register &Base, Register &Index,
                             MachineOperand *&Seg,
                             SmallVectorImpl<MachineOperand *> &DataRegs) {
  if (!MI.mayLoadOrStore())
    return false;

  const int MemIdx = X86::getMemRefBeginIdx(MI);
  if (MemIdx < 0)
    return false;

  for (MachineOperand &MO : MI.operands()) {
    if (MO.isReg() && MO.isUse()) {
      switch (MO.getOperandNo() - MemIdx) {
      case X86::AddrBaseReg:
        Base = MO.getReg();
        break;
      case X86::AddrIndexReg:
        Index = MO.getReg();
        break;
      case X86::AddrSegmentReg:
        Seg = &MO;
        break;
      default:
        DataRegs.push_back(&MO);
        break;
      }
    }
  }

  return true;
}

void PTeXAnalysis::initAnnotatedPublicAccesses(MachineInstr &MI) {
  Register Base;
  Register Index;
  MachineOperand *Seg = nullptr;
  SmallVector<MachineOperand *> DataRegs;
  if (!analyzeMemAccess(MI, Base, Index, Seg, DataRegs))
    return;

  if (Seg->getReg() != X86::DS)
    return;

  Seg->setReg(X86::NoRegister);

  switch (getPTeXMode(MI)) {
  case CTS:
    // Mark all inputs and outputs public.
    markAllOpsPublic(MI);
    break;

  case CT:
  case NCT:
    // Mark the output of pure loads public.
    if (MI.mayLoad() && !MI.mayStore() && DataRegs.empty())
      for (MachineOperand &MO : MI.operands())
        if (MO.isReg() && MO.isDef())
          markOpPublic(MO);
    // Mark the data input of pure stores public.
    if (MI.mayStore() && !MI.mayLoad() && DataRegs.size() == 1)
      markOpPublic(*DataRegs[0]);
    break;

  default: report_fatal_error("unreachable");
  }
}

// added for annotation processing
void PTeXAnalysis::initDeclassifyAnnotations(MachineInstr &MI) {
  if (!MI.isCall())
    return;

  const MachineOperand &CalleeMO = MI.getOperand(0);
  if (!CalleeMO.isGlobal())
    return;

  const GlobalValue *GV = CalleeMO.getGlobal();
  if (!GV->getName().startswith("llvm.protean.declassify"))
    return;

  errs() << "[declassify] found annotation call: " << GV->getName() << "\n";
  errs() << "[declassify]   instruction: " << MI << "\n";

  for (MachineOperand &MO : MI.operands()) {
    // Skip non-register and regmask operands
    if (!MO.isReg() || MO.isRegMask())
      continue;
    // Skip invalid registers
    if (!MO.getReg().isValid())
      continue;
    // Skip stack/shadow stack/flags — not semantically meaningful to mark public
    Register Reg = MO.getReg();
    if (Reg == X86::RSP || Reg == X86::SSP || Reg == X86::EFLAGS)
      continue;

    errs() << "[declassify]   marking public: "
           << MI.getParent()->getParent()->getSubtarget()
                .getRegisterInfo()->getRegAsmName(Reg)
           << "\n";
    markOpPublic(MO);
  }

  errs() << "[declassify]   done.\n";
}

void PTeXAnalysis::init() {
  // Init pub-in and pub-out maps.
  for (MachineBasicBlock &MBB : MF) {
    In[&MBB].init(TRI);
    Out[&MBB].init(TRI);
  }

  // Initialize operand types.
  for (MachineBasicBlock &MBB : MF) {
    for (MachineInstr &MI : MBB) {
      if (getPTeXMode(MI) != NCT) {
        initTransmittedUses(MI);
        initPointerLoadsOrStores(MI);
        initPointerCallArgs(MI);
        initPointerTypes(MI);
        initPointerReturnValue(MI);
        initPublicInstr(MI);
      }
      initAlwaysPublicRegs(MI);
      initFrameSetupAndDestroy(MI);
      initGOTLoads(MI);
      initMachineMemOperands(MI);
      initAnnotatedPublicAccesses(MI);
      initDeclassifyAnnotations(MI);	// added for annotation processing
    }
  }

  // Init entry blocks pub-ins to include all callee-saved registers.
  const MCPhysReg *CSRs = TRI->getCalleeSavedRegs(&MF);
  assert(*CSRs);
  for (const MCPhysReg *CSRIt = CSRs; *CSRIt; ++CSRIt)
    In[&MF.front()].addReg(*CSRIt);

  // TODO: Mark CSRs at exit public?
}

bool PTeXAnalysis::forward() {
  ForwardAnalysis Forward(*this);
  bool Changed = false;
  Changed |= Forward.run();
  Changed |= merge(Forward);
  return Changed;
}

template <class BackwardAnalysis>
bool PTeXAnalysis::runBackward() {
    BackwardAnalysis Backward(*this);
    bool Changed = false;
    Changed |= Backward.run();
    Changed |= merge(Backward);
    return Changed;
}

bool PTeXAnalysis::backward() {
  switch (getPTeXMode(MF)) {
  case CT: return runBackward<BackwardAnalysis_CT>();
  case CTS: return runBackward<BackwardAnalysis_CTS>();
  case NCT: return false;
  default: report_fatal_error("unhandled ptexm mode for PTeXAnalysis::backward");
  }
}

bool PTeXAnalysis::branch() {
  BranchAnalysis Branch(*this);
  return Branch.run();
}

void PTeXAnalysis::cleanupOrphanedMoves(Register Reg,
                                         MachineBasicBlock::iterator ForwardBoundary,
                                         MachineBasicBlock &MBB) {
  const TargetRegisterInfo *TRI = MF.getSubtarget().getRegisterInfo();
  SmallVector<MachineInstr *, 4> ToErase;

  auto It = ForwardBoundary;
  while (It != MBB.begin()) {
    --It;
    MachineInstr &Prev = *It;

    if (Prev.mayStore() || Prev.isCall() || Prev.hasUnmodeledSideEffects())
      break;

    bool definesScanReg = false;
    for (const MachineOperand &MO : Prev.operands()) {
      if (MO.isReg() && MO.isDef() && !MO.isImplicit() &&
          TRI->regsOverlap(MO.getReg(), Reg)) {
        definesScanReg = true;
        break;
      }
    }
    if (!definesScanReg)
      continue;

    // Inline liveness check -- all defs of this instruction must be
    // dead after it for us to safely remove it
    bool allDefsDead = true;
    for (const MachineOperand &DefMO : Prev.operands()) {
      if (!DefMO.isReg() || !DefMO.isDef() || DefMO.isImplicit())
        continue;
      // Scan forward from the instruction after Prev to end of block
      bool dead = true;
      for (auto ScanIt = std::next(It); ScanIt != MBB.end(); ++ScanIt) {
        for (const MachineOperand &MO : ScanIt->operands()) {
          if (!MO.isReg() || !TRI->regsOverlap(MO.getReg(), DefMO.getReg()))
            continue;
          if (MO.isUse() && !MO.isUndef()) {
            dead = false;  // register is read -- not dead
            break;
          }
          if (MO.isDef()) {
            dead = true;   // overwritten before read -- dead
            break;
          }
        }
        if (!dead) break;
      }
      if (!dead) {
        allDefsDead = false;
        break;
      }
    }
    if (!allDefsDead)
      break;

    errs() << "[declassify] removing dead setup move: " << Prev << "\n";
    ToErase.push_back(&Prev);
  }

  for (MachineInstr *Dead : ToErase)
    Dead->eraseFromParent();
}

void PTeXAnalysis::run() {
  init();
  
  // added for annotation processing
  for (MachineBasicBlock &MBB : MF) {
    for (auto MBBI = MBB.begin(); MBBI != MBB.end(); ) {
      MachineInstr &MI = *MBBI;
      ++MBBI;

      if (!MI.isCall()) continue;

      const MachineOperand &CalleeMO = MI.getOperand(0);
      if (!CalleeMO.isGlobal()) continue;
      if (!CalleeMO.getGlobal()->getName().startswith("llvm.protean.declassify"))
        continue;

      errs() << "[declassify] removing: "
             << CalleeMO.getGlobal()->getName() << "\n";

      MF.eraseCallSiteInfo(&MI);
      MI.eraseFromParent();
    }
  } 
 
  LLVM_DEBUG(dbgs() << "==== init ====\n");
  LLVM_DEBUG(print(dbgs()));

#if 0
  if (SimpleAnalysis) {
    bool Changed;

    BackwardAnalysis Backward(*this);
    do {
      Changed = Backward.run();
      merge(Backward);
    } while (Changed);
    LLVM_DEBUG(dbgs() << "===== bwd =====\n");
    LLVM_DEBUG(Backward.print(dbgs()));

    ForwardAnalysis Forward(*this);
    do {
      Changed = Forward.run();
      merge(Forward);
    } while (Changed);
    LLVM_DEBUG(dbgs() << "===== fwd =====\n");
    LLVM_DEBUG(Forward.print(dbgs()));
    
    LLVM_DEBUG(dbgs() << "===== simple =====\n");
    LLVM_DEBUG(print(dbgs()));
    return;
  }
#endif

  bool IterChanged;
  int NumIters = 0;
  do {
    IterChanged = false;

    IterChanged |= forward();
    IterChanged |= backward();
    if (AnalyzeBranches)
      IterChanged |= branch();
    IterChanged |= fixup();

    LLVM_DEBUG(dbgs() << "==== iter " << NumIters << "====\n");
    LLVM_DEBUG(print(dbgs()));

    ++NumIters;
  } while (IterChanged);

  LLVM_DEBUG(dbgs() << "==== final protcetion types ====\n");
  LLVM_DEBUG(print(dbgs()));
}

void PTeXAnalysis::markOpPublic(MachineOperand &MO) {
  if (MO.isReg() && !MO.isUndef())
    MO.setIsPublic();
}

// TODO: Make more generic -- accept range of ops. Can be invoked by Fwd and Bwd analyses.
void PTeXAnalysis::markAllOpsPublic(MachineInstr &MI) {
  for (MachineOperand &MO : MI.operands())
    markOpPublic(MO);
}

// TODO: Re-examine this.
bool PTeXAnalysis::fixup() {
  bool Changed = false;
  for (MachineBasicBlock &MBB : MF) {
    for (MachineInstr &MI : MBB) {
      if (MI.isCall())
        continue;

      // HACK: If there are some explicit outputs and all of them are marked public, then mark the implicit output public, too.
      const auto IsExplicitDef = [] (const MachineOperand &MO) -> bool {
        return MO.isReg() && MO.isDef() && !MO.isImplicit() && !MO.isUndef();
      };
      if (llvm::any_of(MI.operands(), IsExplicitDef) &&
          llvm::all_of(MI.operands(), [&] (const MachineOperand &MO) -> bool {
            // IsImplicitDef => MO.isPublic()
            return !IsExplicitDef(MO) || MO.isPublic();
          })) {
        for (MachineOperand &MO : MI.operands()) {
          if (MO.isReg() && MO.isDef() && MO.isImplicit() && !MO.isUndef() && !MO.isPublic() && MO.getReg() == X86::EFLAGS) {
            LLVM_DEBUG(dbgs() << "HACK: marking implicit output " << MO << " public: " << MI);
            MO.setIsPublic();
            Changed = true;
          }
        }
      }
    }
  }
  return Changed;
}

MachineBasicBlock *PTeXAnalysis::splitCriticalEdge(MachineBasicBlock *Src, MachineBasicBlock *Dest) {
  if (MachineBasicBlock *New = Src->SplitCriticalEdge(Dest, Pass)) {
    In[New] = Out[Src];
    Out[New] = In[Dest];
    return New;
  } else {
    LLVM_DEBUG(dbgs() << "PTeXAnalysis::splitCriticalEdge: failed to split critical edge ";
               Src->printName(dbgs());
               Dest->printName(dbgs()));
    return nullptr;
  }
}
