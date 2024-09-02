/*
 * File      : sm4_api.h
 * Test      : sm4_benchmark
 * Author(s) : Endrit Isufi <endrit.isufi@tuni.fi
 * Date      : 29-jul-2024
 * Description: Basic benchmarking functions for sm3
 * Based on https://github.com/riscv/riscv-crypto/blob/main/benchmarks/sm4/api_sm4.h
 */

#ifndef __SM4_API_H__
#define __SM4_API_H__

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>


/*
* Generated key expansion from sm4 specs example 1
* With input cipher key: 01 23 45 67 89 AB CD EF FE DC BA 98 76 54 32 10
*/
const uint32_t round_keys_0 [32] = {
   0xF12186F9, 0x41662B61, 0x5A6AB19A, 0x7BA92077,
   0x367360F4, 0x776A0C61, 0xB6BB89B3, 0x24763151,
   0xA520307C, 0xB7584DBD, 0xC30753ED, 0x7EE55B57,
   0x6988608C, 0x30D895B7, 0x44BA14AF, 0x104495A1,
   0xD120B428, 0x73B55FA3, 0xCC874966, 0x92244439,
   0xE89E641F, 0x98CA015A, 0xC7159060, 0x99E1FD2E,
   0xB79BD80C, 0x1D2115B0, 0x0E228AEB, 0xF1780C81,
   0x428D3654, 0x62293496, 0x01CF72E5, 0x9124A012
};

/*
* Generated key expansion from sm4 specs example 1 but reversed for decoding.
*/
const uint32_t round_keys_rev [32] = {
   0x9124A012, 0x01CF72E5, 0x62293496, 0x428D3654,
   0xF1780C81, 0x0E228AEB, 0x1D2115B0, 0xB79BD80C,
   0x99E1FD2E, 0xC7159060, 0x98CA015A, 0xE89E641F,
   0x92244439, 0xCC874966, 0x73B55FA3, 0xD120B428,
   0x104495A1, 0x44BA14AF, 0x30D895B7, 0x6988608C,
   0x7EE55B57, 0xC30753ED, 0xB7584DBD, 0xA520307C,
   0x24763151, 0xB6BB89B3, 0x776A0C61, 0x367360F4,
   0x7BA92077, 0x5A6AB19A, 0x41662B61, 0xF12186F9
};

/*input cipher text from sp4 spec example 1*/
const uint8_t spec_input[16] = {0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF,
                                0xFE, 0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10};



void    sm4_key_schedule_enc (
    uint32_t rk [32], //!< Output expanded round key
    uint8_t  mk [16]  //!< Input cipher key
);

void    sm4_key_schedule_dec (
    uint32_t rk [32], //!< Output expanded round key
    uint8_t  mk [16]  //!< Input cipher key
);

void    sm4_block_enc_dec (
    uint8_t  out [16], // Output block
    uint8_t  in  [16], // Input block
    uint32_t rk  [32]  // Round key (encrypt or decrypt)
);

/*!
@brief SM4 encoding with vector operations, requires pre-expanded round keys
@param [out] dest      - result of the encryption
@param [in]  src       - the plain text to be encrypted
@param [in]  length    - data to encrypt, multiple of 16B block sizes
@param [in]  masterKey - expanded round keys.
*/
void zvksed_sm4_encode_vv(
    void* dest,
    const void* src,
    uint64_t length,
    const void* masterKey
);

/*!
@brief SM4 key epxansion and encoding with vector operations,
@param [out] dest      - result of the encryption
@param [in]  src       - the plain text to be encrypted
@param [in]  length    - multiple of 16B block sizes
@param [in]  masterKey - initial round keys
*/
void zvksed_sm4_encode_vv_full(
    void* dest,
    const void* src,
    uint64_t length,
    const void* masterKey
);

/*!
@brief SM4 decoding with vector operations, requires pre-expanded round keys
@param [out] dest      - result of the encryption
@param [in]  src       - the plain text to be encrypted
@param [in]  length    - data to decrypt, multiple of 16B block sizes
@param [in]  masterKey - expanded round keys.
*/
void zvksed_sm4_decode_vv(
    void* dest,
    const void* src,
    uint64_t length,
    const void* masterKey
);


/*
####################################
############# OpenSSL ##############
####################################
*/
# define SM4_ENCRYPT     1
# define SM4_DECRYPT     0

# define SM4_BLOCK_SIZE    16
# define SM4_KEY_SCHEDULE  32

typedef struct SM4_KEY_st {
    uint32_t rk[SM4_KEY_SCHEDULE];
} SM4_KEY;

int ossl_sm4_set_key(const uint8_t *key, SM4_KEY *ks);

void ossl_sm4_encrypt(const uint8_t *in, uint8_t *out, const SM4_KEY *ks);

void ossl_sm4_decrypt(const uint8_t *in, uint8_t *out, const SM4_KEY *ks);

#endif