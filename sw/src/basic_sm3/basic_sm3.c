/*
 * File        : basic_sm3.c
 * Test        : Basic test to exercise AES Encryption/Decryption hardware
 * Author(s)   : Endrit Isufi <endrit.isufi@tuni.fi>
 * Date        : 18-jul-2024
 * Description : Test to exercise the SM4 Vector Instructions i.e.
 *               vsm3c.vi
 *               vsm3me.vv
 * 
 * NOTE: SM3 specs presents words in big-endian
 */
#include <riscv_vector.h>

#include "encoding.h"
#include "basic_sm3.h"
#include <stdint.h>
#include <stddef.h>
#include "runtime.h"
#include "printf.h"


int main(void){
  volatile uint64_t AVL = TEST_VL;
  volatile uint64_t vl  = 0u;
  // count failures
  uint32_t fail_count = 0u;

  // performance counters
  volatile uint64_t sm_count_start, sm_count_end;
  volatile uint64_t sm_insnret_start, sm_insnret_end;

  //initilise VRF to remove X's
  init_vrf();

  //set vtype to SEW32, M1
  vl = __riscv_vsetvl_e32m1(AVL);
  printf("\r\nConfiguration:\r\n AVL = 0x%016lX,\r\n vl  = 0x%016lX\r\n", AVL, vl);

  printf("\r\n************ BASIC SM3 TEST ************\r\n");


  /*--------------vsm3me.vv--------------------*/
  printf("\r\nLoading SM3 words[7:0]:\r\n");
  print_u32_arr(vl, message_words_0);
  asm volatile ("vle32.v "VS1", (%0);" :: "r"(message_words_0));
  printf("\r\nLoading SM3 words[15:8]:\r\n");
  print_u32_arr(vl, message_words_1);
  asm volatile ("vle32.v "VS2", (%0);" :: "r"(message_words_1));

  printf("\r\nExecuting vsm3me.vv\r\n");
  sm_count_start = read_csr(cycle);
  sm_insnret_start     = read_csr(instret);
  asm volatile ("vsm3me.vv "VD", "VS2", "VS1";");
  sm_count_end   = read_csr(cycle);
  sm_insnret_end       = read_csr(instret);

  printf("\r\nStoring New Round Keys:\r\n");
  asm volatile ("vse32.v "VD", (%0);" :: "r"(result));
  print_u32_arr(vl, result);

  fail_count += compare_u32_results((size_t)(vl), result, message_words_ref_1);

    // clear result arr
  for (unsigned i = 0; i < vl; i++) {
    result[i] = 0;
  }
  
  // print performance and clear counters
  printf("\nSM4 cycle count = %4lu\r\n", (sm_count_end - sm_count_start));
  printf("SM4 insn count  = %4lu\r\n", (sm_insnret_end - sm_insnret_start));
  sm_count_start    = 0;
  sm_count_end      = 0;
  sm_insnret_start  = 0;
  sm_insnret_end    = 0;

  
/**************************  VSM3c.vi **********************/

/*--------------vsm3c.vi--------------------*/
  printf("\r\nLoading SM3 current state:\r\n");
  print_u32_arr(vl, current_state_big_endian);
  asm volatile ("vle32.v "VD", (%0);" :: "r"(current_state_big_endian));
  printf("\r\nLoading SM3 message words:\r\n");
  print_u32_arr(vl, message_words_0);
  asm volatile ("vle32.v "VS2", (%0);" :: "r"(message_words_0));

  printf("\r\nExecuting vsm3c.vi\r\n");
  sm_count_start = read_csr(cycle);
  sm_insnret_start     = read_csr(instret);
  asm volatile ("vsm3c.vi "VD", "VS2", 0;");
  sm_count_end   = read_csr(cycle);
  sm_insnret_end       = read_csr(instret);

  printf("\r\nStoring New Round Keys:\r\n");
  asm volatile ("vse32.v "VD", (%0);" :: "r"(result));
  print_u32_arr(vl, result);

  fail_count += compare_u32_results((size_t)(vl), result, next_state_big_endian);

    // clear result arr
  for (unsigned i = 0; i < vl; i++) {
    result[i] = 0;
  }
  
  // print performance and clear counters
  printf("\nSM4 cycle count = %4lu\r\n", (sm_count_end - sm_count_start));
  printf("SM4 insn count  = %4lu\r\n", (sm_insnret_end - sm_insnret_start));
  sm_count_start    = 0;
  sm_count_end      = 0;
  sm_insnret_start  = 0;
  sm_insnret_end    = 0;

/*======================================================*/

    //report results
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
