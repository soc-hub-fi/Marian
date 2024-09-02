/*
 * File        : basic_gcm.c
 * Test        : AES-GCM
 * Author(s)   : Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
 * Date        : 25-jun-2024
 * Description : Basic tests to exercise AES-GCM instructions i.e.
 *              vghsh.vv
 *              vgmul.vv
 */

#include <stdint.h>
#include <stddef.h>

#include <riscv_vector.h>

#include "basic_gcm.h"
#include "encoding.h"
#include "printf.h"
#include "runtime.h"


int main(void) {

  volatile uint64_t AVL = TEST_VL;
  volatile uint64_t vl  = 0;
  // monitor failures throughout test execution           
  uint32_t fail_count = 0;

  printf("\r\n********* BASIC AES-GCM TEST *********\r\n");

  /**************************** VGHSH.VV ***************************/

  printf("\r\n****** VGHSH.VV ******\r\n");

  // initialise VRF to remove x's
  init_vrf();

  // set vtype to SEW32, M1
  vl = __riscv_vsetvl_e32m1(AVL);

  printf("\r\nConfiguration:\r\n AVL = 0x%016lX,\r\n vl  = 0x%016lX\r\n", AVL, vl);

  printf("\r\nLoading Partial Hash (Yi):\r\n");
  print_u32_arr(vl, gcm_part_hash);
  asm volatile ("vle32.v "VD", (%0);" :: "r"(gcm_part_hash));

  printf("\r\nLoading Hash Subkey (Hi):\r\n");
  print_u32_arr(vl, gcm_hash_skey);
  asm volatile ("vle32.v "VS2", (%0);" :: "r"(gcm_hash_skey));

  printf("\r\nLoading Cipher Text (Xi):\r\n");
  print_u32_arr(vl, gcm_cipher_text);
  asm volatile ("vle32.v "VS1", (%0);" :: "r"(gcm_cipher_text));

  printf("\r\nExecuting vghsh.vv\r\n");
  asm volatile ("vghsh.vv "VD", "VS2", "VS1);

  printf("\r\nStoring New Partial Hash(Yi+1):\r\n");
  asm volatile ("vse32.v "VD", (%0);" :: "r"(gcm_new_part_hash));
  print_u32_arr(vl, gcm_new_part_hash);

  fail_count += compare_u32_results((size_t)(vl), gcm_new_part_hash, gcm_ref_new_part_hash);

  /**************************** VGMUL.VV ***************************/

  printf("\r\n****** VGMUL.VV ******\r\n");

  // initialise VRF to remove x's
  init_vrf();

  // set vtype to SEW32, M1
  vl = __riscv_vsetvl_e32m1(AVL);

  printf("\r\nConfiguration:\r\n AVL = 0x%016lX,\r\n vl  = 0x%016lX\r\n", AVL, vl);

  printf("\r\nLoading Multiplier:\r\n");
  print_u32_arr(vl, gcm_multiplier);
  asm volatile ("vle32.v "VD", (%0);" :: "r"(gcm_multiplier));

  printf("\r\nLoading Multiplicand:\r\n");
  print_u32_arr(vl, gcm_multiplicand);
  asm volatile ("vle32.v "VS2", (%0);" :: "r"(gcm_multiplicand));

  printf("\r\nExecuting vgmul.vv\r\n");
  asm volatile ("vgmul.vv "VD", "VS2);

  printf("\r\nStoring Product:\r\n");
  asm volatile ("vse32.v "VD", (%0);" :: "r"(gcm_product));
  print_u32_arr(vl, gcm_product);

  fail_count += compare_u32_results((size_t)(vl), gcm_product, gcm_ref_product);

  /**************************** Report Results ***************************/

  if(fail_count) {
    printf("\n********************* Basic AES-GCM Test Failed! ************ \r\n");
    printf("Failures: %04d\r\n", fail_count);
    return 1;
  } else {    
    printf("\n********************* Basic AES-GCM  Test Success! ************ \r\n");
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