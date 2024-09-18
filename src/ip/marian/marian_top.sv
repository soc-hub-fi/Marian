//------------------------------------------------------------------------------
// Module   : marian_top
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
//            Endrit Isufi   <endrit.isufi@tuni.fi>
// Created  : 20-jan-2024
// Updated  : 02-sep-2024
//
// Description: Top module for Marian. Modified version of ara_soc.sv.
//
// Parameters:
//  - None
//
// Inputs:
//  - clk_i: Clock
//  - rst_ni:  Asynchronous active-low reset
//  - marian_axi_m_<signal_names>_i: external AXI master signals (Non-verilator)
//  - ext_axi_m_<signal_names>_i: external AXI master signals (Verilator)
//  - marian_axi_s_<signal_names>_i: external AXI slave signals (Non-verilator)
//  - ext_axi_s_<signal_names>_i: external AXI slave signals (Verilator)
//  - marian_gpio_i: GPIO data in
//  - marian_ext_irq_i: External interrupts
//  - marian_qspi_data_i: QSPI Data in
//  - marian_uart_rx_i: UART Rx
//  - marian_jtag_tck_i: JTAG test clock
//  - marian_jtag_tms_i: JTAG test mode select
//  - marian_jtag_trstn_i: JTAG reset
//  - marian_jtag_tdi_i: JTAG test data in
//
// Outputs:
//  - marian_uart_tx_o: UART Tx
//  - marian_axi_m_<signal_names>_o: external AXI master signals (Non-verilator)
//  - ext_axi_m_<signal_names>_o: external AXI master signals (Verilator)
//  - marian_axi_s_<signal_names>_o: external AXI slave signals (Non-verilator)
//  - ext_axi_s_<signal_names>_o: external AXI slave signals (Verilator)
//  - marian_gpio_o: GPIO data out
//  - marian_gpio_oe: GPIO pad output enable
//  - marian_ext_irq_o: Marian IRQ out
//  - marian_qspi_csn_o: QSPI chip select
//  - marian_qspi_data_o: QSPI data out
//  - marian_qspi_oe: QSPI pad output enable
//  - marian_qspi_sclk_o: QSPI clock
//  - marian_jtag_tdo_o: JTAG test data out
//
// Revision History:
//  - Version 1.0: Initial release
//  - Version 1.1: Updated port list to match Kactus2 generated wrapper signals
//                 [tzs:24-apr-2024]
//  - Version 1.2: Added ifdef to select whether verilator version is used
//                 [tzs:02-sep-2024]
//
//------------------------------------------------------------------------------

`define STRINGIFY(x) `"x`"

module marian_top
  import axi_pkg::*;
  import marian_pkg::*;
(
  input  logic        clk_i ,
  input  logic        rst_ni ,
  //axi_manager
  input  axi_external_m_req_t  ext_axi_m_req_i,
  output axi_external_m_resp_t ext_axi_m_resp_o,
  // axi subordinate
  output axi_external_s_req_t  ext_axi_s_req_o,
  input  axi_external_s_resp_t ext_axi_s_resp_i,
  // GPIO
  input  logic [ 1:0] marian_gpio_i,
  output logic [ 1:0] marian_gpio_o,
  output logic [ 1:0] marian_gpio_oe,
  // IRQ
  input  logic        marian_ext_irq_i,
  output logic        marian_ext_irq_o,
  // QSPI
  input  logic [ 3:0] marian_qspi_data_i,
  output logic        marian_qspi_csn_o,
  output logic [ 3:0] marian_qspi_data_o,
  output logic [ 3:0] marian_qspi_oe,
  output logic        marian_qspi_sclk_o,
  // UART interface
  input  logic        marian_uart_rx_i,
  output logic        marian_uart_tx_o,
  // JTAG
  input  logic        marian_jtag_tck_i,
  input  logic        marian_jtag_tms_i,
  input  logic        marian_jtag_trstn_i,
  input  logic        marian_jtag_tdi_i,
  output logic        marian_jtag_tdo_o
);


`include "axi/assign.svh"
`include "axi/typedef.svh"
`include "common_cells/registers.svh"
`include "apb/typedef.svh"


  // BootRAM size
  localparam  int unsigned L2NumWords = `L2_NUM_ROWS;

/******************
 * GLOBAL SIGNALS *
 ******************/

  logic                    debug_req_irq_s;
  logic                    timer_irq_s;
  logic                    ipi_s;
  logic [          64-1:0] exit_s;
  logic [(2*NB_CORES)-1:0] plic_irq_s;
  logic [           2-1:0] spi_mode_s;

/**************
* AXI BUSSES *
**************/

  // Buses
  system_req_t  [NrAXIMasters-1:0] system_axi_req;
  system_resp_t [NrAXIMasters-1:0] system_axi_resp;

  soc_wide_req_t    [NrAXISlaves-1:0] periph_wide_axi_req;
  soc_wide_resp_t   [NrAXISlaves-1:0] periph_wide_axi_resp;

  // TEMPORARY DEFAULT ASSIGNMENTS
  assign marian_ext_irq_o   = '0;

/********
 * XBAR *
 ********/

  // xbar -> external ports
  axi_dw_converter #(
    .AxiSlvPortDataWidth ( AxiWideDataWidth          ), // 128
    .AxiMstPortDataWidth ( AxiExtDataWidth           ), // 64
    .AxiAddrWidth        ( AxiAddrWidth              ),
    .AxiIdWidth          ( AxiSocIdWidth             ),
    .AxiMaxReads         ( 10                        ),
    .ar_chan_t           ( soc_wide_ar_chan_t        ),
    .mst_r_chan_t        ( axi_external_s_r_chan_t   ),
    .slv_r_chan_t        ( soc_wide_r_chan_t         ),
    .aw_chan_t           ( axi_external_s_aw_chan_t  ),
    .b_chan_t            ( soc_wide_b_chan_t         ),
    .mst_w_chan_t        ( axi_external_s_w_chan_t   ),
    .slv_w_chan_t        ( soc_wide_w_chan_t         ),
    .axi_mst_req_t       ( axi_external_s_req_t      ),
    .axi_mst_resp_t      ( axi_external_s_resp_t     ),
    .axi_slv_req_t       ( soc_wide_req_t            ),
    .axi_slv_resp_t      ( soc_wide_resp_t           )
  ) i_axi_slave_ports_dwc (
    .clk_i      ( clk_i                              ),
    .rst_ni     ( rst_ni                             ),
    .slv_req_i  ( periph_wide_axi_req[AXI_EXT_S]     ),
    .slv_resp_o ( periph_wide_axi_resp[AXI_EXT_S]    ),
    .mst_req_o  ( ext_axi_s_req_o                    ),
    .mst_resp_i ( ext_axi_s_resp_i                   )
  ); // downsizer 128b -> 64b (AXI S)

  // external ports -> xbar
  axi_dw_converter #(
    .AxiSlvPortDataWidth ( AxiExtDataWidth          ),
    .AxiMstPortDataWidth ( AxiWideDataWidth         ),
    .AxiAddrWidth        ( AxiAddrWidth             ),
    .AxiIdWidth          ( AxiIdWidth               ),
    .AxiMaxReads         ( 10                       ),
    .ar_chan_t           ( axi_external_m_ar_chan_t ),
    .mst_r_chan_t        ( system_r_chan_t          ),
    .slv_r_chan_t        ( axi_external_m_r_chan_t  ),
    .aw_chan_t           ( system_aw_chan_t         ),
    .b_chan_t            ( axi_external_m_b_chan_t  ),
    .mst_w_chan_t        ( system_w_chan_t          ),
    .slv_w_chan_t        ( axi_external_m_w_chan_t  ),
    .axi_mst_req_t       ( system_req_t             ),
    .axi_mst_resp_t      ( system_resp_t            ),
    .axi_slv_req_t       ( axi_external_m_req_t     ),
    .axi_slv_resp_t      ( axi_external_m_resp_t    )
  ) i_axi_master_ports_dwc (
    .clk_i      ( clk_i                             ),
    .rst_ni     ( rst_ni                            ),
    .slv_req_i  ( ext_axi_m_req_i                   ),
    .slv_resp_o ( ext_axi_m_resp_o                  ),
    .mst_req_o  ( system_axi_req[AXI_EXT_M]         ),
    .mst_resp_i ( system_axi_resp[AXI_EXT_M]        )
  ); // upsizer 64b -> 128b (AXI M)


  localparam axi_pkg::xbar_cfg_t XBarCfg = '{
    NoSlvPorts        : NrAXIMasters,
    NoMstPorts        : NrAXISlaves,
    MaxMstTrans       : 4,
    MaxSlvTrans       : 4,
    FallThrough       : 1'b0,
    LatencyMode       : axi_pkg::CUT_MST_PORTS,
    AxiIdWidthSlvPorts: AxiIdWidth,
    AxiIdUsedSlvPorts : AxiIdWidth,
    UniqueIds         : 1'b0,
    AxiAddrWidth      : AxiAddrWidth,
    AxiDataWidth      : AxiWideDataWidth,
    NoAddrRules       : NrAXISlaves
  };

  axi_pkg::xbar_rule_64_t [NrAXISlaves-1:0] routing_rules;
  assign routing_rules = '{
    '{ idx: L2MEM_S,       start_addr: DRAMBase,      end_addr: DRAMBase   + DRAMLength   },
    '{ idx: DBG_S,         start_addr: DBGBase,       end_addr: DBGBase    + DBGLength    },
    '{ idx: AXI_EXT_S,     start_addr: AXIBase ,      end_addr: AXIBase    + AXILength    },
    '{ idx: BROM_S,        start_addr: BROMBase,      end_addr: BROMBase   + BROMLength   },
    '{ idx: PERIPHS_S,     start_addr: PERIPHBase,    end_addr: PERIPHBase + PERIPHLength },
    '{ idx: APB_PERIPHS_S, start_addr: APBPERIPHBase, end_addr: PLICBase   + PLICLength   }
  };

  axi_xbar #(
    .Cfg           ( XBarCfg                 ),
    .slv_aw_chan_t ( system_aw_chan_t        ),
    .mst_aw_chan_t ( soc_wide_aw_chan_t      ),
    .w_chan_t      ( system_w_chan_t         ),
    .slv_b_chan_t  ( system_b_chan_t         ),
    .mst_b_chan_t  ( soc_wide_b_chan_t       ),
    .slv_ar_chan_t ( system_ar_chan_t        ),
    .mst_ar_chan_t ( soc_wide_ar_chan_t      ),
    .slv_r_chan_t  ( system_r_chan_t         ),
    .mst_r_chan_t  ( soc_wide_r_chan_t       ),
    .slv_req_t     ( system_req_t            ),
    .slv_resp_t    ( system_resp_t           ),
    .mst_req_t     ( soc_wide_req_t          ),
    .mst_resp_t    ( soc_wide_resp_t         ),
    .rule_t        ( axi_pkg::xbar_rule_64_t )
  ) i_soc_xbar (
    .clk_i                 ( clk_i                ),
    .rst_ni                ( rst_ni               ),
    .test_i                ( 1'b0                 ),
    .slv_ports_req_i       ( system_axi_req       ),
    .slv_ports_resp_o      ( system_axi_resp      ),
    .mst_ports_req_o       ( periph_wide_axi_req  ),
    .mst_ports_resp_i      ( periph_wide_axi_resp ),
    .addr_map_i            ( routing_rules        ),
    .en_default_mst_port_i ( '0                   ),
    .default_mst_port_i    ( '0                   )
  );

/******************************
 * 64-bit AXI-Lite peripherals*
 ******************************/
 peripherals i_peripherals(
  .clk_i                  ( clk_i                           ),
  .rst_ni                 ( rst_ni                          ),
  .periph_wide_axi_req_i  ( periph_wide_axi_req[PERIPHS_S]  ),
  .periph_wide_axi_resp_o ( periph_wide_axi_resp[PERIPHS_S] ),
  .exit_o                 ( exit_s                          ),
  .timer_irq              ( timer_irq_s                     ),
  .ipi_o                  ( ipi_s                           )

);
/*************************
 * 32-bit APB peripherals*
 *************************/
apb_peripherals i_apb_peripherals(
  .clk_i                  ( clk_i                               ),
  .rst_ni                 ( rst_ni                              ),
  .periph_wide_axi_req_i  ( periph_wide_axi_req[APB_PERIPHS_S]  ),
  .periph_wide_axi_resp_o ( periph_wide_axi_resp[APB_PERIPHS_S] ),
  //UART
  .marian_uart_rx_i       ( marian_uart_rx_i                    ),
  .marian_uart_tx_o       ( marian_uart_tx_o                    ),
  //QSPI
  .marian_qspi_data_i     ( marian_qspi_data_i                  ),
  .marian_qspi_csn_o      ( marian_qspi_csn_o                   ),
  .marian_qspi_data_o     ( marian_qspi_data_o                  ),
  .marian_qspi_sclk_o     ( marian_qspi_sclk_o                  ),
  .spi_mode_o             ( spi_mode_s                          ),
  // GPIO
  .marian_gpio_i          ( marian_gpio_i                       ),
  .marian_gpio_o          ( marian_gpio_o                       ),
  .marian_gpio_oe         ( marian_gpio_oe                      ),
  //PLIC
  .ext_irq_i              ( marian_ext_irq_i                    ),
  .plic_irq_o             ( plic_irq_s                          )
);


/*************
 * BootROM   *
 *************/
 boot_rom #(
   .AxiAddrWidth(AxiAddrWidth ),
   .AxiDataWidth(AxiDataWidth )
   )i_boot_rom(
    .clk_i           (clk_i ),
    .rst_ni          (rst_ni),
    // axi interface
    .axi_req_i    (periph_wide_axi_req[BROM_S] ),
    .axi_resp_o   (periph_wide_axi_resp[BROM_S])
);

    // set output enable based on spi_mode
    // 00 = MISO/MOSI
    // 01 = QSPI Tx
    // 10 = QSPI Rx
    assign marian_qspi_oe = (spi_mode_s == 2'b00) ? 4'b0001 :
    (spi_mode_s == 2'b01) ? 4'b1111 :
    4'b0000;

/*************
 * L2 MEMORY *
 *************/

  // The L2 memory does not support atomics

  soc_wide_req_t  l2mem_wide_axi_req_wo_atomics;
  soc_wide_resp_t l2mem_wide_axi_resp_wo_atomics;

  soc_wide_req_t   bootram_axi_req_cut;
  soc_wide_resp_t  bootram_axi_resp_cut;

  axi_multicut #(
    .NoCuts     ( 2 ),
    .aw_chan_t  ( soc_wide_aw_chan_t ),
    .w_chan_t   ( soc_wide_w_chan_t  ),
    .b_chan_t   ( soc_wide_b_chan_t  ),
    .ar_chan_t  ( soc_wide_ar_chan_t ),
    .r_chan_t   ( soc_wide_r_chan_t  ),
    .axi_req_t  ( soc_wide_req_t     ),
    .axi_resp_t ( soc_wide_resp_t    )
  ) i_bootram_axi_multicut (
    .clk_i      ( clk_i                         ),
    .rst_ni     ( rst_ni                        ),
    .slv_req_i  ( periph_wide_axi_req[L2MEM_S]  ),
    .slv_resp_o ( periph_wide_axi_resp[L2MEM_S] ),
    .mst_req_o  ( bootram_axi_req_cut           ),
    .mst_resp_i ( bootram_axi_resp_cut          )
  );

  axi_atop_filter #(
    .AxiIdWidth      ( AxiSocIdWidth   ),
    .AxiMaxWriteTxns ( 4               ),
    .axi_req_t       ( soc_wide_req_t  ),
    .axi_resp_t      ( soc_wide_resp_t )
  ) i_l2mem_atop_filter (
    .clk_i      ( clk_i                          ),
    .rst_ni     ( rst_ni                         ),
    .slv_req_i  ( bootram_axi_req_cut            ),
    .slv_resp_o ( bootram_axi_resp_cut           ),
    .mst_req_o  ( l2mem_wide_axi_req_wo_atomics  ),
    .mst_resp_i ( l2mem_wide_axi_resp_wo_atomics )
  );

  logic                      l2_req;
  logic                      l2_we;
  logic [AxiAddrWidth-1:0]   l2_addr;
  logic [AxiDataWidth/8-1:0] l2_be;
  logic [AxiDataWidth-1:0]   l2_wdata;
  logic [AxiDataWidth-1:0]   l2_rdata;
  logic                      l2_rvalid;

  axi_to_mem #(
    .AddrWidth  ( AxiAddrWidth    ),
    .DataWidth  ( AxiDataWidth    ),
    .IdWidth    ( AxiSocIdWidth   ),
    .NumBanks   ( 1               ),
    .axi_req_t  ( soc_wide_req_t  ),
    .axi_resp_t ( soc_wide_resp_t )
  ) i_axi_to_mem (
    .clk_i        ( clk_i                          ),
    .rst_ni       ( rst_ni                         ),
    .axi_req_i    ( l2mem_wide_axi_req_wo_atomics  ),
    .axi_resp_o   ( l2mem_wide_axi_resp_wo_atomics ),
    .mem_req_o    ( l2_req                         ),
    .mem_gnt_i    ( l2_req                         ), // Always available
    .mem_we_o     ( l2_we                          ),
    .mem_addr_o   ( l2_addr                        ),
    .mem_strb_o   ( l2_be                          ),
    .mem_wdata_o  ( l2_wdata                       ),
    .mem_rdata_i  ( l2_rdata                       ),
    .mem_rvalid_i ( l2_rvalid                      ),
    .mem_atop_o   ( /* Unused */                   ),
    .busy_o       ( /* Unused */                   )
  );

  sram #(
  `ifndef VERILATOR
    `ifndef FPGA
      .INIT_FILE         ( ""           ),
    `else
      .INIT_FILE         ( `STRINGIFY(`L2_MEM_INIT_FILE) ),
    `endif
  `else
    .INIT_FILE         ( `STRINGIFY(`L2_MEM_INIT_FILE) ),
  `endif
    .DATA_WIDTH        ( AxiDataWidth ),
    .NUM_WORDS         ( L2NumWords   ),
    .REGISTERED_OUTPUT ( 1'b0         )
  ) i_bootram (
    .clk_i  ( clk_i                                                                       ),
    .rst_ni ( rst_ni                                                                      ),
    .req_i  ( l2_req                                                                      ),
    .we_i   ( l2_we                                                                       ),
    .addr_i ( l2_addr[$clog2(L2NumWords)-1+$clog2(AxiDataWidth/8):$clog2(AxiDataWidth/8)] ),
    .wdata_i( l2_wdata                                                                    ),
    .be_i   ( l2_be                                                                       ),
    .rdata_o( l2_rdata                                                                    )
  );

  // One-cycle latency
  `FF(l2_rvalid, l2_req, 1'b0, clk_i , rst_ni );


/****************
 * Debug System *
 ****************/

  // SOC -> dbg
  debug_s_req_t  debug_axi_s_req;
  debug_s_resp_t debug_axi_s_resp;
  // dbg -> SOC
  debug_m_req_t  debug_axi_m_req;
  debug_m_resp_t debug_axi_m_resp;

  // downsizer 128b -> 64b
  axi_dw_converter #(
    .AxiSlvPortDataWidth ( AxiWideDataWidth   ),
    .AxiMstPortDataWidth ( AxiNarrowDataWidth ),
    .AxiAddrWidth        ( AxiAddrWidth       ),
    .AxiIdWidth          ( AxiSocIdWidth      ),
    .AxiMaxReads         ( 1                  ),
    .ar_chan_t           ( soc_wide_ar_chan_t ),
    .mst_r_chan_t        ( debug_s_r_chan_t   ),
    .slv_r_chan_t        ( soc_wide_r_chan_t  ),
    .aw_chan_t           ( debug_s_aw_chan_t  ),
    .b_chan_t            ( soc_wide_b_chan_t  ),
    .mst_w_chan_t        ( debug_s_w_chan_t   ),
    .slv_w_chan_t        ( soc_wide_w_chan_t  ),
    .axi_mst_req_t       ( debug_s_req_t      ),
    .axi_mst_resp_t      ( debug_s_resp_t     ),
    .axi_slv_req_t       ( soc_wide_req_t     ),
    .axi_slv_resp_t      ( soc_wide_resp_t    )
  ) i_axi_debug_slave_dwc (
    .clk_i      ( clk_i                       ),
    .rst_ni     ( rst_ni                      ),
    .slv_req_i  ( periph_wide_axi_req[DBG_S]  ),
    .slv_resp_o ( periph_wide_axi_resp[DBG_S] ),
    .mst_req_o  ( debug_axi_s_req             ),
    .mst_resp_i ( debug_axi_s_resp            )
  );

  // upsizer 64b -> 128b
  axi_dw_converter #(
    .AxiSlvPortDataWidth ( AxiNarrowDataWidth  ),
    .AxiMstPortDataWidth ( AxiWideDataWidth    ),
    .AxiAddrWidth        ( AxiAddrWidth        ),
    .AxiIdWidth          ( AxiIdWidth          ),
    .AxiMaxReads         ( 10                  ),
    .ar_chan_t           ( debug_m_ar_chan_t   ),
    .mst_r_chan_t        ( system_r_chan_t     ),
    .slv_r_chan_t        ( debug_m_r_chan_t    ),
    .aw_chan_t           ( system_aw_chan_t    ),
    .b_chan_t            ( debug_m_b_chan_t    ),
    .mst_w_chan_t        ( system_w_chan_t     ),
    .slv_w_chan_t        ( debug_m_w_chan_t    ),
    .axi_mst_req_t       ( system_req_t        ),
    .axi_mst_resp_t      ( system_resp_t       ),
    .axi_slv_req_t       ( debug_m_req_t       ),
    .axi_slv_resp_t      ( debug_m_resp_t      )
  ) i_axi_debug_master_dwc (
    .clk_i      ( clk_i                        ),
    .rst_ni     ( rst_ni                       ),
    .slv_req_i  ( debug_axi_m_req              ),
    .slv_resp_o ( debug_axi_m_resp             ),
    .mst_req_o  ( system_axi_req[DBG_M]        ),
    .mst_resp_i ( system_axi_resp[DBG_M]       )
  );

 debug_system i_debug_system (
    .clk_i              ( clk_i               ),
    .rstn_i             ( rst_ni              ),
    .debug_axi_s_req_i  ( debug_axi_s_req     ),
    .debug_axi_s_resp_o ( debug_axi_s_resp    ),
    .debug_axi_m_resp_i ( debug_axi_m_resp    ),
    .debug_axi_m_req_o  ( debug_axi_m_req     ),
    .debug_req_irq_o    ( debug_req_irq_s     ),
    .jtag_tck_i         ( marian_jtag_tck_i   ),
    .jtag_tms_i         ( marian_jtag_tms_i   ),
    .jtag_trstn_i       ( marian_jtag_trstn_i ),
    .jtag_tdi_i         ( marian_jtag_tdi_i   ),
    .jtag_tdo_o         ( marian_jtag_tdo_o   )
  );
/***************
 * ARA SYSTEM *
 ***************/

  logic [2:0] hart_id;

  assign hart_id = '0;

  localparam ariane_pkg::ariane_cfg_t ArianeAraConfig = '{
    RASDepth             : 2,
    BTBEntries           : 32,
    BHTEntries           : 128,
    // idempotent region
    NrNonIdempotentRules : 2,
    NonIdempotentAddrBase: {64'b0, 64'b0},
    NonIdempotentLength  : {64'b0, 64'b0},
    NrExecuteRegionRules : 3,
    //                      DRAM,       Boot ROM,    Debug Module
    ExecuteRegionAddrBase: {DRAMBase,   BROMBase,    DBGBase},
    ExecuteRegionLength  : {DRAMLength, BROMLength,  DBGLength},
    // cached region
    NrCachedRegionRules  : 1,
    CachedRegionAddrBase : {DRAMBase},
    CachedRegionLength   : {DRAMLength},
    //  cache config
    Axi64BitCompliant    : 1'b1,
    SwapEndianess        : 1'b0,
    // debug
    DmBaseAddress        : DBGBase,
    NrPMPEntries         : 0
  };

`ifndef TARGET_GATESIM

  ara_system #(
    .NB_CORES           ( NB_CORES             ),
    .NrLanes            ( NrLanes              ),
    .FPUSupport         ( FPUSupport           ),
    .FPExtSupport       ( FPExtSupport         ),
    .FixPtSupport       ( FixPtSupport         ),
    .ArianeCfg          ( ArianeAraConfig      ),
    .AxiAddrWidth       ( AxiAddrWidth         ),
    .AxiIdWidth         ( AxiCoreIdWidth       ),
    .AxiNarrowDataWidth ( AxiNarrowDataWidth   ),
    .AxiWideDataWidth   ( AxiDataWidth         ),
    .ara_axi_ar_t       ( ara_axi_ar_chan_t    ),
    .ara_axi_aw_t       ( ara_axi_aw_chan_t    ),
    .ara_axi_b_t        ( ara_axi_b_chan_t     ),
    .ara_axi_r_t        ( ara_axi_r_chan_t     ),
    .ara_axi_w_t        ( ara_axi_w_chan_t     ),
    .ara_axi_req_t      ( ara_axi_req_t        ),
    .ara_axi_resp_t     ( ara_axi_resp_t       ),
    .ariane_axi_ar_t    ( ariane_axi_ar_chan_t ),
    .ariane_axi_aw_t    ( ariane_axi_aw_chan_t ),
    .ariane_axi_b_t     ( ariane_axi_b_chan_t  ),
    .ariane_axi_r_t     ( ariane_axi_r_chan_t  ),
    .ariane_axi_w_t     ( ariane_axi_w_chan_t  ),
    .ariane_axi_req_t   ( ariane_axi_req_t     ),
    .ariane_axi_resp_t  ( ariane_axi_resp_t    ),
    .system_axi_ar_t    ( system_ar_chan_t     ),
    .system_axi_aw_t    ( system_aw_chan_t     ),
    .system_axi_b_t     ( system_b_chan_t      ),
    .system_axi_r_t     ( system_r_chan_t      ),
    .system_axi_w_t     ( system_w_chan_t      ),
    .system_axi_req_t   ( system_req_t         ),
    .system_axi_resp_t  ( system_resp_t        )
  )

`else

  ara_system

`endif

  i_system (
    .clk_i        ( clk_i                  ),
    .rst_ni       ( rst_ni                 ),
    .boot_addr_i  ( BROMBase               ), // start fetching from bootRom
    .hart_id_i    ( hart_id                ),
    .debug_req_i  ( debug_req_irq_s        ),
    .axi_req_o    ( system_axi_req[SYS_M]  ),
    .axi_resp_i   ( system_axi_resp[SYS_M] ),
    .timer_irq_i  ( timer_irq_s            ),
    .ipi_i        ( ipi_s                  ),
    .plic_irq_i   ( plic_irq_s             )
  );

  //////////////////
  //  Assertions  //
  //////////////////

  if (NrLanes == 0)
    $error("[marian_top] Ara needs to have at least one lane.");

  if (AxiDataWidth == 0)
    $error("[marian_top] The AXI data width must be greater than zero.");

  if (AxiAddrWidth == 0)
    $error("[marian_top] The AXI address width must be greater than zero.");

  if (AxiUserWidth == 0)
    $error("[marian_top] The AXI user width must be greater than zero.");

  if (AxiIdWidth == 0)
    $error("[marian_top] The AXI ID width must be greater than zero.");

endmodule : marian_top
