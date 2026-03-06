// Target 1: CRYPTO_memcmp from boringssl/mem.cc
// Constant-time memory comparison — compares two buffers without
// leaking which byte differs.
#include <stdint.h>
#include <stddef.h>

int CRYPTO_memcmp(const void *in_a, const void *in_b, size_t len) {
  const uint8_t *a = (const uint8_t *)in_a;
  const uint8_t *b = (const uint8_t *)in_b;
  uint8_t x = 0;

  for (size_t i = 0; i < len; i++) {
    x |= a[i] ^ b[i];
  }

  return x;
}
