//******************************************************************************
// File        : uart16550.c
// Author(s)   : Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Date        : 11-jun-2024
// Description : Implementation of functions used to control Pulp APB UART 
// 16550 IP
//*****************************************************************************/

#include "marian.h"
#include "printf.h"
#include "uart16550.h"
 
uint32_t uart_set_baudrate(uint32_t input_clk_Hz, uint32_t target_baudrate) {

  uint32_t res     = 0;
  uint32_t divisor = 0;

  divisor = input_clk_Hz / target_baudrate;

  // set LCR(7) to 1 to enable access to divisor latch
  LCR |= 0x80U;

  // write divisor to DLL/DLM
  DLL = (divisor & 0xFFU);
  DLM = ((divisor >> 8U) & 0xFFU); 

  // clr LCR(7) to 1 to disable access to divisor latch
  LCR &= ~(0x80U);

  return res;
}

uint32_t uart_set_line_cfg(parity_cfg_e parity, stop_cfg_e stop_bits, len_cfg_e len_bits) {

  uint32_t res = 0;

  volatile uint32_t tmp_lcr = LCR;

  tmp_lcr &= ~(0x1FU); // clr bit [4:0]

  // set parity bit config  

  switch (parity) {
    case PARITY_DISABLED:
      // do nothing
      break;
    case PARITY_ODD:
      tmp_lcr |= 0x08U;
      break;
    case PARITY_EVEN: 
      tmp_lcr |= 0x18U; 
      break;
    default:
      // unrecognised option
      res = 1;
      return res;
  }

  // set stop bit config

  switch (stop_bits) {
    case ONE_STOP:
    // do nothing
      break;
    case TWO_STOP:
      tmp_lcr |= 0x4U;
      break;
    default:
      // unrecognised option
      res = 1;
      return res;
  }

  // set data length config

  switch (len_bits) {
    case FIVE_BITS:
      // do nothing
      break;
    case SIX_BITS:
      tmp_lcr |= 0x1U;
      break;
    case SEVEN_BITS:
      tmp_lcr |= 0x2U;
      break;
    case EIGHT_BITS:
      tmp_lcr |= 0x3U;
      break;
    default:
      // unrecognised option
      res = 1;
      return res;
  }

  // write back config into LCR reg
  LCR = tmp_lcr;

  return res;
}

uint32_t uart_set_default_cfg(void) {

  uint32_t res = 0;

  res += uart_set_baudrate(MARIAN_CLOCK_FREQ_HZ, 115200U);
  res += uart_set_line_cfg(PARITY_DISABLED, ONE_STOP, EIGHT_BITS);
 
  return res;
}

uint32_t uart_enable_irq(bool rbf_en, bool tbe_en, bool ls_en, bool ms_en) {
  
  uint32_t tmp_rbf = (rbf_en) ? 0 : (1U << ERBFI_BIT);
  uint32_t tmp_tbe = (tbe_en) ? 0 : (1U << ETBEI_BIT);
  uint32_t tmp_ls  = (ls_en) ? 0 : (1U << ELSI_BIT);
  uint32_t tmp_ms  = (ms_en) ? 0 : (1U << EDSSI_BIT);

  IER = tmp_rbf | tmp_tbe | tmp_ls | tmp_ms;

  return 0;
}

uint32_t transmit_char(char char_tx) {

  uint32_t res     = 0;
  
  volatile uint32_t tmp_lsr = 0;

  // wait for tx_buff fifo to be empty
  while(!(tmp_lsr & (0x20U))) {
    tmp_lsr = LSR;
  }

  // write byte into THR
  THR = (uint32_t)(char_tx);

  return res;
}
