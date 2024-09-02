/*
 * File      : sm3_api.h
 * Test      : sm3_benchmark
 * Author(s) : Endrit Isufi <endrit.isufi@tuni.fi
 * Date      : 25-jul-2024
 * Description: Basic benchmarking functions for sm3
 * Based on <https://github.com/rvkrypto/rvk-misc/blob/main/sm3/sm3_api.h>
 */
#ifndef _SM3_API_H_
#define _SM3_API_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <stddef.h>

//	SM3-256: Compute 32-byte hash to "md" from "in" which has "inlen" bytes.
void sm3_256(uint8_t * md, const void *in, size_t inlen);

//	function pointer to the compression function used by the test wrappers
extern void (*sm3_compress)(uint32_t *sp, const uint32_t *mp, size_t n);

//	SM3-256 CF for RV32 & RV64	(zksh)
void sm3_cf256_zksh(uint32_t *sp, const uint32_t *mp, size_t n);

//	zvksh lmul=1, lmul=2, lmul=4
void sm3_cf256_zvksh_lmul1(uint32_t *sp, const uint32_t *mp, size_t n);
void sm3_cf256_zvksh_lmul2(uint32_t *sp, const uint32_t *mp, size_t n);
void sm3_cf256_zvksh_lmul4(uint32_t *sp, const uint32_t *mp, size_t n);


/**
 * @brief helper to print u32 elements within array in format [idx] - value
 * 
 * @param elem_count number of array elements to print
 * @param arr pointer to array
 */
void print_u32_arr(size_t elem_count, uint32_t* arr);

/**
 * @brief Compare elements of two different arrays and report if discrepancies 
 * exist.
 * 
 * @param elem_count number of elements in the arrays (arrays must be the same size)
 * @param result_arr first array
 * @param ref_arr second array
 * @return uint32_t number of failed comparisons
 */
uint32_t compare_u32_results(size_t elem_count, uint32_t* result_arr, uint32_t* ref_arr);


/*
##################################################################
############################## OpenSSL############################
##################################################################
*/
# define SM3_WORD unsigned int
# define SM3_CBLOCK      64
# define SM3_LBLOCK      (SM3_CBLOCK/4)

typedef struct SM3state_st {
   SM3_WORD A, B, C, D, E, F, G, H;
   SM3_WORD Nl, Nh;
   SM3_WORD data[SM3_LBLOCK];
   unsigned int num;
} SM3_CTX;

int ossl_sm3_init(SM3_CTX *c);
int ossl_sm3_update(SM3_CTX *c, const void *data, size_t len);
int ossl_sm3_final(unsigned char *md, SM3_CTX *c);
void ossl_sm3_block_data_order(SM3_CTX *ctx, const void *p, size_t num);


#ifdef __cplusplus
}
#endif

#endif	//	_SM3_API_H_