; Annotated sodium_is_zero using the best current CT frontier subset
source_filename = "/protean/targets/target_sodium_is_zero.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

declare preserve_allcc ptr @llvm.protean.declassify.p0(ptr)
declare preserve_allcc i64 @llvm.protean.declassify.i64(i64)
declare preserve_allcc i32 @llvm.protean.declassify.i32(i32)
declare preserve_allcc i8 @llvm.protean.declassify.i8(i8)

; Function Attrs: nofree nounwind memory(argmem: read, inaccessiblemem: readwrite) uwtable
define dso_local i32 @sodium_is_zero(ptr nocapture noundef readonly %n, i64 noundef %nlen) local_unnamed_addr #0 {
entry:
  %d = alloca i8, align 1
  call void @llvm.lifetime.start.p0(i64 1, ptr nonnull %d)
  store volatile i8 0, ptr %d, align 1, !tbaa !5
  %cmp9.not = icmp eq i64 %nlen, 0
  br i1 %cmp9.not, label %for.end, label %for.body.preheader

for.body.preheader:                               ; preds = %entry
  %xtraiter = and i64 %nlen, 3
  %0 = icmp ult i64 %nlen, 4
  br i1 %0, label %for.end.loopexit.unr-lcssa, label %for.body.preheader.new

for.body.preheader.new:                           ; preds = %for.body.preheader
  %unroll_iter = and i64 %nlen, -4
  br label %for.body

for.body:                                         ; preds = %for.body, %for.body.preheader.new
  %i.010 = phi i64 [ 0, %for.body.preheader.new ], [ %inc.3, %for.body ]
  %niter = phi i64 [ 0, %for.body.preheader.new ], [ %niter.next.3, %for.body ]
  %arrayidx = getelementptr inbounds i8, ptr %n, i64 %i.010
  %__dfl_1 = call preserve_allcc ptr @llvm.protean.declassify.p0(ptr %arrayidx)
  %1 = load i8, ptr %arrayidx, align 1, !tbaa !5
  %d.0.d.0.d.0.d.0. = load volatile i8, ptr %d, align 1, !tbaa !5
  %or8 = or i8 %d.0.d.0.d.0.d.0., %1
  store volatile i8 %or8, ptr %d, align 1, !tbaa !5
  %inc = or i64 %i.010, 1
  %arrayidx.1 = getelementptr inbounds i8, ptr %n, i64 %inc
  %__dfl_2 = call preserve_allcc ptr @llvm.protean.declassify.p0(ptr %arrayidx.1)
  %2 = load i8, ptr %arrayidx.1, align 1, !tbaa !5
  %d.0.d.0.d.0.d.0..1 = load volatile i8, ptr %d, align 1, !tbaa !5
  %or8.1 = or i8 %d.0.d.0.d.0.d.0..1, %2
  store volatile i8 %or8.1, ptr %d, align 1, !tbaa !5
  %inc.1 = or i64 %i.010, 2
  %arrayidx.2 = getelementptr inbounds i8, ptr %n, i64 %inc.1
  %__dfl_3 = call preserve_allcc ptr @llvm.protean.declassify.p0(ptr %arrayidx.2)
  %3 = load i8, ptr %arrayidx.2, align 1, !tbaa !5
  %d.0.d.0.d.0.d.0..2 = load volatile i8, ptr %d, align 1, !tbaa !5
  %or8.2 = or i8 %d.0.d.0.d.0.d.0..2, %3
  store volatile i8 %or8.2, ptr %d, align 1, !tbaa !5
  %inc.2 = or i64 %i.010, 3
  %arrayidx.3 = getelementptr inbounds i8, ptr %n, i64 %inc.2
  %__dfl_4 = call preserve_allcc ptr @llvm.protean.declassify.p0(ptr %arrayidx.3)
  %4 = load i8, ptr %arrayidx.3, align 1, !tbaa !5
  %d.0.d.0.d.0.d.0..3 = load volatile i8, ptr %d, align 1, !tbaa !5
  %or8.3 = or i8 %d.0.d.0.d.0.d.0..3, %4
  store volatile i8 %or8.3, ptr %d, align 1, !tbaa !5
  %inc.3 = add nuw i64 %i.010, 4
  %niter.next.3 = add i64 %niter, 4
  %niter.ncmp.3 = icmp eq i64 %niter.next.3, %unroll_iter
  br i1 %niter.ncmp.3, label %for.end.loopexit.unr-lcssa, label %for.body, !llvm.loop !8

for.end.loopexit.unr-lcssa:                       ; preds = %for.body, %for.body.preheader
  %i.010.unr = phi i64 [ 0, %for.body.preheader ], [ %inc.3, %for.body ]
  %lcmp.mod.not = icmp eq i64 %xtraiter, 0
  br i1 %lcmp.mod.not, label %for.end, label %for.body.epil

for.body.epil:                                    ; preds = %for.end.loopexit.unr-lcssa, %for.body.epil
  %i.010.epil = phi i64 [ %inc.epil, %for.body.epil ], [ %i.010.unr, %for.end.loopexit.unr-lcssa ]
  %epil.iter = phi i64 [ %epil.iter.next, %for.body.epil ], [ 0, %for.end.loopexit.unr-lcssa ]
  %arrayidx.epil = getelementptr inbounds i8, ptr %n, i64 %i.010.epil
  %__dfl_5 = call preserve_allcc ptr @llvm.protean.declassify.p0(ptr %arrayidx.epil)
  %5 = load i8, ptr %arrayidx.epil, align 1, !tbaa !5
  %d.0.d.0.d.0.d.0..epil = load volatile i8, ptr %d, align 1, !tbaa !5
  %or8.epil = or i8 %d.0.d.0.d.0.d.0..epil, %5
  store volatile i8 %or8.epil, ptr %d, align 1, !tbaa !5
  %inc.epil = add nuw i64 %i.010.epil, 1
  %epil.iter.next = add i64 %epil.iter, 1
  %epil.iter.cmp.not = icmp eq i64 %epil.iter.next, %xtraiter
  br i1 %epil.iter.cmp.not, label %for.end, label %for.body.epil, !llvm.loop !10

for.end:                                          ; preds = %for.end.loopexit.unr-lcssa, %for.body.epil, %entry
  %d.0.d.0.d.0.d.0.4 = load volatile i8, ptr %d, align 1, !tbaa !5
  %conv3 = zext i8 %d.0.d.0.d.0.d.0.4 to i32
  %sub = add nuw nsw i32 %conv3, 511
  %shr7 = lshr i32 %sub, 8
  %and = and i32 %shr7, 1
  call void @llvm.lifetime.end.p0(i64 1, ptr nonnull %d)
  ret i32 %and
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #1

attributes #0 = { nofree nounwind memory(argmem: read, inaccessiblemem: readwrite) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }

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
!9 = !{!"llvm.loop.mustprogress"}
!10 = distinct !{!10, !11}
!11 = !{!"llvm.loop.unroll.disable"}
