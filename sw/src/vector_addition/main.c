/*
 * File      : main.c
 * Test      : Vector Addition
 * Author(s) : Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
 * Date      : 18-jan-2024
 * Description: Basic test performing vector addition. Used for debugging during
 * the development of Marian.
 */

#include <stdint.h>
#include <stdlib.h>

#include <riscv_vector.h>

#include "encoding.h"
#include "printf.h"
#include "runtime.h"

// size of array
#define ARR_LEN 16

/**
 * @brief function to print out vector CSR values
 * 
 */
void print_v_csrs(void);

int main(void) {

  uint64_t vl;
  uint64_t AVL = ARR_LEN;

  uint32_t arr[ARR_LEN] __attribute__((aligned(32)));

  printf("\nSetting vector configuration: ");
  printf("AVL = %dE, SEW = 32b, LMUL = 1, TA, MA.\n", ARR_LEN);  

  // use intrinsics to set vtype
  vl = __riscv_vsetvl_e32m1(AVL);

  printf("Returned vl = %lu\n", vl);

  printf("\nBase Address of arr[] = 0x%016x\n", arr);

  // splat v0 with "0xF"
  asm volatile ("vmv.v.i v0, 0xF");
  // splat v1 elements with 0x8
  asm volatile ("vmv.v.i v1, 0x8");

  // splat v2 elements with 0x1
  asm volatile ("vmv.v.i v2, 0x1");

  // add v1 and v2, store in v3
  asm volatile("vadd.vv v3, v1, v2");

  // add v2 and imm 0x2, store in v4
  asm volatile("vadd.vi v4, v2, 0x2");

  // add v3 and v4, store in v5
  asm volatile("vadd.vv v5, v3, v4");

  // add v4 and v5, store in v6
  asm volatile("vadd.vv v6, v4, v5");

  // add v5 and v6, store in v7
  asm volatile("vadd.vv v7, v5, v6");

  // add v6 and v7, store in v8
  asm volatile("vadd.vv v8, v6, v7");

  // store results into memory
  asm volatile("vse32.v v3, (%0);" :: "r"(arr));

  printf("\nAttempting 'vaeskf1.vi v9, v8, 0x0'\n");

  // attempt an arbitrary key expansion instruction
  asm volatile("vaeskf1.vi v9, v8, 0x0");

  // print out array value following addition + store
  printf("\n\nOutput Array Value: [ ");
  for(int idx = 0; idx < ARR_LEN; idx++) {

    if (idx == (ARR_LEN-1)) {
      printf("%d ]\n", arr[idx]);
    } else {
      printf("%d, ", arr[idx]);
    }
  }

  print_v_csrs();

  return 0;
}

void print_v_csrs(void) {

  uint64_t vstart_val, vl_val, vtype_val, vlenb_val;

  asm volatile("csrrs %0, 0x8,   x0" : "=r"(vstart_val));
  asm volatile("csrrs %0, 0xC20, x0" : "=r"(vl_val    ));
  asm volatile("csrrs %0, 0xC21, x0" : "=r"(vtype_val));
  asm volatile("csrrs %0, 0xC22, x0" : "=r"(vlenb_val ));

  //uint64_t vxsat_val, vxrm_val, vcsr_val;

  //asm volatile("csrrs %0, 0x9,   x0" : "=r"(vxsat_val )); // CAUSES ERROR 
  //asm volatile("csrrs %0, 0xA,   x0" : "=r"(vxrm_val  )); // CAUSES ERROR
  //asm volatile("csrrs %0, 0xF,   x0" : "=r"(vcsr_val  )); // CAUSES ERROR
  
  printf("\n-------------------------------\n");
  printf("CSR Values:\n");
  printf("VSTART = 0x%016lx\n", vstart_val);   
  printf("VL     = 0x%016lx\n", vl_val);  
  printf("VTYPE  = 0x%016lx\n", vtype_val);  
  printf("VLENB  = 0x%016lx\n", vlenb_val);  
  printf("-------------------------------\n");

  //printf("VXSAT  = 0x%016lx\n", vxsat_val);  
  //printf("VXRM   = 0x%016lx\n", vxrm_val);  
  //printf("VCSR   = 0x%016lx\n", vcsr_val); 
}
