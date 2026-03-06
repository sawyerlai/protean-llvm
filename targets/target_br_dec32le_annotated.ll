; Annotated br_dec32le — Declassiflow fully_declassified: true
; Knowledge frontier: all transmitted values at br_dec32le::2
; Declassify: ptr arg %0 (function parameter, architecturally visible to caller)
;
; Declassiflow Phase 4 output:
;   transmitted_vals: ["%20", "%14", "%8", "%4", "%2"]
;   leaked_arg_idxs: []
;   fully_declassified: true
;   degenerate_case: true

source_filename = "target_br_dec32le.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

declare preserve_allcc ptr @llvm.protean.declassify.p0(ptr)

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(argmem: read) uwtable
define dso_local i32 @br_dec32le(ptr nocapture noundef readonly %0) local_unnamed_addr #0 {
  ;; Knowledge frontier: declassify the pointer argument.
  ;; Declassiflow proved all transmitted values in this function are non-secret.
  %ptr.pub = call preserve_allcc ptr @llvm.protean.declassify.p0(ptr %0)
  %2 = load i32, ptr %ptr.pub, align 1
  ret i32 %2
}

attributes #0 = { mustprogress nofree noinline norecurse nosync nounwind willreturn memory(argmem: read) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"clang version 17.0.6 (https://github.com/StanfordPLArchSec/protean-llvm.git 7599a5138d3c6b1b3e4e4f4ee175c3922bf6a87e)"}
