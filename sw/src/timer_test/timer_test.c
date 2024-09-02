/*
 * File      : timer_test.c
 * Test      : APB timer test
 * Author(s) : Endrit Isufi <endrit.isufi@tuni.fi>
 *             Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
 * Date      : 15-May-2024
 * Description: Tests apb_timer interrupt excection
 *              [TZS:22-jul-2024] - Updated test to toggle GPIO pins
 */

#include "gpio.h"
#include "handlers.h"
#include "marian.h"
#include "plic.h"
#include "runtime.h"
#include "timer.h"

// define new timer handler
void timer_compare_handler(void) {
  printf("Timer Value: %u\r\n", get_timer_val());
  gpio_pin_toggle(gpio_0);
  gpio_pin_toggle(gpio_1);
}

int main(void) {

  volatile uint32_t comp_val = 100;

  // set irq handler for timer compare
  register_callback_irq_handler_apb_timer_compare(timer_compare_handler);

  printf("\r\nAPB Timer Test\r\n");

  gpio_dir_set(gpio_0, output);
  gpio_dir_set(gpio_1, output);

  gpio_pin_toggle(gpio_0);

  set_cmp_reg(comp_val);

  enable_plic();
  plic_set_priority(apb_timer_cmp_irq, 1);
  plic_enable_irq(apb_timer_cmp_irq);

  // start timer
  enable_timer();

  while(1) {
    asm volatile ("wfi;");
  }
  

  printf("\r\nAPB Timer Test Complete!\r\n");
  
  return 0;
   
}

