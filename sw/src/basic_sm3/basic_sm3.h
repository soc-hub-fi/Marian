/*
 * File      : basic_sm3.h
 * Test      : Basic SM3
 * Author(s) : Endrit Isufi <endrit.isufi@tuni.fi>
 * Date      : 18-jul-2024
 * Description: Declarations, types and constants to support the basic_sm4 test.
 * 
 */

#ifndef __BASIC_SM3_H__
#define __BASIC_SM3_H__

#include <stdint.h>

// vector reg used for vd
#define VD  "v1"
// vector reg used for v2
#define VS2 "v2"
// vector reg used for v3 
#define VS1 "v3"

// element size used in test
#define TEST_VL 8u

// round number
#define uimm 0u



/*============= vcm3me.vv ===============*/

/*test vectors sampled from tests done on SPIKE*/
static uint32_t message_words_spike_0_tb[TEST_VL] __attribute__((aligned(16))) = {
  0x0112D088, 0x00896844, 0x0044B422, 0x00225A11, 0x8CD978C3, 0x997F3172, 0x2A3700CE, 0x0662016E
};
/*test vectors sampled from tests done on SPIKE*/
static uint32_t message_words_spike_1_tb[TEST_VL] __attribute__((aligned(16))) = {
  0x541A509C, 0x2A0D284E, 0x15069427, 0xA9834A13, 0x309C3674, 0x713605E7, 0x8FB4C921, 0x0F27E1C2
};


// spec ref values #1 used for vs1
static uint32_t message_words_0[TEST_VL] __attribute__((aligned(16))) = {
  0x80636261, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000
};

/* spec ref values #2 used for vs2*/
static uint32_t message_words_1[TEST_VL] __attribute__((aligned(16))) = {
  0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x18000000
};
/* spec ref values, #3 */
static uint32_t message_words_2[TEST_VL] __attribute__((aligned(16))) = {
  0x9092e200, 0x00000000, 0x000c0606, 0x719c70ed,
  0x00000000, 0x8001801f, 0x939f7da9, 0x00000000
};


static uint32_t message_words_ref[TEST_VL] __attribute__((aligned(16))) = {
  0x9092e200, 0x00000000, 0x000c0606, 0x719c70ed,
  0x00000000, 0x8001801f, 0x939f7da9, 0x00000000
};
/* above message words reference but in big endian since specs actually uses these*/
static uint32_t message_words_ref_1[TEST_VL] __attribute__((aligned(16))) = {
  0x00E29290, 0x00000000, 0x06060C00, 0xED709C71,
  0x00000000, 0x1F800180, 0xA97D9F93, 0x00000000
};


/*================= vcm3c.vi ==================*/
// initial values specified in specs
static uint32_t current_state_0[TEST_VL] __attribute__((aligned(16))) = {
  0x7380166f, 0x4914b2b9, 0x172442d7, 0xda8a0600,
  0xa96f30bc, 0x163138aa, 0xe38dee4d, 0xb0fb0e4e
};
/*initial state but in big endian*/
static uint32_t current_state_big_endian[TEST_VL] __attribute__((aligned(16))) = {
  0x6f168073, 0xb9b21449, 0xd7422417, 0x00068ada,
  0xbc306fa9, 0xaa383116, 0x4dee8de3, 0x4e0efbb0
};

/*j=1 reference values from specs but in big endian*/
static uint32_t next_state_big_endian[TEST_VL] __attribute__((aligned(16))) = {
  0x8C4252EA, 0x2BC1EDB9, 0xE7DE2C00, 0x92726529,
  0x233A35AC, 0xF429ADB2, 0x794BE585, 0x89B150C5
};

/*Result of operations*/
static uint32_t result[TEST_VL] __attribute__((aligned(16))) = {0};



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
