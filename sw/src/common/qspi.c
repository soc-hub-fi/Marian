/*
 * File      : qspi.c
 * Author(s) : Endrit Isufi <endrit.isufi@tuni.fi>
 *             Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
 * Date      : 28-May-2024
 * Description: Implementation of Marian QSPI operations
 *              Todo: Add IRQ management
 */

#include "qspi.h"

/************
 *  Setters *
 ************/
void spi_set_addr(uint32_t addr)
{
  SPIM_SPIADR = addr;
}

void spi_set_length(uint16_t data_len, uint8_t addr_len, uint8_t cmd_len)
{
  SPIM_SPILEN = (data_len << 16 | addr_len << 8 | cmd_len);
}

void spi_set_cmd(uint32_t cmd)
{
  SPIM_SPICMD = cmd;
}

void spi_set_data_o(uint32_t data_out)
{
  SPIM_TXFIFO = data_out;
}

void spi_set_dummy_cycles(uint16_t wr_cycles, uint16_t rd_cycles)
{
  SPIM_SPIDUM = (wr_cycles << 16u) | rd_cycles;
}

void spi_set_clk_div(uint8_t clock_div)
{
  SPIM_CLKDIV = clock_div;
}

void spi_set_status_reg(uint8_t cs, uint8_t SRST, uint8_t QWR, uint8_t QRD, uint8_t WR, uint8_t RD)
{
  SPIM_STATUS = (
    (cs   & 0xFu) << 8 |
    (SRST & 0x1u) << 4 | 
    (QWR  & 0x1u) << 3 | 
    (QRD  & 0x1u) << 2 |
    (WR   & 0x1u) << 1 | 
    (RD   & 0x1u)
  );
}

/**************
 *  Getter(s) *
 **************/
uint32_t spi_get_data_in(void)
{
  return SPIM_RXFIFO;
}

uint32_t spi_get_status(void) {
  return SPIM_STATUS;
}

/************
 *  Helpers *
 ************/

void wait_for_idle(void) {
  // loop until SPI FSM is in IDLE
  while((SPIM_STATUS & 0xFu) != 1u);
}