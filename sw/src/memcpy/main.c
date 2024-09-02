/*
 * File      : main.c
 * Test      : memcpy
 * Author(s) : Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
 * Date      : 30-jan-2024
 * Description: Vector implementation of a memcpy to apply pressure to the 
 *              load/store unit and confirm how processor manages the load.
 */

#include <stdint.h>

#include <riscv_vector.h>

#include "printf.h"


void memcpy_vec32(void* dst, void* src, size_t size) {

  uint64_t vl = __riscv_vsetvl_e32m8(size);

  printf(" memcpy vl = 0x%016x\n", vl);

  vuint32m8_t vec_src = __riscv_vle32_v_u32m8(src, vl);
  __riscv_vse32_v_u32m8(dst, vec_src, vl);
}

void populate_array_incr(uint32_t* array, size_t size) {
  for (int idx = 0; idx < (int)(size); idx++) {
    array[idx] = (uint32_t)(idx); 
  }
}

// print array in rows of elements 
// row size defined by row_size (internally)
void print_array(uint32_t* array, size_t size) {
  
  const int row_size = 8;
  int quotient = size / row_size;
  int remainder = size % row_size;
  
  int row = 0;

  printf("\nArray Addr: 0x%016x\n", array);

  printf("Array Vals:\n");
  
  if (quotient) {
    for(row = 0; row < quotient; row++) {
      for (int element = 0; element < row_size; element++) {
        printf("%4d, ", array[(row*row_size)+element]);
      }
      printf("\n");
    }
  }

  if (remainder) {
    for (int element = 0; element < remainder; element++) {
      printf("%4d, ", array[(row*row_size)+element]);
    }
  }
  printf("\n");
}

int main(void) {

  const int N = 11;

  uint32_t A[N], B[N] __attribute__((aligned(32)));

  volatile uint64_t vstart_req = 0x04;
  volatile uint64_t vstart_res = 0;
    
  populate_array_incr(A, N);

  printf("Setting vstart to 0x%016x\n", vstart_req);

  asm volatile("csrrw %0, 0x8, %1" : "=r"(vstart_res) : "r"(vstart_req));

  printf("vstart result = 0x%016x\n", vstart_res);

  printf("\nSource Array:\n");
  print_array(A, N);

  memcpy_vec32(B, A, N);

  printf("\nDestination Array:\n");
  print_array(B, N);

  return 0;
}
