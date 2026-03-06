// Targets 5-8: LoadBytes, SubBytes, ShiftRows, SaveBytes from ctaes/ctaes.c
// Constant-time AES implementation using bit-slicing.
#include <stdint.h>
#include <string.h>

typedef struct {
    uint16_t slice[8];
} AES_state;

/** Convert a byte to sliced form */
static void LoadByte(AES_state* s, unsigned char byte, int r, int c) {
    int i;
    for (i = 0; i < 8; i++) {
        s->slice[i] |= (uint16_t)(byte & 1) << (r * 4 + c);
        byte >>= 1;
    }
}

/** Target 5: Load 16 bytes of data into 8 sliced integers */
void LoadBytes(AES_state *s, const unsigned char* data16) {
    int c;
    memset(s, 0, sizeof(*s));
    for (c = 0; c < 4; c++) {
        int r;
        for (r = 0; r < 4; r++) {
            LoadByte(s, *(data16++), r, c);
        }
    }
}

/** Target 8: Convert 8 sliced integers into 16 bytes of data */
void SaveBytes(unsigned char* data16, const AES_state *s) {
    int c;
    for (c = 0; c < 4; c++) {
        int r;
        for (r = 0; r < 4; r++) {
            int b;
            uint8_t v = 0;
            for (b = 0; b < 8; b++) {
                v |= ((s->slice[b] >> (r * 4 + c)) & 1) << b;
            }
            *(data16++) = v;
        }
    }
}

/** Target 6: S-box implementation */
void SubBytes(AES_state *s, int inv) {
    uint16_t U0 = s->slice[7], U1 = s->slice[6], U2 = s->slice[5], U3 = s->slice[4];
    uint16_t U4 = s->slice[3], U5 = s->slice[2], U6 = s->slice[1], U7 = s->slice[0];

    uint16_t T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16;
    uint16_t T17, T18, T19, T20, T21, T22, T23, T24, T25, T26, T27, D;
    uint16_t M1, M6, M11, M13, M15, M20, M21, M22, M23, M25, M37, M38, M39, M40;
    uint16_t M41, M42, M43, M44, M45, M46, M47, M48, M49, M50, M51, M52, M53, M54;
    uint16_t M55, M56, M57, M58, M59, M60, M61, M62, M63;

    /* Forward linear preprocessing */
    T1 = U0 ^ U3;  T2 = U0 ^ U5;  T3 = U0 ^ U6;  T4 = U3 ^ U5;
    T5 = U4 ^ U6;  T6 = T1 ^ T5;  T7 = U1 ^ U2;  T8 = U7 ^ T6;
    T9 = U7 ^ T7;  T10 = T6 ^ T7; T11 = U1 ^ U5; T12 = U2 ^ U5;
    T13 = T3 ^ T4; T14 = T6 ^ T11; T15 = T5 ^ T11; T16 = T5 ^ T12;
    T17 = T9 ^ T16; T18 = U3 ^ U7; T19 = T7 ^ T18;
    T20 = T1 ^ T19; T21 = U6 ^ U7; T22 = T7 ^ T21;
    T23 = T2 ^ T22; T24 = T2 ^ T10; T25 = T20 ^ T17;
    T26 = T3 ^ T16; T27 = T1 ^ T12; D = U7;

    M1 = T13 & T6; M6 = T3 & T16; M11 = T1 & T15;
    M13 = (T4 & T27) ^ M11; M15 = (T2 & T10) ^ M11;
    M20 = T14 ^ M1 ^ (T23 & T8) ^ M13;
    M21 = (T19 & D) ^ M1 ^ T24 ^ M15;
    M22 = T26 ^ M6 ^ (T22 & T9) ^ M13;
    M23 = (T20 & T17) ^ M6 ^ M15 ^ T25;
    M25 = M22 & M20;
    M37 = M21 ^ ((M20 ^ M21) & (M23 ^ M25));
    M38 = M20 ^ M25 ^ (M21 | (M20 & M23));
    M39 = M23 ^ ((M22 ^ M23) & (M21 ^ M25));
    M40 = M22 ^ M25 ^ (M23 | (M21 & M22));
    M41 = M38 ^ M40; M42 = M37 ^ M39; M43 = M37 ^ M38;
    M44 = M39 ^ M40; M45 = M42 ^ M41;
    M46 = M44 & T6;  M47 = M40 & T8;  M48 = M39 & D;
    M49 = M43 & T16; M50 = M38 & T9;  M51 = M37 & T17;
    M52 = M42 & T15; M53 = M45 & T27; M54 = M41 & T10;
    M55 = M44 & T13; M56 = M40 & T23; M57 = M39 & T19;
    M58 = M43 & T3;  M59 = M38 & T22; M60 = M37 & T20;
    M61 = M42 & T1;  M62 = M45 & T4;  M63 = M41 & T2;

    {
        uint16_t L0 = M61 ^ M62;   uint16_t L1 = M50 ^ M56;
        uint16_t L2 = M46 ^ M48;   uint16_t L3 = M47 ^ M55;
        uint16_t L4 = M54 ^ M58;   uint16_t L5 = M49 ^ M61;
        uint16_t L6 = M62 ^ L5;    uint16_t L7 = M46 ^ L3;
        uint16_t L8 = M51 ^ M59;   uint16_t L9 = M52 ^ M53;
        uint16_t L10 = M53 ^ L4;   uint16_t L11 = M60 ^ L2;
        uint16_t L12 = M48 ^ M51;  uint16_t L13 = M50 ^ L0;
        uint16_t L14 = M52 ^ M61;  uint16_t L15 = M55 ^ L1;
        uint16_t L16 = M56 ^ L0;   uint16_t L17 = M57 ^ L1;
        uint16_t L18 = M58 ^ L8;   uint16_t L19 = M63 ^ L4;
        uint16_t L20 = L0 ^ L1;    uint16_t L21 = L1 ^ L7;
        uint16_t L22 = L3 ^ L12;   uint16_t L23 = L18 ^ L2;
        uint16_t L24 = L15 ^ L9;   uint16_t L25 = L6 ^ L10;
        uint16_t L26 = L7 ^ L9;    uint16_t L27 = L8 ^ L10;
        uint16_t L28 = L11 ^ L14;  uint16_t L29 = L11 ^ L17;
        s->slice[7] = L6 ^ L24;
        s->slice[6] = ~(L16 ^ L26);
        s->slice[5] = ~(L19 ^ L28);
        s->slice[4] = L6 ^ L21;
        s->slice[3] = L20 ^ L22;
        s->slice[2] = L25 ^ L29;
        s->slice[1] = ~(L13 ^ L27);
        s->slice[0] = ~(L6 ^ L23);
    }
}

#define BIT_RANGE(from,to) ((uint16_t)((1 << ((to) - (from))) - 1) << (from))
#define BIT_RANGE_LEFT(x,from,to,shift) (((x) & BIT_RANGE((from), (to))) << (shift))
#define BIT_RANGE_RIGHT(x,from,to,shift) (((x) & BIT_RANGE((from), (to))) >> (shift))

/** Target 7: ShiftRows */
void ShiftRows(AES_state* s) {
    int i;
    for (i = 0; i < 8; i++) {
        uint16_t v = s->slice[i];
        s->slice[i] =
            (v & BIT_RANGE(0, 4)) |
            BIT_RANGE_LEFT(v, 4, 5, 3) | BIT_RANGE_RIGHT(v, 5, 8, 1) |
            BIT_RANGE_LEFT(v, 8, 10, 2) | BIT_RANGE_RIGHT(v, 10, 12, 2) |
            BIT_RANGE_LEFT(v, 12, 15, 1) | BIT_RANGE_RIGHT(v, 15, 16, 3);
    }
}
