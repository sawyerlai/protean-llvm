; Annotated int32_minmax — Declassiflow fully_declassified: true
; Knowledge frontier: all transmitted values at int32_minmax::3
; Declassify: i32 arg %0 and ptr arg %1 (function parameters, visible to caller)
;
; Declassiflow Phase 4 output:
;   transmitted_vals: ["%7", "%6", "%3", "%5", "%8", "%4"]
;   leaked_arg_idxs: []
;   fully_declassified: true
;   degenerate_case: true

source_filename = "target_int32_minmax.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

declare void @llvm.protean.declassify.i32(i32)
declare void @llvm.protean.declassify.p0(ptr)

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(argmem: readwrite) uwtable
define dso_local i32 @int32_minmax(i32 noundef %0, ptr nocapture noundef %1) 
local_unnamed_addr #0 "ptex-fully-declassified" {
  %3 = load i32, ptr %1, align 4, !tbaa !5
  %4 = xor i32 %3, %0
  %5 = sub nsw i32 %3, %0
  %6 = xor i32 %5, %3
  %7 = and i32 %6, %4
  %8 = xor i32 %7, %5
  %9 = icmp slt i32 %8, 0
  %10 = select i1 %9, i32 %3, i32 %0
  %11 = xor i32 %10, %4
  store i32 %11, ptr %1, align 4, !tbaa !5
  ret i32 %10
}

attributes #0 = { mustprogress nofree noinline norecurse nosync nounwind willreturn memory(argmem: readwrite) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"clang version 17.0.6 (https://github.com/StanfordPLArchSec/protean-llvm.git 7599a5138d3c6b1b3e4e4f4ee175c3922bf6a87e)"}
!5 = !{!6, !6, i64 0}
!6 = !{!"int", !7, i64 0}
!7 = !{!"omnipotent char", !8, i64 0}
!8 = !{!"Simple C/C++ TBAA"}
