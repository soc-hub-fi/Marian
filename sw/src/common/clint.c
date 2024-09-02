//******************************************************************************
// File        : clint.c
// Author(s)   : Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Date        : 19-jul-2024
// Description : Implementation of functions used to control CLINT 
//*****************************************************************************/

#include "clint.h"


void set_timer(uint64_t rtc_cycles) {
  CLINT_MTIMECMP_REG = rtc_cycles; // write to CLINT mtimecmp register
}