// Standalone int32_minmax — noinline so it appears in IR
// From djbsort/int32_sort_portable1.c
#include <stdint.h>

typedef int32_t int32;

__attribute__((noinline))
int32 int32_minmax(int32 a, int32 *y) {
    int32 b = *y;
    int32 ab = b ^ a;
    int32 c = b - a;
    c ^= ab & (c ^ b);
    c >>= 31;
    c &= ab;
    a ^= c;
    *y = a ^ ab;
    return a;
}
