/*
 * File      : basic_aes.h
 * Test      : Basic AES
 * Author(s) : Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
 * Date      : 17-jun-2024
 * Description: Declarations, types and constants to support the basic_aes test
 */

#ifndef __BASIC_AES_H__
#define __BASIC_AES_H__

#include <stdint.h>

// vector reg used for vd
#define VD  "v1"
// vector reg used for v2
#define VS2 "v2"
// vector reg used for v3 (unused in AES)
#define VS1 "v3"

// element size used in test
#define TEST_VL 12

/************** VAESZ.VS *************/

// round state
static uint32_t aesz_round_state[TEST_VL] __attribute__((aligned(16))) = {
  0x55088014, 0x2A84400A, 0x15422005, 0xA9A11002, 
  0x54D08801, 0x89684400, 0x44B42200, 0x225A1100, 
  0x112D0880, 0x08968440, 0x044B4220, 0x0225A110
};

// round key
static uint32_t aesz_round_key[TEST_VL] __attribute__((aligned(16))) = {
  0x0112D088, 0x00896844, 0x0044B422, 0x00225A11, 
  0xA3112D08, 0x51889684, 0x28C44B42, 0x146225A1, 
  0xA93112D0, 0x54988968, 0x2A4C44B4, 0x1526225A
};

// new round state (actual)
static uint32_t aesz_new_round_state[TEST_VL] __attribute__((aligned(16))) = {0};

// new round state (reference)
static uint32_t aesz_ref_round_state[TEST_VL] __attribute__((aligned(16))) = {
  0x541A509C, 0x2A0D284E, 0x15069427, 0xA9834A13, 
  0x55C25889, 0x89E12C44, 0x44F09622, 0x22784B11, 
  0x103FD808, 0x081FEC04, 0x040FF602, 0x0207FB01
};

/************** VAESEM.VS/VV *************/

// round state
static uint32_t aesem_round_state[TEST_VL] __attribute__((aligned(16))) = {
  0x55088014, 0x2A84400A, 0x15422005, 0xA9A11002, 
  0x54D08801, 0x89684400, 0x44B42200, 0x225A1100, 
  0x112D0880, 0x08968440, 0x044B4220, 0x0225A110
};

// round key
static uint32_t aesem_round_key[TEST_VL] __attribute__((aligned(16))) = {
  0x0112D088, 0x00896844, 0x0044B422, 0x00225A11, 
  0xA3112D08, 0x51889684, 0x28C44B42, 0x146225A1, 
  0xA93112D0, 0x54988968, 0x2A4C44B4, 0x1526225A
};

// new round state (actual)
static uint32_t aesem_new_round_state[TEST_VL] __attribute__((aligned(16))) = {0};

// new round state (reference)
static uint32_t aesem_vs_ref_round_state[TEST_VL] __attribute__((aligned(16))) = {
  0x8CD79F83, 0xCF22D086, 0x96B1E564, 0xB9CD14B5, 
  0x2EDA8543, 0xC87ECFB2, 0x02B7FFAE, 0x12227EDE, 
  0x4F641A2C, 0x174FFA9F, 0x483A24E9, 0x1AEEA9AC
};

// new round state (reference)
static uint32_t aesem_vv_ref_round_state[TEST_VL] __attribute__((aligned(16))) = {
  0x8CD79F83, 0xCF22D086, 0x96B1E564, 0xB9CD14B5, 
  0x8CD978C3, 0x997F3172, 0x2A3700CE, 0x0662016E, 
  0xE747D874, 0x435E1BB3, 0x6232D47F, 0x0FEAD1E7
};

/************** VAESEF.VS/VV *************/

// round state
static uint32_t aesef_round_state[TEST_VL] __attribute__((aligned(16))) = {
  0x55088014, 0x2A84400A, 0x15422005, 0xA9A11002, 
  0x54D08801, 0x89684400, 0x44B42200, 0x225A1100, 
  0x112D0880, 0x08968440, 0x044B4220, 0x0225A110
};

// round key
static uint32_t aesef_round_key[TEST_VL] __attribute__((aligned(16))) = {
  0x0112D088, 0x00896844, 0x0044B422, 0x00225A11, 
  0xA3112D08, 0x51889684, 0x28C44B42, 0x146225A1, 
  0xA93112D0, 0x54988968, 0x2A4C44B4, 0x1526225A
};

// new round state (actual)
static uint32_t aesef_new_round_state[TEST_VL] __attribute__((aligned(16))) = {0};

// new round state (reference)
static uint32_t aesef_vs_ref_round_state[TEST_VL] __attribute__((aligned(16))) = {
  0xD23ED972, 0xFCBBDF23, 0xE5747E49, 0x597D9766, 
  0x929FCBF4, 0x2037FB27, 0xA7343641, 0x1B679E72, 
  0x76A18F45, 0x82B6444D, 0x309C8695, 0xF2B26ADB
};

// new round state (reference)
static uint32_t aesef_vv_ref_round_state[TEST_VL] __attribute__((aligned(16))) = {
  0xD23ED972, 0xFCBBDF23, 0xE5747E49, 0x597D9766, 
  0x309C3674, 0x713605E7, 0x8FB4C921, 0x0F27E1C2, 
  0xDE824D1D, 0xD6A7A561, 0x1A947603, 0xE7B61290
};

/************** VAESDM.VS/VV *************/

// round state
static uint32_t aesdm_round_state[TEST_VL] __attribute__((aligned(16))) = {
  0x55088014, 0x2A84400A, 0x15422005, 0xA9A11002, 
  0x54D08801, 0x89684400, 0x44B42200, 0x225A1100, 
  0x112D0880, 0x08968440, 0x044B4220, 0x0225A110
};

// round key
static uint32_t aesdm_round_key[TEST_VL] __attribute__((aligned(16))) = {
  0x0112D088, 0x00896844, 0x0044B422, 0x00225A11, 
  0xA3112D08, 0x51889684, 0x28C44B42, 0x146225A1, 
  0xA93112D0, 0x54988968, 0x2A4C44B4, 0x1526225A
};

// new round state (actual)
static uint32_t aesdm_new_round_state[TEST_VL] __attribute__((aligned(16))) = {0};

// new round state (reference)
static uint32_t aesdm_vs_ref_round_state[TEST_VL] __attribute__((aligned(16))) = {
  0x8C18316A, 0xF82F5A6F, 0x37F06138, 0x673275D5, 
  0x6B849AE0, 0x95C3B741, 0xCA37939C, 0xAC11CED6, 
  0xC69FA40E, 0xAB746326, 0x87A7A4DD, 0x45916081
};

// new round state (reference)
static uint32_t aesdm_vv_ref_round_state[TEST_VL] __attribute__((aligned(16))) = {
  0x8C18316A, 0xF82F5A6F, 0x37F06138, 0x673275D5, 
  0x8C8281C6, 0x447815E7, 0x97C577E0, 0x733B5721, 
  0xBFDF9517, 0x49BF3FDB, 0xD9F7A89B, 0x6AB966A2
};

/************** VAESDF.VS/VV *************/

// round state
static uint32_t aesdf_round_state[TEST_VL] __attribute__((aligned(16))) = {
  0x55088014, 0x2A84400A, 0x15422005, 0xA9A11002, 
  0x54D08801, 0x89684400, 0x44B42200, 0x225A1100, 
  0x112D0880, 0x08968440, 0x044B4220, 0x0225A110
};

// round key
static uint32_t aesdf_round_key[TEST_VL] __attribute__((aligned(16))) = {
  0x0112D088, 0x00896844, 0x0044B422, 0x00225A11, 
  0xA3112D08, 0x51889684, 0x28C44B42, 0x146225A1, 
  0xA93112D0, 0x54988968, 0x2A4C44B4, 0x1526225A
};

// new round state (actual)
static uint32_t aesdf_new_round_state[TEST_VL] __attribute__((aligned(16))) = {0};

// new round state (reference)
static uint32_t aesdf_vs_ref_round_state[TEST_VL] __attribute__((aligned(16))) = {
  0x94E4AC13, 0x2F7852E7, 0xB7FBC614, 0xED6D0E7B, 
  0xF3D43381, 0x86CFFF16, 0x94243270, 0xFDD5CE43, 
  0xBEDE21B2, 0x304BD736, 0x6ABEFB76, 0xE317AC6D
};

// new round state (reference)
static uint32_t aesdf_vv_ref_round_state[TEST_VL] __attribute__((aligned(16))) = {
  0x94E4AC13, 0x2F7852E7, 0xB7FBC614, 0xED6D0E7B, 
  0x51D7CE01, 0xD7CE01D6, 0xBCA4CD10, 0xE995B1F3, 
  0x16FDE3EA, 0x645A361A, 0x40B60BE0, 0xF613D426
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