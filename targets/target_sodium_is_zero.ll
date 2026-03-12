; ModuleID = 'target_sodium_is_zero.c'
source_filename = "target_sodium_is_zero.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nofree nounwind memory(argmem: read, inaccessiblemem: readwrite) uwtable
define dso_local i32 @sodium_is_zero(ptr nocapture noundef readonly %0, i64 noundef %1) local_unnamed_addr #0 {
  %3 = alloca i8, align 1
  call void @llvm.lifetime.start.p0(i64 1, ptr nonnull %3)
  store volatile i8 0, ptr %3, align 1, !tbaa !5
  %4 = icmp eq i64 %1, 0
  br i1 %4, label %48, label %5

5:                                                ; preds = %2
  %6 = and i64 %1, 3
  %7 = icmp ult i64 %1, 4
  br i1 %7, label %35, label %8

8:                                                ; preds = %5
  %9 = and i64 %1, -4
  br label %10

10:                                               ; preds = %10, %8
  %11 = phi i64 [ 0, %8 ], [ %32, %10 ]
  %12 = phi i64 [ 0, %8 ], [ %33, %10 ]
  %13 = getelementptr inbounds i8, ptr %0, i64 %11
  %14 = load i8, ptr %13, align 1, !tbaa !5
  %15 = load volatile i8, ptr %3, align 1, !tbaa !5
  %16 = or i8 %15, %14
  store volatile i8 %16, ptr %3, align 1, !tbaa !5
  %17 = or i64 %11, 1
  %18 = getelementptr inbounds i8, ptr %0, i64 %17
  %19 = load i8, ptr %18, align 1, !tbaa !5
  %20 = load volatile i8, ptr %3, align 1, !tbaa !5
  %21 = or i8 %20, %19
  store volatile i8 %21, ptr %3, align 1, !tbaa !5
  %22 = or i64 %11, 2
  %23 = getelementptr inbounds i8, ptr %0, i64 %22
  %24 = load i8, ptr %23, align 1, !tbaa !5
  %25 = load volatile i8, ptr %3, align 1, !tbaa !5
  %26 = or i8 %25, %24
  store volatile i8 %26, ptr %3, align 1, !tbaa !5
  %27 = or i64 %11, 3
  %28 = getelementptr inbounds i8, ptr %0, i64 %27
  %29 = load i8, ptr %28, align 1, !tbaa !5
  %30 = load volatile i8, ptr %3, align 1, !tbaa !5
  %31 = or i8 %30, %29
  store volatile i8 %31, ptr %3, align 1, !tbaa !5
  %32 = add nuw i64 %11, 4
  %33 = add i64 %12, 4
  %34 = icmp eq i64 %33, %9
  br i1 %34, label %35, label %10, !llvm.loop !8

35:                                               ; preds = %10, %5
  %36 = phi i64 [ 0, %5 ], [ %32, %10 ]
  %37 = icmp eq i64 %6, 0
  br i1 %37, label %48, label %38

38:                                               ; preds = %35, %38
  %39 = phi i64 [ %45, %38 ], [ %36, %35 ]
  %40 = phi i64 [ %46, %38 ], [ 0, %35 ]
  %41 = getelementptr inbounds i8, ptr %0, i64 %39
  %42 = load i8, ptr %41, align 1, !tbaa !5
  %43 = load volatile i8, ptr %3, align 1, !tbaa !5
  %44 = or i8 %43, %42
  store volatile i8 %44, ptr %3, align 1, !tbaa !5
  %45 = add nuw i64 %39, 1
  %46 = add i64 %40, 1
  %47 = icmp eq i64 %46, %6
  br i1 %47, label %48, label %38, !llvm.loop !10

48:                                               ; preds = %35, %38, %2
  %49 = load volatile i8, ptr %3, align 1, !tbaa !5
  %50 = zext i8 %49 to i32
  %51 = add nuw nsw i32 %50, 511
  %52 = lshr i32 %51, 8
  %53 = and i32 %52, 1
  call void @llvm.lifetime.end.p0(i64 1, ptr nonnull %3)
  ret i32 %53
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
!10 = distinct !{!10, !11}
!11 = !{!"llvm.loop.unroll.disable"}
