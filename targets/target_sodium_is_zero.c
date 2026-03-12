// Target 4: sodium_is_zero from libsodium/utils.c
// Constant-time check if a buffer is all zeros.
#include <stdint.h>
#include <stddef.h>

int sodium_is_zero(const unsigned char *n, const size_t nlen) {
    size_t                 i;
    volatile unsigned char d = 0U;

    for (i = 0U; i < nlen; i++) {
        d |= n[i];
    }
    return 1 & ((d - 1) >> 8);
}
