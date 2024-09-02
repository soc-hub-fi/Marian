//******************************************************************************
// File      : marian.h
// Author(s) : Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Date      : 11-jun-2024
// Description: Definitions for general subsystem specific operations.
//******************************************************************************
#ifndef __MARIAN__H__
#define __MARIAN__H__

#include "printf.h"

  // build id
  #define BUILD_VER 20240718

  // base addresses of each component in subsystem (corresponds to xbar)
  #define QSPI_BASE_ADDR 0x00004000UL
  #define DRAM_BASE_ADDR 0x80000000UL
  #define UART_BASE_ADDR 0xC0000000UL

  // clock frequency of Marian subsystem 
  #define MARIAN_CLOCK_FREQ_HZ 75000000U

/**
 * @brief Print logo and build information
 * 
 */
void print_marian(void);

#endif // __MARIAN__H__