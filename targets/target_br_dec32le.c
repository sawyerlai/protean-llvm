// Standalone br_dec32le — noinline so it appears in IR
// From bearssl/chacha20_ct.c
#include <stdint.h>

__attribute__((noinline))
uint32_t br_dec32le(const unsigned char *src) {
    return (uint32_t)src[0]
        | ((uint32_t)src[1] << 8)
        | ((uint32_t)src[2] << 16)
        | ((uint32_t)src[3] << 24);
}
