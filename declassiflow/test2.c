int f(int *arr, int len, int idx) {
    if (idx >= 0 && idx < len) {
        return arr[idx];  // transmitter: leaks arr, idx
    }
    return 0;
}