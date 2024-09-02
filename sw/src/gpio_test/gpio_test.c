/*
 * File      : gpio_test.c
 * Test      : gpio_test
 * Author(s) : Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
 * Date      : 20-Jul-2024
 * Description: Tests GPIO operation. 
 * In Marian TB:
 *  GPIO 0 output -> GPIO 1 input
 *  GPIO 1 output -> GPIO 0 input 
*/

#include "clint.h"
#include "gpio.h"
#include "plic.h"
#include "printf.h"
#include "runtime.h"

int main(void) {

  printf("\nGPIO Test\n");

  // Use loopback to test GPIO value detection
  gpio_dir_set(gpio_0, output);
  gpio_dir_set(gpio_1, input);

  printf("\n Waiting for input gpio_1 to be set high...\n");

  gpio_pin_write(gpio_0, high);

  while(gpio_pin_read(gpio_1) == low);

  printf("\n GPIO 1 high detected!\n");

  gpio_pin_toggle(gpio_0); // lo

  gpio_dir_set(gpio_1, output);
  gpio_dir_set(gpio_0, input);

  printf("\n Waiting for input gpio_0 to be set high...\n");

  gpio_pin_write(gpio_1, high);

  while(gpio_pin_read(gpio_0) == low);

  printf("\n GPIO 0 high detected!\n");

  gpio_pin_toggle(gpio_1); // lo

  printf("\n Testing rising edge IRQ on GPIO 0\n");

  // test IRQ
  // set mtimecmp to max to keep MIP.MTIP at 0
  set_timer(0xFFFFFFFFFFFFFFFF);
  // enable M-mode external interrupts
  enable_plic();
  // set GPIO priority to 1
  PLIC_GPIO_PRI = 1U;
  PLIC_IRQ_EN_M |= (1U << GPIO_IRQ);

  gpio_irq_cfg_set(gpio_0, rising_edge);
  gpio_irq_enable(gpio_0);

  gpio_pin_toggle(gpio_1); // hi

  asm volatile ("wfi;");
  // nops required as there is some latency between existing WFI and entering handler...
  for (uint64_t i = 0; i < 100; i++) {
    asm volatile("nop;");
  }

  printf("\n Testing falling edge IRQ on GPIO 0\n");

  gpio_irq_cfg_set(gpio_0, falling_edge);

  gpio_pin_toggle(gpio_1); // lo

  asm volatile ("wfi;");
  // nops required as there is some latency between existing WFI and entering handler...
  for (uint64_t i = 0; i < 100; i++) {
    asm volatile("nop;");
  }

  printf("\nGPIO Test Complete!\n");

  return 0;
}