/*
 * File        : basic_aes.c
 * Test        : Basic test to exercise AES Encryption/Decryption hardware
 * Author(s)   : Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
 * Date        : 17-jun-2024
 * Description : Test to exercise the AES Vector Instructions i.e.
 *               vaesz.vs
 *               vaesem.vs
 *               vaesem.vv
 *               vaesef.vs
 *               vaesef.vv
 *               vaesdm.vs
 *               vaesdm.vv
 *               vaesdf.vs
 *               vaesdf.vv
 */

#include <stdint.h>
#include <stddef.h>

#include <riscv_vector.h>

#include "basic_aes.h"
#include "encoding.h"
#include "printf.h"
#include "runtime.h"


int main(void) {

  volatile uint64_t AVL = TEST_VL;
  volatile uint64_t vl  = 0;
  // monitor failures throughout test execution           
  uint32_t fail_count = 0;

  // performance counters
  volatile uint64_t aes_cycle_count_start, aes_cycle_count_end;
  volatile uint64_t aes_insnret_start, aes_insnret_end;

  printf("\r\n********* BASIC AES TEST *********\r\n");

  /**************************** VAESZ.VS ***************************/

  printf("\r\n****** VAESZ.VS ******\r\n");

  // initialise VRF to remove x's
  init_vrf();

  // set vtype to SEW32, M1
  vl = __riscv_vsetvl_e32m1(AVL);

  printf("\r\nConfiguration:\r\n AVL = 0x%016lX,\r\n vl  = 0x%016lX\r\n", AVL, vl);
  
  printf("\r\nLoading AES Round State:\r\n");
  print_u32_arr(vl, aesz_round_state);
  asm volatile ("vle32.v "VD", (%0);" :: "r"(aesz_round_state));

  printf("\r\nLoading AES Round Key:\r\n");
  print_u32_arr(vl, aesz_round_key);
  asm volatile ("vle32.v "VS2", (%0);" :: "r"(aesz_round_key));

  printf("\r\nExecuting vaesz.vs\r\n");
  aes_cycle_count_start = read_csr(cycle);
  aes_insnret_start     = read_csr(instret);
  asm volatile ("vaesz.vs "VD", "VS2);
  aes_cycle_count_end   = read_csr(cycle);
  aes_insnret_end       = read_csr(instret);
  
  printf("\r\nStoring New Round State:\r\n");
  asm volatile ("vse32.v "VD", (%0);" :: "r"(aesz_new_round_state));
  print_u32_arr(vl, aesz_new_round_state);

  fail_count += compare_u32_results((size_t)(vl), aesz_new_round_state, aesz_ref_round_state);

  // clear result arr
  for (unsigned i = 0; i < vl; i++) {
    aesz_new_round_state[i] = 0;
  }

  // print performance and clear counters
  printf("\nAES cycle count = %4lu\r\n", (aes_cycle_count_end - aes_cycle_count_start));
  printf("AES insn count  = %4lu\r\n", (aes_insnret_end - aes_insnret_start));
  aes_cycle_count_start = 0;
  aes_cycle_count_end   = 0;
  aes_insnret_start     = 0;
  aes_insnret_end       = 0;

  /**************************** VAESEM.VS ***************************/

  printf("\r\n****** VAESEM.VS ******\r\n");

  // initialise VRF to remove x's
  init_vrf();

  // set vtype to SEW32, M1
  vl = __riscv_vsetvl_e32m1(AVL);

  printf("\r\nConfiguration:\r\n AVL = 0x%016lX,\r\n vl  = 0x%016lX\r\n", AVL, vl);
  
  printf("\r\nLoading AES Round State:\r\n");
  print_u32_arr(vl, aesem_round_state);
  asm volatile ("vle32.v "VD", (%0);" :: "r"(aesem_round_state));

  printf("\r\nLoading AES Round Key:\r\n");
  print_u32_arr(vl, aesem_round_key);
  asm volatile ("vle32.v "VS2", (%0);" :: "r"(aesem_round_key));

  printf("\r\nExecuting vaesem.vs\r\n");
  aes_cycle_count_start = read_csr(cycle);
  aes_insnret_start     = read_csr(instret);
  asm volatile ("vaesem.vs "VD", "VS2);
  aes_cycle_count_end   = read_csr(cycle);
  aes_insnret_end       = read_csr(instret);

  printf("\r\nStoring New Round State:\r\n");
  asm volatile ("vse32.v "VD", (%0);" :: "r"(aesem_new_round_state));
  print_u32_arr(vl, aesem_new_round_state);

  fail_count += compare_u32_results((size_t)(vl), aesem_new_round_state, aesem_vs_ref_round_state);

  // clear result arr
  for (unsigned i = 0; i < vl; i++) {
    aesem_new_round_state[i] = 0;
  }

  // print performance and clear counters
  printf("\nAES cycle count = %4lu\r\n", (aes_cycle_count_end - aes_cycle_count_start));
  printf("AES insn count  = %4lu\r\n", (aes_insnret_end - aes_insnret_start));
  aes_cycle_count_start = 0;
  aes_cycle_count_end   = 0;
  aes_insnret_start     = 0;
  aes_insnret_end       = 0;

  /**************************** VAESEM.VV ***************************/

  printf("\r\n****** VAESEM.VV ******\r\n");

  // initialise VRF to remove x's
  init_vrf();

  // set vtype to SEW32, M1
  vl = __riscv_vsetvl_e32m1(AVL);

  printf("\r\nConfiguration:\r\n AVL = 0x%016lX,\r\n vl  = 0x%016lX\r\n", AVL, vl);
  
  printf("\r\nLoading AES Round State:\r\n");
  print_u32_arr(vl, aesem_round_state);
  asm volatile ("vle32.v "VD", (%0);" :: "r"(aesem_round_state));

  printf("\r\nLoading AES Round Key:\r\n");
  print_u32_arr(vl, aesem_round_key);
  asm volatile ("vle32.v "VS2", (%0);" :: "r"(aesem_round_key));

  printf("\r\nExecuting vaesem.vv\r\n");
  aes_cycle_count_start = read_csr(cycle);
  aes_insnret_start     = read_csr(instret);
  asm volatile ("vaesem.vv "VD", "VS2);
  aes_cycle_count_end   = read_csr(cycle);
  aes_insnret_end       = read_csr(instret);

  printf("\r\nStoring New Round State:\r\n");
  asm volatile ("vse32.v "VD", (%0);" :: "r"(aesem_new_round_state));
  print_u32_arr(vl, aesem_new_round_state);

  fail_count += compare_u32_results((size_t)(vl), aesem_new_round_state, aesem_vv_ref_round_state);

  // clear result arr
  for (unsigned i = 0; i < vl; i++) {
    aesem_new_round_state[i] = 0;
  }

  // print performance and clear counters
  printf("\nAES cycle count = %4lu\r\n", (aes_cycle_count_end - aes_cycle_count_start));
  printf("AES insn count  = %4lu\r\n", (aes_insnret_end - aes_insnret_start));
  aes_cycle_count_start = 0;
  aes_cycle_count_end   = 0;
  aes_insnret_start     = 0;
  aes_insnret_end       = 0;

  /**************************** VAESEF.VS ***************************/

  printf("\r\n****** VAESEF.VS ******\r\n");

  // initialise VRF to remove x's
  init_vrf();

  // set vtype to SEW32, M1
  vl = __riscv_vsetvl_e32m1(AVL);

  printf("\r\nConfiguration:\r\n AVL = 0x%016lX,\r\n vl  = 0x%016lX\r\n", AVL, vl);
  
  printf("\r\nLoading AES Round State:\r\n");
  print_u32_arr(vl, aesef_round_state);
  asm volatile ("vle32.v "VD", (%0);" :: "r"(aesef_round_state));

  printf("\r\nLoading AES Round Key:\r\n");
  print_u32_arr(vl, aesef_round_key);
  asm volatile ("vle32.v "VS2", (%0);" :: "r"(aesef_round_key));

  printf("\r\nExecuting vaesef.vs\r\n");
  aes_cycle_count_start = read_csr(cycle);
  aes_insnret_start     = read_csr(instret);
  asm volatile ("vaesef.vs "VD", "VS2);
  aes_cycle_count_end   = read_csr(cycle);
  aes_insnret_end       = read_csr(instret);

  printf("\r\nStoring New Round State:\r\n");
  asm volatile ("vse32.v "VD", (%0);" :: "r"(aesef_new_round_state));
  print_u32_arr(vl, aesef_new_round_state);

  fail_count += compare_u32_results((size_t)(vl), aesef_new_round_state, aesef_vs_ref_round_state);

  // clear result arr
  for (unsigned i = 0; i < vl; i++) {
    aesef_new_round_state[i] = 0;
  }

  // print performance and clear counters
  printf("\nAES cycle count = %4lu\r\n", (aes_cycle_count_end - aes_cycle_count_start));
  printf("AES insn count  = %4lu\r\n", (aes_insnret_end - aes_insnret_start));
  aes_cycle_count_start = 0;
  aes_cycle_count_end   = 0;
  aes_insnret_start     = 0;
  aes_insnret_end       = 0;

  /**************************** VAESEF.VV ***************************/

  printf("\r\n****** VAESEF.VV ******\r\n");

  // initialise VRF to remove x's
  init_vrf();

  // set vtype to SEW32, M1
  vl = __riscv_vsetvl_e32m1(AVL);

  printf("\r\nConfiguration:\r\n AVL = 0x%016lX,\r\n vl  = 0x%016lX\r\n", AVL, vl);
  
  printf("\r\nLoading AES Round State:\r\n");
  print_u32_arr(vl, aesef_round_state);
  asm volatile ("vle32.v "VD", (%0);" :: "r"(aesef_round_state));

  printf("\r\nLoading AES Round Key:\r\n");
  print_u32_arr(vl, aesef_round_key);
  asm volatile ("vle32.v "VS2", (%0);" :: "r"(aesef_round_key));

  printf("\r\nExecuting vaesef.vv\r\n");
  aes_cycle_count_start = read_csr(cycle);
  aes_insnret_start     = read_csr(instret);
  asm volatile ("vaesef.vv "VD", "VS2);
  aes_cycle_count_end   = read_csr(cycle);
  aes_insnret_end       = read_csr(instret);

  printf("\r\nStoring New Round State:\r\n");
  asm volatile ("vse32.v "VD", (%0);" :: "r"(aesef_new_round_state));
  print_u32_arr(vl, aesef_new_round_state);

  fail_count += compare_u32_results((size_t)(vl), aesef_new_round_state, aesef_vv_ref_round_state);

  // clear result arr
  for (unsigned i = 0; i < vl; i++) {
    aesef_new_round_state[i] = 0;
  }

  // print performance and clear counters
  printf("\nAES cycle count = %4lu\r\n", (aes_cycle_count_end - aes_cycle_count_start));
  printf("AES insn count  = %4lu\r\n", (aes_insnret_end - aes_insnret_start));
  aes_cycle_count_start = 0;
  aes_cycle_count_end   = 0;
  aes_insnret_start     = 0;
  aes_insnret_end       = 0;

  /**************************** VAESDM.VS ***************************/

  printf("\r\n****** VAESDM.VS ******\r\n");

  // initialise VRF to remove x's
  init_vrf();

  // set vtype to SEW32, M1
  vl = __riscv_vsetvl_e32m1(AVL);

  printf("\r\nConfiguration:\r\n AVL = 0x%016lX,\r\n vl  = 0x%016lX\r\n", AVL, vl);
  
  printf("\r\nLoading AES Round State:\r\n");
  print_u32_arr(vl, aesdm_round_state);
  asm volatile ("vle32.v "VD", (%0);" :: "r"(aesdm_round_state));

  printf("\r\nLoading AES Round Key:\r\n");
  print_u32_arr(vl, aesdm_round_key);
  asm volatile ("vle32.v "VS2", (%0);" :: "r"(aesdm_round_key));

  printf("\r\nExecuting vaesdm.vs\r\n");
  aes_cycle_count_start = read_csr(cycle);
  aes_insnret_start     = read_csr(instret);
  asm volatile ("vaesdm.vs "VD", "VS2);
  aes_cycle_count_end   = read_csr(cycle);
  aes_insnret_end       = read_csr(instret);

  printf("\r\nStoring New Round State:\r\n");
  asm volatile ("vse32.v "VD", (%0);" :: "r"(aesdm_new_round_state));
  print_u32_arr(vl, aesdm_new_round_state);

  fail_count += compare_u32_results((size_t)(vl), aesdm_new_round_state, aesdm_vs_ref_round_state);

  // clear result arr
  for (unsigned i = 0; i < vl; i++) {
    aesdm_new_round_state[i] = 0;
  }

  // print performance and clear counters
  printf("\nAES cycle count = %4lu\r\n", (aes_cycle_count_end - aes_cycle_count_start));
  printf("AES insn count  = %4lu\r\n", (aes_insnret_end - aes_insnret_start));
  aes_cycle_count_start = 0;
  aes_cycle_count_end   = 0;
  aes_insnret_start     = 0;
  aes_insnret_end       = 0;

  /**************************** VAESDM.VV ***************************/

  printf("\r\n****** VAESDM.VV ******\r\n");

  // initialise VRF to remove x's
  init_vrf();

  // set vtype to SEW32, M1
  vl = __riscv_vsetvl_e32m1(AVL);

  printf("\r\nConfiguration:\r\n AVL = 0x%016lX,\r\n vl  = 0x%016lX\r\n", AVL, vl);
  
  printf("\r\nLoading AES Round State:\r\n");
  print_u32_arr(vl, aesdm_round_state);
  asm volatile ("vle32.v "VD", (%0);" :: "r"(aesdm_round_state));

  printf("\r\nLoading AES Round Key:\r\n");
  print_u32_arr(vl, aesdm_round_key);
  asm volatile ("vle32.v "VS2", (%0);" :: "r"(aesdm_round_key));

  printf("\r\nExecuting vaesdm.vv\r\n");
  aes_cycle_count_start = read_csr(cycle);
  aes_insnret_start     = read_csr(instret);
  asm volatile ("vaesdm.vv "VD", "VS2);
  aes_cycle_count_end   = read_csr(cycle);
  aes_insnret_end       = read_csr(instret);

  printf("\r\nStoring New Round State:\r\n");
  asm volatile ("vse32.v "VD", (%0);" :: "r"(aesdm_new_round_state));
  print_u32_arr(vl, aesdm_new_round_state);

  fail_count += compare_u32_results((size_t)(vl), aesdm_new_round_state, aesdm_vv_ref_round_state);

  // clear result arr
  for (unsigned i = 0; i < vl; i++) {
    aesdm_new_round_state[i] = 0;
  }

  // print performance and clear counters
  printf("\nAES cycle count = %4lu\r\n", (aes_cycle_count_end - aes_cycle_count_start));
  printf("AES insn count  = %4lu\r\n", (aes_insnret_end - aes_insnret_start));
  aes_cycle_count_start = 0;
  aes_cycle_count_end   = 0;
  aes_insnret_start     = 0;
  aes_insnret_end       = 0;

  /**************************** VAESDF.VS ***************************/

  printf("\r\n****** VAESDF.VS ******\r\n");

  // initialise VRF to remove x's
  init_vrf();

  // set vtype to SEW32, M1
  vl = __riscv_vsetvl_e32m1(AVL);

  printf("\r\nConfiguration:\r\n AVL = 0x%016lX,\r\n vl  = 0x%016lX\r\n", AVL, vl);
  
  printf("\r\nLoading AES Round State:\r\n");
  print_u32_arr(vl, aesdf_round_state);
  asm volatile ("vle32.v "VD", (%0);" :: "r"(aesdf_round_state));

  printf("\r\nLoading AES Round Key:\r\n");
  print_u32_arr(vl, aesdf_round_key);
  asm volatile ("vle32.v "VS2", (%0);" :: "r"(aesdf_round_key));

  printf("\r\nExecuting vaesdf.vs\r\n");
  aes_cycle_count_start = read_csr(cycle);
  aes_insnret_start     = read_csr(instret);
  asm volatile ("vaesdf.vs "VD", "VS2);
  aes_cycle_count_end   = read_csr(cycle);
  aes_insnret_end       = read_csr(instret);

  printf("\r\nStoring New Round State:\r\n");
  asm volatile ("vse32.v "VD", (%0);" :: "r"(aesdf_new_round_state));
  print_u32_arr(vl, aesdf_new_round_state);

  fail_count += compare_u32_results((size_t)(vl), aesdf_new_round_state, aesdf_vs_ref_round_state);

  // clear result arr
  for (unsigned i = 0; i < vl; i++) {
    aesdf_new_round_state[i] = 0;
  }

  // print performance and clear counters
  printf("\nAES cycle count = %4lu\r\n", (aes_cycle_count_end - aes_cycle_count_start));
  printf("AES insn count  = %4lu\r\n", (aes_insnret_end - aes_insnret_start));
  aes_cycle_count_start = 0;
  aes_cycle_count_end   = 0;
  aes_insnret_start     = 0;
  aes_insnret_end       = 0;

  /**************************** VAESDF.VV ***************************/

  printf("\r\n****** VAESDF.VV ******\r\n");

  // initialise VRF to remove x's
  init_vrf();

  // set vtype to SEW32, M1
  vl = __riscv_vsetvl_e32m1(AVL);

  printf("\r\nConfiguration:\r\n AVL = 0x%016lX,\r\n vl  = 0x%016lX\r\n", AVL, vl);
  
  printf("\r\nLoading AES Round State:\r\n");
  print_u32_arr(vl, aesdf_round_state);
  asm volatile ("vle32.v "VD", (%0);" :: "r"(aesdf_round_state));

  printf("\r\nLoading AES Round Key:\r\n");
  print_u32_arr(vl, aesdf_round_key);
  asm volatile ("vle32.v "VS2", (%0);" :: "r"(aesdf_round_key));

  printf("\r\nExecuting vaesdf.vv\r\n");
  aes_cycle_count_start = read_csr(cycle);
  aes_insnret_start     = read_csr(instret);
  asm volatile ("vaesdf.vv "VD", "VS2);
  aes_cycle_count_end   = read_csr(cycle);
  aes_insnret_end       = read_csr(instret);

  printf("\r\nStoring New Round State:\r\n");
  asm volatile ("vse32.v "VD", (%0);" :: "r"(aesdf_new_round_state));
  print_u32_arr(vl, aesdf_new_round_state);

  fail_count += compare_u32_results((size_t)(vl), aesdf_new_round_state, aesdf_vv_ref_round_state);

  // clear result arr
  for (unsigned i = 0; i < vl; i++) {
    aesdf_new_round_state[i] = 0;
  }

  // print performance and clear counters
  printf("\nAES cycle count = %4lu\r\n", (aes_cycle_count_end - aes_cycle_count_start));
  printf("AES insn count  = %4lu\r\n", (aes_insnret_end - aes_insnret_start));
  aes_cycle_count_start = 0;
  aes_cycle_count_end   = 0;
  aes_insnret_start     = 0;
  aes_insnret_end       = 0;

  /**************************** Report Results ***************************/

  if(fail_count) {
    printf("\n********************* Basic AES Test Failed! ************ \r\n");
    printf("Failures: %04d\r\n", fail_count);
    return 1;
  } else {    
    printf("\n********************* Basic AES  Test Success! ************ \r\n");
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
      printf("[WARN] - Comparison mismatch in element %04d!\r\n", elem);
      printf("[Expected|Read] - 0x%08X|0x%08X\r\n", ref_arr[elem], result_arr[elem]);
      fail_count++;
    }
  }

  return fail_count;
}