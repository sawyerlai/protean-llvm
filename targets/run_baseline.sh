#!/bin/bash
# Sanity-check script: compile all targets with Protean in each mode,
# count PROT prefixes (ss segment override) and sanitisation instructions (mov %r,%r).
set -e

CC=/protean/llvm/build/bin/clang
DIR=/protean/targets
OUT=/tmp/protean_test

mkdir -p "$OUT"

TARGETS=(
  "target_crypto_memcmp.c:CRYPTO_memcmp"
  "target_sodium_memcmp.c:sodium_memcmp"
  "target_sodium_compare.c:sodium_compare"
  "target_sodium_is_zero.c:sodium_is_zero"
  "target_ctaes.c:LoadBytes,SaveBytes,SubBytes,ShiftRows"
  "target_djbsort.c:int32_sort"
  "target_chacha20.c:br_chacha20_ct_run"
)

MODES=(arch cts ct unr)

printf "%-24s" "Target"
for mode in "${MODES[@]}"; do
  printf "| %-8s " "$mode"
done
echo ""
printf "%-24s" "------------------------"
for mode in "${MODES[@]}"; do
  printf "| %-8s " "--------"
done
echo ""

for entry in "${TARGETS[@]}"; do
  IFS=':' read -r file funcs <<< "$entry"
  basename="${file%.c}"

  printf "%-24s" "$basename"

  for mode in "${MODES[@]}"; do
    objfile="$OUT/${basename}_${mode}.o"

    # Compile (suppress declassify debug prints)
    if $CC -O2 -mllvm -x86-ptex=$mode -c "$DIR/$file" -o "$objfile" 2>/dev/null; then
      # Count PROT prefixes (ss segment override = 0x36) across ALL functions
      prot=$(objdump -d "$objfile" | grep -c '	ss ' || true)
      # Count sanitisation moves: `mov %eXX,%eXX` or `mov %rXX,%rXX` (same src+dst)
      sanit=$(objdump -d "$objfile" | grep -oP 'mov\s+(%\w+),\1' | wc -l || true)
      printf "| %3d/%3d  " "$prot" "$sanit"
    else
      printf "| FAIL     "
    fi
  done
  echo ""
done

echo ""
echo "Format: PROT_prefixes / sanitisation_moves"
echo ""
echo "=== Detailed function-level PROT counts (CT mode) ==="
echo ""

for entry in "${TARGETS[@]}"; do
  IFS=':' read -r file funcs <<< "$entry"
  basename="${file%.c}"
  objfile="$OUT/${basename}_ct.o"

  if [ ! -f "$objfile" ]; then continue; fi

  echo "--- $basename (CT) ---"
  # Get all function symbols and their PROT counts
  objdump -d "$objfile" | awk '
    /^[0-9a-f]+ <[^>]+>:/ {
      if (fname != "" && prot > 0) printf "  %-30s PROT=%d sanit=%d\n", fname, prot, sanit
      fname = $2; prot = 0; sanit = 0
    }
    /\tss / { prot++ }
    /mov\s+%([a-z0-9]+),%\1/ { sanit++ }
    END {
      if (fname != "" && prot > 0) printf "  %-30s PROT=%d sanit=%d\n", fname, prot, sanit
    }
  '
  echo ""
done
