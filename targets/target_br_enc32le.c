// Standalone br_enc32le — noinline so it appears in IR
// From bearssl/chacha20_ct.c
#include <stdint.h>

__attribute__((noinline))
void br_enc32le(unsigned char *dst, uint32_t x) {
    dst[0] = (unsigned char)x;
    dst[1] = (unsigned char)(x >> 8);
    dst[2] = (unsigned char)(x >> 16);
    dst[3] = (unsigned char)(x >> 24);
}
