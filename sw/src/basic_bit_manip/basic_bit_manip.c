/*
 * File        : basic_bit_manip.c
 * Test        : Vector Cryptography Bit Manipulation
 * Author(s)   : Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
 * Date        : 20-jun-2024
 * Description : Test to exercise the AES Encryption Vector Instructions i.e.
 *              vandn.vv
 *              vandn.vx
 *              vbrev8.v
 *              vrev8.v
 *              vrol.vv
 *              vrol.vx
 *              vror.vv
 *              vror.vx
 *              vror.vi
 */

#include <stdint.h>
#include <stddef.h>

#include <riscv_vector.h>

#include "basic_bit_manip.h"
#include "encoding.h"
#include "printf.h"
#include "runtime.h"

int main(void) {

  volatile uint64_t AVL = TEST_VL;
  volatile uint64_t vl  = 0;
  // monitor failures throughout test execution           
  uint32_t fail_count = 0;

  printf("\r\n********* BASIC BIT MANIPULATION TEST *********\r\n");

  /**************************** VANDN.VV ***************************/

  printf("\r\n****** VANDN.VV ******\r\n");

  // initialise VRF with zeroes
  init_vrf();

  // set vtype to SEW32, M1
  vl = __riscv_vsetvl_e32m1(AVL);

  printf("\r\nConfiguration:\r\n AVL = 0x%016lX,\r\n vl  = 0x%016lX\r\n", AVL, vl);

  printf("\r\nLoading OP1:\r\n");
  print_u32_arr(vl, vandn_vv_op1);
  asm volatile ("vle32.v "VS1", (%0);" :: "r"(vandn_vv_op1));

  printf("\r\nLoading OP2:\r\n");
  print_u32_arr(vl, vandn_vv_op2);
  asm volatile ("vle32.v "VS2", (%0);" :: "r"(vandn_vv_op2));

  printf("\r\nExecuting vandn.vv\r\n");
  asm volatile ("vandn.vv "VD", "VS2","VS1); // Todo: test masking

  printf("\r\nStoring Output:\r\n");
  asm volatile ("vse32.v "VD", (%0);" :: "r"(vandn_result));
  print_u32_arr(vl, vandn_result);

  fail_count += compare_u32_results((size_t)(vl), vandn_result, vandn_vv_ref_result);

  /**************************** VANDN.VX ***************************/

  printf("\r\n****** VANDN.VX ******\r\n");

  // initialise VRF with zeroes
  init_vrf();

  // set vtype to SEW32, M1
  vl = __riscv_vsetvl_e32m1(AVL);

  printf("\r\nConfiguration:\r\n AVL = 0x%016lX,\r\n vl  = 0x%016lX\r\n", AVL, vl);

  printf("\r\nLoading OP2:\r\n");
  print_u32_arr(vl, vandn_vv_op2);
  asm volatile ("vle32.v "VS2", (%0);" :: "r"(vandn_vv_op2));

  printf("\r\nExecuting vandn.vx with rs1 = 0x%08X\r\n", vandn_vx_op1);
  asm volatile ("vandn.vx "VD", "VS2", %0;" :: "r"(vandn_vx_op1)); // Todo: test masking

  printf("\r\nStoring Output:\r\n");
  asm volatile ("vse32.v "VD", (%0);" :: "r"(vandn_result));
  print_u32_arr(vl, vandn_result);

  fail_count += compare_u32_results((size_t)(vl), vandn_result, vandn_vx_ref_result);

  /********************* VBREV8 *********************/

  printf("\r\n****** VBREV8.V ******\r\n");

  // initialise VRF with zeroes
  init_vrf();

  // set vtype to SEW32, M1
  vl = __riscv_vsetvl_e32m1(AVL);

  printf("\r\nConfiguration:\r\n AVL = 0x%016lX,\r\n vl  = 0x%016lX\r\n", AVL, vl);

  printf("\r\nLoading Input:\r\n");
  print_u32_arr(vl, vbrev8_input);
  asm volatile ("vle32.v "VS2", (%0);" :: "r"(vbrev8_input));

  printf("\r\nExecuting vbrev8.v\r\n");
  asm volatile ("vbrev8.v "VD", "VS2); // Todo: test masking

  printf("\r\nStoring Output:\r\n");
  asm volatile ("vse32.v "VD", (%0);" :: "r"(vbrev8_result));
  print_u32_arr(vl, vbrev8_result);

  fail_count += compare_u32_results((size_t)(vl), vbrev8_result, vbrev8_ref_result);

  /********************* VREV8 *********************/

  printf("\r\n****** VREV8.V ******\r\n");

  // initialise VRF with zeroes
  init_vrf();

  // set vtype to SEW32, M1
  vl = __riscv_vsetvl_e32m1(AVL);

  printf("\r\nConfiguration:\r\n AVL = 0x%016lX,\r\n vl  = 0x%016lX\r\n", AVL, vl);

  printf("\r\nLoading Input:\r\n");
  print_u32_arr(vl, vrev8_input);
  asm volatile ("vle32.v "VS2", (%0);" :: "r"(vrev8_input));

  printf("\r\nExecuting vrev8.v\r\n");
  asm volatile ("vrev8.v "VD", "VS2); // Todo: test masking

  printf("\r\nStoring Output:\r\n");
  asm volatile ("vse32.v "VD", (%0);" :: "r"(vrev8_result));
  print_u32_arr(vl, vrev8_result);

  fail_count += compare_u32_results((size_t)(vl), vrev8_result, vrev8_ref_result);

  /**************************** VROL.VV ***************************/

  printf("\r\n****** VROL.VV ******\r\n");

  // initialise VRF with zeroes
  init_vrf();

  // set vtype to SEW32, M1
  vl = __riscv_vsetvl_e32m1(AVL);

  printf("\r\nConfiguration:\r\n AVL = 0x%016lX,\r\n vl  = 0x%016lX\r\n", AVL, vl);

  printf("\r\nLoading Rotate Amount:\r\n");
  print_u32_arr(vl, vrol_vv_rot_amount);
  asm volatile ("vle32.v "VS1", (%0);" :: "r"(vrol_vv_rot_amount));

  printf("\r\nLoading Data:\r\n");
  print_u32_arr(vl, vrol_vv_data);
  asm volatile ("vle32.v "VS2", (%0);" :: "r"(vrol_vv_data));

  printf("\r\nExecuting vrol.vv\r\n");
  asm volatile ("vrol.vv "VD", "VS2", "VS1); // Todo: test masking

  printf("\r\nStoring Rotated Data:\r\n");
  asm volatile ("vse32.v "VD", (%0);" :: "r"(vrol_result));
  print_u32_arr(vl, vrol_result);

  fail_count += compare_u32_results((size_t)(vl), vrol_result, vrol_vv_ref_result);

  /**************************** VROL.VX ***************************/

  printf("\r\n****** VROL.VX ******\r\n");

  // initialise VRF with zeroes
  init_vrf();

  // set vtype to SEW32, M1
  vl = __riscv_vsetvl_e32m1(AVL);

  printf("\r\nConfiguration:\r\n AVL = 0x%016lX,\r\n vl  = 0x%016lX\r\n", AVL, vl);

  printf("\r\nLoading OP2:\r\n");
  print_u32_arr(vl, vrol_vv_data);
  asm volatile ("vle32.v "VS2", (%0);" :: "r"(vrol_vv_data));

  printf("\r\nExecuting vrol.vx with rs1 = 0x%08X\r\n", vrol_vx_rot_amount);
  asm volatile ("vrol.vx "VD", "VS2", %0;" :: "r"(vrol_vx_rot_amount)); // Todo: test masking

  printf("\r\nStoring Output:\r\n");
  asm volatile ("vse32.v "VD", (%0);" :: "r"(vrol_result));
  print_u32_arr(vl, vrol_result);

  fail_count += compare_u32_results((size_t)(vl), vrol_result, vrol_vx_ref_result);

  /**************************** VROR.VV ***************************/

  printf("\r\n****** VROR.VV ******\r\n");

  // initialise VRF with zeroes
  init_vrf();

  // set vtype to SEW32, M1
  vl = __riscv_vsetvl_e32m1(AVL);

  printf("\r\nConfiguration:\r\n AVL = 0x%016lX,\r\n vl  = 0x%016lX\r\n", AVL, vl);

  printf("\r\nLoading Rotate Amount:\r\n");
  print_u32_arr(vl, vror_vv_rot_amount);
  asm volatile ("vle32.v "VS1", (%0);" :: "r"(vror_vv_rot_amount));

  printf("\r\nLoading Data:\r\n");
  print_u32_arr(vl, vror_vv_data);
  asm volatile ("vle32.v "VS2", (%0);" :: "r"(vror_vv_data));

  printf("\r\nExecuting vror.vv\r\n");
  asm volatile ("vror.vv "VD", "VS2","VS1); // Todo: test masking

  printf("\r\nStoring Rotated Data:\r\n");
  asm volatile ("vse32.v "VD", (%0);" :: "r"(vror_result));
  print_u32_arr(vl, vror_result);

  fail_count += compare_u32_results((size_t)(vl), vror_result, vror_vv_ref_result);

  /**************************** VROR.VX ***************************/

  printf("\r\n****** VROR.VX ******\r\n");

  // initialise VRF with zeroes
  init_vrf();

  // set vtype to SEW32, M1
  vl = __riscv_vsetvl_e32m1(AVL);

  printf("\r\nConfiguration:\r\n AVL = 0x%016lX,\r\n vl  = 0x%016lX\r\n", AVL, vl);

  printf("\r\nLoading Rotate Amount:\r\n");
  print_u32_arr(vl, vror_vv_data);
  asm volatile ("vle32.v "VS2", (%0);" :: "r"(vror_vv_data));

  printf("\r\nExecuting vror.vx with rs1 = 0x%08X\r\n", vror_vx_rot_amount);
  asm volatile ("vror.vx "VD", "VS2", %0;" :: "r"(vror_vx_rot_amount)); // Todo: test masking

  printf("\r\nStoring Rotated Data:\r\n");
  asm volatile ("vse32.v "VD", (%0);" :: "r"(vror_result));
  print_u32_arr(vl, vror_result);

  fail_count += compare_u32_results((size_t)(vl), vror_result, vror_vx_ref_result);

  /**************************** VROR.VI ***************************/

  printf("\r\n****** VROR.VI ******\r\n");

  // initialise VRF with zeroes
  init_vrf();

  // set vtype to SEW32, M1
  vl = __riscv_vsetvl_e32m1(AVL);

  printf("\r\nConfiguration:\r\n AVL = 0x%016lX,\r\n vl  = 0x%016lX\r\n", AVL, vl);

  printf("\r\nLoading Rotate Amount:\r\n");
  print_u32_arr(vl, vror_vv_data);
  asm volatile ("vle32.v "VS2", (%0);" :: "r"(vror_vv_data));

  printf("\r\nExecuting vror.vi with imm = 0x%08X\r\n", 0x8);
  asm volatile ("vror.vi "VD", "VS2", 0x8;"); // Todo: test masking

  printf("\r\nStoring Rotated Data:\r\n");
  asm volatile ("vse32.v "VD", (%0);" :: "r"(vror_result));
  print_u32_arr(vl, vror_result);

  fail_count += compare_u32_results((size_t)(vl), vror_result, vror_vi_ref_result);

  /**************************** Report Results ***************************/

  if(fail_count) {
    printf("\n********************* VC Bit Manipulation Test Failed! ************ \r\n");
    printf("Failures: %04d\r\n", fail_count);
    return 1;
  } else {    
    printf("\n********************* VC Bit Manipulation  Test Success! ************ \r\n");
    return 0;
  }
}

/*** FUNCTION DEFINITIONS ***/

void print_u32_arr(size_t elem_count, uint32_t* arr) {

  printf("\r\n");

  for(unsigned idx = 0; idx < elem_count; idx++ ){
    printf("[%02d] - 0x%08X\r\n", idx, *(arr++));
  }
}

uint32_t compare_u32_results(size_t elem_count, uint32_t* result_arr, uint32_t* ref_arr) {

  uint32_t fail_count = 0;

  for (size_t elem = 0; elem < elem_count; elem++) {

    if (result_arr[elem] != ref_arr[elem]) {
      printf("[WARN] - Comparison mismatch in element %04ld!\r\n", elem);
      printf("[Expected|Read] - 0x%08X|0x%08X\r\n", ref_arr[elem], result_arr[elem]);
      fail_count++;
    }
  }

  return fail_count;
}