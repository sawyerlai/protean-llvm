// Target 9: int32_sort from djbsort
// Constant-time sorting network.
#include <stdint.h>

#define int32 int32_t

static inline int32 int32_minmax(int32 a, int32 *y) {
  int32 b = *y;
  int32 ab = b ^ a;
  int32 c = b - a;
  c ^= ab & (c ^ b);
  c >>= 31;
  c &= ab;
  a ^= c;
  *y = b ^ c;
  return a;
}

static void minmax_vector(int32 *x, int32 *y, long long n) {
  while (n-- > 0) {
    *x = int32_minmax(*x, y);
    ++x;
    ++y;
  }
}

static void outshuffle(int32 *x, long long n, long long m) {
  int32 y[m];
  long long j;
  for (j = 0; j < m; ++j) y[j] = x[j];
  for (j = m; j < n; ++j) x[(j - m) * 2 + 1] = x[j];
  for (j = 0; j < m; ++j) x[j * 2] = y[j];
}

static void merge(int32 *x, long long n, long long m) {
  long long p = 1;
  while (p < m) p <<= 1;
  minmax_vector(x, x + m, n - m);
  while (p >>= 1)
    minmax_vector(x + m, x + p, m - p);
  outshuffle(x, n, m);
}

void int32_sort(int32 *x, long long n) {
  long long m;
  if (n < 2) return;
  m = (n + 1) >> 1;
  int32_sort(x, m);
  int32_sort(x + m, n - m);
  merge(x, n, m);
}
