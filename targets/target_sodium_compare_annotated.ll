; Annotated sodium_compare using the best current CT frontier subset
source_filename = "/protean/targets/target_sodium_compare.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

declare preserve_allcc ptr @llvm.protean.declassify.p0(ptr)
declare preserve_allcc i64 @llvm.protean.declassify.i64(i64)
declare preserve_allcc i32 @llvm.protean.declassify.i32(i32)
declare preserve_allcc i8 @llvm.protean.declassify.i8(i8)

; Function Attrs: nofree nounwind memory(argmem: read, inaccessiblemem: readwrite) uwtable
define dso_local i32 @sodium_compare(ptr nocapture noundef readonly %b1_, ptr nocapture noundef readonly %b2_, i64 noundef %len) local_unnamed_addr #0 {
entry:
  %gt = alloca i8, align 1
  %eq = alloca i8, align 1
  call void @llvm.lifetime.start.p0(i64 1, ptr nonnull %gt)
  store volatile i8 0, ptr %gt, align 1, !tbaa !5
  call void @llvm.lifetime.start.p0(i64 1, ptr nonnull %eq)
  store volatile i8 1, ptr %eq, align 1, !tbaa !5
  %cmp.not29 = icmp eq i64 %len, 0
  br i1 %cmp.not29, label %while.end, label %while.body

while.body:                                       ; preds = %entry, %while.body
  %i.030 = phi i64 [ %dec, %while.body ], [ %len, %entry ]
  %dec = add i64 %i.030, -1
  %arrayidx = getelementptr inbounds i8, ptr %b1_, i64 %dec
  %0 = load i8, ptr %arrayidx, align 1, !tbaa !5
  %arrayidx1 = getelementptr inbounds i8, ptr %b2_, i64 %dec
  %1 = load i8, ptr %arrayidx1, align 1, !tbaa !5
  %conv3 = zext i8 %1 to i32
  %__dfl_1 = call preserve_allcc i32 @llvm.protean.declassify.i32(i32 %conv3)
  %conv4 = zext i8 %0 to i32
  %__dfl_2 = call preserve_allcc i32 @llvm.protean.declassify.i32(i32 %conv4)
  %sub = sub nsw i32 %conv3, %conv4
  %shr = lshr i32 %sub, 8
  %eq.0.eq.0.eq.0.eq.0. = load volatile i8, ptr %eq, align 1, !tbaa !5
  %gt.0.gt.0.gt.0.gt.0. = load volatile i8, ptr %gt, align 1, !tbaa !5
  %2 = trunc i32 %shr to i8
  %3 = and i8 %eq.0.eq.0.eq.0.eq.0., %2
  %conv7 = or i8 %3, %gt.0.gt.0.gt.0.gt.0.
  store volatile i8 %conv7, ptr %gt, align 1, !tbaa !5
  %xor = xor i32 %conv3, %conv4
  %sub10 = add nuw nsw i32 %xor, 65535
  %shr11 = lshr i32 %sub10, 8
  %eq.0.eq.0.eq.0.eq.0.22 = load volatile i8, ptr %eq, align 1, !tbaa !5
  %4 = trunc i32 %shr11 to i8
  %conv14 = and i8 %eq.0.eq.0.eq.0.eq.0.22, %4
  store volatile i8 %conv14, ptr %eq, align 1, !tbaa !5
  %cmp.not = icmp eq i64 %dec, 0
  br i1 %cmp.not, label %while.end, label %while.body, !llvm.loop !8

while.end:                                        ; preds = %while.body, %entry
  %gt.0.gt.0.gt.0.gt.0.24 = load volatile i8, ptr %gt, align 1, !tbaa !5
  %conv15 = zext i8 %gt.0.gt.0.gt.0.gt.0.24 to i32
  %gt.0.gt.0.gt.0.gt.0.25 = load volatile i8, ptr %gt, align 1, !tbaa !5
  %conv16 = zext i8 %gt.0.gt.0.gt.0.gt.0.25 to i32
  %eq.0.eq.0.eq.0.eq.0.23 = load volatile i8, ptr %eq, align 1, !tbaa !5
  %conv17 = zext i8 %eq.0.eq.0.eq.0.eq.0.23 to i32
  %add = add nsw i32 %conv15, -1
  %add18 = add nsw i32 %add, %conv16
  %sub19 = add nsw i32 %add18, %conv17
  call void @llvm.lifetime.end.p0(i64 1, ptr nonnull %eq)
  call void @llvm.lifetime.end.p0(i64 1, ptr nonnull %gt)
  ret i32 %sub19
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
