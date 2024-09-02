
#include <stdio.h>
#include <stdint.h>
#include <string.h>

#include "crypto/sha/api_sha512.h"
#include "crypto/sha/zvknh.h"

static uint64_t K [80] = {
    0x428a2f98d728ae22L, 0x7137449123ef65cdL, 0xb5c0fbcfec4d3b2fL,
    0xe9b5dba58189dbbcL, 0x3956c25bf348b538L, 0x59f111f1b605d019L,
    0x923f82a4af194f9bL, 0xab1c5ed5da6d8118L, 0xd807aa98a3030242L,
    0x12835b0145706fbeL, 0x243185be4ee4b28cL, 0x550c7dc3d5ffb4e2L,
    0x72be5d74f27b896fL, 0x80deb1fe3b1696b1L, 0x9bdc06a725c71235L,
    0xc19bf174cf692694L, 0xe49b69c19ef14ad2L, 0xefbe4786384f25e3L,
    0x0fc19dc68b8cd5b5L, 0x240ca1cc77ac9c65L, 0x2de92c6f592b0275L,
    0x4a7484aa6ea6e483L, 0x5cb0a9dcbd41fbd4L, 0x76f988da831153b5L,
    0x983e5152ee66dfabL, 0xa831c66d2db43210L, 0xb00327c898fb213fL,
    0xbf597fc7beef0ee4L, 0xc6e00bf33da88fc2L, 0xd5a79147930aa725L,
    0x06ca6351e003826fL, 0x142929670a0e6e70L, 0x27b70a8546d22ffcL,
    0x2e1b21385c26c926L, 0x4d2c6dfc5ac42aedL, 0x53380d139d95b3dfL,
    0x650a73548baf63deL, 0x766a0abb3c77b2a8L, 0x81c2c92e47edaee6L,
    0x92722c851482353bL, 0xa2bfe8a14cf10364L, 0xa81a664bbc423001L,
    0xc24b8b70d0f89791L, 0xc76c51a30654be30L, 0xd192e819d6ef5218L,
    0xd69906245565a910L, 0xf40e35855771202aL, 0x106aa07032bbd1b8L,
    0x19a4c116b8d2d0c8L, 0x1e376c085141ab53L, 0x2748774cdf8eeb99L,
    0x34b0bcb5e19b48a8L, 0x391c0cb3c5c95a63L, 0x4ed8aa4ae3418acbL,
    0x5b9cca4f7763e373L, 0x682e6ff3d6b2b8a3L, 0x748f82ee5defb2fcL,
    0x78a5636f43172f60L, 0x84c87814a1f0ab72L, 0x8cc702081a6439ecL,
    0x90befffa23631e28L, 0xa4506cebde82bde9L, 0xbef9a3f7b2c67915L,
    0xc67178f2e372532bL, 0xca273eceea26619cL, 0xd186b8c721c0c207L,
    0xeada7dd6cde0eb1eL, 0xf57d4f7fee6ed178L, 0x06f067aa72176fbaL,
    0x0a637dc5a2c898a6L, 0x113f9804bef90daeL, 0x1b710b35131c471bL,
    0x28db77f523047d84L, 0x32caab7b40c72493L, 0x3c9ebe0a15c9bebcL,
    0x431d67c49c100d4cL, 0x4cc5d4becb3e42b6L, 0x597f299cfc657e2aL,
    0x5fcb6fab3ad6faecL, 0x6c44198c4a475817L
};


void sha512_hash_init_vec (
    uint64_t    H [8]  // out - message block hash
){
	H[0] = 0X9B05688C2B3E6C1F;
	H[1] = 0X510E527FADE682D1;
	H[2] = 0XBB67AE8584CAA73B;
	H[3] = 0X6A09E667F3BCC908;
	H[4] = 0X5BE0CD19137E2179;
	H[5] = 0X1F83D9ABFB41BD6B;
	H[6] = 0XA54FF53A5F1D36F1;
	H[7] = 0X3C6EF372FE94F82B;
}

void sha512_hash_init (
    uint64_t    H [8]  // out - message block hash
){
	H[0] = 0x6A09E667F3BCC908L;
	H[1] = 0xBB67AE8584CAA73BL;
	H[2] = 0x3C6EF372FE94F82BL;
	H[3] = 0xA54FF53A5F1D36F1L;
	H[4] = 0x510E527FADE682D1L;
	H[5] = 0x9B05688C2B3E6C1FL;
	H[6] = 0x1F83D9ABFB41BD6BL;
	H[7] = 0x5BE0CD19137E2179L;
}

#define SHA512_LOAD64_BE(X, A, I) {    \
    X = ((uint64_t*)A)[I];             \
    X = (((X >>  0) & 0xFF) << 56) |   \
        (((X >>  8) & 0xFF) << 48) |   \
        (((X >> 16) & 0xFF) << 40) |   \
        (((X >> 24) & 0xFF) << 32) |   \
        (((X >> 32) & 0xFF) << 24) |   \
        (((X >> 40) & 0xFF) << 16) |   \
        (((X >> 48) & 0xFF) <<  8) |   \
        (((X >> 56) & 0xFF) <<  0) ;   \
}

#define SHA512_STORE64_BE(X, A, I) {    \
    A[I] = \
        (((X >>  0) & 0xFF) << 56) |   \
        (((X >>  8) & 0xFF) << 48) |   \
        (((X >> 16) & 0xFF) << 40) |   \
        (((X >> 24) & 0xFF) << 32) |   \
        (((X >> 32) & 0xFF) << 24) |   \
        (((X >> 40) & 0xFF) << 16) |   \
        (((X >> 48) & 0xFF) <<  8) |   \
        (((X >> 56) & 0xFF) <<  0) ;   \
}

#define ROR64(X,Y) ((X>>Y) | (X << (64-Y)))
#define SHR64(X,Y) ((X>>Y)                )

#define CH(X,Y,Z)  ((X&Y)^(~X&Z))
#define MAJ(X,Y,Z) ((X&Y)^(X&Z)^(Y&Z))

#define SUM_0(X)   (ROR64(X,28) ^ ROR64(X,34) ^ ROR64(X,39))
#define SUM_1(X)   (ROR64(X,14) ^ ROR64(X,18) ^ ROR64(X,41))

#define SIGMA_0(X) (ROR64(X, 1) ^ ROR64(X, 8) ^ SHR64(X, 7))
#define SIGMA_1(X) (ROR64(X,19) ^ ROR64(X,61) ^ SHR64(X, 6))

#define ROUND(A,B,C,D,E,F,G,H,K,W) { \
    H  = H + SUM_1(E) + CH(E,F,G) + K + W   ; \
    D  = D + H                              ; \
    H  = H + SUM_0(A) + MAJ(A,B,C)          ; \
}

#define SCHEDULE(M0,M1,M9,ME) { \
    M0 = SIGMA_1(ME) + M9 + SIGMA_0(M1) + M0; \
}

void sha512_hash_block (
    uint64_t    H[ 8], //!< in,out - message block hash
    uint64_t    M[16]  //!< in - The message block to add to the hash
){
    uint64_t    a,b,c,d,e,f,g,h ;   // Working variables.

    a   =   H[0];                   // Initialise working variables.
    b   =   H[1];
    c   =   H[2];
    d   =   H[3];
    e   =   H[4];
    f   =   H[5];
    g   =   H[6];
    h   =   H[7];

    uint64_t m0, m1, m2, m3, m4, m5, m6, m7, m8, m9, ma, mb, mc, md, me, mf;

    SHA512_LOAD64_BE(m0, M,  0);
    SHA512_LOAD64_BE(m1, M,  1);
    SHA512_LOAD64_BE(m2, M,  2);
    SHA512_LOAD64_BE(m3, M,  3);
    SHA512_LOAD64_BE(m4, M,  4);
    SHA512_LOAD64_BE(m5, M,  5);
    SHA512_LOAD64_BE(m6, M,  6);
    SHA512_LOAD64_BE(m7, M,  7);
    SHA512_LOAD64_BE(m8, M,  8);
    SHA512_LOAD64_BE(m9, M,  9);
    SHA512_LOAD64_BE(ma, M, 10);
    SHA512_LOAD64_BE(mb, M, 11);
    SHA512_LOAD64_BE(mc, M, 12);
    SHA512_LOAD64_BE(md, M, 13);
    SHA512_LOAD64_BE(me, M, 14);
    SHA512_LOAD64_BE(mf, M, 15);

    uint64_t *kp = K     ;
    uint64_t *ke = K + 64;

    while(1) {
        
        ROUND(a, b, c, d, e, f, g, h, kp[ 0], m0)
        ROUND(h, a, b, c, d, e, f, g, kp[ 1], m1)
        ROUND(g, h, a, b, c, d, e, f, kp[ 2], m2)
        ROUND(f, g, h, a, b, c, d, e, kp[ 3], m3)
        ROUND(e, f, g, h, a, b, c, d, kp[ 4], m4)
        ROUND(d, e, f, g, h, a, b, c, kp[ 5], m5)
        ROUND(c, d, e, f, g, h, a, b, kp[ 6], m6)
        ROUND(b, c, d, e, f, g, h, a, kp[ 7], m7)
        ROUND(a, b, c, d, e, f, g, h, kp[ 8], m8)
        ROUND(h, a, b, c, d, e, f, g, kp[ 9], m9)
        ROUND(g, h, a, b, c, d, e, f, kp[10], ma)
        ROUND(f, g, h, a, b, c, d, e, kp[11], mb)
        ROUND(e, f, g, h, a, b, c, d, kp[12], mc)
        ROUND(d, e, f, g, h, a, b, c, kp[13], md)
        ROUND(c, d, e, f, g, h, a, b, kp[14], me)
        ROUND(b, c, d, e, f, g, h, a, kp[15], mf)

        if(kp == ke){break;}
        kp+=16;

        SCHEDULE(m0, m1, m9, me)
        SCHEDULE(m1, m2, ma, mf)
        SCHEDULE(m2, m3, mb, m0)
        SCHEDULE(m3, m4, mc, m1)
        SCHEDULE(m4, m5, md, m2)
        SCHEDULE(m5, m6, me, m3)
        SCHEDULE(m6, m7, mf, m4)
        SCHEDULE(m7, m8, m0, m5)
        SCHEDULE(m8, m9, m1, m6)
        SCHEDULE(m9, ma, m2, m7)
        SCHEDULE(ma, mb, m3, m8)
        SCHEDULE(mb, mc, m4, m9)
        SCHEDULE(mc, md, m5, ma)
        SCHEDULE(md, me, m6, mb)
        SCHEDULE(me, mf, m7, mc)
        SCHEDULE(mf, m0, m8, md)

    }
    
    H[0] += a;
    H[1] += b;
    H[2] += c;
    H[3] += d;
    H[4] += e;
    H[5] += f;
    H[6] += g;
    H[7] += h;
}


void sha512_hash (
    uint64_t    H[ 8], //!< in,out - message block hash
    uint8_t   * M    , //!< in - The message to be hashed
    size_t      len    //!< Length of the message in *bytes*.
){
    uint64_t   p_H[ 8] ;
    uint64_t   p_B[16] ;
    uint8_t  * p_M     = M ;

    size_t     len_bits= len << 3;

    sha512_hash_init(p_H);

    while(len >= 128) {
        memcpy(p_B, p_M, 128);          // Copy 128 bytes / 1024 bits . 

        sha512_hash_block (p_H, p_B);   // Digest another block

        p_M += 128;                     // Adjust pointers and length.
        len -= 128;
    }

    memcpy(p_B, p_M, len);              // Copy remaining bytes into block

    uint8_t * bp = (uint8_t*)p_B;
    bp[len++] = 0x80;                   // Append `1` to end of message

    if(len > 112) {                     // Do we spill into another block?
        memset(bp+len, 0, 128-len);     // If yes, clear rest of this block
        sha512_hash_block(p_H, p_B);    // Length will be added in a new block
        len = 0;                        //
    }

    size_t i = 128;
    while(len_bits) {                   // Add length to end of this block
        bp[--i] = len_bits  & 0xFF;
        len_bits= len_bits >>    8;
    }

    memset(bp + len, 0, i-len);         // Clear fstart of block/EoM to len

    sha512_hash_block(p_H,p_B);

    for(size_t i = 0; i < 8; i ++) {    // Store result in big endian
        uint64_t x = p_H[i];
        SHA512_STORE64_BE(x,H,i);
    }
}

void sha512_hash_vec (
    uint64_t    H[ 8], //!< in,out - message block hash
    uint8_t   * M    , //!< in - The message to be hashed
    size_t      len    //!< Length of the message in *bytes*.
){
    uint64_t   p_H        [ 8];
    uint64_t   H_unordered[ 8];
    uint64_t   p_B        [16];

    uint8_t*   p_M      = M;
    size_t     len_bits = len << 3;

    sha512_hash_init_vec(p_H);

    while(len >= 128) {
        memcpy(p_B, p_M, 128);          // Copy 128 bytes / 1024 bits . 

        sha512_block_lmul1((uint8_t*)(p_H), p_B);   // Digest another block

        p_M += 128;                     // Adjust pointers and length.
        len -= 128;
    }

    memcpy(p_B, p_M, len);              // Copy remaining bytes into block

    uint8_t * bp = (uint8_t*)p_B;
    bp[len++] = 0x80;                   // Append `1` to end of message

    if(len > 112) {                     // Do we spill into another block?
        memset(bp+len, 0, 128-len);     // If yes, clear rest of this block
        sha512_block_lmul1((uint8_t*)(p_H), p_B);    // Length will be added in a new block
        len = 0;                        //
    }

    size_t i = 128;
    while(len_bits) {                   // Add length to end of this block
        bp[--i] = len_bits  & 0xFF;
        len_bits= len_bits >>    8;
    }

    memset(bp + len, 0, i-len);         // Clear fstart of block/EoM to len

    sha512_block_lmul1((uint8_t*)(p_H),p_B);

    for(size_t i = 0; i < 8; i ++) {    // Store result in big endian
        uint64_t x = p_H[i];
        SHA512_STORE64_BE(x,H_unordered,i);
    }

    // reorder hash words to match scalar digest ordering
    H[0] = H_unordered[3];
    H[1] = H_unordered[2];
    H[2] = H_unordered[7];
    H[3] = H_unordered[6];
    H[4] = H_unordered[1];
    H[5] = H_unordered[0];
    H[6] = H_unordered[5];
    H[7] = H_unordered[4];
}

/**********************************OpenSSL*************************************/

static const SHA_LONG64 K512[80] = {
    U64(0x428a2f98d728ae22), U64(0x7137449123ef65cd),
    U64(0xb5c0fbcfec4d3b2f), U64(0xe9b5dba58189dbbc),
    U64(0x3956c25bf348b538), U64(0x59f111f1b605d019),
    U64(0x923f82a4af194f9b), U64(0xab1c5ed5da6d8118),
    U64(0xd807aa98a3030242), U64(0x12835b0145706fbe),
    U64(0x243185be4ee4b28c), U64(0x550c7dc3d5ffb4e2),
    U64(0x72be5d74f27b896f), U64(0x80deb1fe3b1696b1),
    U64(0x9bdc06a725c71235), U64(0xc19bf174cf692694),
    U64(0xe49b69c19ef14ad2), U64(0xefbe4786384f25e3),
    U64(0x0fc19dc68b8cd5b5), U64(0x240ca1cc77ac9c65),
    U64(0x2de92c6f592b0275), U64(0x4a7484aa6ea6e483),
    U64(0x5cb0a9dcbd41fbd4), U64(0x76f988da831153b5),
    U64(0x983e5152ee66dfab), U64(0xa831c66d2db43210),
    U64(0xb00327c898fb213f), U64(0xbf597fc7beef0ee4),
    U64(0xc6e00bf33da88fc2), U64(0xd5a79147930aa725),
    U64(0x06ca6351e003826f), U64(0x142929670a0e6e70),
    U64(0x27b70a8546d22ffc), U64(0x2e1b21385c26c926),
    U64(0x4d2c6dfc5ac42aed), U64(0x53380d139d95b3df),
    U64(0x650a73548baf63de), U64(0x766a0abb3c77b2a8),
    U64(0x81c2c92e47edaee6), U64(0x92722c851482353b),
    U64(0xa2bfe8a14cf10364), U64(0xa81a664bbc423001),
    U64(0xc24b8b70d0f89791), U64(0xc76c51a30654be30),
    U64(0xd192e819d6ef5218), U64(0xd69906245565a910),
    U64(0xf40e35855771202a), U64(0x106aa07032bbd1b8),
    U64(0x19a4c116b8d2d0c8), U64(0x1e376c085141ab53),
    U64(0x2748774cdf8eeb99), U64(0x34b0bcb5e19b48a8),
    U64(0x391c0cb3c5c95a63), U64(0x4ed8aa4ae3418acb),
    U64(0x5b9cca4f7763e373), U64(0x682e6ff3d6b2b8a3),
    U64(0x748f82ee5defb2fc), U64(0x78a5636f43172f60),
    U64(0x84c87814a1f0ab72), U64(0x8cc702081a6439ec),
    U64(0x90befffa23631e28), U64(0xa4506cebde82bde9),
    U64(0xbef9a3f7b2c67915), U64(0xc67178f2e372532b),
    U64(0xca273eceea26619c), U64(0xd186b8c721c0c207),
    U64(0xeada7dd6cde0eb1e), U64(0xf57d4f7fee6ed178),
    U64(0x06f067aa72176fba), U64(0x0a637dc5a2c898a6),
    U64(0x113f9804bef90dae), U64(0x1b710b35131c471b),
    U64(0x28db77f523047d84), U64(0x32caab7b40c72493),
    U64(0x3c9ebe0a15c9bebc), U64(0x431d67c49c100d4c),
    U64(0x4cc5d4becb3e42b6), U64(0x597f299cfc657e2a),
    U64(0x5fcb6fab3ad6faec), U64(0x6c44198c4a475817)
};


#ifdef INCLUDE_C_SHA512
void sha512_block_data_order_c(SHA512_CTX *ctx, const void *in, size_t num)
#else
static void sha512_block_data_order(SHA512_CTX *ctx, const void *in,
                                    size_t num)
#endif
{
    const SHA_LONG64 *W = in;
    SHA_LONG64 a, b, c, d, e, f, g, h, s0, s1, T1;
    SHA_LONG64 X[16];
    int i;

    while (num--) {

        a = ctx->h[0];
        b = ctx->h[1];
        c = ctx->h[2];
        d = ctx->h[3];
        e = ctx->h[4];
        f = ctx->h[5];
        g = ctx->h[6];
        h = ctx->h[7];

#  ifdef B_ENDIAN
        T1 = X[0] = W[0];
        ROUND_00_15_512(0, a, b, c, d, e, f, g, h);
        T1 = X[1] = W[1];
        ROUND_00_15_512(1, h, a, b, c, d, e, f, g);
        T1 = X[2] = W[2];
        ROUND_00_15_512(2, g, h, a, b, c, d, e, f);
        T1 = X[3] = W[3];
        ROUND_00_15_512(3, f, g, h, a, b, c, d, e);
        T1 = X[4] = W[4];
        ROUND_00_15_512(4, e, f, g, h, a, b, c, d);
        T1 = X[5] = W[5];
        ROUND_00_15_512(5, d, e, f, g, h, a, b, c);
        T1 = X[6] = W[6];
        ROUND_00_15_512(6, c, d, e, f, g, h, a, b);
        T1 = X[7] = W[7];
        ROUND_00_15_512(7, b, c, d, e, f, g, h, a);
        T1 = X[8] = W[8];
        ROUND_00_15_512(8, a, b, c, d, e, f, g, h);
        T1 = X[9] = W[9];
        ROUND_00_15_512(9, h, a, b, c, d, e, f, g);
        T1 = X[10] = W[10];
        ROUND_00_15_512(10, g, h, a, b, c, d, e, f);
        T1 = X[11] = W[11];
        ROUND_00_15_512(11, f, g, h, a, b, c, d, e);
        T1 = X[12] = W[12];
        ROUND_00_15_512(12, e, f, g, h, a, b, c, d);
        T1 = X[13] = W[13];
        ROUND_00_15_512(13, d, e, f, g, h, a, b, c);
        T1 = X[14] = W[14];
        ROUND_00_15_512(14, c, d, e, f, g, h, a, b);
        T1 = X[15] = W[15];
        ROUND_00_15_512(15, b, c, d, e, f, g, h, a);
#  else
        T1 = X[0] = PULL64(W[0]);
        ROUND_00_15_512(0, a, b, c, d, e, f, g, h);
        T1 = X[1] = PULL64(W[1]);
        ROUND_00_15_512(1, h, a, b, c, d, e, f, g);
        T1 = X[2] = PULL64(W[2]);
        ROUND_00_15_512(2, g, h, a, b, c, d, e, f);
        T1 = X[3] = PULL64(W[3]);
        ROUND_00_15_512(3, f, g, h, a, b, c, d, e);
        T1 = X[4] = PULL64(W[4]);
        ROUND_00_15_512(4, e, f, g, h, a, b, c, d);
        T1 = X[5] = PULL64(W[5]);
        ROUND_00_15_512(5, d, e, f, g, h, a, b, c);
        T1 = X[6] = PULL64(W[6]);
        ROUND_00_15_512(6, c, d, e, f, g, h, a, b);
        T1 = X[7] = PULL64(W[7]);
        ROUND_00_15_512(7, b, c, d, e, f, g, h, a);
        T1 = X[8] = PULL64(W[8]);
        ROUND_00_15_512(8, a, b, c, d, e, f, g, h);
        T1 = X[9] = PULL64(W[9]);
        ROUND_00_15_512(9, h, a, b, c, d, e, f, g);
        T1 = X[10] = PULL64(W[10]);
        ROUND_00_15_512(10, g, h, a, b, c, d, e, f);
        T1 = X[11] = PULL64(W[11]);
        ROUND_00_15_512(11, f, g, h, a, b, c, d, e);
        T1 = X[12] = PULL64(W[12]);
        ROUND_00_15_512(12, e, f, g, h, a, b, c, d);
        T1 = X[13] = PULL64(W[13]);
        ROUND_00_15_512(13, d, e, f, g, h, a, b, c);
        T1 = X[14] = PULL64(W[14]);
        ROUND_00_15_512(14, c, d, e, f, g, h, a, b);
        T1 = X[15] = PULL64(W[15]);
        ROUND_00_15_512(15, b, c, d, e, f, g, h, a);
#  endif

        for (i = 16; i < 80; i += 16) {
            ROUND_16_80_512(i, 0, a, b, c, d, e, f, g, h, X);
            ROUND_16_80_512(i, 1, h, a, b, c, d, e, f, g, X);
            ROUND_16_80_512(i, 2, g, h, a, b, c, d, e, f, X);
            ROUND_16_80_512(i, 3, f, g, h, a, b, c, d, e, X);
            ROUND_16_80_512(i, 4, e, f, g, h, a, b, c, d, X);
            ROUND_16_80_512(i, 5, d, e, f, g, h, a, b, c, X);
            ROUND_16_80_512(i, 6, c, d, e, f, g, h, a, b, X);
            ROUND_16_80_512(i, 7, b, c, d, e, f, g, h, a, X);
            ROUND_16_80_512(i, 8, a, b, c, d, e, f, g, h, X);
            ROUND_16_80_512(i, 9, h, a, b, c, d, e, f, g, X);
            ROUND_16_80_512(i, 10, g, h, a, b, c, d, e, f, X);
            ROUND_16_80_512(i, 11, f, g, h, a, b, c, d, e, X);
            ROUND_16_80_512(i, 12, e, f, g, h, a, b, c, d, X);
            ROUND_16_80_512(i, 13, d, e, f, g, h, a, b, c, X);
            ROUND_16_80_512(i, 14, c, d, e, f, g, h, a, b, X);
            ROUND_16_80_512(i, 15, b, c, d, e, f, g, h, a, X);
        }

        ctx->h[0] += a;
        ctx->h[1] += b;
        ctx->h[2] += c;
        ctx->h[3] += d;
        ctx->h[4] += e;
        ctx->h[5] += f;
        ctx->h[6] += g;
        ctx->h[7] += h;

        W += SHA_LBLOCK;
    }
}

void sha512_block_data_order(SHA512_CTX *ctx, const void *in, size_t num)
{
    //if (RISCV_HAS_ZVKB_AND_ZVKNHB() && riscv_vlen() >= 128) {
    //    sha512_block_data_order_zvkb_zvknhb(ctx, in, num);
    //} else {
        sha512_block_data_order_c(ctx, in, num);
    //}
}

int SHA512_Init(SHA512_CTX *c)
{
    c->h[0] = U64(0x6a09e667f3bcc908);
    c->h[1] = U64(0xbb67ae8584caa73b);
    c->h[2] = U64(0x3c6ef372fe94f82b);
    c->h[3] = U64(0xa54ff53a5f1d36f1);
    c->h[4] = U64(0x510e527fade682d1);
    c->h[5] = U64(0x9b05688c2b3e6c1f);
    c->h[6] = U64(0x1f83d9abfb41bd6b);
    c->h[7] = U64(0x5be0cd19137e2179);

    c->Nl = 0;
    c->Nh = 0;
    c->num = 0;
    c->md_len = SHA512_DIGEST_LENGTH;
    return 1;
}


int SHA512_Update(SHA512_CTX *c, const void *_data, size_t len)
{
    SHA_LONG64 l;
    unsigned char *p = c->u.p;
    const unsigned char *data = (const unsigned char *)_data;

    if (len == 0)
        return 1;

    l = (c->Nl + (((SHA_LONG64) len) << 3)) & U64(0xffffffffffffffff);
    if (l < c->Nl)
        c->Nh++;
    if (sizeof(len) >= 8)
        c->Nh += (((SHA_LONG64) len) >> 61);
    c->Nl = l;

    if (c->num != 0) {
        size_t n = sizeof(c->u) - c->num;

        if (len < n) {
            memcpy(p + c->num, data, len), c->num += (unsigned int)len;
            return 1;
        } else {
            memcpy(p + c->num, data, n), c->num = 0;
            len -= n, data += n;
            sha512_block_data_order(c, p, 1);
        }
    }

    if (len >= sizeof(c->u)) {
#ifndef SHA512_BLOCK_CAN_MANAGE_UNALIGNED_DATA
        if ((size_t)data % sizeof(c->u.d[0]) != 0)
            while (len >= sizeof(c->u))
                memcpy(p, data, sizeof(c->u)),
                sha512_block_data_order(c, p, 1),
                len -= sizeof(c->u), data += sizeof(c->u);
        else
#endif
            sha512_block_data_order(c, data, len / sizeof(c->u)),
            data += len, len %= sizeof(c->u), data -= len;
    }

    if (len != 0)
        memcpy(p, data, len), c->num = (int)len;

    return 1;
}

int SHA512_Final(unsigned char *md, SHA512_CTX *c)
{
    unsigned char *p = (unsigned char *)c->u.p;
    size_t n = c->num;

    p[n] = 0x80;                /* There always is a room for one */
    n++;
    if (n > (sizeof(c->u) - 16)) {
        memset(p + n, 0, sizeof(c->u) - n);
        n = 0;
        sha512_block_data_order(c, p, 1);
    }

    memset(p + n, 0, sizeof(c->u) - 16 - n);
#ifdef  B_ENDIAN
    c->u.d[SHA_LBLOCK - 2] = c->Nh;
    c->u.d[SHA_LBLOCK - 1] = c->Nl;
#else
    p[sizeof(c->u) - 1] = (unsigned char)(c->Nl);
    p[sizeof(c->u) - 2] = (unsigned char)(c->Nl >> 8);
    p[sizeof(c->u) - 3] = (unsigned char)(c->Nl >> 16);
    p[sizeof(c->u) - 4] = (unsigned char)(c->Nl >> 24);
    p[sizeof(c->u) - 5] = (unsigned char)(c->Nl >> 32);
    p[sizeof(c->u) - 6] = (unsigned char)(c->Nl >> 40);
    p[sizeof(c->u) - 7] = (unsigned char)(c->Nl >> 48);
    p[sizeof(c->u) - 8] = (unsigned char)(c->Nl >> 56);
    p[sizeof(c->u) - 9] = (unsigned char)(c->Nh);
    p[sizeof(c->u) - 10] = (unsigned char)(c->Nh >> 8);
    p[sizeof(c->u) - 11] = (unsigned char)(c->Nh >> 16);
    p[sizeof(c->u) - 12] = (unsigned char)(c->Nh >> 24);
    p[sizeof(c->u) - 13] = (unsigned char)(c->Nh >> 32);
    p[sizeof(c->u) - 14] = (unsigned char)(c->Nh >> 40);
    p[sizeof(c->u) - 15] = (unsigned char)(c->Nh >> 48);
    p[sizeof(c->u) - 16] = (unsigned char)(c->Nh >> 56);
#endif

    sha512_block_data_order(c, p, 1);

    if (md == 0)
        return 0;

    switch (c->md_len) {
    /* Let compiler decide if it's appropriate to unroll... */
    case SHA224_DIGEST_LENGTH:
        for (n = 0; n < SHA224_DIGEST_LENGTH / 8; n++) {
            SHA_LONG64 t = c->h[n];

            *(md++) = (unsigned char)(t >> 56);
            *(md++) = (unsigned char)(t >> 48);
            *(md++) = (unsigned char)(t >> 40);
            *(md++) = (unsigned char)(t >> 32);
            *(md++) = (unsigned char)(t >> 24);
            *(md++) = (unsigned char)(t >> 16);
            *(md++) = (unsigned char)(t >> 8);
            *(md++) = (unsigned char)(t);
        }
        /*
         * For 224 bits, there are four bytes left over that have to be
         * processed separately.
         */
        {
            SHA_LONG64 t = c->h[SHA224_DIGEST_LENGTH / 8];

            *(md++) = (unsigned char)(t >> 56);
            *(md++) = (unsigned char)(t >> 48);
            *(md++) = (unsigned char)(t >> 40);
            *(md++) = (unsigned char)(t >> 32);
        }
        break;
    case SHA256_DIGEST_LENGTH:
        for (n = 0; n < SHA256_DIGEST_LENGTH / 8; n++) {
            SHA_LONG64 t = c->h[n];

            *(md++) = (unsigned char)(t >> 56);
            *(md++) = (unsigned char)(t >> 48);
            *(md++) = (unsigned char)(t >> 40);
            *(md++) = (unsigned char)(t >> 32);
            *(md++) = (unsigned char)(t >> 24);
            *(md++) = (unsigned char)(t >> 16);
            *(md++) = (unsigned char)(t >> 8);
            *(md++) = (unsigned char)(t);
        }
        break;
    case SHA384_DIGEST_LENGTH:
        for (n = 0; n < SHA384_DIGEST_LENGTH / 8; n++) {
            SHA_LONG64 t = c->h[n];

            *(md++) = (unsigned char)(t >> 56);
            *(md++) = (unsigned char)(t >> 48);
            *(md++) = (unsigned char)(t >> 40);
            *(md++) = (unsigned char)(t >> 32);
            *(md++) = (unsigned char)(t >> 24);
            *(md++) = (unsigned char)(t >> 16);
            *(md++) = (unsigned char)(t >> 8);
            *(md++) = (unsigned char)(t);
        }
        break;
    case SHA512_DIGEST_LENGTH:
        for (n = 0; n < SHA512_DIGEST_LENGTH / 8; n++) {
            SHA_LONG64 t = c->h[n];

            *(md++) = (unsigned char)(t >> 56);
            *(md++) = (unsigned char)(t >> 48);
            *(md++) = (unsigned char)(t >> 40);
            *(md++) = (unsigned char)(t >> 32);
            *(md++) = (unsigned char)(t >> 24);
            *(md++) = (unsigned char)(t >> 16);
            *(md++) = (unsigned char)(t >> 8);
            *(md++) = (unsigned char)(t);
        }
        break;
    /* ... as well as make sure md_len is not abused. */
    default:
        return 0;
    }

    return 1;
}
