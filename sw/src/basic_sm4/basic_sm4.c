/*
 * File        : basic_sm4.c
 * Test        : Basic test to exercise SM4 Encryption/Decryption hardware
 * Author(s)   : Endrit Isufi <endrit.isufi@tuni.fi>
 * Date        : 18-jul-2024
 * Description : Test to exercise the SM4 Vector Instructions i.e.
 *               vsm4k.vi
 *               vsm4r.vv
 *               vsm4r.vs
 */
#include <riscv_vector.h>

#include "encoding.h"
#include "basic_sm4.h"
#include <stdint.h>
#include <stddef.h>
#include "runtime.h"
#include "printf.h"

int main(void)
{
  volatile uint64_t AVL = TEST_VL;
  volatile uint64_t vl  = 0u;
  // count failures
  uint32_t fail_count = 0u;

  // performance counters
  volatile uint64_t sm_count_start, sm_count_end;
  volatile uint64_t sm_insnret_start, sm_insnret_end;

  printf("\r\n************ BASIC SM4 TEST ************\r\n");
  
  /**************************  VSM4K.vi **********************/

  //initilise VRF to remove X's
  init_vrf();

  //set vtype to SEW32, M1
  vl = __riscv_vsetvl_e32m1(AVL);
  printf("\r\nConfiguration:\r\n AVL = 0x%016lX,\r\n vl  = 0x%016lX\r\n", AVL, vl);

  printf("\r\nLoading SM4 Round Keys:\r\n");
  print_u32_arr(vl, sm4_round_keys);
  asm volatile ("vle32.v "VS2", (%0);" :: "r"(sm4_round_keys));

  printf("\r\nExecuting vsm4k.vi\r\n");
  sm_count_start = read_csr(cycle);
  sm_insnret_start     = read_csr(instret);
  asm volatile ("vsm4k.vi "VD", "VS2", 1u;");
  sm_count_end   = read_csr(cycle);
  sm_insnret_end       = read_csr(instret);

  printf("\r\nStoring New Round Keys:\r\n");
  asm volatile ("vse32.v "VD", (%0);" :: "r"(new_round_keys));
  print_u32_arr(vl, new_round_keys);

  fail_count += compare_u32_results((size_t)(vl), new_round_keys, ref_round_keys_0);

    // clear result arr
  for (unsigned i = 0; i < vl; i++) {
    new_round_keys[i] = 0;
  }
  
  // print performance and clear counters
  printf("\nSM4 cycle count = %4lu\r\n", (sm_count_end - sm_count_start));
  printf("SM4 insn count  = %4lu\r\n", (sm_insnret_end - sm_insnret_start));
  sm_count_start    = 0;
  sm_count_end      = 0;
  sm_insnret_start  = 0;
  sm_insnret_end    = 0;

  printf("\r\nLoading new round keys:\r\n");
  asm volatile ("vle32.v "VS2", (%0);" :: "r"(sm4_round_keys));
  print_u32_arr(vl, sm4_round_keys);
  printf("\r\nLoading SM4 current state:\r\n");
  asm volatile ("vle32.v "VD", (%0);" :: "r"(sm4_state0));
  print_u32_arr(vl, sm4_state0);

  printf("\r\nExecuting vsm4r.vv\r\n");
  sm_count_start = read_csr(cycle);
  sm_insnret_start     = read_csr(instret);
  asm volatile ("vsm4r.vv "VD", "VS2";");
  sm_count_end   = read_csr(cycle);
  sm_insnret_end       = read_csr(instret);

printf("\r\nStoring New state:\r\n");
  asm volatile ("vse32.v "VD", (%0);" :: "r"(new_cipher));
  print_u32_arr(vl, new_cipher);


  fail_count += compare_u32_results((size_t)(vl), new_cipher, ref_cipher_0);

    // clear result arr
  for (unsigned i = 0; i < vl; i++) {
    new_cipher[i]     = 0;
  }

  // print performance and clear counters
  printf("\nSM4 cycle count = %4lu\r\n", (sm_count_end - sm_count_start));
  printf("SM4 insn count  = %4lu\r\n", (sm_insnret_end - sm_insnret_start));
  sm_count_start    = 0;
  sm_count_end      = 0;
  sm_insnret_start  = 0;
  sm_insnret_end    = 0;


  printf("\r\nLoading new round keys:\r\n");
  asm volatile ("vle32.v "VS2", (%0);" :: "r"(sm4_round_keys));
  print_u32_arr(vl, sm4_round_keys);
  printf("\r\nLoading SM4 current state:\r\n");
  asm volatile ("vle32.v "VD", (%0);" :: "r"(sm4_state0));
  print_u32_arr(vl, sm4_state0);

  printf("\r\nExecuting vsm4r.vs\r\n");
  sm_count_start = read_csr(cycle);
  sm_insnret_start     = read_csr(instret);
  asm volatile ("vsm4r.vs "VD", "VS2";");
  sm_count_end   = read_csr(cycle);
  sm_insnret_end       = read_csr(instret);

printf("\r\nStoring New state:\r\n");
  asm volatile ("vse32.v "VD", (%0);" :: "r"(new_cipher));
  print_u32_arr(vl, new_cipher);


  fail_count += compare_u32_results((size_t)(vl), new_cipher, ref_cipher_0);

    // clear result arr
  for (unsigned i = 0; i < vl; i++) {
    new_cipher[i]     = 0;
  }

  // print performance and clear counters
  printf("\nSM4 cycle count = %4lu\r\n", (sm_count_end - sm_count_start));
  printf("SM4 insn count  = %4lu\r\n", (sm_insnret_end - sm_insnret_start));
  sm_count_start    = 0;
  sm_count_end      = 0;
  sm_insnret_start  = 0;
  sm_insnret_end    = 0;

  if(fail_count) {
    printf("\n********************* Basic SM4 Test Failed! ************ \r\n");
    printf("Failures: %04d\r\n", fail_count);
    return 1;
  } else {    
    printf("\n********************* Basic SM4  Test Success! ************ \r\n");
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