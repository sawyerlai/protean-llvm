; ModuleID = 'target_crypto_memcmp.c'
source_filename = "target_crypto_memcmp.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nofree norecurse nosync nounwind memory(argmem: read) uwtable
define dso_local i32 @CRYPTO_memcmp(ptr nocapture noundef readonly %0, ptr nocapture noundef readonly %1, i64 noundef %2) local_unnamed_addr #0 {
  %4 = icmp eq i64 %2, 0
  br i1 %4, label %61, label %5

5:                                                ; preds = %3
  %6 = icmp ult i64 %2, 8
  br i1 %6, label %55, label %7

7:                                                ; preds = %5
  %8 = icmp ult i64 %2, 32
  br i1 %8, label %36, label %9

9:                                                ; preds = %7
  %10 = and i64 %2, -32
  br label %11

11:                                               ; preds = %11, %9
  %12 = phi i64 [ 0, %9 ], [ %27, %11 ]
  %13 = phi <16 x i8> [ zeroinitializer, %9 ], [ %25, %11 ]
  %14 = phi <16 x i8> [ zeroinitializer, %9 ], [ %26, %11 ]
  %15 = getelementptr inbounds i8, ptr %0, i64 %12
  %16 = load <16 x i8>, ptr %15, align 1, !tbaa !5
  %17 = getelementptr inbounds i8, ptr %15, i64 16
  %18 = load <16 x i8>, ptr %17, align 1, !tbaa !5
  %19 = getelementptr inbounds i8, ptr %1, i64 %12
  %20 = load <16 x i8>, ptr %19, align 1, !tbaa !5
  %21 = getelementptr inbounds i8, ptr %19, i64 16
  %22 = load <16 x i8>, ptr %21, align 1, !tbaa !5
  %23 = xor <16 x i8> %20, %16
  %24 = xor <16 x i8> %22, %18
  %25 = or <16 x i8> %23, %13
  %26 = or <16 x i8> %24, %14
  %27 = add nuw i64 %12, 32
  %28 = icmp eq i64 %27, %10
  br i1 %28, label %29, label %11, !llvm.loop !8

29:                                               ; preds = %11
  %30 = or <16 x i8> %26, %25
  %31 = tail call i8 @llvm.vector.reduce.or.v16i8(<16 x i8> %30)
  %32 = icmp eq i64 %10, %2
  br i1 %32, label %58, label %33

33:                                               ; preds = %29
  %34 = and i64 %2, 24
  %35 = icmp eq i64 %34, 0
  br i1 %35, label %55, label %36

36:                                               ; preds = %7, %33
  %37 = phi i8 [ 0, %7 ], [ %31, %33 ]
  %38 = phi i64 [ 0, %7 ], [ %10, %33 ]
  %39 = and i64 %2, -8
  %40 = insertelement <8 x i8> <i8 poison, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0, i8 0>, i8 %37, i64 0
  br label %41

41:                                               ; preds = %41, %36
  %42 = phi i64 [ %38, %36 ], [ %50, %41 ]
  %43 = phi <8 x i8> [ %40, %36 ], [ %49, %41 ]
  %44 = getelementptr inbounds i8, ptr %0, i64 %42
  %45 = load <8 x i8>, ptr %44, align 1, !tbaa !5
  %46 = getelementptr inbounds i8, ptr %1, i64 %42
  %47 = load <8 x i8>, ptr %46, align 1, !tbaa !5
  %48 = xor <8 x i8> %47, %45
  %49 = or <8 x i8> %48, %43
  %50 = add nuw i64 %42, 8
  %51 = icmp eq i64 %50, %39
  br i1 %51, label %52, label %41, !llvm.loop !12

52:                                               ; preds = %41
  %53 = tail call i8 @llvm.vector.reduce.or.v8i8(<8 x i8> %49)
  %54 = icmp eq i64 %39, %2
  br i1 %54, label %58, label %55

55:                                               ; preds = %5, %33, %52
  %56 = phi i64 [ 0, %5 ], [ %10, %33 ], [ %39, %52 ]
  %57 = phi i8 [ 0, %5 ], [ %31, %33 ], [ %53, %52 ]
  br label %63

58:                                               ; preds = %63, %52, %29
  %59 = phi i8 [ %31, %29 ], [ %53, %52 ], [ %71, %63 ]
  %60 = zext i8 %59 to i32
  br label %61

61:                                               ; preds = %58, %3
  %62 = phi i32 [ 0, %3 ], [ %60, %58 ]
  ret i32 %62

63:                                               ; preds = %55, %63
  %64 = phi i64 [ %72, %63 ], [ %56, %55 ]
  %65 = phi i8 [ %71, %63 ], [ %57, %55 ]
  %66 = getelementptr inbounds i8, ptr %0, i64 %64
  %67 = load i8, ptr %66, align 1, !tbaa !5
  %68 = getelementptr inbounds i8, ptr %1, i64 %64
  %69 = load i8, ptr %68, align 1, !tbaa !5
  %70 = xor i8 %69, %67
  %71 = or i8 %70, %65
  %72 = add nuw i64 %64, 1
  %73 = icmp eq i64 %72, %2
  br i1 %73, label %58, label %63, !llvm.loop !13
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i8 @llvm.vector.reduce.or.v16i8(<16 x i8>) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i8 @llvm.vector.reduce.or.v8i8(<8 x i8>) #1

attributes #0 = { nofree norecurse nosync nounwind memory(argmem: read) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }

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
!8 = distinct !{!8, !9, !10, !11}
!9 = !{!"llvm.loop.mustprogress"}
!10 = !{!"llvm.loop.isvectorized", i32 1}
!11 = !{!"llvm.loop.unroll.runtime.disable"}
!12 = distinct !{!12, !9, !10, !11}
!13 = distinct !{!13, !9, !11, !10}
