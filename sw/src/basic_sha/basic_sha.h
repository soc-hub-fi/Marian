/*
 * File      : basic_sha.h
 * Test      : Basic SHA-2
 * Author(s) : Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
 * Date      : 19-jun-2024
 * Description: Declarations, types and constants to support the basic_sha test
 */

#ifndef __BASIC_SHA_H__
#define __BASIC_SHA_H__

#include <stdint.h>
#include <stddef.h>

// vector reg used for vd
#define VD  "v3"
// vector reg used for v2
#define VS2 "v1"
// vector reg used for v3 (unused in AES)
#define VS1 "v2"

// element size used in test
#define TEST_VL 8

/************** VSHA2C[HL].VV (SEW32) *************/

// curr state  {c, d, g, h} (SEW32)
static uint32_t sha2_c_state_0_32[TEST_VL] __attribute__((aligned(16))) = {
  0x55088014, 0x2A84400A, 0x15422005, 0xA9A11002, 
  0x54D08801, 0x89684400, 0x44B42200, 0x225A1100
};

// curr state  {a, b, e, f} (SEW32)
static uint32_t sha2_c_state_1_32[TEST_VL] __attribute__((aligned(16))) = {
  0x0112D088, 0x00896844, 0x0044B422, 0x00225A11, 
  0xA3112D08, 0x51889684, 0x28C44B42, 0x146225A1
};

// Msg Sched + Const (SEW32)
static uint32_t sha2_msg_sched_32[TEST_VL] __attribute__((aligned(16))) = {
  0x0A93112D, 0xA6498896, 0x5324C44B, 0x8A926225, 
  0xE6493112, 0x73249889, 0x9A924C44, 0x4D492622
};

// Next State (SEW32)
static uint32_t sha2_n_state_32[TEST_VL] __attribute__((aligned(16))) = {0};

// Next State Reference (HIGH) (SEW32)
static uint32_t sha2_n_state_hi_ref_32[TEST_VL] __attribute__((aligned(16))) = {
  0x43A9BAFA, 0xC1EEC96E, 0x48707E8D, 0x803AA06E, 
  0xC2FE8BA5, 0xF78B98CC, 0x7F1318CD, 0xE73F9CE4
};

// Next State Reference (LOW) (SEW32)
static uint32_t sha2_n_state_lo_ref_32[TEST_VL] __attribute__((aligned(16))) = {
  0xFB1807DC, 0x7EEA9648, 0xFFDECB6F, 0xB536543B,
  0x0EB57073, 0x594A4579, 0xCAC9FD9B, 0x794AE7FE
};

/************** VSHA2C[HL].VV (SEW64) *************/

// curr state  {c, d, g, h} (SEW64)
static uint64_t sha2_c_state_0_64[TEST_VL] __attribute__((aligned(16))) = {
  0x2712F64F7497CB7A, 0x13897B27BA4BE5BD, 0xD1C4BD93DD25F2DE, 0x68E25EC9EE92F96F, 
  0xEC712F64F7497CB7, 0xAE3897B27BA4BE5B, 0x8F1C4BD93DD25F2D, 0x9F8E25EC9EE92F96
};

// curr state  {a, b, e, f} (SEW64)
static uint64_t sha2_c_state_1_64[TEST_VL] __attribute__((aligned(16))) = {
  0xF1FC712F64F7497C, 0x78FE3897B27BA4BE, 0x3C7F1C4BD93DD25F, 0xC63F8E25EC9EE92F, 
  0xBB1FC712F64F7497, 0x858FE3897B27BA4B, 0x9AC7F1C4BD93DD25, 0x9563F8E25EC9EE92
};

// Msg Sched + Const (SEW64)
static uint64_t sha2_msg_sched_64[TEST_VL] __attribute__((aligned(16))) = {
  0xC7AB1FC712F64F74, 0x63D58FE3897B27BA, 0x31EAC7F1C4BD93DD, 0xC0F563F8E25EC9EE, 
  0x607AB1FC712F64F7, 0xE83D58FE3897B27B, 0xAC1EAC7F1C4BD93D, 0x8E0F563F8E25EC9E
};

// Next State (SEW64)
static uint64_t sha2_n_state_64[TEST_VL] __attribute__((aligned(16))) = {0};

// Next State Reference (HIGH) (SEW64)
static uint64_t sha2_n_state_hi_ref_64[TEST_VL] __attribute__((aligned(16))) = {
  0xCECF2F117235EDDE, 0xFC1548A35B1841A5, 0x6299A52D4FAA733A, 0xED457196003D444A, 
  0x95ED637116F45EDA, 0x5FCD83C45335FDBB, 0x662A0ACD4E39A72F, 0x812BBF0FF8CD37BE
};

// Next State Reference (LOW) (SEW64)
static uint64_t sha2_n_state_lo_ref_64[TEST_VL] __attribute__((aligned(16))) = {
  0x648F86E6C06EA975, 0x4F28D7AE17E6DD84, 0xF859FD029DE32ED1, 0x5F37F5DE5F8CEB07, 
  0x4A4968EE6BD7EA94, 0x0EE5CE7905DC6F8D, 0x1A86104AA31D32E9, 0x1671F19D6382CB30
};

/************** VSHA2MS.VV (SEW32) *************/

// msg words [3:0] (SEW32)
static uint32_t sha2_msg_0_32[TEST_VL] __attribute__((aligned(16))) = {
  0x55088014, 0x2A84400A, 0x15422005, 0xA9A11002, 
  0x54D08801, 0x89684400, 0x44B42200, 0x225A1100
};

// msg words [11, 10, 9, 4] (SEW32)
static uint32_t sha2_msg_1_32[TEST_VL] __attribute__((aligned(16))) = {
  0x0112D088, 0x00896844, 0x0044B422, 0x00225A11, 
  0xA3112D08, 0x51889684, 0x28C44B42, 0x146225A1
};

// msg words [15, 14, -, 12] (SEW32)
static uint32_t sha2_msg_2_32[TEST_VL] __attribute__((aligned(16))) = {
  0x0A93112D, 0xA6498896, 0x5324C44B, 0x8A926225, 
  0xE6493112, 0x73249889, 0x9A924C44, 0x4D492622
};

// msg words [19:16] (SEW32)
static uint32_t sha2_msg_3_32[TEST_VL] __attribute__((aligned(16))) = {0};

// msg words [19:16] Reference (SEW32)
static uint32_t sha2_msg_3_ref_32[TEST_VL] __attribute__((aligned(16))) = {
  0x5150FD3F, 0x28C149BF, 0xCAF85B1B, 0xE618E24D, 
  0x1725935F, 0x6A92C9AF, 0x5527E647, 0x95026DFA
};

/************** VSHA2MS.VV (SEW64) *************/

// msg words [3:0] (SEW64)
static uint64_t sha2_msg_0_64[TEST_VL] __attribute__((aligned(16))) = {
  0x2712F64F7497CB7A, 0x13897B27BA4BE5BD, 0xD1C4BD93DD25F2DE, 0x68E25EC9EE92F96F, 
  0xEC712F64F7497CB7, 0xAE3897B27BA4BE5B, 0x8F1C4BD93DD25F2D, 0x9F8E25EC9EE92F96
};

// msg words [11, 10, 9, 4] (SEW64)
static uint64_t sha2_msg_1_64[TEST_VL] __attribute__((aligned(16))) = {
  0xF1FC712F64F7497C, 0x78FE3897B27BA4BE, 0x3C7F1C4BD93DD25F, 0xC63F8E25EC9EE92F, 
  0xBB1FC712F64F7497, 0x858FE3897B27BA4B, 0x9AC7F1C4BD93DD25, 0x9563F8E25EC9EE92
};

// msg words [15, 14, -, 12] (SEW64)
static uint64_t sha2_msg_2_64[TEST_VL] __attribute__((aligned(16))) = {
 0xC7AB1FC712F64F74, 0x63D58FE3897B27BA, 0x31EAC7F1C4BD93DD, 0xC0F563F8E25EC9EE, 
 0x607AB1FC712F64F7, 0xE83D58FE3897B27B, 0xAC1EAC7F1C4BD93D, 0x8E0F563F8E25EC9E
};

// msg words [19:16] (SEW64)
static uint64_t sha2_msg_3_64[TEST_VL] __attribute__((aligned(16))) = {0};

// msg words [19:16] Reference (SEW64)
static uint64_t sha2_msg_3_ref_64[TEST_VL] __attribute__((aligned(16))) = {
  0x12EB87B296FEEF59, 0xE52DBCD94B7F77AE, 0xBEC90718849A7B73, 0xFA8647324EAD700E, 
  0x1951C21B296FEEF1, 0x03F0E80D94B7F779, 0x341D3A4F370DA798, 0x2CB33F5BEB42D6E6
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
 * @brief helper to print u64 elements within array in format [idx] - value
 * 
 * @param elem_count number of array elements to print
 * @param arr pointer to array
 */
void print_u64_arr(size_t elem_count, uint64_t* arr);

/**
 * @brief Compare elements of two different u32 arrays and report if discrepancies 
 * exist.
 * 
 * @param elem_count number of elements in the arrays (arrays must be the same size)
 * @param result_arr first array
 * @param ref_arr second array
 * @return uint32_t number of failed comparisons
 */
uint32_t compare_u32_results(size_t elem_count, uint32_t* result_arr, uint32_t* ref_arr);

/**
 * @brief Compare elements of two different u64 arrays and report if discrepancies 
 * exist.
 * 
 * @param elem_count number of elements in the arrays (arrays must be the same size)
 * @param result_arr first array
 * @param ref_arr second array
 * @return uint32_t number of failed comparisons
 */
uint32_t compare_u64_results(size_t elem_count, uint64_t* result_arr, uint64_t* ref_arr);

#endif