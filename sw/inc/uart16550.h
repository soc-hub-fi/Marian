//******************************************************************************
// File      : uart16550.h
// Author(s) : Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Date      : 04-jun-2024
// Description: Header file for Pulp APB UART operations 
// Note: bit 8 of LCR controls the access to some of the registers.
// Reg map for UART IP:
// ┌──────┬────────┬───┬──────┬────────────────────────────────────────────────┐ 
// │LCR(7)│ OFFSET │REG│ACCESS│DESC                                            │ 
// ├──────┼────────┼───┼──────┼────────────────────────────────────────────────┤ 
// │  0   │  0x00  │RBR│  RO  │ Receiver Buffer Register                       │ 
// │  0   │  0x00  │THR│  WO  │ Transmitter Holding Register                   │ 
// │  0   │  0x04  │IER│  R/W │ Interrupt Enable Register                      │ 
// │  x   │  0x08  │IIR│  RO  │ Interrupt Identification Register              │ 
// │  x   │  0x08  │FCR│  WO  │ FIFO Control Register                          │ 
// │  1   │  0x08  │FCR│  RO  │ FIFO Control Register                          │ 
// │  x   │  0x0C  │LCR│  R/W │ Line Control Register                          │ 
// │  x   │  0x10  │MCR│  R/W │ Modem Control Register                         │ 
// │  x   │  0x14  │LSR│  R/W │ Line Status Register                           │ 
// │  x   │  0x18  │MSR│  R/W │ Modem Status Register                          │ 
// │  x   │  0x1C  │SCR│  R/W │ Scratch Register                               │ 
// │  1   │  0x00  │DLL│  R/W │ Divisor Latch (Least Significant Byte) Register│ 
// │  1   │  0x04  │DLM│  R/W │ Divisor Latch (Most Significant Byte) Register │ 
// └──────┴────────┴───┴──────┴────────────────────────────────────────────────┘ 
//******************************************************************************
#ifndef __UART16550__H__
#define __UART16550__H__

#include <stdint.h>
#include <stdbool.h>

#include "marian.h"                                                       

#define RBR_ADDR_OFFSET 0x00U
#define THR_ADDR_OFFSET 0x00U
#define IER_ADDR_OFFSET 0x04U
#define IIR_ADDR_OFFSET 0x08U
#define FCR_ADDR_OFFSET 0x08U
#define LCR_ADDR_OFFSET 0x0CU
#define MCR_ADDR_OFFSET 0x10U
#define LSR_ADDR_OFFSET 0x14U
#define MSR_ADDR_OFFSET 0x18U
#define SCR_ADDR_OFFSET 0x1CU
#define DLL_ADDR_OFFSET 0x00U
#define DLM_ADDR_OFFSET 0x04U

#define RBR_ADDR (UART_BASE_ADDR + RBR_ADDR_OFFSET)
#define THR_ADDR (UART_BASE_ADDR + THR_ADDR_OFFSET)
#define IER_ADDR (UART_BASE_ADDR + IER_ADDR_OFFSET)
#define IIR_ADDR (UART_BASE_ADDR + IIR_ADDR_OFFSET)
#define FCR_ADDR (UART_BASE_ADDR + FCR_ADDR_OFFSET)
#define LCR_ADDR (UART_BASE_ADDR + LCR_ADDR_OFFSET)
#define MCR_ADDR (UART_BASE_ADDR + MCR_ADDR_OFFSET)
#define LSR_ADDR (UART_BASE_ADDR + LSR_ADDR_OFFSET)
#define MSR_ADDR (UART_BASE_ADDR + MSR_ADDR_OFFSET)
#define SCR_ADDR (UART_BASE_ADDR + SCR_ADDR_OFFSET)
#define DLL_ADDR (UART_BASE_ADDR + DLL_ADDR_OFFSET)
#define DLM_ADDR (UART_BASE_ADDR + DLM_ADDR_OFFSET)

#define RBR *((volatile uint32_t*)(RBR_ADDR))
#define THR *((volatile uint32_t*)(THR_ADDR))
#define IER *((volatile uint32_t*)(IER_ADDR))
#define IIR *((volatile uint32_t*)(IIR_ADDR))
#define FCR *((volatile uint32_t*)(FCR_ADDR))
#define LCR *((volatile uint32_t*)(LCR_ADDR))
#define MCR *((volatile uint32_t*)(MCR_ADDR))
#define LSR *((volatile uint32_t*)(LSR_ADDR))
#define MSR *((volatile uint32_t*)(MSR_ADDR))
#define SCR *((volatile uint32_t*)(SCR_ADDR))
#define DLL *((volatile uint32_t*)(DLL_ADDR))
#define DLM *((volatile uint32_t*)(DLM_ADDR))

// IER bit offsets
#define ERBFI_BIT 0U
#define ETBEI_BIT 1U
#define ELSI_BIT  2U
#define EDSSI_BIT 3U

typedef enum {
  PARITY_DISABLED = 0,
  PARITY_ODD,
  PARITY_EVEN
} parity_cfg_e;

typedef enum {
  ONE_STOP = 0,
  TWO_STOP,
} stop_cfg_e;

typedef enum {
  FIVE_BITS = 0,
  SIX_BITS,
  SEVEN_BITS,
  EIGHT_BITS
} len_cfg_e;

typedef enum {
  RBF = 0,
  TBE,
  LS,
  MS
} uart_irq_e;


/**
 * @brief Configure the baudrate of the UART 
 * 
 * @param input_clk_Hz Input clock frequency to UART in Hz
 * @param target_baudrate Target Baudrate in Baud
 * @return uint32_t Success(0)
 */
uint32_t uart_set_baudrate(uint32_t input_clk_Hz, uint32_t target_baudrate);

/**
 * @brief Configure the line configuration of the UART
 * 
 * @param parity 
 * @param stop_bits Number of stop bits 
 * @param len_bits Data length in bits
 * @return uint32_t  Success(0)
 */
uint32_t uart_set_line_cfg(parity_cfg_e parity, stop_cfg_e stop_bits, len_cfg_e len_bits);

/**
 * @brief helper to set UART into a default configuration i.e. 115200 8N1
 * 
 * @return uint32_t Success(0)
 */
uint32_t uart_set_default_cfg(void);

/**
 * @brief enable selected UART interrupts by setting corresponding parameters to true. Any
 * interrupts set to false will be diabled
 * 
 * @param rbf_en read buffer full irq enable
 * @param tbe_en transmit buffer empty irq enable
 * @param ls_en line status irq enable
 * @param ms_en modem status irq enable
 * @return uint32_t 0 if OK
 */
uint32_t uart_enable_irq(bool rbf_en, bool tbe_en, bool ls_en, bool ms_en);

/**
 * @brief write a single character to the UART
 * 
 * @param char_tx character to be transmitted
 * @return uint32_t Success(0)
 */
uint32_t transmit_char(char char_tx);

#endif // __UART16550__H__