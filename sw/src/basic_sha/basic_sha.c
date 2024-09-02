/*
 * File        : basic_sha.c
 * Test        : Basic test to exercise SHA-2 hash hardware
 * Author(s)   : Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
 * Date        : 19-jun-2024
 * Description : Test to exercise the SHA-2 Vector Instructions i.e.
 *               vsha2ch.vv (SEW32 + SEW64),
 *               vsha2cl.vv (SEW32 + SEW64),
 *               vsha2ms.vv (SEW32 + SEW64)
 */

#include <stdint.h>

#include <riscv_vector.h>

#include "basic_sha.h"
#include "encoding.h"
#include "printf.h"
#include "runtime.h"

int main(void) {

  volatile uint64_t AVL = TEST_VL;
  volatile uint64_t vl  = 0;
  // monitor failures throughout test execution           
  uint32_t fail_count = 0;

  printf("\r\n********* BASIC SHA-2 TEST *********\r\n");

  /************************ VSHA2CH.VV (SEW32) ************************/

  printf("\r\n****** VSHA2CH.VV (SEW32) ******\r\n");

  // initialise VRF to remove x's
  init_vrf();

  // configure vtype
  vl = __riscv_vsetvl_e32m1(AVL);

  printf("\nConfiguration:\r\n AVL = 0x%016lX,\r\n vl  = 0x%016lX\r\n", AVL, vl);

  printf("\nLoading curr state {c, d, g, h}:\r\n");
  print_u32_arr(vl, sha2_c_state_0_32);
  asm volatile ("vle32.v "VD", (%0);" :: "r"(sha2_c_state_0_32));

  printf("\nLoading curr state {a, b, e, f}:\r\n");
  print_u32_arr(vl, sha2_c_state_1_32);
  asm volatile ("vle32.v "VS2", (%0);" :: "r"(sha2_c_state_1_32));
  
  printf("\nLoading Msg Sched + Const:\r\n");
  print_u32_arr(vl, sha2_msg_sched_32);
  asm volatile ("vle32.v "VS1", (%0);" :: "r"(sha2_msg_sched_32));

  printf("\nExecuting vsha2ch.vv\r\n");
  asm volatile ("vsha2ch.vv "VD",  "VS2", "VS1);

  printf("\r\nStoring Next State:\r\n");
  asm volatile ("vse32.v "VD", (%0);" :: "r"(sha2_n_state_32));
  print_u32_arr(vl, sha2_n_state_32);

  fail_count += compare_u32_results((size_t)(vl), sha2_n_state_32, sha2_n_state_hi_ref_32);

  // clear result arr
  for (unsigned i = 0; i < vl; i++) {
    sha2_n_state_32[i] = 0;
  }

  /************************ VSHA2CL.VV (SEW32) ************************/

  printf("\r\n****** VSHA2CL.VV (SEW32) ******\r\n");

  // initialise VRF to remove x's
  init_vrf();

  // configure vtype
  vl = __riscv_vsetvl_e32m1(AVL);

  printf("\nConfiguration:\r\n AVL = 0x%016lX,\r\n vl  = 0x%016lX\r\n", AVL, vl);

  printf("\nLoading curr state {c, d, g, h}:\r\n");
  print_u32_arr(vl, sha2_c_state_0_32);
  asm volatile ("vle32.v "VD", (%0);" :: "r"(sha2_c_state_0_32));

  printf("\nLoading curr state {a, b, e, f}:\r\n");
  print_u32_arr(vl, sha2_c_state_1_32);
  asm volatile ("vle32.v "VS2", (%0);" :: "r"(sha2_c_state_1_32));
  
  printf("\nLoading Msg Sched + Const:\r\n");
  print_u32_arr(vl, sha2_msg_sched_32);
  asm volatile ("vle32.v "VS1", (%0);" :: "r"(sha2_msg_sched_32));

  printf("\nExecuting vsha2cl.vv\r\n");
  asm volatile ("vsha2cl.vv "VD",  "VS2", "VS1);

  printf("\r\nStoring Next State:\r\n");
  asm volatile ("vse32.v "VD", (%0);" :: "r"(sha2_n_state_32));
  print_u32_arr(vl, sha2_n_state_32);

  fail_count += compare_u32_results((size_t)(vl), sha2_n_state_32, sha2_n_state_lo_ref_32);

  // clear result arr
  for (unsigned i = 0; i < vl; i++) {
    sha2_n_state_32[i] = 0;
  }

  /************************ VSHA2CH.VV (SEW64) ************************/

  printf("\r\n****** VSHA2CH.VV (SEW64) ******\r\n");

  // initialise VRF to remove x's
  init_vrf();

  // configure vtype
  vl = __riscv_vsetvl_e64m1(AVL);

  printf("\nConfiguration:\r\n AVL = 0x%016lX,\r\n vl  = 0x%016lX\r\n", AVL, vl);

  printf("\nLoading curr state {c, d, g, h}:\r\n");
  print_u64_arr(vl, sha2_c_state_0_64);
  asm volatile ("vle64.v "VD", (%0);" :: "r"(sha2_c_state_0_64));

  printf("\nLoading curr state {a, b, e, f}:\r\n");
  print_u64_arr(vl, sha2_c_state_1_64);
  asm volatile ("vle64.v "VS2", (%0);" :: "r"(sha2_c_state_1_64));
  
  printf("\nLoading Msg Sched + Const:\r\n");
  print_u64_arr(vl, sha2_msg_sched_64);
  asm volatile ("vle64.v "VS1", (%0);" :: "r"(sha2_msg_sched_64));

  printf("\nExecuting vsha2ch.vv\r\n");
  asm volatile ("vsha2ch.vv "VD",  "VS2", "VS1);

  printf("\r\nStoring Next State:\r\n");
  asm volatile ("vse64.v "VD", (%0);" :: "r"(sha2_n_state_64));
  print_u64_arr(vl, sha2_n_state_64);

  fail_count += compare_u64_results((size_t)(vl), sha2_n_state_64, sha2_n_state_hi_ref_64);

  // clear result arr
  for (unsigned i = 0; i < vl; i++) {
    sha2_n_state_64[i] = 0;
  }

  /************************ VSHA2CL.VV (SEW64) ************************/

  printf("\r\n****** VSHA2CL.VV (SEW64) ******\r\n");

  // initialise VRF to remove x's
  init_vrf();

  // configure vtype
  vl = __riscv_vsetvl_e64m1(AVL);

  printf("\nConfiguration:\r\n AVL = 0x%016lX,\r\n vl  = 0x%016lX\r\n", AVL, vl);

  printf("\nLoading curr state {c, d, g, h}:\r\n");
  print_u64_arr(vl, sha2_c_state_0_64);
  asm volatile ("vle64.v "VD", (%0);" :: "r"(sha2_c_state_0_64));

  printf("\nLoading curr state {a, b, e, f}:\r\n");
  print_u64_arr(vl, sha2_c_state_1_64);
  asm volatile ("vle64.v "VS2", (%0);" :: "r"(sha2_c_state_1_64));
  
  printf("\nLoading Msg Sched + Const:\r\n");
  print_u64_arr(vl, sha2_msg_sched_64);
  asm volatile ("vle64.v "VS1", (%0);" :: "r"(sha2_msg_sched_64));

  printf("\nExecuting vsha2cl.vv\r\n");
  asm volatile ("vsha2cl.vv "VD",  "VS2", "VS1);

  printf("\r\nStoring Next State:\r\n");
  asm volatile ("vse64.v "VD", (%0);" :: "r"(sha2_n_state_64));
  print_u64_arr(vl, sha2_n_state_64);

  fail_count += compare_u64_results((size_t)(vl), sha2_n_state_64, sha2_n_state_lo_ref_64);

  // clear result arr
  for (unsigned i = 0; i < vl; i++) {
    sha2_n_state_64[i] = 0;
  }

  /************************ VSHA2MS.VV (SEW32) ************************/

  printf("\r\n****** VSHA2MS.VV (SEW32) ******\r\n");

  // initialise VRF to remove x's
  init_vrf();

  // configure vtype
  vl = __riscv_vsetvl_e32m1(AVL);

  printf("\nConfiguration:\r\n AVL = 0x%016lX,\r\n vl  = 0x%016lX\r\n", AVL, vl);

  printf("\nLoading msg words [3:0]:\r\n");
  print_u32_arr(vl, sha2_msg_0_32);
  asm volatile ("vle32.v "VD", (%0);" :: "r"(sha2_msg_0_32));

  printf("\nmsg words [11, 10, 9, 4]:\r\n");
  print_u32_arr(vl, sha2_msg_1_32);
  asm volatile ("vle32.v "VS2", (%0);" :: "r"(sha2_msg_1_32));
  
  printf("\nLoading msg words [15, 14, -, 12]:\r\n");
  print_u32_arr(vl, sha2_msg_2_32);
  asm volatile ("vle32.v "VS1", (%0);" :: "r"(sha2_msg_2_32));

  printf("\nExecuting vsha2ms.vv\r\n");
  asm volatile ("vsha2ms.vv "VD",  "VS2", "VS1);

  printf("\r\nStoring msg words [19:16]:\r\n");
  asm volatile ("vse32.v "VD", (%0);" :: "r"(sha2_msg_3_32));
  print_u32_arr(vl, sha2_msg_3_32);

  fail_count += compare_u32_results((size_t)(vl), sha2_msg_3_32, sha2_msg_3_ref_32);

  // clear result arr
  for (unsigned i = 0; i < vl; i++) {
    sha2_n_state_32[i] = 0;
  }

  /************************ VSHA2MS.VV (SEW64) ************************/

  printf("\r\n****** VSHA2MS.VV (SEW64) ******\r\n");

  // initialise VRF to remove x's
  init_vrf();

  // configure vtype
  vl = __riscv_vsetvl_e64m1(AVL);

  printf("\nConfiguration:\r\n AVL = 0x%016lX,\r\n vl  = 0x%016lX\r\n", AVL, vl);

  printf("\nLoading msg words [3:0]:\r\n");
  print_u64_arr(vl, sha2_msg_0_64);
  asm volatile ("vle64.v "VD", (%0);" :: "r"(sha2_msg_0_64));

  printf("\nmsg words [11, 10, 9, 4]:\r\n");
  print_u64_arr(vl, sha2_msg_1_64);
  asm volatile ("vle64.v "VS2", (%0);" :: "r"(sha2_msg_1_64));
  
  printf("\nLoading msg words [15, 14, -, 12]:\r\n");
  print_u64_arr(vl, sha2_msg_2_64);
  asm volatile ("vle64.v "VS1", (%0);" :: "r"(sha2_msg_2_64));

  printf("\nExecuting vsha2ms.vv\r\n");
  asm volatile ("vsha2ms.vv "VD",  "VS2", "VS1);

  printf("\r\nStoring msg words [19:16]:\r\n");
  asm volatile ("vse64.v "VD", (%0);" :: "r"(sha2_msg_3_64));
  print_u64_arr(vl, sha2_msg_3_64);

  fail_count += compare_u64_results((size_t)(vl), sha2_msg_3_64, sha2_msg_3_ref_64);

  // clear result arr
  for (unsigned i = 0; i < vl; i++) {
    sha2_n_state_32[i] = 0;
  }

  /**************************** Report Results ***************************/

  if(fail_count) {
    printf("\n********************* Basic SHA-2 Test Failed! ************ \r\n");
    printf("Failures: %04d\r\n", fail_count);
    return 1;
  } else {    
    printf("\n********************* Basic SHA-2  Test Success! ************ \r\n");
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

void print_u64_arr(size_t elem_count, uint64_t* arr) {

  printf("\r\n");

  for(unsigned idx = 0; idx < elem_count; idx++ ){
    printf("[%02d] - 0x%016lX\r\n", idx, *(arr++));
  }
}

uint32_t compare_u32_results(size_t elem_count, uint32_t* result_arr, uint32_t* ref_arr) {

  uint32_t fail_count = 0;

  for (size_t elem = 0; elem < elem_count; elem++) {

    if (result_arr[elem] != ref_arr[elem]) {
      printf("[WARN] - Comparison mismatch in element %04d!\r\n", elem);
      printf("[Expected|Read] - 0x%08X|0x%08X\r\n", ref_arr[elem], result_arr[elem]);
      fail_count++;
    }
  }

  return fail_count;
}

uint32_t compare_u64_results(size_t elem_count, uint64_t* result_arr, uint64_t* ref_arr) {

  uint32_t fail_count = 0;

  for (size_t elem = 0; elem < elem_count; elem++) {

    if (result_arr[elem] != ref_arr[elem]) {
      printf("[WARN] - Comparison mismatch in element %04d!\r\n", elem);
      printf("[Expected|Read] - 0x%016lX|0x%016lX\r\n", ref_arr[elem], result_arr[elem]);
      fail_count++;
    }
  }

  return fail_count;
}