/*
 * File      : gpio.c
 * Author(s) : Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
 * Date      : 20-jul-2024
 * Description: Contains implementations of GPIO functions
 */

#include "gpio.h"

static volatile gpio_reg_t* gpio_reg = (volatile gpio_reg_t*)(GPIO_BASE_ADDR);

void gpio_dir_set(gpio_pin_e gpio_pin, gpio_dir_e gpio_direction) {
  if (gpio_direction == input) {
    // clock gate must be enabled for GPIO to act as an input
    gpio_reg->gpio_gpioen |= (1U << gpio_pin);
    gpio_reg->gpio_paddir &= ~(1U << gpio_pin);
  } else {
    // disable clock gate if output (not required, just efficient)
    gpio_reg->gpio_gpioen &= ~(1U << gpio_pin);
    gpio_reg->gpio_paddir |= (1U << gpio_pin);
  }
}

gpio_dir_e gpio_dir_get(gpio_pin_e gpio_pin) {
  return (gpio_dir_e)(((gpio_reg->gpio_paddir) >> gpio_pin) & 1U);
}

gpio_state_e gpio_pin_read(gpio_pin_e gpio_pin) {
  return (gpio_state_e)(((gpio_reg->gpio_padin) >> gpio_pin) & 1U);
}

void gpio_pin_write(gpio_pin_e gpio_pin, gpio_state_e gpio_state) {
  if (gpio_state == low) {
    gpio_reg->gpio_padout &= ~(1U << gpio_pin);
  } else {
    gpio_reg->gpio_padout |= (1U << gpio_pin);
  }
}

void gpio_pin_toggle(gpio_pin_e gpio_pin) {
  gpio_reg->gpio_padout ^= (1U << gpio_pin);
}

void gpio_irq_cfg_set(gpio_pin_e gpio_pin, gpio_irq_type_e gpio_irq_type) {
  // interrupt config is encoded in 2 bits, apply mask first
  gpio_reg->gpio_inttype &= ~(3U << (2*gpio_pin));
  gpio_reg->gpio_inttype |= (gpio_irq_type << (2*gpio_pin));
}

void gpio_irq_enable(gpio_pin_e gpio_pin) {
  gpio_reg->gpio_inten |= (1U << gpio_pin);
}

void gpio_irq_disable(gpio_pin_e gpio_pin) {
  gpio_reg->gpio_inten &= ~(1U << gpio_pin);
}