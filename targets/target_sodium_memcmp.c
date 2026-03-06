// Target 2: sodium_memcmp from libsodium/utils.c
// Constant-time memory comparison.
#include <stdint.h>
#include <stddef.h>

int sodium_memcmp(const void *const b1_, const void *const b2_, size_t len) {
    const unsigned char *b1 = (const unsigned char *) b1_;
    const unsigned char *b2 = (const unsigned char *) b2_;
    size_t                 i;
    volatile unsigned char d = 0U;

    for (i = 0U; i < len; i++) {
        d |= b1[i] ^ b2[i];
    }
    return (1 & ((d - 1) >> 8)) - 1;
}
