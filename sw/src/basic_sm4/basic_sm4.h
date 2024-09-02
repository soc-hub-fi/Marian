/*
 * File      : basic_sm4.h
 * Test      : Basic SM4
 * Author(s) : Endrit Isufi <endrit.isufi@tuni.fi>
 * Date      : 17-jul-2024
 * Description: Declarations, types and constants to support the basic_sm4 test.
 */

#ifndef __BASIC_SM4_H__
#define __BASIC_SM4_H__

#include <stdint.h>

// vector reg used for vd
#define VD  "v1"
// vector reg used for v2
#define VS2 "v2"
// vector reg used for v3 (unused in sm4)
#define VS1 "v3"

// element size used in test
#define TEST_VL 4

// round number
#define uimm 1u

/************** vsm4k.vi *************/
// current round keys #1 (sole test vector in the standard itself)
static uint32_t sm4_round_keys[TEST_VL] __attribute__((aligned(16))) = {
  0xF12186F9, 0x41662B61, 0x5A6AB19A, 0x7BA92077
};
static uint32_t sm4_round_keys_rev[TEST_VL] __attribute__((aligned(16))) = {
  0x7BA92077, 0x5A6AB19A, 0x41662B61, 0xF12186F9
};

// current round keys #2 
static uint32_t sm4_round_key_1[TEST_VL] __attribute__((aligned(16))) = {
  0xFEDCBA98, 0x76543210, 0x01234567, 0x89ABCDEF
};

// next round keys (actual)
static uint32_t new_round_keys[TEST_VL] __attribute__((aligned(16))) = {0};
// next cipher text (actual)
static uint32_t new_cipher[TEST_VL] __attribute__((aligned(16))) = {0};

//round keys 4-7 from sm4 spec.
static uint32_t ref_round_keys_0[TEST_VL] __attribute__((aligned(16))) = {
  0x367360F4, 0x776A0C61, 0xB6BB89B3, 0x24763151
};

// current state 0
static uint32_t sm4_state0[TEST_VL] __attribute__((aligned(16))) = {
  0x1234567, 0x89ABCDEF, 0xFEDCBA98, 0x76543210
};

// cipher text #1 (reference)
static uint32_t ref_cipher_0[TEST_VL] __attribute__((aligned(16))) = {
  0x27FAD345, 0xA18B4CB2, 0x11C1E22A, 0xCC13E2EE
};

// cipher text #2 (reference)
static uint32_t ref_round_keys_1[TEST_VL] __attribute__((aligned(16))) = {
  0xF766678F, 0x13F01ADE, 0xAC1B3EA9, 0x55ADB594
};

// system parameters to generate initial round keys
static uint32_t FK[4] = {
  0xA3B1BAC6, 0x56AA3350, 0x677D9197, 0xB27022DC
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
