/*
 * File      : key_expansion.c
 * Test      : key_expansion
 * Author(s) : Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
 * Date      : 31-jan-2024
 * Description: Test to exercise the AES Key Expansion instructions
 *              i.e. vaeskf1.vi, vaeskf2.vi
 */

#include <riscv_vector.h>

#include "encoding.h"
#include "key_expansion.h"
#include "printf.h"
#include "runtime.h"

int main(void) {

  // performance counters
  uint64_t aes128_cycle_count_start, aes128_cycle_count_end,
           aes256_cycle_count_start, aes256_cycle_count_end;
  uint64_t aes128_insnret_start, aes128_insnret_end,
           aes256_insnret_start, aes256_insnret_end;
  
  uint32_t fail_count = 0;

  uint64_t AVL = 4;  
  uint64_t vl  = 0;
  
  printf("\r\n *** vaesfk1 and vaesfk2 Test *** \r\n");  

  // initialise VRF to remove x's
  init_vrf();

  // set vtype to SEW32, M1
  vl = __riscv_vsetvl_e32m1(AVL);

  printf("\r\nConfiguration:\r\n AVL = 0x%016lX,\r\n vl = 0x%016lX\r\n", AVL, vl);
  
  printf("\r\nLoading aes-128 cipher key into v1.\r\n");

  asm volatile ("vle32.v v1, (%0);" :: "r"(aes128_cipher_key));

  printf("Executing vaesfk1 and storing result.\r\n");

  aes128_cycle_count_start = read_csr(cycle);
  aes128_insnret_start     = read_csr(instret);

    // perform key expansion in chain
  asm volatile ("vaeskf1.vi  v2,  v1, 0x1");
  asm volatile ("vaeskf1.vi  v3,  v2, 0x2");
  asm volatile ("vaeskf1.vi  v4,  v3, 0x3");
  asm volatile ("vaeskf1.vi  v5,  v4, 0x4");
  asm volatile ("vaeskf1.vi  v6,  v5, 0x5");
  asm volatile ("vaeskf1.vi  v7,  v6, 0x6");
  asm volatile ("vaeskf1.vi  v8,  v7, 0x7");
  asm volatile ("vaeskf1.vi  v9,  v8, 0x8");
  asm volatile ("vaeskf1.vi v10,  v9, 0x9");
  asm volatile ("vaeskf1.vi v11, v10, 0xA");

  // store result in next round key location
  asm volatile ("vse32.v v1,  (%0);" :: "r"(aes128_round_keys     ));
  asm volatile ("vse32.v v2,  (%0);" :: "r"(aes128_round_keys +  4));
  asm volatile ("vse32.v v3,  (%0);" :: "r"(aes128_round_keys +  8));
  asm volatile ("vse32.v v4,  (%0);" :: "r"(aes128_round_keys + 12));
  asm volatile ("vse32.v v5,  (%0);" :: "r"(aes128_round_keys + 16));
  asm volatile ("vse32.v v6,  (%0);" :: "r"(aes128_round_keys + 20));
  asm volatile ("vse32.v v7,  (%0);" :: "r"(aes128_round_keys + 24));
  asm volatile ("vse32.v v8,  (%0);" :: "r"(aes128_round_keys + 28));
  asm volatile ("vse32.v v9,  (%0);" :: "r"(aes128_round_keys + 32));
  asm volatile ("vse32.v v10, (%0);" :: "r"(aes128_round_keys + 36));
  asm volatile ("vse32.v v11, (%0);" :: "r"(aes128_round_keys + 40));

  aes128_cycle_count_end = read_csr(cycle);
  aes128_insnret_end     = read_csr(instret);

  printf("\r\nLoading aes-256 cipher key into v1/v2.\r\n");

  asm volatile ("vle32.v v1, (%0);" :: "r"(aes256_cipher_key    ));
  asm volatile ("vse32.v v1, (%0);" :: "r"(aes256_round_keys    ));

  asm volatile ("vle32.v v2, (%0);" :: "r"(aes256_cipher_key +  4));
  asm volatile ("vse32.v v2, (%0);" :: "r"(aes256_round_keys +  4));

  printf("Executing vaesfk2 and storing result.\r\n");

  aes256_cycle_count_start = read_csr(cycle);
  aes256_insnret_start     = read_csr(instret);

  // perform key expansion and store result
  asm volatile ("vaeskf2.vi v1, v2, 0x2");
  asm volatile ("vse32.v v1, (%0);" :: "r"(aes256_round_keys +  8));
  asm volatile ("vaeskf2.vi v2, v1, 0x3");
  asm volatile ("vse32.v v2, (%0);" :: "r"(aes256_round_keys + 12));

  asm volatile ("vaeskf2.vi v1, v2, 0x4");
  asm volatile ("vse32.v v1, (%0);" :: "r"(aes256_round_keys + 16));
  asm volatile ("vaeskf2.vi v2, v1, 0x5");
  asm volatile ("vse32.v v2, (%0);" :: "r"(aes256_round_keys + 20));
  asm volatile ("vaeskf2.vi v1, v2, 0x6");
  asm volatile ("vse32.v v1, (%0);" :: "r"(aes256_round_keys + 24));
  asm volatile ("vaeskf2.vi v2, v1, 0x7");
  asm volatile ("vse32.v v2, (%0);" :: "r"(aes256_round_keys + 28));
  asm volatile ("vaeskf2.vi v1, v2, 0x8");
  asm volatile ("vse32.v v1, (%0);" :: "r"(aes256_round_keys + 32));
  asm volatile ("vaeskf2.vi v2, v1, 0x9");
  asm volatile ("vse32.v v2, (%0);" :: "r"(aes256_round_keys + 36));
  asm volatile ("vaeskf2.vi v1, v2, 0xA");
  asm volatile ("vse32.v v1, (%0);" :: "r"(aes256_round_keys + 40));
  asm volatile ("vaeskf2.vi v2, v1, 0xB");
  asm volatile ("vse32.v v2, (%0);" :: "r"(aes256_round_keys + 44));
  asm volatile ("vaeskf2.vi v1, v2, 0xC");
  asm volatile ("vse32.v v1, (%0);" :: "r"(aes256_round_keys + 48));
  asm volatile ("vaeskf2.vi v2, v1, 0xD");
  asm volatile ("vse32.v v2, (%0);" :: "r"(aes256_round_keys + 52));
  asm volatile ("vaeskf2.vi v1, v2, 0xE");
  asm volatile ("vse32.v v1, (%0);" :: "r"(aes256_round_keys + 56));

  aes256_cycle_count_end = read_csr(cycle);
  aes256_insnret_end     = read_csr(instret);

  // print aes128 results
  printf("\r\nAES128 Round keys:\r\n");

  for (int key = 0; key < 44; key++) {
    printf(" [%2d] 0x%08X\r\n", key, aes128_round_keys[key]);
  }

  // print ase256 results
  printf("\r\nAES256 Round keys:\r\n");

  for (int key = 0; key < 60; key++) {
    printf(" [%2d] 0x%08X\r\n", key, aes256_round_keys[key]);
  }    

  printf("\r\nVerifying AES128 Round keys...\r\n");
  // check AES128 results
  for (int rnd_key_wrd = 0; rnd_key_wrd < 44; rnd_key_wrd++) {
    if (aes128_round_keys[rnd_key_wrd] != aes128_reference_keys[rnd_key_wrd]) {
      printf("[ASE128 Failure] Key #%2d - Expected: 0x%08X, Actual: 0x%08X\r\n", 
        rnd_key_wrd, 
        aes128_reference_keys[rnd_key_wrd], 
        aes128_round_keys[rnd_key_wrd]
      );
      fail_count++;
    }
  }

  printf("Verifying AES256 Round keys...\r\n");
  // check AES256 results
  for (int rnd_key_wrd = 0; rnd_key_wrd < 60; rnd_key_wrd++) {
    if (aes256_round_keys[rnd_key_wrd] != aes256_reference_keys[rnd_key_wrd]) {
      printf("[ASE256 Failure] Key #%2d - Expected: 0x%08X, Actual: 0x%08X\r\n", 
        rnd_key_wrd, 
        aes256_reference_keys[rnd_key_wrd], 
        aes256_round_keys[rnd_key_wrd]
      );
      fail_count++;
    }
  }  

  if(fail_count) {
    printf("\r\n *** Test Failed! *** \r\n");
    return 1;
  } else {
    printf("\r\n *** Test Success! *** \r\n");
    printf("\r\nAES-128 cycle count = %4lu\r\n", (aes128_cycle_count_end - aes128_cycle_count_start));
    printf("AES-256 cycle count = %4lu\r\n", (aes256_cycle_count_end - aes256_cycle_count_start));
    printf("AES-128 insn count  = %4lu\r\n", (aes128_insnret_end - aes128_insnret_start));
    printf("AES-256 insn count  = %4lu\r\n\n", (aes256_insnret_end - aes256_insnret_start));
    return 0;
  }

}

