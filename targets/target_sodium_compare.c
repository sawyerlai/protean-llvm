// Target 3: sodium_compare from libsodium/utils.c
// Constant-time comparison that returns ordering (<0, 0, >0).
#include <stdint.h>
#include <stddef.h>

int sodium_compare(const unsigned char *b1_, const unsigned char *b2_, size_t len) {
    const unsigned char *b1 = b1_;
    const unsigned char *b2 = b2_;
    size_t                 i;
    volatile unsigned char gt = 0U;
    volatile unsigned char eq = 1U;
    uint16_t               x1, x2;

    i = len;
    while (i != 0U) {
        i--;
        x1 = b1[i];
        x2 = b2[i];
        gt |= (((unsigned int) x2 - (unsigned int) x1) >> 8) & eq;
        eq &= (((unsigned int) (x2 ^ x1)) - 1) >> 8;
    }
    return (int) (gt + gt + eq) - 1;
}
