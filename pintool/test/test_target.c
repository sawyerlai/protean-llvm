#include <stdio.h>

volatile int sink = 0;

/* Called exactly 3 times from main — lets us verify:
   PIN count for secret_work == static PROT count * 3 */
void secret_work(int n) {
    int i;
    for (i = 0; i < n; i++)
        sink += i * i;
}

int main(void) {
    secret_work(3);
    secret_work(3);
    secret_work(3);
    return 0;
}
