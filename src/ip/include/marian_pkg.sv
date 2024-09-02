//------------------------------------------------------------------------------
// Package  : marian_pkg
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
//            Endrit Isufi   <endrit.isufi@tuni.fi>
// Created  : 13-jan-2024
//
// Description: Package to contain types and values which are required
//              throughout the Marian design.
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

package marian_pkg;

`include "axi/typedef.svh"
`include "apb/typedef.svh"
`include "register_interface/typedef.svh"
`include "common_cells/registers.svh"

  import axi_pkg::*;
  import ara_pkg::*;

  // Support for floating-point data types
  localparam fpu_support_e   FPUSupport   = FPUSupportHalfSingleDouble;
  // External support for vfrec7, vfrsqrt7
  localparam fpext_support_e FPExtSupport = FPExtSupportEnable;
  // Support for fixed-point data types
  localparam fixpt_support_e FixPtSupport = FixedPointEnable;

  // RVV Parameters
  localparam int unsigned NrLanes = `NR_LANES; // Number of parallel vector lanes.
  // Number of CPU cores
  localparam int unsigned  NB_CORES   = 1;
  // Number of external interrupts
  localparam int unsigned  NumExternalIRQ = 1 + // ext
                                            2 + // SPI
                                            1 + // UART
                                            1 + // GPIO
                                            2;  // timer

  /*******************
   * SoC XBAR CONFIG *
   *******************/

   // IDs for xbar masters
   typedef enum int unsigned {
    DBG_S         = 0,
    L2MEM_S       = 1,
    AXI_EXT_S     = 2, //external AXI slave
    BROM_S        = 3,
    PERIPHS_S     = 4, //64-bit peripheral sub-system
    APB_PERIPHS_S = 5  //32-bit apb peripheral sub-system
  } axi_slaves_e;

  // IDs for xbar slaves
  typedef enum int unsigned {
    SYS_M =     0,
    DBG_M =     1,
    AXI_EXT_M = 2
  } axi_masters_e;

  typedef enum int unsigned {
    CFG_M       = 0,
    CLINT_M     = 1
  } periph_wide_masters_e;

  typedef enum int unsigned {
    UART_M    = 0,
    QSPI_M    = 1,
    TIMR_M    = 2,
    GPIO_M    = 3,
    PLIC_M    = 4
  } periph_apb_masters_e;
  //number of master ports on 64-bit & 32-bit peripheral sub-systems
  localparam integer NrPeriphWideMasters = CLINT_M + 1;
  localparam integer NrPeriphApbMasters  = PLIC_M + 1;

  // Number of master ports on SoC xbar (labelled as slaves as slaves connect INTO xbar)
  localparam integer NrAXISlaves = APB_PERIPHS_S + 1;
  // Number of slave ports on SoC xbar (labelled as masters as masters connect INTO xbar)
  localparam integer NrAXIMasters = AXI_EXT_M + 1;

  // Memory Map
  // 1GByte of DDR
  localparam logic [63:0] DBGLength       = 64'h1000;
  localparam logic [63:0] CTRLLength      = 64'h1000;
  localparam logic [63:0] CLINTLength     = 64'h1000;
  localparam logic [63:0] BROMLength      = 64'h1000;
  localparam logic [63:0] AXILength       = 64'h4000_0000;
  localparam logic [63:0] DRAMLength      = 64'h10_0000;
  localparam logic [63:0] UARTLength      = 64'h1000;
  localparam logic [63:0] QSPILength      = 64'h1000;
  localparam logic [63:0] TIMRLength      = 64'h1000;
  localparam logic [63:0] GPIOLength      = 64'h1000;
  localparam logic [63:0] PLICLength      = 64'h400_0000;
  localparam logic [63:0] PERIPHLength    = CTRLLength +
                                            CLINTLength;
  localparam logic [63:0] APBPERIPHLength = UARTLength +
                                            QSPILength +
                                            TIMRLength +
                                            GPIOLength +
                                            PLICLength;

  // base addresses for SoC xbar
  //! Note that UARTBase must be 0xC000_0000 as there is a dependency within the RISCV tests 
  //  written for PULP Ara.
  typedef enum logic [63:0] {
    DBGBase       = 64'h0000_0000,
    CTRLBase      = 64'h0000_2000,
    CLINTBase     = 64'h0000_3000,
    BROMBase      = 64'h0000_5000,
    AXIBase       = 64'h4000_0000,
    DRAMBase      = 64'h8000_0000,
    UARTBase      = 64'hC000_0000,
    QSPIBase      = 64'hC000_1000,
    TIMRBase      = 64'hC000_2000,
    GPIOBase      = 64'hC000_3000,
    PLICBase      = 64'hCC00_0000
  } soc_bus_start_e;

  localparam logic [63:0] PERIPHBase    = CTRLBase; // 64-bit peripheral sub-system
  localparam logic [63:0] APBPERIPHBase = UARTBase;  // 32-bit apb peripheral sub-system
  //Address parameters for CLINT registers
  localparam logic [15:0] CLINT_MSIP_BASE     = 16'h3008;
  localparam logic [15:0] CLINT_MTIMECMP_BASE = 16'h3020;
  localparam logic [15:0] CLINT_MTIME_BASE    = 16'h3040;


  /*************************
   * Peripheral subsystems *
   *************************/
  localparam int unsigned PeriphNarrowDataWidth = 32;
  localparam int unsigned PeriphWideDataWidth   = 64;
  localparam int unsigned PeriphAddrWidth       = 64;
  localparam int unsigned PeriphNarrowStrbWidth = PeriphNarrowDataWidth / 8;
  localparam int unsigned PeriphWideStrbWidth   = PeriphWideDataWidth / 8;

  typedef logic [  PeriphWideStrbWidth-1:0] periph_wide_strb_t;
  typedef logic [PeriphNarrowStrbWidth-1:0] periph_narrow_strb_t;
  typedef logic [      PeriphAddrWidth-1:0] periph_addr_t;
  typedef logic [PeriphNarrowDataWidth-1:0] periph_narrow_data_t;
  typedef logic [  PeriphWideDataWidth-1:0] periph_wide_data_t;


  /**************
   * AXI CONFIG *
   **************/

  //CLINT
  localparam int unsigned CLINTDataWidth = 64;
  localparam int unsigned CLINTIdWidth   = 4;
  localparam int unsigned CLINTNRCORES   = 1;

  // external AXI params + types
  localparam int unsigned AxiExtDataWidth = 64;
  localparam int unsigned AxiExtAddrWidth = 64;
  localparam int unsigned AxiExtStrbWidth = AxiExtDataWidth / 8;
  localparam int unsigned AxiExtIdWidth   = 5;
  localparam int unsigned AxiExtUserWidth = 1;

  typedef logic [AxiExtDataWidth-1:0] axi_ext_data_t;
  typedef logic [AxiExtStrbWidth-1:0] axi_ext_strb_t;
  typedef logic [AxiExtAddrWidth-1:0] axi_ext_addr_t;
  typedef logic [  AxiExtIdWidth-1:0] axi_ext_id_t;
  typedef logic [AxiExtUserWidth-1:0] axi_ext_user_t;

  // AXI Interface
  localparam int unsigned AxiDataWidth = (64 * NrLanes) / 2;
  localparam int unsigned AxiAddrWidth =  64;
  localparam int unsigned AxiUserWidth =   1;
  localparam int unsigned AxiIdWidth   =   5;
  localparam int unsigned AxiStrbWidth = AxiDataWidth / 8;

  // Ara's AXI params
  localparam integer AxiWideDataWidth   = AxiDataWidth;
  localparam integer AxiWideStrbWidth   = AxiStrbWidth;
  // SoC AXI params
  localparam integer AxiSocIdWidth  = AxiIdWidth + $clog2(NrAXIMasters);
  // Ariane's AXI params
  localparam integer AxiNarrowDataWidth = 64;
  localparam integer AxiNarrowStrbWidth = AxiNarrowDataWidth / 8;
  localparam integer AxiCoreIdWidth     = AxiIdWidth - 1; // AXI mux appends 1 bit
  // Periph AXI params
  localparam integer AxiPeriphDataWidth = 32;
  localparam integer AxiPeriphStrbWidth = AxiPeriphDataWidth / 8;
  localparam integer AxiPeriphIdWidth   = AxiUserWidth;

  // internal types
  typedef logic [      AxiDataWidth-1:0] axi_data_t;
  typedef logic [    AxiDataWidth/8-1:0] axi_strb_t;
  typedef logic [      AxiAddrWidth-1:0] axi_addr_t;
  typedef logic [      AxiUserWidth-1:0] axi_user_t;
  typedef logic [        AxiIdWidth-1:0] axi_id_t;
  typedef logic [AxiNarrowDataWidth-1:0] axi_narrow_data_t;
  typedef logic [AxiNarrowStrbWidth-1:0] axi_narrow_strb_t;
  typedef logic [    AxiCoreIdWidth-1:0] axi_core_id_t;
  typedef logic [     AxiSocIdWidth-1:0] axi_soc_id_t;

  /****************
   * AXI typedefs *
   ****************/

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

   // 128b SoC AXI bus
   `AXI_TYPEDEF_ALL(soc_wide, axi_addr_t, axi_soc_id_t, axi_data_t, axi_strb_t, axi_user_t)

   // 64b AXI SoC bus
   `AXI_TYPEDEF_ALL(soc_narrow, axi_addr_t, axi_soc_id_t, axi_narrow_data_t, axi_narrow_strb_t,
   axi_user_t)
   // 64b SoC AXI-Lite bus
   `AXI_LITE_TYPEDEF_ALL(soc_narrow_lite, axi_addr_t, axi_narrow_data_t, axi_narrow_strb_t)

   // 32b AXI UART bus
   `AXI_TYPEDEF_ALL(uart_axi, axi_addr_t, axi_soc_id_t, logic [31:0], logic [3:0], axi_user_t)
   // 32b AXI-LITE SoC bus
   `AXI_LITE_TYPEDEF_ALL(uart_lite, axi_addr_t, logic [31:0], logic [3:0])
   // 32b APB SoC bus
   `APB_TYPEDEF_ALL(uart_apb, axi_addr_t, logic [31:0], logic [3:0])

   // 32b AXI TIMR bus
   `AXI_TYPEDEF_ALL(timr_axi, axi_addr_t, axi_soc_id_t, logic [31:0], logic [3:0], axi_user_t)
   // 32b AXI-LITE SoC bus
   `AXI_LITE_TYPEDEF_ALL(timr_lite, axi_addr_t, logic [31:0], logic [3:0])
   // 32b APB SoC bus
   `APB_TYPEDEF_ALL(timr_apb, axi_addr_t, logic [31:0], logic [3:0])

   //32b QSPI
   `AXI_TYPEDEF_ALL(spi_axi, axi_addr_t, axi_soc_id_t, logic [31:0], logic [3:0], axi_user_t)

   //external 64b AXI M (from external into Marian)
   `AXI_TYPEDEF_ALL(axi_external_m, axi_ext_addr_t, axi_ext_id_t, axi_ext_data_t, axi_ext_strb_t, axi_ext_user_t)
   //external 64b AXI S (from Marian out to external)
   `AXI_TYPEDEF_ALL(axi_external_s, axi_ext_addr_t, axi_soc_id_t, axi_ext_data_t, axi_ext_strb_t, axi_ext_user_t)

   // 64b CLINT:
   `AXI_TYPEDEF_ALL(clint_axi, axi_addr_t, axi_soc_id_t , logic[63:0], axi_narrow_strb_t, axi_user_t)
   //CLINT AXI-Lite bus
   `AXI_LITE_TYPEDEF_ALL(clint_lite, axi_addr_t, logic [31:0], logic [3:0])

   // 32b PLIC AXI
   `AXI_TYPEDEF_ALL(plic_axi, axi_addr_t, axi_soc_id_t , logic[31:0], logic [3:0], axi_user_t)
   // 32b PLIC REG
   `REG_BUS_TYPEDEF_ALL(plic_reg, axi_addr_t, logic[31:0], logic [3:0]) 

   //peripheral 64b sub-system
   `AXI_TYPEDEF_ALL(periph_axi_wide, axi_addr_t, axi_soc_id_t , periph_wide_data_t, periph_wide_strb_t, axi_user_t)
   `AXI_LITE_TYPEDEF_ALL(periph_wide_lite, periph_addr_t, periph_wide_data_t, periph_wide_strb_t)
   
   //Peripheral 32b sub-system 
   `AXI_TYPEDEF_ALL(periph_axi_narrow, axi_addr_t, axi_soc_id_t , periph_narrow_data_t, periph_narrow_strb_t, axi_user_t)
   `AXI_LITE_TYPEDEF_ALL(periph_narrow_lite, periph_addr_t, periph_narrow_data_t, logic [3:0])
   `APB_TYPEDEF_ALL(periph_apb, periph_addr_t, periph_narrow_data_t, logic [3:0])
endpackage
