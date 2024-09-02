//------------------------------------------------------------------------------
// Module   : marian_fpga_pkg
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 20-jan-2024
//
// Description: Package to contain types and values which will aid with FPGA
//              synthesis. The creation of this was motivated by the fact that
//              a number of PULP AXI components generate errors when running 
//              synthesis in Vivado.
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

package marian_fpga_pkg;

`include "axi/typedef.svh"
`include "apb/typedef.svh"

  import axi_pkg::*;
  import ara_pkg::*;

  // Support for floating-point data types
  localparam fpu_support_e   FPUSupport   = FPUSupportHalfSingleDouble;
  // External support for vfrec7, vfrsqrt7
  localparam fpext_support_e FPExtSupport = FPExtSupportEnable;
  // Support for fixed-point data types
  localparam fixpt_support_e FixPtSupport = FixedPointEnable;

  // RVV Parameters
  localparam int unsigned NrLanes      =   4; // Number of parallel vector lanes.

  // Number of master ports on SoC xbar (labelled as slaves as slaves connect INTO xbar)
  localparam integer NrAXISlaves = 6;
  // Number of slave ports on SoC xbar (labelled as masters as masters connect INTO xbar)
  localparam integer NrAXIMasters = 3;

  // AXI Interface
  localparam int unsigned AxiDataWidth = (64 * NrLanes) / 2;
  localparam int unsigned AxiAddrWidth =  64;
  localparam int unsigned AxiUserWidth =   1;
  localparam int unsigned AxiIdWidth   =   5;
  localparam int unsigned AxiStrbWidth = AxiDataWidth / 8;

  // Ara's AXI params
  localparam integer AxiWideDataWidth   = AxiDataWidth;
  localparam integer AxiWideStrbWidth   = AxiStrbWidth;
  // Ariane's AXI params
  localparam integer AxiNarrowDataWidth = 64;
  localparam integer AxiNarrowStrbWidth = AxiNarrowDataWidth / 8;
  localparam integer AxiCoreIdWidth     = AxiIdWidth - 1;
  // SoC AXI params
  localparam integer AxiSocIdWidth  = AxiIdWidth + $clog2(NrAXIMasters);
  // Periph AXI params
  localparam integer AxiPeriphDataWidth = 32;
  localparam integer AxiPeriphStrbWidth = AxiPeriphDataWidth / 8;
  localparam integer AxiPeriphIdWidth   = AxiUserWidth;

  // Dependant parameters. DO NOT CHANGE!
  typedef logic [      AxiDataWidth-1:0] axi_data_t;
  typedef logic [    AxiDataWidth/8-1:0] axi_strb_t;
  typedef logic [      AxiAddrWidth-1:0] axi_addr_t;
  typedef logic [      AxiUserWidth-1:0] axi_user_t;
  typedef logic [        AxiIdWidth-1:0] axi_id_t  ;

  // internal types
  typedef logic [AxiNarrowDataWidth-1:0] axi_narrow_data_t;
  typedef logic [AxiNarrowStrbWidth-1:0] axi_narrow_strb_t;
  typedef logic [    AxiCoreIdWidth-1:0] axi_core_id_t;
  typedef logic [AxiPeriphDataWidth-1:0] axi_periph_data_t;
  typedef logic [AxiPeriphStrbWidth-1:0] axi_periph_strb_t;
  typedef logic [  AxiPeriphIdWidth-1:0] axi_periph_id_t;
  typedef logic [     AxiSocIdWidth-1:0] axi_soc_id_t;

  // AXI typedefs
  // ARA:
  `AXI_TYPEDEF_ALL(ara_axi, axi_addr_t, axi_core_id_t, axi_data_t, axi_strb_t, axi_user_t)

  // ARIANE:
  `AXI_TYPEDEF_ALL(ariane_axi, axi_addr_t, axi_core_id_t, axi_narrow_data_t, axi_narrow_strb_t,
  axi_user_t)

  // SYSTEM:
  `AXI_TYPEDEF_ALL(system, axi_addr_t, axi_id_t, axi_data_t, axi_strb_t, axi_user_t)

  // 64b DEBUG M:
  `AXI_TYPEDEF_ALL(debug_m, axi_addr_t, axi_id_t, axi_narrow_data_t, axi_narrow_strb_t,
  axi_user_t)
  // 64b DEBUG S:
  `AXI_TYPEDEF_ALL(debug_s, axi_addr_t, axi_soc_id_t, axi_narrow_data_t, axi_narrow_strb_t,
  axi_user_t)

  // PERIPH:
  `AXI_TYPEDEF_ALL(periph, axi_addr_t, axi_periph_id_t, axi_periph_data_t, axi_periph_strb_t,
  axi_user_t)

  // PERIPH_LITE:
  `AXI_LITE_TYPEDEF_ALL(periph_lite, axi_addr_t, axi_periph_data_t, axi_periph_strb_t)

  // 32b APB SoC bus
  `APB_TYPEDEF_ALL(uart_apb, axi_addr_t, logic [31:0], logic [3:0])

  // Main memory depth for FPGA
  localparam int unsigned L2NumWords = 256; // 256*128 = 32kB
  localparam logic [63:0] DRAMLength = AxiDataWidth * L2NumWords; // size in Bytes

  // FPGA Memory Address Lengths
  localparam logic [63:0] DbgLength   = 64'h0000_1000;
  localparam logic [63:0] DBGLength   = 64'h0000_1000;
  localparam logic [63:0] CTRLLength  = 64'h0000_1000;
  localparam logic [63:0] UARTLength  = 64'h0000_1000;
  localparam logic [63:0] AXILength   = 64'h0000_1000;
  localparam logic [63:0] CLINTLength = 64'h0000_BFF8;
  localparam logic [63:0] QSPILength  = 64'h0000_1000;
  localparam logic [63:0] BROMLength  = 64'h0000_2000;
  localparam logic [63:0] PLICLength  = 64'h0000_1000;

  // FPGA Memory Map //
  // COMMON
  localparam logic [63:0] DbgBase   = 64'h0000_0000;
  localparam logic [63:0] CTRLBase  = 64'h0000_2000;
  localparam logic [63:0] QSPIBase  = 64'h0000_4000;
  localparam logic [63:0] DRAMBase  = 64'h8000_0000;
  localparam logic [63:0] UARTBase  = 64'hC000_0000;
  // Marian Only
  localparam logic [63:0] GPIOBase  = 64'h0000_5000;
  localparam logic [63:0] TimrBase  = 64'h0000_6000;
  // Marian Periph Only
  localparam logic [63:0] AXIBase   = 64'h0000_3000;
  localparam logic [63:0] BROMBase  = 64'h0000_5000;
  localparam logic [63:0] CLINTBase = 64'h0010_0000;
  localparam logic [63:0] PLICBase  = 64'h0000_8000;

endpackage
