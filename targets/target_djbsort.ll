; ModuleID = 'target_djbsort.c'
source_filename = "target_djbsort.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nofree nosync nounwind memory(readwrite, inaccessiblemem: none) uwtable
define dso_local void @int32_sort(ptr noundef %0, i64 noundef %1) local_unnamed_addr #0 {
  %3 = icmp slt i64 %1, 2
  br i1 %3, label %160, label %4

4:                                                ; preds = %2
  %5 = add nuw nsw i64 %1, 1
  %6 = lshr i64 %5, 1
  tail call void @int32_sort(ptr noundef %0, i64 noundef %6)
  %7 = getelementptr inbounds i32, ptr %0, i64 %6
  %8 = sub nsw i64 %1, %6
  tail call void @int32_sort(ptr noundef %7, i64 noundef %8)
  br label %9

9:                                                ; preds = %9, %4
  %10 = phi i64 [ 1, %4 ], [ %12, %9 ]
  %11 = icmp slt i64 %10, %6
  %12 = shl i64 %10, 1
  br i1 %11, label %9, label %13, !llvm.loop !5

13:                                               ; preds = %9
  %14 = icmp sgt i64 %8, 0
  br i1 %14, label %15, label %80

15:                                               ; preds = %13
  %16 = sub i64 %1, %6
  %17 = icmp ult i64 %16, 8
  br i1 %17, label %57, label %18

18:                                               ; preds = %15
  %19 = shl i64 %1, 2
  %20 = getelementptr i8, ptr %0, i64 %19
  %21 = xor i64 %6, -1
  %22 = add i64 %21, %1
  %23 = shl i64 %22, 2
  %24 = add i64 %23, 4
  %25 = getelementptr i8, ptr %0, i64 %24
  %26 = icmp ult ptr %7, %25
  %27 = icmp ugt ptr %20, %0
  %28 = and i1 %26, %27
  br i1 %28, label %57, label %29

29:                                               ; preds = %18
  %30 = and i64 %16, -4
  %31 = sub i64 %8, %30
  %32 = shl i64 %30, 2
  %33 = getelementptr i8, ptr %7, i64 %32
  %34 = shl i64 %30, 2
  %35 = getelementptr i8, ptr %0, i64 %34
  br label %36

36:                                               ; preds = %36, %29
  %37 = phi i64 [ 0, %29 ], [ %53, %36 ]
  %38 = shl i64 %37, 2
  %39 = getelementptr i8, ptr %7, i64 %38
  %40 = shl i64 %37, 2
  %41 = getelementptr i8, ptr %0, i64 %40
  %42 = load <4 x i32>, ptr %41, align 4, !tbaa !7, !alias.scope !11
  %43 = load <4 x i32>, ptr %39, align 4, !tbaa !7, !alias.scope !14, !noalias !11
  %44 = xor <4 x i32> %43, %42
  %45 = sub nsw <4 x i32> %43, %42
  %46 = xor <4 x i32> %45, %43
  %47 = and <4 x i32> %46, %44
  %48 = xor <4 x i32> %47, %45
  %49 = icmp slt <4 x i32> %48, zeroinitializer
  %50 = select <4 x i1> %49, <4 x i32> %44, <4 x i32> zeroinitializer
  %51 = xor <4 x i32> %50, %42
  %52 = xor <4 x i32> %50, %43
  store <4 x i32> %52, ptr %39, align 4, !tbaa !7, !alias.scope !14, !noalias !11
  store <4 x i32> %51, ptr %41, align 4, !tbaa !7, !alias.scope !11
  %53 = add nuw i64 %37, 4
  %54 = icmp eq i64 %53, %30
  br i1 %54, label %55, label %36, !llvm.loop !16

55:                                               ; preds = %36
  %56 = icmp eq i64 %16, %30
  br i1 %56, label %80, label %57

57:                                               ; preds = %18, %15, %55
  %58 = phi i64 [ %8, %18 ], [ %8, %15 ], [ %31, %55 ]
  %59 = phi ptr [ %7, %18 ], [ %7, %15 ], [ %33, %55 ]
  %60 = phi ptr [ %0, %18 ], [ %0, %15 ], [ %35, %55 ]
  br label %61

61:                                               ; preds = %57, %61
  %62 = phi i64 [ %65, %61 ], [ %58, %57 ]
  %63 = phi ptr [ %78, %61 ], [ %59, %57 ]
  %64 = phi ptr [ %77, %61 ], [ %60, %57 ]
  %65 = add nsw i64 %62, -1
  %66 = load i32, ptr %64, align 4, !tbaa !7
  %67 = load i32, ptr %63, align 4, !tbaa !7
  %68 = xor i32 %67, %66
  %69 = sub nsw i32 %67, %66
  %70 = xor i32 %69, %67
  %71 = and i32 %70, %68
  %72 = xor i32 %71, %69
  %73 = icmp slt i32 %72, 0
  %74 = select i1 %73, i32 %68, i32 0
  %75 = xor i32 %74, %66
  %76 = xor i32 %74, %67
  store i32 %76, ptr %63, align 4, !tbaa !7
  store i32 %75, ptr %64, align 4, !tbaa !7
  %77 = getelementptr inbounds i32, ptr %64, i64 1
  %78 = getelementptr inbounds i32, ptr %63, i64 1
  %79 = icmp ugt i64 %62, 1
  br i1 %79, label %61, label %80, !llvm.loop !19

80:                                               ; preds = %61, %55, %13
  %81 = icmp ult i64 %10, 2
  br i1 %81, label %159, label %82

82:                                               ; preds = %80
  %83 = shl i64 %6, 2
  %84 = add i64 %83, 4
  %85 = getelementptr i8, ptr %0, i64 %84
  %86 = shl i64 %6, 3
  %87 = or i64 %86, 4
  %88 = getelementptr i8, ptr %0, i64 %87
  %89 = getelementptr i8, ptr %85, i64 -4
  %90 = icmp ult ptr %7, %89
  br label %91

91:                                               ; preds = %82, %157
  %92 = phi i64 [ %93, %157 ], [ %10, %82 ]
  %93 = ashr i64 %92, 1
  %94 = sub nsw i64 %6, %93
  %95 = icmp sgt i64 %94, 0
  br i1 %95, label %96, label %157

96:                                               ; preds = %91
  %97 = getelementptr i32, ptr %0, i64 %93
  %98 = sub i64 %6, %93
  %99 = icmp ult i64 %98, 8
  br i1 %99, label %134, label %100

100:                                              ; preds = %96
  %101 = xor i64 %93, -1
  %102 = shl i64 %101, 2
  %103 = getelementptr i8, ptr %88, i64 %102
  %104 = icmp ult ptr %97, %103
  %105 = and i1 %104, %90
  br i1 %105, label %134, label %106

106:                                              ; preds = %100
  %107 = and i64 %98, -4
  %108 = sub i64 %94, %107
  %109 = shl i64 %107, 2
  %110 = getelementptr i8, ptr %97, i64 %109
  %111 = shl i64 %107, 2
  %112 = getelementptr i8, ptr %7, i64 %111
  br label %113

113:                                              ; preds = %113, %106
  %114 = phi i64 [ 0, %106 ], [ %130, %113 ]
  %115 = shl i64 %114, 2
  %116 = getelementptr i8, ptr %97, i64 %115
  %117 = shl i64 %114, 2
  %118 = getelementptr i8, ptr %7, i64 %117
  %119 = load <4 x i32>, ptr %118, align 4, !tbaa !7, !alias.scope !20
  %120 = load <4 x i32>, ptr %116, align 4, !tbaa !7, !alias.scope !23, !noalias !20
  %121 = xor <4 x i32> %120, %119
  %122 = sub nsw <4 x i32> %120, %119
  %123 = xor <4 x i32> %122, %120
  %124 = and <4 x i32> %123, %121
  %125 = xor <4 x i32> %124, %122
  %126 = icmp slt <4 x i32> %125, zeroinitializer
  %127 = select <4 x i1> %126, <4 x i32> %121, <4 x i32> zeroinitializer
  %128 = xor <4 x i32> %127, %119
  %129 = xor <4 x i32> %127, %120
  store <4 x i32> %129, ptr %116, align 4, !tbaa !7, !alias.scope !23, !noalias !20
  store <4 x i32> %128, ptr %118, align 4, !tbaa !7, !alias.scope !20
  %130 = add nuw i64 %114, 4
  %131 = icmp eq i64 %130, %107
  br i1 %131, label %132, label %113, !llvm.loop !25

132:                                              ; preds = %113
  %133 = icmp eq i64 %98, %107
  br i1 %133, label %157, label %134

134:                                              ; preds = %100, %96, %132
  %135 = phi i64 [ %94, %100 ], [ %94, %96 ], [ %108, %132 ]
  %136 = phi ptr [ %97, %100 ], [ %97, %96 ], [ %110, %132 ]
  %137 = phi ptr [ %7, %100 ], [ %7, %96 ], [ %112, %132 ]
  br label %138

138:                                              ; preds = %134, %138
  %139 = phi i64 [ %142, %138 ], [ %135, %134 ]
  %140 = phi ptr [ %155, %138 ], [ %136, %134 ]
  %141 = phi ptr [ %154, %138 ], [ %137, %134 ]
  %142 = add nsw i64 %139, -1
  %143 = load i32, ptr %141, align 4, !tbaa !7
  %144 = load i32, ptr %140, align 4, !tbaa !7
  %145 = xor i32 %144, %143
  %146 = sub nsw i32 %144, %143
  %147 = xor i32 %146, %144
  %148 = and i32 %147, %145
  %149 = xor i32 %148, %146
  %150 = icmp slt i32 %149, 0
  %151 = select i1 %150, i32 %145, i32 0
  %152 = xor i32 %151, %143
  %153 = xor i32 %151, %144
  store i32 %153, ptr %140, align 4, !tbaa !7
  store i32 %152, ptr %141, align 4, !tbaa !7
  %154 = getelementptr inbounds i32, ptr %141, i64 1
  %155 = getelementptr inbounds i32, ptr %140, i64 1
  %156 = icmp ugt i64 %139, 1
  br i1 %156, label %138, label %157, !llvm.loop !26

157:                                              ; preds = %138, %132, %91
  %158 = icmp ult i64 %92, 4
  br i1 %158, label %159, label %91, !llvm.loop !27

159:                                              ; preds = %157, %80
  tail call fastcc void @outshuffle(ptr noundef %0, i64 noundef %1, i64 noundef %6)
  br label %160

160:                                              ; preds = %2, %159
  ret void
}

; Function Attrs: nofree nosync nounwind memory(argmem: readwrite) uwtable
define internal fastcc void @outshuffle(ptr nocapture noundef %0, i64 noundef %1, i64 noundef %2) unnamed_addr #1 {
  %4 = alloca i32, i64 %2, align 16
  %5 = icmp sgt i64 %2, 0
  br i1 %5, label %6, label %8

6:                                                ; preds = %3
  %7 = shl nuw i64 %2, 2
  call void @llvm.memcpy.p0.p0.i64(ptr nonnull align 16 %4, ptr align 4 %0, i64 %7, i1 false), !tbaa !7
  br label %8

8:                                                ; preds = %6, %3
  %9 = icmp slt i64 %2, %1
  br i1 %9, label %10, label %24

10:                                               ; preds = %8
  %11 = sub i64 %1, %2
  %12 = xor i64 %2, -1
  %13 = and i64 %11, 1
  %14 = icmp eq i64 %13, 0
  br i1 %14, label %20, label %15

15:                                               ; preds = %10
  %16 = getelementptr inbounds i32, ptr %0, i64 %2
  %17 = load i32, ptr %16, align 4, !tbaa !7
  %18 = getelementptr inbounds i32, ptr %0, i64 1
  store i32 %17, ptr %18, align 4, !tbaa !7
  %19 = add nsw i64 %2, 1
  br label %20

20:                                               ; preds = %15, %10
  %21 = phi i64 [ %2, %10 ], [ %19, %15 ]
  %22 = sub i64 0, %1
  %23 = icmp eq i64 %12, %22
  br i1 %23, label %24, label %30

24:                                               ; preds = %20, %30, %8
  br i1 %5, label %25, label %85

25:                                               ; preds = %24
  %26 = and i64 %2, 3
  %27 = icmp ult i64 %2, 4
  br i1 %27, label %72, label %28

28:                                               ; preds = %25
  %29 = and i64 %2, -4
  br label %47

30:                                               ; preds = %20, %30
  %31 = phi i64 [ %45, %30 ], [ %21, %20 ]
  %32 = getelementptr inbounds i32, ptr %0, i64 %31
  %33 = load i32, ptr %32, align 4, !tbaa !7
  %34 = sub nsw i64 %31, %2
  %35 = shl nsw i64 %34, 1
  %36 = or i64 %35, 1
  %37 = getelementptr inbounds i32, ptr %0, i64 %36
  store i32 %33, ptr %37, align 4, !tbaa !7
  %38 = add nsw i64 %31, 1
  %39 = getelementptr inbounds i32, ptr %0, i64 %38
  %40 = load i32, ptr %39, align 4, !tbaa !7
  %41 = sub nsw i64 %38, %2
  %42 = shl nsw i64 %41, 1
  %43 = or i64 %42, 1
  %44 = getelementptr inbounds i32, ptr %0, i64 %43
  store i32 %40, ptr %44, align 4, !tbaa !7
  %45 = add nsw i64 %31, 2
  %46 = icmp eq i64 %45, %1
  br i1 %46, label %24, label %30, !llvm.loop !28

47:                                               ; preds = %47, %28
  %48 = phi i64 [ 0, %28 ], [ %69, %47 ]
  %49 = phi i64 [ 0, %28 ], [ %70, %47 ]
  %50 = getelementptr inbounds i32, ptr %4, i64 %48
  %51 = load i32, ptr %50, align 16, !tbaa !7
  %52 = shl nuw nsw i64 %48, 1
  %53 = getelementptr inbounds i32, ptr %0, i64 %52
  store i32 %51, ptr %53, align 4, !tbaa !7
  %54 = or i64 %48, 1
  %55 = getelementptr inbounds i32, ptr %4, i64 %54
  %56 = load i32, ptr %55, align 4, !tbaa !7
  %57 = shl nuw nsw i64 %54, 1
  %58 = getelementptr inbounds i32, ptr %0, i64 %57
  store i32 %56, ptr %58, align 4, !tbaa !7
  %59 = or i64 %48, 2
  %60 = getelementptr inbounds i32, ptr %4, i64 %59
  %61 = load i32, ptr %60, align 8, !tbaa !7
  %62 = shl nuw nsw i64 %59, 1
  %63 = getelementptr inbounds i32, ptr %0, i64 %62
  store i32 %61, ptr %63, align 4, !tbaa !7
  %64 = or i64 %48, 3
  %65 = getelementptr inbounds i32, ptr %4, i64 %64
  %66 = load i32, ptr %65, align 4, !tbaa !7
  %67 = shl nuw nsw i64 %64, 1
  %68 = getelementptr inbounds i32, ptr %0, i64 %67
  store i32 %66, ptr %68, align 4, !tbaa !7
  %69 = add nuw nsw i64 %48, 4
  %70 = add i64 %49, 4
  %71 = icmp eq i64 %70, %29
  br i1 %71, label %72, label %47, !llvm.loop !29

72:                                               ; preds = %47, %25
  %73 = phi i64 [ 0, %25 ], [ %69, %47 ]
  %74 = icmp eq i64 %26, 0
  br i1 %74, label %85, label %75

75:                                               ; preds = %72, %75
  %76 = phi i64 [ %82, %75 ], [ %73, %72 ]
  %77 = phi i64 [ %83, %75 ], [ 0, %72 ]
  %78 = getelementptr inbounds i32, ptr %4, i64 %76
  %79 = load i32, ptr %78, align 4, !tbaa !7
  %80 = shl nuw nsw i64 %76, 1
  %81 = getelementptr inbounds i32, ptr %0, i64 %80
  store i32 %79, ptr %81, align 4, !tbaa !7
  %82 = add nuw nsw i64 %76, 1
  %83 = add i64 %77, 1
  %84 = icmp eq i64 %83, %26
  br i1 %84, label %85, label %75, !llvm.loop !30

85:                                               ; preds = %72, %75, %24
  ret void
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i64, i1 immarg) #2

attributes #0 = { nofree nosync nounwind memory(readwrite, inaccessiblemem: none) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nofree nosync nounwind memory(argmem: readwrite) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"clang version 17.0.6 (https://github.com/StanfordPLArchSec/protean-llvm.git 7599a5138d3c6b1b3e4e4f4ee175c3922bf6a87e)"}
!5 = distinct !{!5, !6}
!6 = !{!"llvm.loop.mustprogress"}
!7 = !{!8, !8, i64 0}
!8 = !{!"int", !9, i64 0}
!9 = !{!"omnipotent char", !10, i64 0}
!10 = !{!"Simple C/C++ TBAA"}
!11 = !{!12}
!12 = distinct !{!12, !13}
!13 = distinct !{!13, !"LVerDomain"}
!14 = !{!15}
!15 = distinct !{!15, !13}
!16 = distinct !{!16, !6, !17, !18}
!17 = !{!"llvm.loop.isvectorized", i32 1}
!18 = !{!"llvm.loop.unroll.runtime.disable"}
!19 = distinct !{!19, !6, !17}
!20 = !{!21}
!21 = distinct !{!21, !22}
!22 = distinct !{!22, !"LVerDomain"}
!23 = !{!24}
!24 = distinct !{!24, !22}
!25 = distinct !{!25, !6, !17, !18}
!26 = distinct !{!26, !6, !17}
!27 = distinct !{!27, !6}
!28 = distinct !{!28, !6}
!29 = distinct !{!29, !6}
!30 = distinct !{!30, !31}
!31 = !{!"llvm.loop.unroll.disable"}
