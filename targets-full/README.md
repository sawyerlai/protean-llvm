# Dataset Targets (10 Functions)

This folder contains source files for concrete test targets.

## Upstream Revisions
- boringssl: fbf01ffae10929d863b6744bb505f0cae6c9c712
- libsodium: 148d2d60dd4c8de780e794a27260f29295ad98a4
- ctaes: 3b10b89b05ca1ef5fff33316777249df25c8b930
- bearssl: 3d9be2f60b7764e46836514bcd6e453abdfa864a
- djbsort: release 20180717 (archive: djbsort-20180717.tar.gz)

## Target Mapping
1. 'CRYPTO_memcmp' -> 'boringssl/mem.cc'
2. 'sodium_memcmp' -> 'libsodium/utils.c'
3. 'sodium_compare' -> 'libsodium/utils.c'
4. 'sodium_is_zero' -> 'libsodium/utils.c'
5. 'LoadBytes' -> 'ctaes/ctaes.c'
6. 'SubBytes' -> 'ctaes/ctaes.c'
7. 'ShiftRows' -> 'ctaes/ctaes.c'
8. 'SaveBytes' -> 'ctaes/ctaes.c'
9. 'int32_sort' -> 'djbsort/int32_sort_portable1.c'
10. 'br_chacha20_ct_run' -> 'bearssl/chacha20_ct.c'

## Notes
- These are copied from upstream source trees to keep target code in one place.
- Some targets are static/internal functions in their original file.
- For djbsort, this dataset uses the portable C implementation variant of int32_sort.
