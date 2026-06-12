#!/usr/bin/env bash
# run_tests.sh — PTeX public annotation pipeline stress tester
#
# Usage:
#   ./run_tests.sh [n_tests] [fraction] [ptex_mode]
#
#   n_tests    number of test iterations (default: 100)
#   fraction   annotation density, 0.0–1.0 (default: 0.3)
#   ptex_mode  PTeX mode passed to llc (default: cts)
#
# Corpus:
#   Place .ll files in testing_flow/corpus/ to use as seed inputs.
#   To add ctaes.ll from the container root:
#       cp /protean/ctaes.ll /protean/llvm/testing_flow/corpus/
#   To re-enable sodium_is_zero.ll:
#       cp /protean/sodium_is_zero.ll /protean/llvm/testing_flow/corpus/
#
# Results:
#   Crashing inputs  -> testing_flow/results/crashes/
#   Regressions      -> testing_flow/results/regressions/
#   (regression = annotated output has MORE ss prefixes than baseline)

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
LLVM="$REPO_ROOT/build/bin"
INJECT="$SCRIPT_DIR/inject_annotations.py"
CORPUS_DIR="$SCRIPT_DIR/corpus"
RESULTS_DIR="$SCRIPT_DIR/results"
CRASHES_DIR="$RESULTS_DIR/crashes"
REGRESSIONS_DIR="$RESULTS_DIR/regressions"

N_TESTS=${1:-100}
FRAC=${2:-0.3}
PTEX_MODE=${3:-cts}
DEBUG=${DEBUG:-0}   # set DEBUG=1 to save every generated .ll to results/debug/
# corpus files can produce small regalloc-noise regressions because
# PUBLIC_SEED pseudos extend vreg liveness and change register pressure. Allow
# up to CORPUS_TOL extra ss instructions for corpus-sourced tests; gen_ir.py
# tests use strict 0 tolerance because their patterns are purpose-built.
CORPUS_TOL=${CORPUS_TOL:-5}

# ── Preflight checks ──────────────────────────────────────────────────────────

if [ ! -x "$LLVM/llc" ]; then
    echo "ERROR: llc not found at $LLVM/llc"
    echo "       Build with: ninja -C $REPO_ROOT/build llc"
    exit 1
fi

if [ ! -f "$INJECT" ]; then
    echo "ERROR: inject_annotations.py not found at $INJECT"
    exit 1
fi

GEN_IR="$SCRIPT_DIR/gen_ir.py"
if [ ! -f "$GEN_IR" ]; then
    echo "ERROR: gen_ir.py not found at $GEN_IR"
    exit 1
fi

HAVE_CSMITH=0
if command -v csmith >/dev/null 2>&1; then
    HAVE_CSMITH=1
    echo "csmith detected — will use for 1 in 4 iterations"
fi

CORPUS_FILES=()
for _f in "$CORPUS_DIR"/*.ll; do
    [ -f "$_f" ] && CORPUS_FILES+=("$_f")
done
if [ ${#CORPUS_FILES[@]} -gt 0 ]; then
    echo "Corpus: ${#CORPUS_FILES[@]} file(s) in $CORPUS_DIR"
else
    echo "No corpus files — using gen_ir.py for all iterations"
fi

mkdir -p "$CRASHES_DIR" "$REGRESSIONS_DIR"
[ "$DEBUG" -eq 1 ] && mkdir -p "$RESULTS_DIR/debug"

# ── Helpers ───────────────────────────────────────────────────────────────────

count_ss() {
    # Count ss-prefixed instructions in an object file.
    # objdump format: "   6:	36 ...       	ss mov ..." (tab then "ss ")
    objdump -d "$1" 2>/dev/null | grep -c $'\tss ' || true
}

run_llc() {
    # $1 = input .ll, $2 = output .o, $3 = extra flags (optional)
    "$LLVM/llc" "$1" --x86-ptex="$PTEX_MODE" --filetype=obj \
        -o "$2" 2>/tmp/ptex_err.txt
}

# ── Main loop ─────────────────────────────────────────────────────────────────

pass=0; crash=0; regression=0

echo "Running $N_TESTS tests  (mode=$PTEX_MODE  fraction=$FRAC)"
echo "──────────────────────────────────────────────────"

for i in $(seq 1 "$N_TESTS"); do

    # 1. Choose / generate source IR
    # Priority: csmith (1-in-4) > corpus file > gen_ir.py
    # track source type to apply appropriate oracle tolerance.
    SRC_TYPE="gen"
    if [ "$HAVE_CSMITH" -eq 1 ] && [ $(( i % 4 )) -eq 0 ]; then
        csmith > /tmp/ptex_src.c 2>/dev/null
        "$LLVM/clang" -I/usr/include/csmith -O1 -S -emit-llvm \
            /tmp/ptex_src.c -o /tmp/ptex_base.ll 2>/dev/null || continue
        SRC_TYPE="csmith"
    elif [ ${#CORPUS_FILES[@]} -gt 0 ] && [ $(( i % 2 )) -eq 0 ]; then
        # Every other iteration use a corpus file for realistic patterns
        idx=$(( RANDOM % ${#CORPUS_FILES[@]} ))
        cp "${CORPUS_FILES[$idx]}" /tmp/ptex_base.ll
        SRC_TYPE="corpus"
    else
        # Default: generate targeted IR with memory loads and branches
        python3 "$GEN_IR" "$i" 8 > /tmp/ptex_base.ll
    fi

    # 2. Inject annotations (seed = iteration number for reproducibility)
    if ! python3 "$INJECT" /tmp/ptex_base.ll "$FRAC" "$i" \
            > /tmp/ptex_ann.ll 2>/dev/null; then
        echo "SKIP  [$i] inject failed"
        continue
    fi

    # Save generated files when DEBUG=1
    if [ "$DEBUG" -eq 1 ]; then
        cp /tmp/ptex_base.ll "$RESULTS_DIR/debug/base_${i}.ll"
        cp /tmp/ptex_ann.ll  "$RESULTS_DIR/debug/ann_${i}.ll"
    fi

    # 3. Baseline: compile without annotations
    base_ss=0
    if run_llc /tmp/ptex_base.ll /tmp/ptex_base.o; then
        base_ss=$(count_ss /tmp/ptex_base.o)
    fi

    # 4. Annotated: compile with annotations
    if ! run_llc /tmp/ptex_ann.ll /tmp/ptex_ann.o; then
        echo "CRASH [$i] seed=$i  ($(head -1 /tmp/ptex_err.txt))"
        cp /tmp/ptex_ann.ll  "$CRASHES_DIR/crash_${i}.ll"
        cp /tmp/ptex_err.txt "$CRASHES_DIR/crash_${i}.err"
        crash=$(( crash + 1 ))
        continue
    fi

    ann_ss=$(count_ss /tmp/ptex_ann.o)

    # apply tolerance based on source type:
    # Corpus/csmith files get CORPUS_TOL slack because PUBLIC_SEED pseudos extend
    # vreg liveness and can shift regalloc by a few instructions. gen_ir.py tests
    # use strict 0 tolerance since their IR is purpose-built for this pipeline.
    if [ "$SRC_TYPE" = "corpus" ] || [ "$SRC_TYPE" = "csmith" ]; then
        TOL=$CORPUS_TOL
    else
        TOL=0
    fi

    # 5. Oracle: annotations should never increase ss count (within tolerance)
    if [ "$ann_ss" -gt "$(( base_ss + TOL ))" ]; then
        echo "REGR  [$i] seed=$i  ss: $base_ss -> $ann_ss  (src=$SRC_TYPE)"
        cp /tmp/ptex_ann.ll "$REGRESSIONS_DIR/regression_${i}.ll"
        regression=$(( regression + 1 ))
    else
        echo "OK    [$i] seed=$i  ss: $base_ss -> $ann_ss  (src=$SRC_TYPE)"
        pass=$(( pass + 1 ))
    fi

done

# ── Summary ───────────────────────────────────────────────────────────────────

echo "──────────────────────────────────────────────────"
echo "  Passed:      $pass / $N_TESTS"
echo "  Crashes:     $crash"
echo "  Regressions: $regression"
if [ "$crash" -gt 0 ];      then echo "  Crash inputs:      $CRASHES_DIR"; fi
if [ "$regression" -gt 0 ]; then echo "  Regression inputs: $REGRESSIONS_DIR"; fi

exit 0
