; ModuleID = 'target_sodium_memcmp.c'
source_filename = "target_sodium_memcmp.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nofree nounwind memory(argmem: read, inaccessiblemem: readwrite) uwtable
define dso_local i32 @sodium_memcmp(ptr nocapture noundef readonly %0, ptr nocapture noundef readonly %1, i64 noundef %2) local_unnamed_addr #0 {
  %4 = alloca i8, align 1
  call void @llvm.lifetime.start.p0(i64 1, ptr nonnull %4)
  store volatile i8 0, ptr %4, align 1, !tbaa !5
  %5 = icmp eq i64 %2, 0
  br i1 %5, label %43, label %6

6:                                                ; preds = %3
  %7 = and i64 %2, 1
  %8 = icmp eq i64 %2, 1
  br i1 %8, label %32, label %9

9:                                                ; preds = %6
  %10 = and i64 %2, -2
  br label %11

11:                                               ; preds = %11, %9
  %12 = phi i64 [ 0, %9 ], [ %29, %11 ]
  %13 = phi i64 [ 0, %9 ], [ %30, %11 ]
  %14 = getelementptr inbounds i8, ptr %0, i64 %12
  %15 = load i8, ptr %14, align 1, !tbaa !5
  %16 = getelementptr inbounds i8, ptr %1, i64 %12
  %17 = load i8, ptr %16, align 1, !tbaa !5
  %18 = xor i8 %17, %15
  %19 = load volatile i8, ptr %4, align 1, !tbaa !5
  %20 = or i8 %19, %18
  store volatile i8 %20, ptr %4, align 1, !tbaa !5
  %21 = or i64 %12, 1
  %22 = getelementptr inbounds i8, ptr %0, i64 %21
  %23 = load i8, ptr %22, align 1, !tbaa !5
  %24 = getelementptr inbounds i8, ptr %1, i64 %21
  %25 = load i8, ptr %24, align 1, !tbaa !5
  %26 = xor i8 %25, %23
  %27 = load volatile i8, ptr %4, align 1, !tbaa !5
  %28 = or i8 %27, %26
  store volatile i8 %28, ptr %4, align 1, !tbaa !5
  %29 = add nuw i64 %12, 2
  %30 = add i64 %13, 2
  %31 = icmp eq i64 %30, %10
  br i1 %31, label %32, label %11, !llvm.loop !8

32:                                               ; preds = %11, %6
  %33 = phi i64 [ 0, %6 ], [ %29, %11 ]
  %34 = icmp eq i64 %7, 0
  br i1 %34, label %43, label %35

35:                                               ; preds = %32
  %36 = getelementptr inbounds i8, ptr %0, i64 %33
  %37 = load i8, ptr %36, align 1, !tbaa !5
  %38 = getelementptr inbounds i8, ptr %1, i64 %33
  %39 = load i8, ptr %38, align 1, !tbaa !5
  %40 = xor i8 %39, %37
  %41 = load volatile i8, ptr %4, align 1, !tbaa !5
  %42 = or i8 %41, %40
  store volatile i8 %42, ptr %4, align 1, !tbaa !5
  br label %43

43:                                               ; preds = %35, %32, %3
  %44 = load volatile i8, ptr %4, align 1, !tbaa !5
  %45 = zext i8 %44 to i32
  %46 = add nuw nsw i32 %45, 511
  %47 = lshr i32 %46, 8
  %48 = and i32 %47, 1
  %49 = add nsw i32 %48, -1
  call void @llvm.lifetime.end.p0(i64 1, ptr nonnull %4)
  ret i32 %49
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
