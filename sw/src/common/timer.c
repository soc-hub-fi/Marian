//******************************************************************************
// File        : timer.c
// Author(s)   : Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Date        : 19-jul-2024
// Description : Implementation of functions used to control Pulp APB Timer 
//*****************************************************************************/

#include "timer.h"


void set_cmp_reg(uint32_t val) {
  CMP_REG = val;
}

void enable_timer(void) {
  CTRL_REG = 1u;
}

void disable_timer(void) {
  CTRL_REG = 0u;
}

int32_t are_equal(void) {
  return TIMER_REG == CMP_REG;
}

uint32_t get_timer_val(void) {
  return TIMER_REG;
}