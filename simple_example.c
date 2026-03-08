/**
 * spectre_example.c
 *
 * A simple Spectre-vulnerable program demonstrating the classic
 * bounds-check bypass (Spectre v1) pattern. This is the canonical
 * example used in the Protean paper (Figure 3).
 *
 * Compile with ProtCC passes:
 *
 *   # Non-secret-accessing (no-op pass):
 *   clang -O2 -mprotcc-arch spectre_example.c -o out_arch
 *
 *   # Static constant-time:
 *   clang -O2 -mprotcc-cts  spectre_example.c -o out_cts
 *
 *   # Constant-time:
 *   clang -O2 -mprotcc-ct   spectre_example.c -o out_ct
 *
 *   # Unrestricted (maximum protection):
 *   clang -O2 -mprotcc-unr  spectre_example.c -o out_unr
 *
 * To inspect the inserted PROT prefixes, disassemble the output:
 *   objdump -d out_ct | grep -A2 -B2 prot
 */

#include <stddef.h>
#include <stdint.h>
#include <stdio.h>

/* Simulated victim memory layout */
#define ARRAY_SIZE 16
static uint8_t array1[ARRAY_SIZE];      /* bounds-checked public array */
static uint8_t array2[256 * 64];        /* side-channel gadget array */
static uint8_t secret_data[64];         /* secret that should not leak */

/* Victim function: classic Spectre v1 gadget.
 * If the CPU speculatively bypasses the bounds check on 'x',
 * it can transiently read secret_data and encode it into array2,
 * leaking it via a cache side-channel. */
uint8_t victim_function(size_t x) {
    uint8_t y = 0;
    if (x < ARRAY_SIZE) {
        /* Transmitter: array2 access leaks array1[x] via cache timing */
        y = array2[array1[x] * 64];
    }
    return y;
}

/* A simple constant-time conditional select (no branches on secret).
 * This is the kind of code ProtCC-CT is designed to protect efficiently. */
uint8_t ct_select(uint8_t secret_cond, uint8_t a, uint8_t b) {
    /* mask = 0xFF if secret_cond != 0, else 0x00 */
    uint8_t mask = (uint8_t)(-(int8_t)(!!secret_cond));
    return (mask & a) | (~mask & b);
}

int main(void) {
    /* Initialize arrays */
    for (int i = 0; i < ARRAY_SIZE; i++)
        array1[i] = (uint8_t)i;
    for (int i = 0; i < 64; i++)
        secret_data[i] = (uint8_t)(0xAB ^ i);  /* "secret" */

    /* Normal (non-speculative) usage */
    uint8_t result = victim_function(5);
    printf("victim_function(5)  = %u (expected: %u)\n", result, array2[5 * 64]);

    /* Out-of-bounds index -- architecturally safe due to bounds check,
     * but speculatively dangerous (Spectre gadget). */
    uint8_t safe = victim_function(999);
    printf("victim_function(999) = %u (bounds check fired, got 0)\n", safe);

    /* Constant-time select */
    uint8_t chosen = ct_select(1, 42, 99);
    printf("ct_select(1, 42, 99) = %u (expected: 42)\n", chosen);

    return 0;


