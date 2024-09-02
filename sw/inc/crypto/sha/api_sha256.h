
#ifndef __API_SHA256__
#define __API_SHA256__

#include <stdint.h>
#include <stddef.h>

#include "crypto/share/util.h"

// Add a single message block to the current hash digest.
void sha256_hash (
  uint32_t  H[8],  // in,out - message block hash
  uint8_t*  M,     // in - The message to be hashed
  size_t    len    // Length of the message in *bytes*.
);

// Add a single message block to the current hash digest (using zvknh).
void sha256_hash_vec (
  uint32_t  H[8],  // in,out - message block hash
  uint8_t*  M,     // in - The message to be hashed
  size_t    len    // Length of the message in *bytes*.
);

void sha256_hash_init (
    uint32_t    H [8]  // out - message block hash
);

void sha256_hash_block (
    uint32_t    H[ 8], // in,out - message block hash
    uint32_t    M[16]  // in - The message block to add to the hash
);

/**********************************OpenSSL*************************************/

#define INCLUDE_C_SHA256 //Todo: What do you do?

#define DECLARE_IS_ENDIAN const int ossl_is_little_endian = __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
#define IS_LITTLE_ENDIAN (ossl_is_little_endian)
#define IS_BIG_ENDIAN (!ossl_is_little_endian)

#define MD32_REG_T int

#define SHA_LONG unsigned int

#define SHA_LBLOCK      16
#define SHA_CBLOCK      (SHA_LBLOCK*4)/* SHA treats input data as a
                                         * contiguous array of 32 bit wide
                                         * big-endian values. */
#define SHA256_CBLOCK   (SHA_LBLOCK*4)/* SHA-256 treats input data as a
                                        * contiguous array of 32 bit wide
                                        * big-endian values. */
#define SHA_LAST_BLOCK  (SHA_CBLOCK-8)
#define SHA256_DIGEST_LENGTH    32
#define SHA512_DIGEST_LENGTH    64

#define ROTATE(a,n)     (((a)<<(n))|(((a)&0xffffffff)>>(32-(n))))
#define Ch(x,y,z)       (((x) & (y)) ^ ((~(x)) & (z)))
#define Sigma0(x)       (ROTATE((x),30) ^ ROTATE((x),19) ^ ROTATE((x),10))
#define Sigma1(x) (ROTATE((x),26) ^ ROTATE((x),21) ^ ROTATE((x),7))
#define sigma0(x)       (ROTATE((x),25) ^ ROTATE((x),14) ^ ((x)>>3))
#define sigma1(x)       (ROTATE((x),15) ^ ROTATE((x),13) ^ ((x)>>10))

#define Maj(x,y,z)      (((x) & (y)) ^ ((x) & (z)) ^ ((y) & (z)))

#define ROUND_00_15(i,a,b,c,d,e,f,g,h)          do {    \
        T1 += h + Sigma1(e) + Ch(e,f,g) + K256[i];      \
        h = Sigma0(a) + Maj(a,b,c);                     \
        d += T1;        h += T1;                } while (0)

#define ROUND_16_63(i,a,b,c,d,e,f,g,h,X)        do {    \
        s0 = X[(i+1)&0x0f];     s0 = sigma0(s0);        \
        s1 = X[(i+14)&0x0f];    s1 = sigma1(s1);        \
        T1 = X[(i)&0x0f] += s0 + s1 + X[(i+9)&0x0f];    \
        ROUND_00_15(i,a,b,c,d,e,f,g,h);         } while (0)

#  define HOST_c2l(c,l)  (l =(((unsigned long)(*((c)++)))<<24),          \
                         l|=(((unsigned long)(*((c)++)))<<16),          \
                         l|=(((unsigned long)(*((c)++)))<< 8),          \
                         l|=(((unsigned long)(*((c)++)))    )           )
#  define HOST_l2c(l,c)  (*((c)++)=(unsigned char)(((l)>>24)&0xff),      \
                         *((c)++)=(unsigned char)(((l)>>16)&0xff),      \
                         *((c)++)=(unsigned char)(((l)>> 8)&0xff),      \
                         *((c)++)=(unsigned char)(((l)    )&0xff),      \
                         l)

typedef struct SHA256state_st {
    SHA_LONG h[8];
    SHA_LONG Nl, Nh;
    SHA_LONG data[SHA_LBLOCK];
    unsigned int num, md_len;
} SHA256_CTX;

// A crypto_md32_block_func should incorporate |num_blocks| of input from |data|
// into |state|. It is assumed the caller has sized |state| and |data| for the
// hash function.
typedef void (*crypto_md32_block_func)(uint32_t *state, const uint8_t *data, size_t num_blocks);

int SHA256_Init(SHA256_CTX *c);
int SHA256_Update(SHA256_CTX *c, const void *data, size_t len);
int SHA256_Final(uint8_t out[SHA256_DIGEST_LENGTH], SHA256_CTX *c);

#endif // __API_SHA256__
