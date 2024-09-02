

#ifndef __API_SHA512__
#define __API_SHA512__

#include <stdint.h>
#include <stddef.h>

#include "crypto/share/util.h"

// Hash a message using SHA512
void sha512_hash (
  uint64_t  H[8], // in,out - message block hash
  uint8_t*  M   , // in - The message to be hashed
  size_t    len   // Length of the message in *bytes*.
);

// Hash a message using SHA512 (using zvknh).
void sha512_hash_vec (
  uint64_t  H[8], // in,out - message block hash
  uint8_t*  M   , // in - The message to be hashed
  size_t    len   // Length of the message in *bytes*.
);

void sha512_hash_init (
    uint64_t    H [8]  // out - message block hash
);

void sha512_hash_block (
    uint64_t    H[ 8], // in,out - message block hash
    uint64_t    M[16]  // in - The message block to add to the hash
);

/**********************************OpenSSL*************************************/

#define INCLUDE_C_SHA512 //Todo: What do you do?

#define SHA_LONG unsigned int

#define SHA_LBLOCK      16
#define SHA_CBLOCK      (SHA_LBLOCK*4)/* SHA treats input data as a
                                         * contiguous array of 32 bit wide
                                         * big-endian values. */
#define SHA_LAST_BLOCK  (SHA_CBLOCK-8)

#define SHA512_CBLOCK   (SHA_LBLOCK*8)
#if (defined(_WIN32) || defined(_WIN64)) && !defined(__MINGW32__)
# define SHA_LONG64 unsigned __int64
#elif defined(__arch64__)
# define SHA_LONG64 unsigned long
#else
# define SHA_LONG64 unsigned long long
#endif

#define U64(C) C##ULL

#define B(x,j)    (((SHA_LONG64)(*(((const unsigned char *)(&x))+j)))<<((7-j)*8))
#define PULL64(x) (B(x,0)|B(x,1)|B(x,2)|B(x,3)|B(x,4)|B(x,5)|B(x,6)|B(x,7))
#define ROTR(x,s)       (((x)>>s) | (x)<<(64-s))
#define Sigma0_512(x)   (ROTR((x),28) ^ ROTR((x),34) ^ ROTR((x),39))
#define Sigma1_512(x)   (ROTR((x),14) ^ ROTR((x),18) ^ ROTR((x),41))
#define sigma0_512(x)   (ROTR((x),1)  ^ ROTR((x),8)  ^ ((x)>>7))
#define sigma1_512(x)   (ROTR((x),19) ^ ROTR((x),61) ^ ((x)>>6))
#define Ch(x,y,z)       (((x) & (y)) ^ ((~(x)) & (z)))
#define Maj_512(x,y,z)      (((x) & (y)) ^ ((x) & (z)) ^ ((y) & (z)))

#define ROUND_00_15_512(i,a,b,c,d,e,f,g,h)        do {    \
        T1 += h + Sigma1_512(e) + Ch(e,f,g) + K512[i];      \
        h = Sigma0_512(a) + Maj_512(a,b,c);                     \
        d += T1;        h += T1;                        } while (0)

#define ROUND_16_80_512(i,j,a,b,c,d,e,f,g,h,X)    do {    \
        s0 = X[(j+1)&0x0f];     s0 = sigma0_512(s0);        \
        s1 = X[(j+14)&0x0f];    s1 = sigma1_512(s1);        \
        T1 = X[(j)&0x0f] += s0 + s1 + X[(j+9)&0x0f];    \
        ROUND_00_15_512(i+j,a,b,c,d,e,f,g,h);               } while (0)


#define SHA256_192_DIGEST_LENGTH 24
#define SHA224_DIGEST_LENGTH    28
#define SHA256_DIGEST_LENGTH    32
#define SHA384_DIGEST_LENGTH    48
#define SHA512_DIGEST_LENGTH    64

typedef struct SHA512state_st {
    SHA_LONG64 h[8];
    SHA_LONG64 Nl, Nh;
    union {
        SHA_LONG64 d[SHA_LBLOCK];
        unsigned char p[SHA512_CBLOCK];
    } u;
    unsigned int num, md_len;
} SHA512_CTX;

int SHA512_Init(SHA512_CTX *c);
int SHA512_Update(SHA512_CTX *c, const void *_data, size_t len);
int SHA512_Final(unsigned char *md, SHA512_CTX *c);

#endif // __API_SHA512__
