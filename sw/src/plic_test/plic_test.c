/*
 * File      : plic_test.c
 * Test      : plic_test
 * Author(s) : Endrit Isufi <endrit.isufi@tuni.fi>
 * Date      : 15-May-2024
 * Description: Tests PLIC interrupt execution
 */

#include "clint.h"
#include "plic.h"
#include "runtime.h"
#include "timer.h"

int main(void) {

  uint32_t irq_count = 0;

  printf("PLIC Test\n");

  // set mtimecmp to max to keep MIP.MTIP at 0
  set_timer(0xFFFFFFFFFFFFFFFF);

  // enable M-mode external interrupts
  enable_plic();

  // set APB Timer priority to 1
  PLIC_APB_TIMER_COMPARE_PRI = 1U;

  // enable UART IRQ in PLIC
  PLIC_IRQ_EN_M |= (1U << APB_TIMER_COMPARE_IRQ);

  // set compare register 
  set_cmp_reg(10000);

  // start timer
  enable_timer();
  
  while(irq_count < 10) {
    asm volatile ("wfi;");
    irq_count++;
    // nops required as there is some latency between existing WFI and entering handler...
    for (uint64_t i = 0; i < 100; i++) {
      asm volatile("nop;");
    }
    printf("\nirq_count = %d\n", irq_count);
  }

  printf("\nPLIC Test Complete!\n\n");

  return 0;
}

/*@brief Write and read all registers accessible.*/
void connectivity_test()
{
  printf("[PLIC] writing all regs\n");
  *(volatile uint32_t*)(0xCC000000u) = 1u;
  *(volatile uint32_t*)(0xCC000004u) = 1u;
  *(volatile uint32_t*)(0xCC000008u) = 1u;
  *(volatile uint32_t*)(0xCC00000cu) = 1u;
  *(volatile uint32_t*)(0xCC000010u) = 1u;
  *(volatile uint32_t*)(0xCC000014u) = 1u;
  *(volatile uint32_t*)(0xCC000018u) = 1u;
  *(volatile uint32_t*)(0xCC001000u) = 1u;
  *(volatile uint32_t*)(0xCC002000u) = 1u;
  *(volatile uint32_t*)(0xCC002080u) = 1u;
  *(volatile uint32_t*)(0xCC200000u) = 1u;
  *(volatile uint32_t*)(0xCC201000u) = 1u;
  *(volatile uint32_t*)(0xCC200004u) = 1u;
  *(volatile uint32_t*)(0xCC201004u) = 1u;
  printf("[PLIC] Reading all regs\n");
  printf("read: %d\n",*(volatile uint32_t*)(0xCC000000u));
  printf("read: %d\n",*(volatile uint32_t*)(0xCC000004u));
  printf("read: %d\n",*(volatile uint32_t*)(0xCC000008u));
  printf("read: %d\n",*(volatile uint32_t*)(0xCC00000cu));
  printf("read: %d\n",*(volatile uint32_t*)(0xCC000010u));
  printf("read: %d\n",*(volatile uint32_t*)(0xCC000014u));
  printf("read: %d\n",*(volatile uint32_t*)(0xCC000018u));
  printf("read: %d\n",*(volatile uint32_t*)(0xCC001000u));
  printf("read: %d\n",*(volatile uint32_t*)(0xCC002000u));
  printf("read: %d\n",*(volatile uint32_t*)(0xCC002080u));
  printf("read: %d\n",*(volatile uint32_t*)(0xCC200000u));
  printf("read: %d\n",*(volatile uint32_t*)(0xCC201000u));
  printf("read: %d\n",*(volatile uint32_t*)(0xCC200004u));
  printf("read: %d\n",*(volatile uint32_t*)(0xCC201004u));
}

