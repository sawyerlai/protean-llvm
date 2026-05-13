; ModuleID = 'test2.c'
source_filename = "test2.c"
target datalayout = "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128"
target triple = "aarch64-unknown-linux-gnu"

declare void @llvm.protean.markpublic.p0(ptr) 

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read) uwtable
define dso_local i32 @f(ptr nocapture noundef readonly %0, i32 noundef %1, i32 noundef %2) local_unnamed_addr #0 {
  %4 = icmp sgt i32 %2, -1
  %5 = icmp slt i32 %2, %1
  %6 = and i1 %4, %5
  br i1 %6, label %7, label %11

7:                                                ; preds = %3
  %8 = zext i32 %2 to i64
  %9 = getelementptr inbounds i32, ptr %0, i64 %8
  call void @llvm.protean.markpublic.p0(ptr %9)
  %10 = load i32, ptr %9, align 4, !tbaa !6
  br label %11

11:                                               ; preds = %3, %7
  %12 = phi i32 [ %10, %7 ], [ 0, %3 ]
  ret i32 %12
}

attributes #0 = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read) uwtable "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+fp-armv8,+neon,+outline-atomics,+v8a,-fmv" }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 1}
!5 = !{!"Ubuntu clang version 16.0.6 (++20231112100510+7cbf1a259152-1~exp1~20231112100554.106)"}
!6 = !{!7, !7, i64 0}
!7 = !{!"int", !8, i64 0}
!8 = !{!"omnipotent char", !9, i64 0}
!9 = !{!"Simple C/C++ TBAA"}