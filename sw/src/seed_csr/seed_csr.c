/*
 * File      : main.c
 * Test      : seed_csr
 * Author(s) : Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
 * Date      : 08-jun-2024
 * Description: Basic test to exercise seed CSR
 */

#include <stdint.h>

#include "printf.h"

int main(void) {

  printf("** seed_csr test **\r\n");

  volatile uint64_t seed, dummy_wr;

  seed     = 0;
  dummy_wr = 0;

  asm volatile("csrrw %0, 0x15, %1" : "=r"(seed) : "r"(dummy_wr));

  printf("Seed CSR = 0x%016X\r\n", seed);

  return 0;
}
