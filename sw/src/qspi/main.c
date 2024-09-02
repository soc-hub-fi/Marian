/*
 * File      : main.c
 * Test      : qspi
 * Author(s) : Endrit Isufi <endrit.isufi@tuni.fi>
 * Date      : 15-May-2024
 * Description: Tests axi_spi_master peripheral functionality by
 * first initializing the spi slave, then writing to memory and
 * finally reading data.
 */

#include "printf.h"
#include "qspi.h"
#include "runtime.h"

/*
  Commands axi_spi_slave module accepts. Shifted to 8 MSB bits of a 32 bit register.
  Values based on file spi_slave_cmd_parser.sv
*/
#define WR_REG_0  1u << 24 // bit 0 of reg0 enables qspi 
#define WR_MEM    2u << 24
#define RD_REG_0  5u << 24
#define RD_REG_1  7u << 24
#define RD_MEM   11u << 24
#define WR_REG_1 17u << 24 // Nr. of dummy cycles
#define WR_REG_2 32u << 24 // wrap length, low 
#define RD_REG_2 33u << 24
#define WR_REG_3 48u << 24 // wrap length, high
#define RD_REG_3 49u << 24

int main(void) {

  printf("--- QSPI TEST BEGIN ---\r\n");

  //enable slave qspi using normal wr.
  spi_set_clk_div(4u);
  spi_set_length(8u,0u,8u);
  spi_set_cmd(WR_REG_0);
  spi_set_data_o(1u <<24);
  spi_set_status_reg(1u, 0u, 0u, 0u, 1u, 0u);
  wait_for_idle();

  //write to mem
  spi_set_clk_div(4u);
  spi_set_length(32u,32u,8u);
  spi_set_addr(4000u);
  spi_set_cmd(WR_MEM);
  spi_set_data_o(80u << 24);
  spi_set_status_reg(1u, 0u, 1u, 0u, 0u, 0u);
  wait_for_idle();

  // read reg0
  spi_set_length(8u,0u,8u);
  spi_set_cmd(RD_REG_0);
  spi_set_dummy_cycles(0u, 32u);
  spi_set_status_reg(1u,0u, 0u, 1u, 0u ,0u);
  wait_for_idle();

  printf("--- QSPI TEST END ---\n");
  return 0;
}
