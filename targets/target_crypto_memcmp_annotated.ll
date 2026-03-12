; Annotated CRYPTO_memcmp currently keeps no frontier markers because all
; tested marker subsets were neutral or worse under CT, and non-empty loop
; variants still trigger the current CTS verifier bug.
source_filename = "/protean/targets/target_crypto_memcmp.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nofree norecurse nosync nounwind memory(argmem: read) uwtable
define dso_local i32 @CRYPTO_memcmp(ptr nocapture noundef readonly %in_a, ptr nocapture noundef readonly %in_b, i64 noundef %len) local_unnamed_addr #0 {
entry:
  %cmp12.not = icmp eq i64 %len, 0
  br i1 %cmp12.not, label %for.cond.cleanup, label %for.body.preheader

for.body.preheader:                               ; preds = %entry
  %xtraiter = and i64 %len, 3
  %0 = icmp ult i64 %len, 4
  br i1 %0, label %for.cond.cleanup.loopexit.unr-lcssa, label %for.body.preheader.new

for.body.preheader.new:                           ; preds = %for.body.preheader
  %unroll_iter = and i64 %len, -4
  br label %for.body

for.cond.cleanup.loopexit.unr-lcssa:              ; preds = %for.body, %for.body.preheader
  %or11.lcssa.ph = phi i8 [ undef, %for.body.preheader ], [ %or11.3, %for.body ]
  %i.014.unr = phi i64 [ 0, %for.body.preheader ], [ %inc.3, %for.body ]
  %x.013.unr = phi i8 [ 0, %for.body.preheader ], [ %or11.3, %for.body ]
  %lcmp.mod.not = icmp eq i64 %xtraiter, 0
  br i1 %lcmp.mod.not, label %for.cond.cleanup.loopexit, label %for.body.epil

for.body.epil:                                    ; preds = %for.cond.cleanup.loopexit.unr-lcssa, %for.body.epil
  %i.014.epil = phi i64 [ %inc.epil, %for.body.epil ], [ %i.014.unr, %for.cond.cleanup.loopexit.unr-lcssa ]
  %x.013.epil = phi i8 [ %or11.epil, %for.body.epil ], [ %x.013.unr, %for.cond.cleanup.loopexit.unr-lcssa ]
  %epil.iter = phi i64 [ %epil.iter.next, %for.body.epil ], [ 0, %for.cond.cleanup.loopexit.unr-lcssa ]
  %arrayidx.epil = getelementptr inbounds i8, ptr %in_a, i64 %i.014.epil
  %1 = load i8, ptr %arrayidx.epil, align 1, !tbaa !5
  %arrayidx1.epil = getelementptr inbounds i8, ptr %in_b, i64 %i.014.epil
  %2 = load i8, ptr %arrayidx1.epil, align 1, !tbaa !5
  %xor10.epil = xor i8 %2, %1
  %or11.epil = or i8 %xor10.epil, %x.013.epil
  %inc.epil = add nuw i64 %i.014.epil, 1
  %epil.iter.next = add i64 %epil.iter, 1
  %epil.iter.cmp.not = icmp eq i64 %epil.iter.next, %xtraiter
  br i1 %epil.iter.cmp.not, label %for.cond.cleanup.loopexit, label %for.body.epil, !llvm.loop !8

for.cond.cleanup.loopexit:                        ; preds = %for.body.epil, %for.cond.cleanup.loopexit.unr-lcssa
  %or11.lcssa = phi i8 [ %or11.lcssa.ph, %for.cond.cleanup.loopexit.unr-lcssa ], [ %or11.epil, %for.body.epil ]
  %3 = zext i8 %or11.lcssa to i32
  br label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.cond.cleanup.loopexit, %entry
  %x.0.lcssa = phi i32 [ 0, %entry ], [ %3, %for.cond.cleanup.loopexit ]
  ret i32 %x.0.lcssa

for.body:                                         ; preds = %for.body, %for.body.preheader.new
  %i.014 = phi i64 [ 0, %for.body.preheader.new ], [ %inc.3, %for.body ]
  %x.013 = phi i8 [ 0, %for.body.preheader.new ], [ %or11.3, %for.body ]
  %niter = phi i64 [ 0, %for.body.preheader.new ], [ %niter.next.3, %for.body ]
  %arrayidx = getelementptr inbounds i8, ptr %in_a, i64 %i.014
  %4 = load i8, ptr %arrayidx, align 1, !tbaa !5
  %arrayidx1 = getelementptr inbounds i8, ptr %in_b, i64 %i.014
  %5 = load i8, ptr %arrayidx1, align 1, !tbaa !5
  %xor10 = xor i8 %5, %4
  %or11 = or i8 %xor10, %x.013
  %inc = or i64 %i.014, 1
  %arrayidx.1 = getelementptr inbounds i8, ptr %in_a, i64 %inc
  %6 = load i8, ptr %arrayidx.1, align 1, !tbaa !5
  %arrayidx1.1 = getelementptr inbounds i8, ptr %in_b, i64 %inc
  %7 = load i8, ptr %arrayidx1.1, align 1, !tbaa !5
  %xor10.1 = xor i8 %7, %6
  %or11.1 = or i8 %xor10.1, %or11
  %inc.1 = or i64 %i.014, 2
  %arrayidx.2 = getelementptr inbounds i8, ptr %in_a, i64 %inc.1
  %8 = load i8, ptr %arrayidx.2, align 1, !tbaa !5
  %arrayidx1.2 = getelementptr inbounds i8, ptr %in_b, i64 %inc.1
  %9 = load i8, ptr %arrayidx1.2, align 1, !tbaa !5
  %xor10.2 = xor i8 %9, %8
  %or11.2 = or i8 %xor10.2, %or11.1
  %inc.2 = or i64 %i.014, 3
  %arrayidx.3 = getelementptr inbounds i8, ptr %in_a, i64 %inc.2
  %10 = load i8, ptr %arrayidx.3, align 1, !tbaa !5
  %arrayidx1.3 = getelementptr inbounds i8, ptr %in_b, i64 %inc.2
  %11 = load i8, ptr %arrayidx1.3, align 1, !tbaa !5
  %xor10.3 = xor i8 %11, %10
  %or11.3 = or i8 %xor10.3, %or11.2
  %inc.3 = add nuw i64 %i.014, 4
  %niter.next.3 = add i64 %niter, 4
  %niter.ncmp.3 = icmp eq i64 %niter.next.3, %unroll_iter
  br i1 %niter.ncmp.3, label %for.cond.cleanup.loopexit.unr-lcssa, label %for.body, !llvm.loop !10
}

attributes #0 = { nofree norecurse nosync nounwind memory(argmem: read) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"clang version 17.0.6 (https://github.com/StanfordPLArchSec/protean-llvm.git d5b250e4587c0a6f27a7b92b3a1675932ffb74a4)"}
!5 = !{!6, !6, i64 0}
!6 = !{!"omnipotent char", !7, i64 0}
!7 = !{!"Simple C/C++ TBAA"}
!8 = distinct !{!8, !9}
!9 = !{!"llvm.loop.unroll.disable"}
!10 = distinct !{!10, !11}
!11 = !{!"llvm.loop.mustprogress"}
