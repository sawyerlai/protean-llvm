# Targets Results

This directory restores the target-test layout that previously existed on the
`sawyer-declassify` branch and updates it with the current Protean results.

## What Is Here

- `run_baseline.sh`: old harness script from `sawyer-declassify`
- `target_*.c`: target C test inputs
- `target_*.ll`: baseline LLVM IR inputs
- `target_*_annotated.ll`: annotated LLVM IR inputs
- `*_base.o`, `*_ann.o`: saved object artifacts that were already present in this checkout
- `protean_results.txt`: current summary comparing saved `sawyer-declassify` outputs to the current rerun
- `baseline_vs_declassify_disasm.txt`: current disassembly-side comparison

## Annotation Policy

The corrected annotated target files follow the style used in
`/protean/annotated_protean_ex.ll`.

That means:

- declassify intrinsics are inserted as markers
- the original SSA values still drive the computation
- the annotated file does not rewrite the entire function to use only `.pub`
  values

This matters because the older `sawyer-declassify` target annotations were more
aggressive, and that was not a fair match for the example annotation style.

## Current Results

These are the active comparisons for the target trio we reran with the corrected
annotation style.

| Function | Saved sawyer annotated PROT | Saved sawyer annotated sanit | Current annotated PROT | Current annotated sanit | Result |
| --- | ---: | ---: | ---: | ---: | --- |
| `br_dec32le` | 0 | 1 | 0 | 1 | equal |
| `br_enc32le` | 0 | 2 | 0 | 1 | better |
| `int32_minmax` | 0 | 2 | 0 | 1 | better |

Interpretation:

- Current progress is at least as good as `sawyer-declassify` on these targets.
- `br_enc32le` and `int32_minmax` are better because they keep the same PROT
  reduction while removing one extra sanitization move.
- `br_dec32le` is unchanged relative to the saved target artifact.

## `foo` Result

The example from `/protean/annotated_protean_ex.ll` currently behaves like this:

- baseline keeps the two protected `ss mov` operations
- annotated also keeps the protected `ss mov` operations
- annotated still carries synthetic call-lowering overhead: `push/pop` and an
  identity move

So the main remaining issue is not lost declassification behavior; it is the
extra frame/setup overhead around annotated functions.

## Key Findings

- The verifier crash encountered during testing was fixed in
  `PTeXAnalysis.cpp` by correcting dead-register analysis for tied use/def
  operands.
- The current pass preserves protected operations on `foo` and the rerun target
  cases.
- The remaining cleanup problem is synthetic `push/pop` frame overhead after
  declassify-call erasure.

## Important Files

- `protean_results.txt`: short result summary
- `baseline_vs_declassify_disasm.txt`: disassembly comparison
- `target_br_dec32le_annotated.ll`: corrected example-style annotation
- `target_br_enc32le_annotated.ll`: corrected example-style annotation
- `target_int32_minmax_annotated.ll`: corrected example-style annotation

## How To Rerun

Rebuild `llc` after any pass change:

```bash
cd /protean/llvm/build
ninja llc
```

Compile the three active annotated targets in CT mode:

```bash
/protean/llvm/build/bin/llc -O2 -mtriple=x86_64-unknown-linux-gnu -x86-ptex=ct -filetype=obj /protean/targets/target_br_dec32le_annotated.ll -o /tmp/target_br_dec32le_annotated.o
/protean/llvm/build/bin/llc -O2 -mtriple=x86_64-unknown-linux-gnu -x86-ptex=ct -filetype=obj /protean/targets/target_br_enc32le_annotated.ll -o /tmp/target_br_enc32le_annotated.o
/protean/llvm/build/bin/llc -O2 -mtriple=x86_64-unknown-linux-gnu -x86-ptex=ct -filetype=obj /protean/targets/target_int32_minmax_annotated.ll -o /tmp/target_int32_minmax_annotated.o
```

Inspect disassembly:

```bash
objdump -d /tmp/target_br_dec32le_annotated.o
objdump -d /tmp/target_br_enc32le_annotated.o
objdump -d /tmp/target_int32_minmax_annotated.o
```

## Current Bottom Line

Current progress is better than the saved `sawyer-declassify` target artifacts
for the active rerun targets, but the pass still needs one more cleanup step to
remove the synthetic `push/pop` frame overhead from annotated functions.