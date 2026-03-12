; Annotated sodium_memcmp using the best current CT frontier subset
source_filename = "/protean/targets/target_sodium_memcmp.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

declare preserve_allcc ptr @llvm.protean.declassify.p0(ptr)
declare preserve_allcc i64 @llvm.protean.declassify.i64(i64)
declare preserve_allcc i32 @llvm.protean.declassify.i32(i32)
declare preserve_allcc i8 @llvm.protean.declassify.i8(i8)

; Function Attrs: nofree nounwind memory(argmem: read, inaccessiblemem: readwrite) uwtable
define dso_local i32 @sodium_memcmp(ptr nocapture noundef readonly %b1_, ptr nocapture noundef readonly %b2_, i64 noundef %len) local_unnamed_addr #0 {
entry:
  %d = alloca i8, align 1
  call void @llvm.lifetime.start.p0(i64 1, ptr nonnull %d)
  store volatile i8 0, ptr %d, align 1, !tbaa !5
  %cmp14.not = icmp eq i64 %len, 0
  br i1 %cmp14.not, label %for.end, label %for.body.preheader

for.body.preheader:                               ; preds = %entry
  %xtraiter = and i64 %len, 1
  %0 = icmp eq i64 %len, 1
  br i1 %0, label %for.end.loopexit.unr-lcssa, label %for.body.preheader.new

for.body.preheader.new:                           ; preds = %for.body.preheader
  %unroll_iter = and i64 %len, -2
  br label %for.body

for.body:                                         ; preds = %for.body, %for.body.preheader.new
  %i.015 = phi i64 [ 0, %for.body.preheader.new ], [ %inc.1, %for.body ]
  %niter = phi i64 [ 0, %for.body.preheader.new ], [ %niter.next.1, %for.body ]
  %arrayidx = getelementptr inbounds i8, ptr %b1_, i64 %i.015
  %__dfl_1 = call preserve_allcc ptr @llvm.protean.declassify.p0(ptr %arrayidx)
  %1 = load i8, ptr %arrayidx, align 1, !tbaa !5
  %arrayidx1 = getelementptr inbounds i8, ptr %b2_, i64 %i.015
  %__dfl_2 = call preserve_allcc ptr @llvm.protean.declassify.p0(ptr %arrayidx1)
  %2 = load i8, ptr %arrayidx1, align 1, !tbaa !5
  %xor12 = xor i8 %2, %1
  %d.0.d.0.d.0.d.0. = load volatile i8, ptr %d, align 1, !tbaa !5
  %or13 = or i8 %d.0.d.0.d.0.d.0., %xor12
  store volatile i8 %or13, ptr %d, align 1, !tbaa !5
  %inc = or i64 %i.015, 1
  %arrayidx.1 = getelementptr inbounds i8, ptr %b1_, i64 %inc
  %__dfl_3 = call preserve_allcc ptr @llvm.protean.declassify.p0(ptr %arrayidx.1)
  %3 = load i8, ptr %arrayidx.1, align 1, !tbaa !5
  %arrayidx1.1 = getelementptr inbounds i8, ptr %b2_, i64 %inc
  %__dfl_4 = call preserve_allcc ptr @llvm.protean.declassify.p0(ptr %arrayidx1.1)
  %4 = load i8, ptr %arrayidx1.1, align 1, !tbaa !5
  %xor12.1 = xor i8 %4, %3
  %d.0.d.0.d.0.d.0..1 = load volatile i8, ptr %d, align 1, !tbaa !5
  %or13.1 = or i8 %d.0.d.0.d.0.d.0..1, %xor12.1
  store volatile i8 %or13.1, ptr %d, align 1, !tbaa !5
  %inc.1 = add nuw i64 %i.015, 2
  %niter.next.1 = add i64 %niter, 2
  %niter.ncmp.1 = icmp eq i64 %niter.next.1, %unroll_iter
  br i1 %niter.ncmp.1, label %for.end.loopexit.unr-lcssa, label %for.body, !llvm.loop !8

for.end.loopexit.unr-lcssa:                       ; preds = %for.body, %for.body.preheader
  %i.015.unr = phi i64 [ 0, %for.body.preheader ], [ %inc.1, %for.body ]
  %lcmp.mod.not = icmp eq i64 %xtraiter, 0
  br i1 %lcmp.mod.not, label %for.end, label %for.body.epil

for.body.epil:                                    ; preds = %for.end.loopexit.unr-lcssa
  %arrayidx.epil = getelementptr inbounds i8, ptr %b1_, i64 %i.015.unr
  %__dfl_5 = call preserve_allcc ptr @llvm.protean.declassify.p0(ptr %arrayidx.epil)
  %5 = load i8, ptr %arrayidx.epil, align 1, !tbaa !5
  %arrayidx1.epil = getelementptr inbounds i8, ptr %b2_, i64 %i.015.unr
  %__dfl_6 = call preserve_allcc ptr @llvm.protean.declassify.p0(ptr %arrayidx1.epil)
  %6 = load i8, ptr %arrayidx1.epil, align 1, !tbaa !5
  %xor12.epil = xor i8 %6, %5
  %d.0.d.0.d.0.d.0..epil = load volatile i8, ptr %d, align 1, !tbaa !5
  %or13.epil = or i8 %d.0.d.0.d.0.d.0..epil, %xor12.epil
  store volatile i8 %or13.epil, ptr %d, align 1, !tbaa !5
  br label %for.end

for.end:                                          ; preds = %for.body.epil, %for.end.loopexit.unr-lcssa, %entry
  %d.0.d.0.d.0.d.0.7 = load volatile i8, ptr %d, align 1, !tbaa !5
  %conv5 = zext i8 %d.0.d.0.d.0.d.0.7 to i32
  %sub = add nuw nsw i32 %conv5, 511
  %shr11 = lshr i32 %sub, 8
  %and = and i32 %shr11, 1
  %sub6 = add nsw i32 %and, -1
  call void @llvm.lifetime.end.p0(i64 1, ptr nonnull %d)
  ret i32 %sub6
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
