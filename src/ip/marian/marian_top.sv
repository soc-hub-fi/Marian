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
  // It seems that Verilator doesn't seem to like splitting out the ports...
`ifndef VERILATOR

    // Interface: axi_manager
  input  logic        marian_axi_m_ar_ready_i,
  input  logic        marian_axi_m_aw_ready_i,
  input  logic [ 8:0] marian_axi_m_b_id_i,
  input  logic [ 1:0] marian_axi_m_b_resp_i,
  input  logic        marian_axi_m_b_user_i,
  input  logic        marian_axi_m_b_valid_i,
  input  logic [63:0] marian_axi_m_r_data_i,
  input  logic [ 8:0] marian_axi_m_r_id_i,
  input  logic        marian_axi_m_r_last_i,
  input  logic [ 1:0] marian_axi_m_r_resp_i,
  input  logic        marian_axi_m_r_user_i,
  input  logic        marian_axi_m_r_valid_i,
  input  logic        marian_axi_m_w_ready_i,
  output logic [31:0] marian_axi_m_ar_addr_o,
  output logic [ 1:0] marian_axi_m_ar_burst_o,
  output logic [ 3:0] marian_axi_m_ar_cache_o,
  output logic [ 8:0] marian_axi_m_ar_id_o,
  output logic [ 7:0] marian_axi_m_ar_len_o,
  output logic        marian_axi_m_ar_lock_o,
  output logic [ 2:0] marian_axi_m_ar_prot_o,
  output logic [ 3:0] marian_axi_m_ar_qos_o,
  output logic [ 3:0] marian_axi_m_ar_region_o,
  output logic [ 2:0] marian_axi_m_ar_size_o,
  output logic        marian_axi_m_ar_user_o,
  output logic        marian_axi_m_ar_valid_o,
  output logic [31:0] marian_axi_m_aw_addr_o,
  output logic [ 5:0] marian_axi_m_aw_atop_o,
  output logic [ 1:0] marian_axi_m_aw_burst_o,
  output logic [ 3:0] marian_axi_m_aw_cache_o,
  output logic [ 8:0] marian_axi_m_aw_id_o,
  output logic [ 7:0] marian_axi_m_aw_len_o,
  output logic        marian_axi_m_aw_lock_o,
  output logic [ 2:0] marian_axi_m_aw_prot_o,
  output logic [ 3:0] marian_axi_m_aw_qos_o,
  output logic [ 3:0] marian_axi_m_aw_region_o,
  output logic [ 2:0] marian_axi_m_aw_size_o,
  output logic        marian_axi_m_aw_user_o,
  output logic        marian_axi_m_aw_valid_o,
  output logic        marian_axi_m_b_ready_o,
  output logic        marian_axi_m_r_ready_o,
  output logic [63:0] marian_axi_m_w_data_o,
  output logic        marian_axi_m_w_last_o,
  output logic [ 7:0] marian_axi_m_w_strb_o,
  output logic        marian_axi_m_w_user_o,
  output logic        marian_axi_m_w_valid_o,
  // Interface: axi_subordinate
  input  logic [31:0] marian_axi_s_ar_addr_i,
  input  logic [ 1:0] marian_axi_s_ar_burst_i,
  input  logic [ 3:0] marian_axi_s_ar_cache_i,
  input  logic [ 8:0] marian_axi_s_ar_id_i,
  input  logic [ 7:0] marian_axi_s_ar_len_i,
  input  logic        marian_axi_s_ar_lock_i,
  input  logic [ 2:0] marian_axi_s_ar_prot_i,
  input  logic [ 3:0] marian_axi_s_ar_qos_i,
  input  logic [ 3:0] marian_axi_s_ar_region_i,
  input  logic [ 2:0] marian_axi_s_ar_size_i,
  input  logic        marian_axi_s_ar_user_i,
  input  logic        marian_axi_s_ar_valid_i,
  input  logic [31:0] marian_axi_s_aw_addr_i,
  input  logic [ 5:0] marian_axi_s_aw_atop_i,
  input  logic [ 1:0] marian_axi_s_aw_burst_i,
  input  logic [ 3:0] marian_axi_s_aw_cache_i,
  input  logic [ 8:0] marian_axi_s_aw_id_i,
  input  logic [ 7:0] marian_axi_s_aw_len_i,
  input  logic        marian_axi_s_aw_lock_i,
  input  logic [ 2:0] marian_axi_s_aw_prot_i,
  input  logic [ 3:0] marian_axi_s_aw_qos_i,
  input  logic [ 3:0] marian_axi_s_aw_region_i,
  input  logic [ 2:0] marian_axi_s_aw_size_i,
  input  logic        marian_axi_s_aw_user_i,
  input  logic        marian_axi_s_aw_valid_i,
  input  logic        marian_axi_s_b_ready_i,
  input  logic        marian_axi_s_r_ready_i,
  input  logic [63:0] marian_axi_s_w_data_i,
  input  logic        marian_axi_s_w_last_i,
  input  logic [ 7:0] marian_axi_s_w_strb_i,
  input  logic        marian_axi_s_w_user_i,
  input  logic        marian_axi_s_w_valid_i,
  output logic        marian_axi_s_ar_ready_o,
  output logic        marian_axi_s_aw_ready_o,
  output logic [ 8:0] marian_axi_s_b_id_o,
  output logic [ 1:0] marian_axi_s_b_resp_o,
  output logic        marian_axi_s_b_user_o,
  output logic        marian_axi_s_b_valid_o,
  output logic [63:0] marian_axi_s_r_data_o,
  output logic [ 8:0] marian_axi_s_r_id_o,
  output logic        marian_axi_s_r_last_o,
  output logic [ 1:0] marian_axi_s_r_resp_o,
  output logic        marian_axi_s_r_user_o,
  output logic        marian_axi_s_r_valid_o,
  output logic        marian_axi_s_w_ready_o,

`else

  //axi_manager
  input  axi_external_m_req_t  ext_axi_m_req_i,
  output axi_external_m_resp_t ext_axi_m_resp_o,
  // axi subordinate
  output axi_external_s_req_t  ext_axi_s_req_o,
  input  axi_external_s_resp_t ext_axi_s_resp_i,

`endif

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

`ifndef VERILATOR

/* When testing with Verilator v5.008, an issue was identified in which breaking
   out signals and assigning them to Pulp AXI structs prevents signals from
   correctly propagating. Signal breakout is required to interface with wrappers
   generated by Tampere Universities Kactus 2 tool. This ugly ifndef is the fix
*/

    // SOC -> ext
  axi_external_s_req_t  ext_axi_s_req_o;
  axi_external_s_resp_t ext_axi_s_resp_i;
  // ext -> SOC
  axi_external_m_req_t  ext_axi_m_req_i;
  axi_external_m_resp_t ext_axi_m_resp_o;

  //assign AXI outputs
  assign marian_axi_s_ar_ready_o  = ext_axi_m_resp_o.ar_ready;
  assign marian_axi_s_aw_ready_o  = ext_axi_m_resp_o.aw_ready;
  assign marian_axi_s_b_id_o      = ext_axi_m_resp_o.b.id;
  assign marian_axi_s_b_resp_o    = ext_axi_m_resp_o.b.resp;
  assign marian_axi_s_b_user_o    = ext_axi_m_resp_o.b.user;
  assign marian_axi_s_b_valid_o   = ext_axi_m_resp_o.b_valid;
  assign marian_axi_s_r_data_o    = ext_axi_m_resp_o.r.data;
  assign marian_axi_s_r_id_o      = ext_axi_m_resp_o.r.id;
  assign marian_axi_s_r_last_o    = ext_axi_m_resp_o.r.last;
  assign marian_axi_s_r_resp_o    = ext_axi_m_resp_o.r.resp;
  assign marian_axi_s_r_user_o    = ext_axi_m_resp_o.r.user;
  assign marian_axi_s_r_valid_o   = ext_axi_m_resp_o.r_valid;
  assign marian_axi_s_w_ready_o   = ext_axi_m_resp_o.w_ready;

  assign marian_axi_m_ar_addr_o   = ext_axi_s_req_o.ar.addr [31:0]; // FIXME slicing
  assign marian_axi_m_ar_burst_o  = ext_axi_s_req_o.ar.burst;
  assign marian_axi_m_ar_cache_o  = ext_axi_s_req_o.ar.cache;
  assign marian_axi_m_ar_id_o     = ext_axi_s_req_o.ar.id;
  assign marian_axi_m_ar_len_o    = ext_axi_s_req_o.ar.len;
  assign marian_axi_m_ar_lock_o   = ext_axi_s_req_o.ar.lock;
  assign marian_axi_m_ar_prot_o   = ext_axi_s_req_o.ar.prot;
  assign marian_axi_m_ar_qos_o    = ext_axi_s_req_o.ar.qos;
  assign marian_axi_m_ar_region_o = ext_axi_s_req_o.ar.region;
  assign marian_axi_m_ar_size_o   = ext_axi_s_req_o.ar.size;
  assign marian_axi_m_ar_user_o   = ext_axi_s_req_o.ar.user;
  assign marian_axi_m_ar_valid_o  = ext_axi_s_req_o.ar_valid;
  assign marian_axi_m_aw_addr_o   = ext_axi_s_req_o.aw.addr [31:0]; // FIXME slicing
  assign marian_axi_m_aw_atop_o   = ext_axi_s_req_o.aw.atop;
  assign marian_axi_m_aw_burst_o  = ext_axi_s_req_o.aw.burst;
  assign marian_axi_m_aw_cache_o  = ext_axi_s_req_o.aw.cache;
  assign marian_axi_m_aw_id_o     = ext_axi_s_req_o.aw.id;
  assign marian_axi_m_aw_len_o    = ext_axi_s_req_o.aw.len;
  assign marian_axi_m_aw_lock_o   = ext_axi_s_req_o.aw.lock;
  assign marian_axi_m_aw_prot_o   = ext_axi_s_req_o.aw.prot;
  assign marian_axi_m_aw_qos_o    = ext_axi_s_req_o.aw.qos;
  assign marian_axi_m_aw_region_o = ext_axi_s_req_o.aw.region;
  assign marian_axi_m_aw_size_o   = ext_axi_s_req_o.aw.size;
  assign marian_axi_m_aw_user_o   = ext_axi_s_req_o.aw.user;
  assign marian_axi_m_aw_valid_o  = ext_axi_s_req_o.aw_valid;
  assign marian_axi_m_b_ready_o   = ext_axi_s_req_o.b_ready;
  assign marian_axi_m_r_ready_o   = ext_axi_s_req_o.r_ready;
  assign marian_axi_m_w_data_o    = ext_axi_s_req_o.w.data;
  assign marian_axi_m_w_last_o    = ext_axi_s_req_o.w.last;
  assign marian_axi_m_w_strb_o    = ext_axi_s_req_o.w.strb;
  assign marian_axi_m_w_user_o    = ext_axi_s_req_o.w.user;
  assign marian_axi_m_w_valid_o   = ext_axi_s_req_o.w_valid;

  //assign AXI inputs
  assign ext_axi_m_req_i.ar.addr   = {32'h0, marian_axi_s_ar_addr_i}; // FIXME padding
  assign ext_axi_m_req_i.ar.burst  = marian_axi_s_ar_burst_i;
  assign ext_axi_m_req_i.ar.cache  = marian_axi_s_ar_cache_i;
  assign ext_axi_m_req_i.ar.id     = marian_axi_s_ar_id_i;
  assign ext_axi_m_req_i.ar.len    = marian_axi_s_ar_len_i;
  assign ext_axi_m_req_i.ar.lock   = marian_axi_s_ar_lock_i;
  assign ext_axi_m_req_i.ar.prot   = marian_axi_s_ar_prot_i;
  assign ext_axi_m_req_i.ar.qos    = marian_axi_s_ar_qos_i;
  assign ext_axi_m_req_i.ar.region = marian_axi_s_ar_region_i;
  assign ext_axi_m_req_i.ar.size   = marian_axi_s_ar_size_i;
  assign ext_axi_m_req_i.ar.user   = marian_axi_s_ar_user_i;
  assign ext_axi_m_req_i.ar_valid  = marian_axi_s_ar_valid_i;
  assign ext_axi_m_req_i.aw.addr   = {32'h0 ,marian_axi_s_aw_addr_i}; // FIXME padding
  assign ext_axi_m_req_i.aw.atop   = marian_axi_s_aw_atop_i;
  assign ext_axi_m_req_i.aw.burst  = marian_axi_s_aw_burst_i;
  assign ext_axi_m_req_i.aw.cache  = marian_axi_s_aw_cache_i;
  assign ext_axi_m_req_i.aw.id     = marian_axi_s_aw_id_i;
  assign ext_axi_m_req_i.aw.len    = marian_axi_s_aw_len_i;
  assign ext_axi_m_req_i.aw.lock   = marian_axi_s_aw_lock_i;
  assign ext_axi_m_req_i.aw.prot   = marian_axi_s_aw_prot_i;
  assign ext_axi_m_req_i.aw.qos    = marian_axi_s_aw_qos_i;
  assign ext_axi_m_req_i.aw.region = marian_axi_s_aw_region_i;
  assign ext_axi_m_req_i.aw.size   = marian_axi_s_aw_size_i;
  assign ext_axi_m_req_i.aw.user   = marian_axi_s_aw_user_i;
  assign ext_axi_m_req_i.aw_valid  = marian_axi_s_aw_valid_i;
  assign ext_axi_m_req_i.b_ready   = marian_axi_s_b_ready_i;
  assign ext_axi_m_req_i.r_ready   = marian_axi_s_r_ready_i;
  assign ext_axi_m_req_i.w.data    = marian_axi_s_w_data_i;
  assign ext_axi_m_req_i.w.last    = marian_axi_s_w_last_i;
  assign ext_axi_m_req_i.w.strb    = marian_axi_s_w_strb_i;
  assign ext_axi_m_req_i.w.user    = marian_axi_s_w_user_i;
  assign ext_axi_m_req_i.w_valid   = marian_axi_s_w_valid_i;

  assign ext_axi_s_resp_i.ar_ready = marian_axi_m_ar_ready_i;
  assign ext_axi_s_resp_i.aw_ready = marian_axi_m_aw_ready_i;
  assign ext_axi_s_resp_i.b.id     = marian_axi_m_b_id_i;
  assign ext_axi_s_resp_i.b.resp   = marian_axi_m_b_resp_i;
  assign ext_axi_s_resp_i.b.user   = marian_axi_m_b_user_i;
  assign ext_axi_s_resp_i.b_valid  = marian_axi_m_b_valid_i;
  assign ext_axi_s_resp_i.r.data   = marian_axi_m_r_data_i;
  assign ext_axi_s_resp_i.r.id     = marian_axi_m_r_id_i;
  assign ext_axi_s_resp_i.r.last   = marian_axi_m_r_last_i;
  assign ext_axi_s_resp_i.r.resp   = marian_axi_m_r_resp_i;
  assign ext_axi_s_resp_i.r.user   = marian_axi_m_r_user_i;
  assign ext_axi_s_resp_i.r_valid  = marian_axi_m_r_valid_i;
  assign ext_axi_s_resp_i.w_ready  = marian_axi_m_w_ready_i;

`endif

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
