/*
 * File      : basic_bit_manip.h
 * Test      : Vector Cryptography Bit Manipulation
 * Author(s) : Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
 * Date      : 20-jun-2024
 * Description: Declarations, types and constants to support the bit_manip test
 */

#ifndef __BASIC_BIT_MANIP_H__
#define __BASIC_BIT_MANIP_H__

#include <stddef.h>
#include <stdint.h>

// vector reg used for vd
#define VD  "v3"
// vector reg used for vs2
#define VS2 "v2"
// vector reg used for vs1
#define VS1 "v1"

// element size used in test
#define TEST_VL 12

/********************* VANDN[VV,VX] *********************/

// vandn op1 (vs1)
static uint32_t vandn_vv_op1[TEST_VL] __attribute__((aligned(16))) = {
  0x55088014, 0x2A84400A, 0x15422005, 0xA9A11002, 
  0x54D08801, 0x89684400, 0x44B42200, 0x225A1100, 
  0x112D0880, 0x08968440, 0x044B4220, 0x0225A110
};

// vandn op1 (rs1)
static uint32_t vandn_vx_op1 = 0xDEADBEEF;

// vandn op2
static uint32_t vandn_vv_op2[TEST_VL] __attribute__((aligned(16))) = {
  0x0112D088, 0x00896844, 0x0044B422, 0x00225A11, 
  0xA3112D08, 0x51889684, 0x28C44B42, 0x146225A1, 
  0xA93112D0, 0x54988968, 0x2A4C44B4, 0x1526225A
};

// vandn Result
static uint32_t vandn_result[TEST_VL] __attribute__((aligned(16))) = {0};

// vandn.vv Reference Result
static uint32_t vandn_vv_ref_result[TEST_VL] __attribute__((aligned(16))) = {
  0x00125088, 0x00092844, 0x00049422, 0x00024A11, 
  0xA3012508, 0x50809284, 0x28404942, 0x142024A1, 
  0xA8101250, 0x54080928, 0x2A040494, 0x1502024A
};

// vandn.vx Reference Result
static uint32_t vandn_vx_ref_result[TEST_VL] __attribute__((aligned(16))) = {
  0x01124000, 0x00004000, 0x00400000, 0x00024010, 
  0x21100100, 0x01000000, 0x20404100, 0x00420100, 
  0x21100010, 0x00100100, 0x20404010, 0x01020010
};

/********************* VBREV8 *********************/

// vbrev8 input
static uint32_t vbrev8_input[TEST_VL] __attribute__((aligned(16))) = {
  0x55088014, 0x2A84400A, 0x15422005, 0xA9A11002, 
  0x54D08801, 0x89684400, 0x44B42200, 0x225A1100, 
  0x112D0880, 0x08968440, 0x044B4220, 0x0225A110
};

// vbrev8 Result
static uint32_t vbrev8_result[TEST_VL] __attribute__((aligned(16))) = {0};

// vbrev8 Reference Result
static uint32_t vbrev8_ref_result[TEST_VL] __attribute__((aligned(16))) = {
  0xAA100128, 0x54210250, 0xA84204A0, 0x95850840, 
  0x2A0B1180, 0x91162200, 0x222D4400, 0x445A8800, 
  0x88B41001, 0x10692102, 0x20D24204, 0x40A48508
};

/********************* VREV8 *********************/

// vrev8 input
static uint32_t vrev8_input[TEST_VL] __attribute__((aligned(16))) = {
  0x55088014, 0x2A84400A, 0x15422005, 0xA9A11002, 
  0x54D08801, 0x89684400, 0x44B42200, 0x225A1100, 
  0x112D0880, 0x08968440, 0x044B4220, 0x0225A110
};

// vrev8 Result
static uint32_t vrev8_result[TEST_VL] __attribute__((aligned(16))) = {0};

// vrev8 Reference Result
static uint32_t vrev8_ref_result[TEST_VL] __attribute__((aligned(16))) = {
  0x14800855, 0x0A40842A, 0x05204215, 0x0210A1A9, 
  0x0188D054, 0x00446889, 0x0022B444, 0x00115A22, 
  0x80082D11, 0x40849608, 0x20424B04, 0x10A12502
};

/********************* VROL[VV,VX] *********************/

// vrol op1 (vs1)
static uint32_t vrol_vv_rot_amount[TEST_VL] __attribute__((aligned(16))) = {
  0x55088014, 0x2A84400A, 0x15422005, 0xA9A11002, 
  0x54D08801, 0x89684400, 0x44B42200, 0x225A1100, 
  0x112D0880, 0x08968440, 0x044B4220, 0x0225A110
};

// vrol op1 (rs1)
static uint32_t vrol_vx_rot_amount = 0x8;

// vrol op2
static uint32_t vrol_vv_data[TEST_VL] __attribute__((aligned(16))) = {
  0x0112D088, 0x00896844, 0x0044B422, 0x00225A11, 
  0xA3112D08, 0x51889684, 0x28C44B42, 0x146225A1, 
  0xA93112D0, 0x54988968, 0x2A4C44B4, 0x1526225A
};

// vrol Result
static uint32_t vrol_result[TEST_VL] __attribute__((aligned(16))) = {0};

// vrol.vv Reference Result
static uint32_t vrol_vv_ref_result[TEST_VL] __attribute__((aligned(16))) = {
  0x0880112D, 0x25A11002, 0x08968440, 0x00896844, 
  0x46225A11, 0x51889684, 0x28C44B42, 0x146225A1, 
  0xA93112D0, 0x54988968, 0x2A4C44B4, 0x225A1526
};

// vrol.vx Reference Result
static uint32_t vrol_vx_ref_result[TEST_VL] __attribute__((aligned(16))) = {
  0x12D08801, 0x89684400, 0x44B42200, 0x225A1100, 
  0x112D08A3, 0x88968451, 0xC44B4228, 0x6225A114, 
  0x3112D0A9, 0x98896854, 0x4C44B42A, 0x26225A15
};

/********************* VROR[VV,VX,VI] *********************/

// vrol op1 (vs1)
static uint32_t vror_vv_rot_amount[TEST_VL] __attribute__((aligned(16))) = {
  0x55088014, 0x2A84400A, 0x15422005, 0xA9A11002, 
  0x54D08801, 0x89684400, 0x44B42200, 0x225A1100, 
  0x112D0880, 0x08968440, 0x044B4220, 0x0225A110
};

// vrol op1 (rs1)
static uint32_t vror_vx_rot_amount = 0x8;

// vrol op2
static uint32_t vror_vv_data[TEST_VL] __attribute__((aligned(16))) = {
  0x0112D088, 0x00896844, 0x0044B422, 0x00225A11, 
  0xA3112D08, 0x51889684, 0x28C44B42, 0x146225A1, 
  0xA93112D0, 0x54988968, 0x2A4C44B4, 0x1526225A
};

// vrol Result
static uint32_t vror_result[TEST_VL] __attribute__((aligned(16))) = {0};

// vrol.vv Reference Result
static uint32_t vror_vv_ref_result[TEST_VL] __attribute__((aligned(16))) = {
  0x2D088011, 0x1100225A, 0x100225A1, 0x40089684, 
  0x51889684, 0x51889684, 0x28C44B42, 0x146225A1, 
  0xA93112D0, 0x54988968, 0x2A4C44B4, 0x225A1526
};

// vrol.vx Reference Result
static uint32_t vror_vx_ref_result[TEST_VL] __attribute__((aligned(16))) = {
  0x880112D0, 0x44008968, 0x220044B4, 0x1100225A, 
  0x08A3112D, 0x84518896, 0x4228C44B, 0xA1146225, 
  0xD0A93112, 0x68549889, 0xB42A4C44, 0x5A152622
};

// vrol.vi Reference Result
static uint32_t vror_vi_ref_result[TEST_VL] __attribute__((aligned(16))) = {
  0x880112D0, 0x44008968, 0x220044B4, 0x1100225A, 
  0x08A3112D, 0x84518896, 0x4228C44B, 0xA1146225, 
  0xD0A93112, 0x68549889, 0xB42A4C44, 0x5A152622
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
