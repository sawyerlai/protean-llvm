#include <stdint.h>
#include <stdio.h>

#define ARRAY_SIZE 16
static int A[ARRAY_SIZE];

int foo(int *secret) {
  int x = *secret;
  int y = 0;

  if (x >= 0)
    y = A[x];

  return y;
}

int main(void) {
  /* Initialize A so the access is meaningful */
  for (int i = 0; i < ARRAY_SIZE; i++)
    A[i] = i * 2;

  int s = 5;
  printf("foo(%d) = %d\n", s, foo(&s));
  return 0;
}
