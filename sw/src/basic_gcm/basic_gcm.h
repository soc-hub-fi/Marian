/*
 * File        : basic_gcm.h
 * Test        : AES-GCM
 * Author(s)   : Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
 * Date        : 25-jun-2024
 * Description : Declarations, Types and Structures to support AES-GCM tests
 */

#ifndef __BASIC_GCM_H__
#define __BASIC_GCM_H__

#include <stdint.h>

// vector reg used for vd
#define VD  "v3"
// vector reg used for vs2
#define VS2 "v1"
// vector reg used for vs1
#define VS1 "v2"

// element size used in test
#define TEST_VL 12

/********************* VGHSH.VV *********************/

// Partial Hash (Yi)
static uint32_t gcm_part_hash[TEST_VL] __attribute__((aligned(16))) = {
  0x55088014, 0x2A84400A, 0x15422005, 0xA9A11002, 
  0x54D08801, 0x89684400, 0x44B42200, 0x225A1100, 
  0x112D0880, 0x08968440, 0x044B4220, 0x0225A110
};

// Cipher Text (Xi)
static uint32_t gcm_cipher_text[TEST_VL] __attribute__((aligned(16))) = {
  0x0112D088, 0x00896844, 0x0044B422, 0x00225A11, 
  0xA3112D08, 0x51889684, 0x28C44B42, 0x146225A1, 
  0xA93112D0, 0x54988968, 0x2A4C44B4, 0x1526225A
};

// Hash Subkey (Hi)
static uint32_t gcm_hash_skey[TEST_VL] __attribute__((aligned(16))) = {
  0x541A509C, 0x2A0D284E, 0x15069427, 0xA9834A13, 
  0x55C25889, 0x89E12C44, 0x44F09622, 0x22784B11, 
  0x103FD808, 0x081FEC04, 0x040FF602, 0x0207FB01
};

// Partial Hash (Yi+1)
static uint32_t gcm_new_part_hash[TEST_VL] __attribute__((aligned(16))) = {0};

// Partial Hash Reference (Yi+1)
static uint32_t gcm_ref_new_part_hash[TEST_VL] __attribute__((aligned(16))) = {
  0xBC148D6A, 0x9F71BE42, 0x2FA421E7, 0x7A73AFF1, 
  0x3CAB5C72, 0x1C08E471, 0x81F717BF, 0x03E3F1FB, 
  0x0DCC89BD, 0x21C3F92D, 0xB7EB5D77, 0x41402719
};

/********************* VGMUL.VV *********************/

// Multiplier
static uint32_t gcm_multiplier[TEST_VL] __attribute__((aligned(16))) = {
  0x55088014, 0x2A84400A, 0x15422005, 0xA9A11002, 
  0x54D08801, 0x89684400, 0x44B42200, 0x225A1100, 
  0x112D0880, 0x08968440, 0x044B4220, 0x0225A110
};

// Multiplicand
static uint32_t gcm_multiplicand[TEST_VL] __attribute__((aligned(16))) = {
  0x0112D088, 0x00896844, 0x0044B422, 0x00225A11, 
  0xA3112D08, 0x51889684, 0x28C44B42, 0x146225A1, 
  0xA93112D0, 0x54988968, 0x2A4C44B4, 0x1526225A
};

// Product
static uint32_t gcm_product[TEST_VL] __attribute__((aligned(16))) = {0};

// Product Reference
static uint32_t gcm_ref_product[TEST_VL] __attribute__((aligned(16))) = {
  0xC1870055, 0xD297A538, 0xEA1E1272, 0x1D8D92B4, 
  0x9D975D45, 0xB9515E46, 0x1ACA60BE, 0x47B1BBEC, 
  0x4BB9C90F, 0x699CED59, 0x538DCC44, 0x37304E50
};

/************** Function Declarations *************/

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

#endif