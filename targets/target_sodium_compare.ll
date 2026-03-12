; ModuleID = 'target_sodium_compare.c'
source_filename = "target_sodium_compare.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nofree nounwind memory(argmem: read, inaccessiblemem: readwrite) uwtable
define dso_local i32 @sodium_compare(ptr nocapture noundef readonly %0, ptr nocapture noundef readonly %1, i64 noundef %2) local_unnamed_addr #0 {
  %4 = alloca i8, align 1
  %5 = alloca i8, align 1
  call void @llvm.lifetime.start.p0(i64 1, ptr nonnull %4)
  store volatile i8 0, ptr %4, align 1, !tbaa !5
  call void @llvm.lifetime.start.p0(i64 1, ptr nonnull %5)
  store volatile i8 1, ptr %5, align 1, !tbaa !5
  %6 = icmp eq i64 %2, 0
  br i1 %6, label %30, label %7

7:                                                ; preds = %3, %7
  %8 = phi i64 [ %9, %7 ], [ %2, %3 ]
  %9 = add i64 %8, -1
  %10 = getelementptr inbounds i8, ptr %0, i64 %9
  %11 = load i8, ptr %10, align 1, !tbaa !5
  %12 = getelementptr inbounds i8, ptr %1, i64 %9
  %13 = load i8, ptr %12, align 1, !tbaa !5
  %14 = zext i8 %13 to i32
  %15 = zext i8 %11 to i32
  %16 = sub nsw i32 %14, %15
  %17 = lshr i32 %16, 8
  %18 = load volatile i8, ptr %5, align 1, !tbaa !5
  %19 = load volatile i8, ptr %4, align 1, !tbaa !5
  %20 = trunc i32 %17 to i8
  %21 = and i8 %18, %20
  %22 = or i8 %21, %19
  store volatile i8 %22, ptr %4, align 1, !tbaa !5
  %23 = xor i32 %14, %15
  %24 = add nuw nsw i32 %23, 65535
  %25 = lshr i32 %24, 8
  %26 = load volatile i8, ptr %5, align 1, !tbaa !5
  %27 = trunc i32 %25 to i8
  %28 = and i8 %26, %27
  store volatile i8 %28, ptr %5, align 1, !tbaa !5
  %29 = icmp eq i64 %9, 0
  br i1 %29, label %30, label %7, !llvm.loop !8

30:                                               ; preds = %7, %3
  %31 = load volatile i8, ptr %4, align 1, !tbaa !5
  %32 = zext i8 %31 to i32
  %33 = load volatile i8, ptr %4, align 1, !tbaa !5
  %34 = zext i8 %33 to i32
  %35 = load volatile i8, ptr %5, align 1, !tbaa !5
  %36 = zext i8 %35 to i32
  %37 = add nsw i32 %32, -1
  %38 = add nsw i32 %37, %34
  %39 = add nsw i32 %38, %36
  call void @llvm.lifetime.end.p0(i64 1, ptr nonnull %5)
  call void @llvm.lifetime.end.p0(i64 1, ptr nonnull %4)
  ret i32 %39
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
!4 = !{!"clang version 17.0.6 (https://github.com/StanfordPLArchSec/protean-llvm.git 7599a5138d3c6b1b3e4e4f4ee175c3922bf6a87e)"}
!5 = !{!6, !6, i64 0}
!6 = !{!"omnipotent char", !7, i64 0}
!7 = !{!"Simple C/C++ TBAA"}
!8 = distinct !{!8, !9}
!9 = !{!"llvm.loop.mustprogress"}
