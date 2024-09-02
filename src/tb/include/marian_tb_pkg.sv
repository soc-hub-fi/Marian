//------------------------------------------------------------------------------
// Package  : marian_pkg
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 01-may-2024
//
// Description: Package to contain types and values which are required
//              within the Marian TB
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

package marian_tb_pkg;

`include "axi/assign.svh"
`include "axi/typedef.svh"

// spi register offsets
parameter SPI_REG_STATUS = 8'h00;
parameter SPI_REG_CLKDIV = 8'h04;
parameter SPI_REG_SPICMD = 8'h08;
parameter SPI_REG_SPIADR = 8'h0C;
parameter SPI_REG_SPILEN = 8'h10;
parameter SPI_REG_SPIDUM = 8'h14;
parameter SPI_REG_TXFIFO = 8'h20;
parameter SPI_REG_RXFIFO = 8'h40;
parameter SPI_REG_INTCFG = 8'h24; // unused
parameter SPI_REG_INTSTA = 8'h28; // unused

  //running tests
  logic SPI_TEST = 1;
  logic EXT_AXI_TEST = 0;

  // AXI params
  localparam int unsigned AXI_DV_ADDR_WIDTH = 32;
  localparam int unsigned AXI_DV_DATA_WIDTH = 64;
  localparam int unsigned AXI_DV_ID_WIDTH   = 9;
  localparam int unsigned AXI_DV_USER_WIDTH = 1;

  // types for AXI definition
  typedef logic [    AXI_DV_DATA_WIDTH-1:0] axi_dv_data_t;
  typedef logic [(AXI_DV_DATA_WIDTH/8)-1:0] axi_dv_strb_t;
  typedef logic [    AXI_DV_ADDR_WIDTH-1:0] axi_dv_addr_t;
  typedef logic [    AXI_DV_USER_WIDTH-1:0] axi_dv_user_t;
  typedef logic [      AXI_DV_ID_WIDTH-1:0] axi_dv_id_t;

  // ********
  // Note that the following definitions are identical, but decoupling them may allow for easy
  // future modifications
  // ********
  // 64b AXI M (from AXI DV into Marian)
  `AXI_TYPEDEF_ALL(axi_dv_m, axi_dv_addr_t, axi_dv_id_t, axi_dv_data_t, axi_dv_strb_t, axi_dv_user_t)
  // external 64b AXI S (from Marian out to AXI DV)
  `AXI_TYPEDEF_ALL(axi_dv_s, axi_dv_addr_t, axi_dv_id_t, axi_dv_data_t, axi_dv_strb_t, axi_dv_user_t)


endpackage
