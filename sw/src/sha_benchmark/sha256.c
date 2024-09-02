
#include <stdio.h>
#include <string.h>

#include "crypto/sha/api_sha256.h"
#include "crypto/sha/zvknh.h"

static uint32_t K [64] = {
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1,
    0x923f82a4, 0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
    0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786,
    0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147,
    0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
    0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b,
    0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a,
    0x5b9cca4f, 0x682e6ff3, 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
    0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
};

void sha256_hash_init_vec (
    uint32_t    H [8]  //!< out - message block hash
){
    H[0] = 0X9B05688C;
    H[1] = 0X510E527F;
    H[2] = 0XBB67AE85;
    H[3] = 0X6A09E667;
    H[4] = 0X5BE0CD19;
    H[5] = 0X1F83D9AB;
    H[6] = 0XA54FF53A;
    H[7] = 0X3C6EF372;
}

void sha256_hash_init (
    uint32_t    H [8]  //!< out - message block hash
){
    H[0] = 0x6a09e667;
    H[1] = 0xbb67ae85;
    H[2] = 0x3c6ef372;
    H[3] = 0xa54ff53a;
    H[4] = 0x510e527f;
    H[5] = 0x9b05688c;
    H[6] = 0x1f83d9ab;
    H[7] = 0x5be0cd19;
}

#define SHA256_LOAD32_BE(X, A, I) {    \
    X = ((uint32_t*)A)[I];             \
    X = (((X >>  0) & 0xFF) << 24) |   \
        (((X >>  8) & 0xFF) << 16) |   \
        (((X >> 16) & 0xFF) <<  8) |   \
        (((X >> 24) & 0xFF) <<  0) ;   \
}

#define SHA256_STORE32_BE(X, A, I) {    \
    A[I] = \
        (((X >>  0) & 0xFF) << 24) |   \
        (((X >>  8) & 0xFF) << 16) |   \
        (((X >> 16) & 0xFF) <<  8) |   \
        (((X >> 24) & 0xFF) <<  0) ;   \
}


#define ROR32(X,Y) ((X>>Y) | (X << (32-Y)))
#define SHR32(X,Y) ((X>>Y)                )

#define CH(X,Y,Z)  ((X&Y)^(~X&Z))
#define MAJ(X,Y,Z) ((X&Y)^(X&Z)^(Y&Z))

#define SUM_0(X)   (ROR32(X, 2) ^ ROR32(X,13) ^ ROR32(X,22))
#define SUM_1(X)   (ROR32(X, 6) ^ ROR32(X,11) ^ ROR32(X,25))

#define SIGMA_0(X) (ROR32(X, 7) ^ ROR32(X,18) ^ SHR32(X, 3))
#define SIGMA_1(X) (ROR32(X,17) ^ ROR32(X,19) ^ SHR32(X,10))

#define ROUND(A,B,C,D,E,F,G,H,K,W) { \
    H  = H + SUM_1(E) + CH(E,F,G) + K + W   ; \
    D  = D + H                              ; \
    H  = H + SUM_0(A) + MAJ(A,B,C)          ; \
}

#define SCHEDULE(M0,M1,M9,ME) { \
    M0 = SIGMA_1(ME) + M9 + SIGMA_0(M1) + M0; \
}

void sha256_hash_block (
    uint32_t    H[ 8], // in,out - message block hash
    uint32_t    M[16]  // in - The message block to add to the hash
){
    uint32_t    a,b,c,d,e,f,g,h ;   // Working variables.

    a   =   H[0];                   // Initialise working variables.
    b   =   H[1];
    c   =   H[2];
    d   =   H[3];
    e   =   H[4];
    f   =   H[5];
    g   =   H[6];
    h   =   H[7];

    uint32_t m0, m1, m2, m3, m4, m5, m6, m7, m8, m9, ma, mb, mc, md, me, mf;

    SHA256_LOAD32_BE(m0, M,  0);
    SHA256_LOAD32_BE(m1, M,  1);
    SHA256_LOAD32_BE(m2, M,  2);
    SHA256_LOAD32_BE(m3, M,  3);
    SHA256_LOAD32_BE(m4, M,  4);
    SHA256_LOAD32_BE(m5, M,  5);
    SHA256_LOAD32_BE(m6, M,  6);
    SHA256_LOAD32_BE(m7, M,  7);
    SHA256_LOAD32_BE(m8, M,  8);
    SHA256_LOAD32_BE(m9, M,  9);
    SHA256_LOAD32_BE(ma, M, 10);
    SHA256_LOAD32_BE(mb, M, 11);
    SHA256_LOAD32_BE(mc, M, 12);
    SHA256_LOAD32_BE(md, M, 13);
    SHA256_LOAD32_BE(me, M, 14);
    SHA256_LOAD32_BE(mf, M, 15);

    uint32_t *kp = K     ;
    uint32_t *ke = K + 48;

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


void sha256_hash (
    uint32_t    H[ 8], //!< in,out - message block hash
    uint8_t   * M    , //!< in - The message to be hashed
    size_t      len    //!< Length of the message in *bytes*.
){
    uint32_t   p_H[ 8] ;
    uint32_t   p_B[16] ;
    uint8_t  * p_M     = M ;

    size_t     len_bits= len << 3;

    sha256_hash_init(p_H);

    while(len >= 64) {
        memcpy(p_B, p_M, 64);           // Copy 64 bytes/512 bits to process. 

        sha256_hash_block (p_H, p_B);   // Digest another block

        p_M += 64;                      // Adjust pointers and length.
        len -= 64;
    }

    memcpy(p_B, p_M, len);              // Copy remaining bytes into block

    uint8_t * bp = (uint8_t*)p_B;
    bp[len++] = 0x80;                   // Append `1` to end of message

    if(len > 56) {                      // Do we spill into another block?
        memset(bp+len, 0, 64-len);      // If yes, clear rest of this block
        sha256_hash_block(p_H, p_B);    // Length will be added in a new block
        len = 0;                        //
    }

    size_t i = 64;
    while(len_bits) {                   // Add length to end of this block
        bp[--i] = len_bits  & 0xFF;
        len_bits= len_bits >>    8;
    }

    memset(bp + len, 0, i-len);         // Clear fstart of block/EoM to len

    sha256_hash_block(p_H,p_B);

    for(size_t i = 0; i < 8; i ++) {    // Store result in big endian
        uint32_t x = p_H[i];
        SHA256_STORE32_BE(x,H,i);
    }
}

void sha256_hash_vec (
    uint32_t    H[ 8], //!< in,out - message block hash
    uint8_t*    M    , //!< in - The message to be hashed
    size_t      len    //!< Length of the message in *bytes*.
){
    uint32_t   p_H        [ 8];
    uint32_t   H_unordered[ 8];
    uint32_t   p_B        [16];

    uint8_t*   p_M      = M ;
    size_t     len_bits = len << 3;

    sha256_hash_init_vec(p_H);

    while(len >= 64) {
        memcpy(p_B, p_M, 64);           // Copy 64 bytes/512 bits to process. 

        sha256_block_lmul1((uint8_t*)(p_H), p_B);   // Digest another block

        p_M += 64;                      // Adjust pointers and length.
        len -= 64;
    }

    memcpy(p_B, p_M, len);              // Copy remaining bytes into block

    uint8_t * bp = (uint8_t*)p_B;
    bp[len++] = 0x80;                   // Append `1` to end of message

    if(len > 56) {                      // Do we spill into another block?
        memset(bp+len, 0, 64-len);      // If yes, clear rest of this block
        sha256_block_lmul1((uint8_t*)(p_H), p_B);    // Length will be added in a new block
        len = 0;                        //
    }

    size_t i = 64;
    while(len_bits) {                   // Add length to end of this block
        bp[--i] = len_bits  & 0xFF;
        len_bits= len_bits >>    8;
    }

    memset(bp + len, 0, i-len);         // Clear fstart of block/EoM to len

    sha256_block_lmul1((uint8_t*)(p_H),p_B);

    for(size_t i = 0; i < 8; i ++) {    // Store result in big endian
        uint32_t x = p_H[i];
        SHA256_STORE32_BE(x,H_unordered,i);
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

static const SHA_LONG K256[64] = {
    0x428a2f98UL, 0x71374491UL, 0xb5c0fbcfUL, 0xe9b5dba5UL,
    0x3956c25bUL, 0x59f111f1UL, 0x923f82a4UL, 0xab1c5ed5UL,
    0xd807aa98UL, 0x12835b01UL, 0x243185beUL, 0x550c7dc3UL,
    0x72be5d74UL, 0x80deb1feUL, 0x9bdc06a7UL, 0xc19bf174UL,
    0xe49b69c1UL, 0xefbe4786UL, 0x0fc19dc6UL, 0x240ca1ccUL,
    0x2de92c6fUL, 0x4a7484aaUL, 0x5cb0a9dcUL, 0x76f988daUL,
    0x983e5152UL, 0xa831c66dUL, 0xb00327c8UL, 0xbf597fc7UL,
    0xc6e00bf3UL, 0xd5a79147UL, 0x06ca6351UL, 0x14292967UL,
    0x27b70a85UL, 0x2e1b2138UL, 0x4d2c6dfcUL, 0x53380d13UL,
    0x650a7354UL, 0x766a0abbUL, 0x81c2c92eUL, 0x92722c85UL,
    0xa2bfe8a1UL, 0xa81a664bUL, 0xc24b8b70UL, 0xc76c51a3UL,
    0xd192e819UL, 0xd6990624UL, 0xf40e3585UL, 0x106aa070UL,
    0x19a4c116UL, 0x1e376c08UL, 0x2748774cUL, 0x34b0bcb5UL,
    0x391c0cb3UL, 0x4ed8aa4aUL, 0x5b9cca4fUL, 0x682e6ff3UL,
    0x748f82eeUL, 0x78a5636fUL, 0x84c87814UL, 0x8cc70208UL,
    0x90befffaUL, 0xa4506cebUL, 0xbef9a3f7UL, 0xc67178f2UL
};

static inline void *OPENSSL_memcpy(void *dst, const void *src, size_t n) {
  if (n == 0) {
    return dst;
  }

  return memcpy(dst, src, n);
}

static inline void *OPENSSL_memset(void *dst, int c, size_t n) {
  if (n == 0) {
    return dst;
  }

  return memset(dst, c, n);
}

static inline uint32_t CRYPTO_bswap4(uint32_t x) {
  return __builtin_bswap32(x);
}

static inline void CRYPTO_store_u32_le(void *out, uint32_t v) {
  OPENSSL_memcpy(out, &v, sizeof(v));
}

static inline void CRYPTO_store_u32_be(void *out, uint32_t v) {
  v = CRYPTO_bswap4(v);
  OPENSSL_memcpy(out, &v, sizeof(v));
}

#ifdef INCLUDE_C_SHA256
void sha256_block_data_order_c(SHA256_CTX *ctx, const void *in, size_t num)
#else
static void sha256_block_data_order(SHA256_CTX *ctx, const void *in,
                                    size_t num)
#endif
{
    unsigned MD32_REG_T a, b, c, d, e, f, g, h, s0, s1, T1;
    SHA_LONG X[16];
    int i;
    const unsigned char *data = in;
    DECLARE_IS_ENDIAN;

    while (num--) {

        a = ctx->h[0];
        b = ctx->h[1];
        c = ctx->h[2];
        d = ctx->h[3];
        e = ctx->h[4];
        f = ctx->h[5];
        g = ctx->h[6];
        h = ctx->h[7];

        if (!IS_LITTLE_ENDIAN && sizeof(SHA_LONG) == 4
            && ((size_t)in % 4) == 0) {
            const SHA_LONG *W = (const SHA_LONG *)data;

            T1 = X[0] = W[0];
            ROUND_00_15(0, a, b, c, d, e, f, g, h);
            T1 = X[1] = W[1];
            ROUND_00_15(1, h, a, b, c, d, e, f, g);
            T1 = X[2] = W[2];
            ROUND_00_15(2, g, h, a, b, c, d, e, f);
            T1 = X[3] = W[3];
            ROUND_00_15(3, f, g, h, a, b, c, d, e);
            T1 = X[4] = W[4];
            ROUND_00_15(4, e, f, g, h, a, b, c, d);
            T1 = X[5] = W[5];
            ROUND_00_15(5, d, e, f, g, h, a, b, c);
            T1 = X[6] = W[6];
            ROUND_00_15(6, c, d, e, f, g, h, a, b);
            T1 = X[7] = W[7];
            ROUND_00_15(7, b, c, d, e, f, g, h, a);
            T1 = X[8] = W[8];
            ROUND_00_15(8, a, b, c, d, e, f, g, h);
            T1 = X[9] = W[9];
            ROUND_00_15(9, h, a, b, c, d, e, f, g);
            T1 = X[10] = W[10];
            ROUND_00_15(10, g, h, a, b, c, d, e, f);
            T1 = X[11] = W[11];
            ROUND_00_15(11, f, g, h, a, b, c, d, e);
            T1 = X[12] = W[12];
            ROUND_00_15(12, e, f, g, h, a, b, c, d);
            T1 = X[13] = W[13];
            ROUND_00_15(13, d, e, f, g, h, a, b, c);
            T1 = X[14] = W[14];
            ROUND_00_15(14, c, d, e, f, g, h, a, b);
            T1 = X[15] = W[15];
            ROUND_00_15(15, b, c, d, e, f, g, h, a);

            data += SHA256_CBLOCK;
        } else {
            SHA_LONG l;

            (void)HOST_c2l(data, l);
            T1 = X[0] = l;
            ROUND_00_15(0, a, b, c, d, e, f, g, h);
            (void)HOST_c2l(data, l);
            T1 = X[1] = l;
            ROUND_00_15(1, h, a, b, c, d, e, f, g);
            (void)HOST_c2l(data, l);
            T1 = X[2] = l;
            ROUND_00_15(2, g, h, a, b, c, d, e, f);
            (void)HOST_c2l(data, l);
            T1 = X[3] = l;
            ROUND_00_15(3, f, g, h, a, b, c, d, e);
            (void)HOST_c2l(data, l);
            T1 = X[4] = l;
            ROUND_00_15(4, e, f, g, h, a, b, c, d);
            (void)HOST_c2l(data, l);
            T1 = X[5] = l;
            ROUND_00_15(5, d, e, f, g, h, a, b, c);
            (void)HOST_c2l(data, l);
            T1 = X[6] = l;
            ROUND_00_15(6, c, d, e, f, g, h, a, b);
            (void)HOST_c2l(data, l);
            T1 = X[7] = l;
            ROUND_00_15(7, b, c, d, e, f, g, h, a);
            (void)HOST_c2l(data, l);
            T1 = X[8] = l;
            ROUND_00_15(8, a, b, c, d, e, f, g, h);
            (void)HOST_c2l(data, l);
            T1 = X[9] = l;
            ROUND_00_15(9, h, a, b, c, d, e, f, g);
            (void)HOST_c2l(data, l);
            T1 = X[10] = l;
            ROUND_00_15(10, g, h, a, b, c, d, e, f);
            (void)HOST_c2l(data, l);
            T1 = X[11] = l;
            ROUND_00_15(11, f, g, h, a, b, c, d, e);
            (void)HOST_c2l(data, l);
            T1 = X[12] = l;
            ROUND_00_15(12, e, f, g, h, a, b, c, d);
            (void)HOST_c2l(data, l);
            T1 = X[13] = l;
            ROUND_00_15(13, d, e, f, g, h, a, b, c);
            (void)HOST_c2l(data, l);
            T1 = X[14] = l;
            ROUND_00_15(14, c, d, e, f, g, h, a, b);
            (void)HOST_c2l(data, l);
            T1 = X[15] = l;
            ROUND_00_15(15, b, c, d, e, f, g, h, a);
        }

        for (i = 16; i < 64; i += 8) {
            ROUND_16_63(i + 0, a, b, c, d, e, f, g, h, X);
            ROUND_16_63(i + 1, h, a, b, c, d, e, f, g, X);
            ROUND_16_63(i + 2, g, h, a, b, c, d, e, f, X);
            ROUND_16_63(i + 3, f, g, h, a, b, c, d, e, X);
            ROUND_16_63(i + 4, e, f, g, h, a, b, c, d, X);
            ROUND_16_63(i + 5, d, e, f, g, h, a, b, c, X);
            ROUND_16_63(i + 6, c, d, e, f, g, h, a, b, X);
            ROUND_16_63(i + 7, b, c, d, e, f, g, h, a, X);
        }

        ctx->h[0] += a;
        ctx->h[1] += b;
        ctx->h[2] += c;
        ctx->h[3] += d;
        ctx->h[4] += e;
        ctx->h[5] += f;
        ctx->h[6] += g;
        ctx->h[7] += h;

    }
}

void sha256_block_data_order(SHA256_CTX *ctx, const void *in, size_t num)
{
    //if (RISCV_HAS_ZVKB() && (RISCV_HAS_ZVKNHA() || RISCV_HAS_ZVKNHB()) &&
    //    riscv_vlen() >= 128) {
    //    sha256_block_data_order_zvkb_zvknha_or_zvknhb(ctx, in, num);
    //} else {
        sha256_block_data_order_c(ctx, in, num);
    //}
}

// crypto_md32_update adds |len| bytes from |in| to the digest. |data| must be a
// buffer of length |block_size| with the first |*num| bytes containing a
// partial block. This function combines the partial block with |in| and
// incorporates any complete blocks into the digest state |h|. It then updates
// |data| and |*num| with the new partial block and updates |*Nh| and |*Nl| with
// the data consumed.
static inline void crypto_md32_update(crypto_md32_block_func block_func,
                                      uint32_t *h, uint8_t *data,
                                      size_t block_size, unsigned *num,
                                      uint32_t *Nh, uint32_t *Nl,
                                      const uint8_t *in, size_t len) {
  if (len == 0) {
    return;
  }

  uint32_t l = *Nl + (((uint32_t)len) << 3);
  if (l < *Nl) {
    // Handle carries.
    (*Nh)++;
  }
  *Nh += (uint32_t)(len >> 29);
  *Nl = l;

  size_t n = *num;
  if (n != 0) {
    if (len >= block_size || len + n >= block_size) {
      OPENSSL_memcpy(data + n, in, block_size - n);
      block_func(h, data, 1);
      n = block_size - n;
      in += n;
      len -= n;
      *num = 0;
      // Keep |data| zeroed when unused.
      OPENSSL_memset(data, 0, block_size);
    } else {
      OPENSSL_memcpy(data + n, in, len);
      *num += (unsigned)len;
      return;
    }
  }

  n = len / block_size;
  if (n > 0) {
    block_func(h, in, n);
    n *= block_size;
    in += n;
    len -= n;
  }

  if (len != 0) {
    *num = (unsigned)len;
    OPENSSL_memcpy(data, in, len);
  }
}

  // crypto_md32_final incorporates the partial block and trailing length into the
// digest state |h|. The trailing length is encoded in little-endian if
// |is_big_endian| is zero and big-endian otherwise. |data| must be a buffer of
// length |block_size| with the first |*num| bytes containing a partial block.
// |Nh| and |Nl| contain the total number of bits processed. On return, this
// function clears the partial block in |data| and
// |*num|.
//
// This function does not serialize |h| into a final digest. This is the
// responsibility of the caller.
static inline void crypto_md32_final(crypto_md32_block_func block_func,
                                     uint32_t *h, uint8_t *data,
                                     size_t block_size, unsigned *num,
                                     uint32_t Nh, uint32_t Nl,
                                     int is_big_endian) {
  // |data| always has room for at least one byte. A full block would have
  // been consumed.
  size_t n = *num;
  //assert(n < block_size);
  data[n] = 0x80;
  n++;

  // Fill the block with zeros if there isn't room for a 64-bit length.
  if (n > block_size - 8) {
    OPENSSL_memset(data + n, 0, block_size - n);
    n = 0;
    block_func(h, data, 1);
  }
  OPENSSL_memset(data + n, 0, block_size - 8 - n);

  // Append a 64-bit length to the block and process it.
  if (is_big_endian) {
    CRYPTO_store_u32_be(data + block_size - 8, Nh);
    CRYPTO_store_u32_be(data + block_size - 4, Nl);
  } else {
    CRYPTO_store_u32_le(data + block_size - 8, Nl);
    CRYPTO_store_u32_le(data + block_size - 4, Nh);
  }
  block_func(h, data, 1);
  *num = 0;
  OPENSSL_memset(data, 0, block_size);
}

static int sha256_final_impl(uint8_t *out, SHA256_CTX *c) {
  crypto_md32_final(&sha256_block_data_order, c->h, c->data, SHA256_CBLOCK,
                    &c->num, c->Nh, c->Nl, /*is_big_endian=*/1);

  // TODO(davidben): This overflow check one of the few places a low-level hash
  // 'final' function can fail. SHA-512 does not have a corresponding check.
  // These functions already misbehave if the caller arbitrarily mutates |c|, so
  // can we assume one of |SHA256_Init| or |SHA224_Init| was used?
  if (c->md_len > SHA256_DIGEST_LENGTH) {
    return 0;
  }

  //assert(c->md_len % 4 == 0);
  const size_t out_words = c->md_len / 4;
  for (size_t i = 0; i < out_words; i++) {
    CRYPTO_store_u32_be(out, c->h[i]);
    out += 4;
  }
  return 1;
}


int SHA256_Init(SHA256_CTX *c)
{
    memset(c, 0, sizeof(*c));
    c->h[0] = 0x6a09e667UL;
    c->h[1] = 0xbb67ae85UL;
    c->h[2] = 0x3c6ef372UL;
    c->h[3] = 0xa54ff53aUL;
    c->h[4] = 0x510e527fUL;
    c->h[5] = 0x9b05688cUL;
    c->h[6] = 0x1f83d9abUL;
    c->h[7] = 0x5be0cd19UL;
    c->md_len = SHA256_DIGEST_LENGTH;
    return 1;
}

int SHA256_Update(SHA256_CTX *c, const void *data, size_t len) {
  crypto_md32_update(&sha256_block_data_order, c->h, c->data, SHA256_CBLOCK,
                     &c->num, &c->Nh, &c->Nl, data, len);
  return 1;
}

int SHA256_Final(uint8_t out[SHA256_DIGEST_LENGTH], SHA256_CTX *c) {
  // Ideally we would assert |sha->md_len| is |SHA256_DIGEST_LENGTH| to match
  // the size hint, but calling code often pairs |SHA224_Init| with
  // |SHA256_Final| and expects |sha->md_len| to carry the size over.
  //
  // TODO(davidben): Add an assert and fix code to match them up.
  return sha256_final_impl(out, c);
}
