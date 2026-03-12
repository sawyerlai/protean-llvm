extern int A[256];

int foo(int *p) {
    int x = *((volatile int*)p);
    int y = 0;
    if (x >= 0)
        y = A[x];
    return y;
}
