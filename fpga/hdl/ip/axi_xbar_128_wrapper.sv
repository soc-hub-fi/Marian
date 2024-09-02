//------------------------------------------------------------------------------
// Module   : axi_xbar_128_wrapper
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 12-jan-2024
//
// Description: SV wrapper for the 128b Xilinx AXI AXI Crossbar IP used within
// the marian_fpga project.
//
// Parameters:
//  - None
//
// Inputs:
//  - clk_i: Clock in
//  - rstn_i: Active-low asynchronous reset
//  - marian_m_axi_req_i: Marian AXI-M interface request signals
//  - dbg_m_axi_req_i: Debug Module AXI-M interface request signals
//  - dbg_s_axi_resp_i: Debug Module AXI-S interface respose signals
//  - uart_s_axi_resp_i: UART AXI-S interface respose signals
//  - qspi_s_axi_resp_i: QSPI AXI-S interface respose signals
//  - gpio_s_axi_resp_i: GPIO AXI-S interface respose signals
//  - timer_s_axi_resp_i: Timer AXI-S interface respose signals
//  - memory_s_axi_resp_i: Memory AXI-S interface respose signals
//
// Outputs:
//  - marian_m_axi_resp_o: Marian AXI-M interface response signals
//  - dbg_m_axi_resp_o: Debug Module AXI-M interface response signals
//  - dbg_s_axi_req_o: Debug Module AXI-S interface request signals
//  - uart_s_axi_req_o: UART AXI-S interface request signals
//  - qspi_s_axi_req_o: QSPI AXI-S interface request signals
//  - gpio_s_axi_req_o: GPIO AXI-S interface request signals
//  - timer_s_axi_req_o: Timer AXI-S interface request signals
//  - memory_s_axi_req_o: Memory AXI-S interface request signals
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

import marian_fpga_pkg::*;

module axi_xbar_128_wrapper (
  input  logic             clk_i,
  input  logic             rstn_i,

  // AXI-M -> XBAR AXI-S
  // Marian mgr
  input  system_req_t  marian_m_axi_req_i,
  output system_resp_t marian_m_axi_resp_o,
  // Debug module mgr
  input  system_req_t  dbg_m_axi_req_i,
  output system_resp_t dbg_m_axi_resp_o,

  // XBAR AXI-M -> AXI-S
  // Debug module sub
  input  system_resp_t dbg_s_axi_resp_i,
  output system_req_t  dbg_s_axi_req_o,
  // UART sub
  input  system_resp_t uart_s_axi_resp_i,
  output system_req_t  uart_s_axi_req_o,
  // QSPI sub
  input  system_resp_t qspi_s_axi_resp_i,
  output system_req_t  qspi_s_axi_req_o,
  // GPIO sub
  input  system_resp_t gpio_s_axi_resp_i,
  output system_req_t  gpio_s_axi_req_o,
  // Timer sub
  input  system_resp_t timer_s_axi_resp_i,
  output system_req_t  timer_s_axi_req_o,
  // Memory sub
  input  system_resp_t memory_s_axi_resp_i,
  output system_req_t  memory_s_axi_req_o
);

  // xbar port count
  localparam integer AXIMPortCount = 2; // slaves on xbar, masters -> connecting in
  localparam integer AXISPortCount = 6; // masters on xbar, slaves -> connecting out

  // xBar AXI_S Idx
  localparam int MIdxMarian = 0;
  localparam int MIdxDbgMod = 1;
  // xBar AXI_M Idx
  localparam int SIdxDbgM = 0;
  localparam int SIdxQSPI = 1;
  localparam int SIdxGPIO = 2;
  localparam int SIdxTimr = 3;
  localparam int SIdxDRAM = 4;
  localparam int SIdxUART = 5;

  // AXI-M Types
  typedef logic [AXIMPortCount-1:0][  AxiIdWidth-1:0] axi_m_id_arr_t;
  typedef logic [AXIMPortCount-1:0][AxiAddrWidth-1:0] axi_m_addr_arr_t;
  typedef logic [AXIMPortCount-1:0][           8-1:0] axi_m_axlen_arr_t;
  typedef logic [AXIMPortCount-1:0][           3-1:0] axi_m_axsize_arr_t;
  typedef logic [AXIMPortCount-1:0][           2-1:0] axi_m_axburst_arr_t;
  typedef logic [AXIMPortCount-1:0][           1-1:0] axi_m_axlock_arr_t;
  typedef logic [AXIMPortCount-1:0][           4-1:0] axi_m_axcache_arr_t;
  typedef logic [AXIMPortCount-1:0][           3-1:0] axi_m_axprot_arr_t;
  typedef logic [AXIMPortCount-1:0][           4-1:0] axi_m_axqos_arr_t;
  typedef logic [AXIMPortCount-1:0][AxiUserWidth-1:0] axi_m_user_arr_t;
  typedef logic [AXIMPortCount-1:0][           1-1:0] axi_m_vld_arr_t;
  typedef logic [AXIMPortCount-1:0][           1-1:0] axi_m_rdy_arr_t;
  typedef logic [AXIMPortCount-1:0][AxiDataWidth-1:0] axi_m_data_arr_t;
  typedef logic [AXIMPortCount-1:0][AxiStrbWidth-1:0] axi_m_strb_arr_t;
  typedef logic [AXIMPortCount-1:0][           1-1:0] axi_m_last_arr_t;
  typedef logic [AXIMPortCount-1:0][           2-1:0] axi_m_resp_arr_t;
  // AXI-S Types
  typedef logic [AXISPortCount-1:0][  AxiIdWidth-1:0] axi_s_id_arr_t;
  typedef logic [AXISPortCount-1:0][AxiAddrWidth-1:0] axi_s_addr_arr_t;
  typedef logic [AXISPortCount-1:0][           8-1:0] axi_s_axlen_arr_t;
  typedef logic [AXISPortCount-1:0][           3-1:0] axi_s_axsize_arr_t;
  typedef logic [AXISPortCount-1:0][           2-1:0] axi_s_axburst_arr_t;
  typedef logic [AXISPortCount-1:0][           1-1:0] axi_s_axlock_arr_t;
  typedef logic [AXISPortCount-1:0][           4-1:0] axi_s_axcache_arr_t;
  typedef logic [AXISPortCount-1:0][           3-1:0] axi_s_axprot_arr_t;
  typedef logic [AXISPortCount-1:0][           6-1:0] axi_s_awatop_arr_t;
  typedef logic [AXISPortCount-1:0][           4-1:0] axi_s_axqos_arr_t;
  typedef logic [AXISPortCount-1:0][AxiUserWidth-1:0] axi_s_user_arr_t;
  typedef logic [AXISPortCount-1:0][           1-1:0] axi_s_vld_arr_t;
  typedef logic [AXISPortCount-1:0][           1-1:0] axi_s_rdy_arr_t;
  typedef logic [AXISPortCount-1:0][AxiDataWidth-1:0] axi_s_data_arr_t;
  typedef logic [AXISPortCount-1:0][AxiStrbWidth-1:0] axi_s_strb_arr_t;
  typedef logic [AXISPortCount-1:0][           1-1:0] axi_s_last_arr_t;
  typedef logic [AXISPortCount-1:0][           2-1:0] axi_s_resp_arr_t;
  typedef logic [AXISPortCount-1:0][           4-1:0] axi_s_region_arr_t;

  wire [  9:0] s_axi_awid_s;
  wire [127:0] s_axi_awaddr_s;
  wire [ 15:0] s_axi_awlen_s;
  wire [  5:0] s_axi_awsize_s;
  wire [  3:0] s_axi_awburst_s;
  wire [  1:0] s_axi_awlock_s;
  wire [  7:0] s_axi_awcache_s;
  wire [  5:0] s_axi_awprot_s;
  wire [  7:0] s_axi_awqos_s;
  wire [  1:0] s_axi_awuser_s;
  wire [  1:0] s_axi_awvalid_s;
  wire [  1:0] s_axi_awready_s;
  wire [255:0] s_axi_wdata_s;
  wire [ 31:0] s_axi_wstrb_s;
  wire [  1:0] s_axi_wlast_s;
  wire [  1:0] s_axi_wuser_s;
  wire [  1:0] s_axi_wvalid_s;
  wire [  1:0] s_axi_wready_s;
  wire [  9:0] s_axi_bid_s;
  wire [  3:0] s_axi_bresp_s;
  wire [  1:0] s_axi_buser_s;
  wire [  1:0] s_axi_bvalid_s;
  wire [  1:0] s_axi_bready_s;
  wire [  9:0] s_axi_arid_s;
  wire [127:0] s_axi_araddr_s;
  wire [ 15:0] s_axi_arlen_s;
  wire [  5:0] s_axi_arsize_s;
  wire [  3:0] s_axi_arburst_s;
  wire [  1:0] s_axi_arlock_s;
  wire [  7:0] s_axi_arcache_s;
  wire [  5:0] s_axi_arprot_s;
  wire [  7:0] s_axi_arqos_s;
  wire [  1:0] s_axi_aruser_s;
  wire [  1:0] s_axi_arvalid_s;
  wire [  1:0] s_axi_arready_s;
  wire [  9:0] s_axi_rid_s;
  wire [255:0] s_axi_rdata_s;
  wire [  3:0] s_axi_rresp_s;
  wire [  1:0] s_axi_rlast_s;
  wire [  1:0] s_axi_ruser_s;
  wire [  1:0] s_axi_rvalid_s;
  wire [  1:0] s_axi_rready_s;
  wire [ 29:0] m_axi_awid_s;
  wire [383:0] m_axi_awaddr_s;
  wire [ 47:0] m_axi_awlen_s;
  wire [ 17:0] m_axi_awsize_s;
  wire [ 11:0] m_axi_awburst_s;
  wire [  5:0] m_axi_awlock_s;
  wire [ 23:0] m_axi_awcache_s;
  wire [ 17:0] m_axi_awprot_s;
  wire [ 23:0] m_axi_awregion_s;
  wire [ 23:0] m_axi_awqos_s;
  wire [  5:0] m_axi_awuser_s;
  wire [  5:0] m_axi_awvalid_s;
  wire [  5:0] m_axi_awready_s;
  wire [767:0] m_axi_wdata_s;
  wire [ 95:0] m_axi_wstrb_s;
  wire [  5:0] m_axi_wlast_s;
  wire [  5:0] m_axi_wuser_s;
  wire [  5:0] m_axi_wvalid_s;
  wire [  5:0] m_axi_wready_s;
  wire [ 29:0] m_axi_bid_s;
  wire [ 11:0] m_axi_bresp_s;
  wire [  5:0] m_axi_buser_s;
  wire [  5:0] m_axi_bvalid_s;
  wire [  5:0] m_axi_bready_s;
  wire [ 29:0] m_axi_arid_s;
  wire [383:0] m_axi_araddr_s;
  wire [ 47:0] m_axi_arlen_s;
  wire [ 17:0] m_axi_arsize_s;
  wire [ 11:0] m_axi_arburst_s;
  wire [  5:0] m_axi_arlock_s;
  wire [ 23:0] m_axi_arcache_s;
  wire [ 17:0] m_axi_arprot_s;
  wire [ 23:0] m_axi_arregion_s;
  wire [ 23:0] m_axi_arqos_s;
  wire [  5:0] m_axi_aruser_s;
  wire [  5:0] m_axi_arvalid_s;
  wire [  5:0] m_axi_arready_s;
  wire [ 29:0] m_axi_rid_s;
  wire [767:0] m_axi_rdata_s;
  wire [ 11:0] m_axi_rresp_s;
  wire [  5:0] m_axi_rlast_s;
  wire [  5:0] m_axi_ruser_s;
  wire [  5:0] m_axi_rvalid_s;
  wire [  5:0] m_axi_rready_s;

  // AXI-M aggregated signals
  // aw
  axi_m_id_arr_t      m_axi_awid_arr_s;
  axi_m_addr_arr_t    m_axi_awaddr_arr_s;
  axi_m_axlen_arr_t   m_axi_awlen_arr_s;
  axi_m_axsize_arr_t  m_axi_awsize_arr_s;
  axi_m_axburst_arr_t m_axi_awburst_arr_s;
  axi_m_axlock_arr_t  m_axi_awlock_arr_s;
  axi_m_axcache_arr_t m_axi_awcache_arr_s;
  axi_m_axprot_arr_t  m_axi_awprot_arr_s;
  axi_m_axqos_arr_t   m_axi_awqos_arr_s;
  axi_m_user_arr_t    m_axi_awuser_arr_s;
  axi_m_vld_arr_t     m_axi_awvalid_arr_s;
  axi_m_rdy_arr_t     m_axi_awready_arr_s;
  // w
  axi_m_data_arr_t    m_axi_wdata_arr_s;
  axi_m_strb_arr_t    m_axi_wstrb_arr_s;
  axi_m_last_arr_t    m_axi_wlast_arr_s;
  axi_m_user_arr_t    m_axi_wuser_arr_s;
  axi_m_vld_arr_t     m_axi_wvalid_arr_s;
  axi_m_rdy_arr_t     m_axi_wready_arr_s;
  // b
  axi_m_id_arr_t      m_axi_bid_arr_s;
  axi_m_resp_arr_t    m_axi_bresp_arr_s;
  axi_m_user_arr_t    m_axi_buser_arr_s;
  axi_m_vld_arr_t     m_axi_bvalid_arr_s;
  axi_m_rdy_arr_t     m_axi_bready_arr_s;
  // ar
  axi_m_id_arr_t      m_axi_arid_arr_s;
  axi_m_addr_arr_t    m_axi_araddr_arr_s;
  axi_m_axlen_arr_t   m_axi_arlen_arr_s;
  axi_m_axsize_arr_t  m_axi_arsize_arr_s;
  axi_m_axburst_arr_t m_axi_arburst_arr_s;
  axi_m_axlock_arr_t  m_axi_arlock_arr_s;
  axi_m_axcache_arr_t m_axi_arcache_arr_s;
  axi_m_axprot_arr_t  m_axi_arprot_arr_s;
  axi_m_axqos_arr_t   m_axi_arqos_arr_s;
  axi_m_user_arr_t    m_axi_aruser_arr_s;
  axi_m_vld_arr_t     m_axi_arvalid_arr_s;
  axi_m_rdy_arr_t     m_axi_arready_arr_s;
  // r
  axi_m_id_arr_t      m_axi_rid_arr_s;
  axi_m_data_arr_t    m_axi_rdata_arr_s;
  axi_m_resp_arr_t    m_axi_rresp_arr_s;
  axi_m_last_arr_t    m_axi_rlast_arr_s;
  axi_m_user_arr_t    m_axi_ruser_arr_s;
  axi_m_vld_arr_t     m_axi_rvalid_arr_s;
  axi_m_rdy_arr_t     m_axi_rready_arr_s;

  // AXI-S aggregated signals
  // aw
  axi_s_id_arr_t      s_axi_awid_arr_s;
  axi_s_addr_arr_t    s_axi_awaddr_arr_s;
  axi_s_axlen_arr_t   s_axi_awlen_arr_s;
  axi_s_axsize_arr_t  s_axi_awsize_arr_s;
  axi_s_axburst_arr_t s_axi_awburst_arr_s;
  axi_s_axlock_arr_t  s_axi_awlock_arr_s;
  axi_s_axcache_arr_t s_axi_awcache_arr_s;
  axi_s_axprot_arr_t  s_axi_awprot_arr_s;
  axi_s_awatop_arr_t  s_axi_awatop_arr_s;
  axi_s_region_arr_t  s_axi_awregion_arr_s;
  axi_s_axqos_arr_t   s_axi_awqos_arr_s;
  axi_s_user_arr_t    s_axi_awuser_arr_s;
  axi_s_vld_arr_t     s_axi_awvalid_arr_s;
  axi_s_rdy_arr_t     s_axi_awready_arr_s;
  // w
  axi_s_data_arr_t    s_axi_wdata_arr_s;
  axi_s_strb_arr_t    s_axi_wstrb_arr_s;
  axi_s_last_arr_t    s_axi_wlast_arr_s;
  axi_s_user_arr_t    s_axi_wuser_arr_s;
  axi_s_vld_arr_t     s_axi_wvalid_arr_s;
  axi_s_rdy_arr_t     s_axi_wready_arr_s;
  // b
  axi_s_id_arr_t      s_axi_bid_arr_s;
  axi_s_resp_arr_t    s_axi_bresp_arr_s;
  axi_s_user_arr_t    s_axi_buser_arr_s;
  axi_s_vld_arr_t     s_axi_bvalid_arr_s;
  axi_s_rdy_arr_t     s_axi_bready_arr_s;
  // ar
  axi_s_id_arr_t      s_axi_arid_arr_s;
  axi_s_addr_arr_t    s_axi_araddr_arr_s;
  axi_s_axlen_arr_t   s_axi_arlen_arr_s;
  axi_s_axsize_arr_t  s_axi_arsize_arr_s;
  axi_s_axburst_arr_t s_axi_arburst_arr_s;
  axi_s_axlock_arr_t  s_axi_arlock_arr_s;
  axi_s_axcache_arr_t s_axi_arcache_arr_s;
  axi_s_axprot_arr_t  s_axi_arprot_arr_s;
  axi_s_region_arr_t  s_axi_arregion_arr_s;
  axi_s_axqos_arr_t   s_axi_arqos_arr_s;
  axi_s_user_arr_t    s_axi_aruser_arr_s;
  axi_s_vld_arr_t     s_axi_arvalid_arr_s;
  axi_s_rdy_arr_t     s_axi_arready_arr_s;
  // r
  axi_s_id_arr_t      s_axi_rid_arr_s;
  axi_s_data_arr_t    s_axi_rdata_arr_s;
  axi_s_resp_arr_t    s_axi_rresp_arr_s;
  axi_s_last_arr_t    s_axi_rlast_arr_s;
  axi_s_user_arr_t    s_axi_ruser_arr_s;
  axi_s_vld_arr_t     s_axi_rvalid_arr_s;
  axi_s_rdy_arr_t     s_axi_rready_arr_s;

  // assignments to port interfaces
  // marian m

  // move MSB -> LSB as MSB used by xbar
  assign m_axi_awid_arr_s    [MIdxMarian] = {marian_m_axi_req_i.aw.id[AxiIdWidth-2:0],
                                             marian_m_axi_req_i.aw.id[AxiIdWidth-1]};
  assign m_axi_arid_arr_s    [MIdxMarian] = {marian_m_axi_req_i.ar.id[AxiIdWidth-2:0],
                                             marian_m_axi_req_i.ar.id[AxiIdWidth-1]};
  assign m_axi_awaddr_arr_s  [MIdxMarian] = marian_m_axi_req_i.aw.addr;
  assign m_axi_awlen_arr_s   [MIdxMarian] = marian_m_axi_req_i.aw.len;
  assign m_axi_awsize_arr_s  [MIdxMarian] = marian_m_axi_req_i.aw.size;
  assign m_axi_awburst_arr_s [MIdxMarian] = marian_m_axi_req_i.aw.burst;
  assign m_axi_awlock_arr_s  [MIdxMarian] = marian_m_axi_req_i.aw.lock;
  assign m_axi_awcache_arr_s [MIdxMarian] = marian_m_axi_req_i.aw.cache;
  assign m_axi_awprot_arr_s  [MIdxMarian] = marian_m_axi_req_i.aw.prot;
  assign m_axi_awqos_arr_s   [MIdxMarian] = marian_m_axi_req_i.aw.qos;
  assign m_axi_awuser_arr_s  [MIdxMarian] = marian_m_axi_req_i.aw.user;
  assign m_axi_awvalid_arr_s [MIdxMarian] = marian_m_axi_req_i.aw_valid;
  assign m_axi_wdata_arr_s   [MIdxMarian] = marian_m_axi_req_i.w.data;
  assign m_axi_wstrb_arr_s   [MIdxMarian] = marian_m_axi_req_i.w.strb;
  assign m_axi_wlast_arr_s   [MIdxMarian] = marian_m_axi_req_i.w.last;
  assign m_axi_wuser_arr_s   [MIdxMarian] = marian_m_axi_req_i.w.user;
  assign m_axi_wvalid_arr_s  [MIdxMarian] = marian_m_axi_req_i.w_valid;
  assign m_axi_bready_arr_s  [MIdxMarian] = marian_m_axi_req_i.b_ready;
  assign m_axi_araddr_arr_s  [MIdxMarian] = marian_m_axi_req_i.ar.addr;
  assign m_axi_arlen_arr_s   [MIdxMarian] = marian_m_axi_req_i.ar.len;
  assign m_axi_arsize_arr_s  [MIdxMarian] = marian_m_axi_req_i.ar.size;
  assign m_axi_arburst_arr_s [MIdxMarian] = marian_m_axi_req_i.ar.burst;
  assign m_axi_arlock_arr_s  [MIdxMarian] = marian_m_axi_req_i.ar.lock;
  assign m_axi_arcache_arr_s [MIdxMarian] = marian_m_axi_req_i.ar.cache;
  assign m_axi_arprot_arr_s  [MIdxMarian] = marian_m_axi_req_i.ar.prot;
  assign m_axi_arqos_arr_s   [MIdxMarian] = marian_m_axi_req_i.ar.qos;
  assign m_axi_aruser_arr_s  [MIdxMarian] = marian_m_axi_req_i.ar.user;
  assign m_axi_arvalid_arr_s [MIdxMarian] = marian_m_axi_req_i.ar_valid;
  assign m_axi_rready_arr_s  [MIdxMarian] = marian_m_axi_req_i.r_ready;

  assign marian_m_axi_resp_o.aw_ready = m_axi_awready_arr_s [MIdxMarian];
  assign marian_m_axi_resp_o.ar_ready = m_axi_arready_arr_s [MIdxMarian];
  assign marian_m_axi_resp_o.w_ready  = m_axi_wready_arr_s  [MIdxMarian];
  assign marian_m_axi_resp_o.b_valid  = m_axi_bvalid_arr_s  [MIdxMarian];
  assign marian_m_axi_resp_o.b.resp   = m_axi_bresp_arr_s   [MIdxMarian];
  assign marian_m_axi_resp_o.b.user   = m_axi_buser_arr_s   [MIdxMarian];
  assign marian_m_axi_resp_o.r_valid  = m_axi_rvalid_arr_s  [MIdxMarian];
  assign marian_m_axi_resp_o.r.data   = m_axi_rdata_arr_s   [MIdxMarian];
  assign marian_m_axi_resp_o.r.resp   = m_axi_rresp_arr_s   [MIdxMarian];
  assign marian_m_axi_resp_o.r.last   = m_axi_rlast_arr_s   [MIdxMarian];
  assign marian_m_axi_resp_o.r.user   = m_axi_ruser_arr_s   [MIdxMarian];

  // move LSB -> MSB to restore ID for marian system mux
  assign marian_m_axi_resp_o.b.id     = {m_axi_bid_arr_s[MIdxMarian][0],
                                         m_axi_bid_arr_s[MIdxMarian][AxiIdWidth-1:1]};
  assign marian_m_axi_resp_o.r.id     = {m_axi_rid_arr_s[MIdxMarian][0],
                                         m_axi_rid_arr_s[MIdxMarian][AxiIdWidth-1:1]};

  // debug m
  assign m_axi_awid_arr_s    [MIdxDbgMod] = dbg_m_axi_req_i.aw.id;
  assign m_axi_awaddr_arr_s  [MIdxDbgMod] = dbg_m_axi_req_i.aw.addr;
  assign m_axi_awlen_arr_s   [MIdxDbgMod] = dbg_m_axi_req_i.aw.len;
  assign m_axi_awsize_arr_s  [MIdxDbgMod] = dbg_m_axi_req_i.aw.size;
  assign m_axi_awburst_arr_s [MIdxDbgMod] = dbg_m_axi_req_i.aw.burst;
  assign m_axi_awlock_arr_s  [MIdxDbgMod] = dbg_m_axi_req_i.aw.lock;
  assign m_axi_awcache_arr_s [MIdxDbgMod] = dbg_m_axi_req_i.aw.cache;
  assign m_axi_awprot_arr_s  [MIdxDbgMod] = dbg_m_axi_req_i.aw.prot;
  assign m_axi_awqos_arr_s   [MIdxDbgMod] = dbg_m_axi_req_i.aw.qos;
  assign m_axi_awuser_arr_s  [MIdxDbgMod] = dbg_m_axi_req_i.aw.user;
  assign m_axi_awvalid_arr_s [MIdxDbgMod] = dbg_m_axi_req_i.aw_valid;
  assign m_axi_wdata_arr_s   [MIdxDbgMod] = dbg_m_axi_req_i.w.data;
  assign m_axi_wstrb_arr_s   [MIdxDbgMod] = dbg_m_axi_req_i.w.strb;
  assign m_axi_wlast_arr_s   [MIdxDbgMod] = dbg_m_axi_req_i.w.last;
  assign m_axi_wuser_arr_s   [MIdxDbgMod] = dbg_m_axi_req_i.w.user;
  assign m_axi_wvalid_arr_s  [MIdxDbgMod] = dbg_m_axi_req_i.w_valid;
  assign m_axi_bready_arr_s  [MIdxDbgMod] = dbg_m_axi_req_i.b_ready;
  assign m_axi_arid_arr_s    [MIdxDbgMod] = dbg_m_axi_req_i.ar.id;
  assign m_axi_araddr_arr_s  [MIdxDbgMod] = dbg_m_axi_req_i.ar.addr;
  assign m_axi_arlen_arr_s   [MIdxDbgMod] = dbg_m_axi_req_i.ar.len;
  assign m_axi_arsize_arr_s  [MIdxDbgMod] = dbg_m_axi_req_i.ar.size;
  assign m_axi_arburst_arr_s [MIdxDbgMod] = dbg_m_axi_req_i.ar.burst;
  assign m_axi_arlock_arr_s  [MIdxDbgMod] = dbg_m_axi_req_i.ar.lock;
  assign m_axi_arcache_arr_s [MIdxDbgMod] = dbg_m_axi_req_i.ar.cache;
  assign m_axi_arprot_arr_s  [MIdxDbgMod] = dbg_m_axi_req_i.ar.prot;
  assign m_axi_arqos_arr_s   [MIdxDbgMod] = dbg_m_axi_req_i.ar.qos;
  assign m_axi_aruser_arr_s  [MIdxDbgMod] = dbg_m_axi_req_i.ar.user;
  assign m_axi_arvalid_arr_s [MIdxDbgMod] = dbg_m_axi_req_i.ar_valid;
  assign m_axi_rready_arr_s  [MIdxDbgMod] = dbg_m_axi_req_i.r_ready;

  assign dbg_m_axi_resp_o.aw_ready = m_axi_awready_arr_s [MIdxDbgMod];
  assign dbg_m_axi_resp_o.ar_ready = m_axi_arready_arr_s [MIdxDbgMod];
  assign dbg_m_axi_resp_o.w_ready  = m_axi_wready_arr_s  [MIdxDbgMod];
  assign dbg_m_axi_resp_o.b_valid  = m_axi_bvalid_arr_s  [MIdxDbgMod];
  assign dbg_m_axi_resp_o.b.id     = m_axi_bid_arr_s     [MIdxDbgMod];
  assign dbg_m_axi_resp_o.b.resp   = m_axi_bresp_arr_s   [MIdxDbgMod];
  assign dbg_m_axi_resp_o.b.user   = m_axi_buser_arr_s   [MIdxDbgMod];
  assign dbg_m_axi_resp_o.r_valid  = m_axi_rvalid_arr_s  [MIdxDbgMod];
  assign dbg_m_axi_resp_o.r.id     = m_axi_rid_arr_s     [MIdxDbgMod];
  assign dbg_m_axi_resp_o.r.data   = m_axi_rdata_arr_s   [MIdxDbgMod];
  assign dbg_m_axi_resp_o.r.resp   = m_axi_rresp_arr_s   [MIdxDbgMod];
  assign dbg_m_axi_resp_o.r.last   = m_axi_rlast_arr_s   [MIdxDbgMod];
  assign dbg_m_axi_resp_o.r.user   = m_axi_ruser_arr_s   [MIdxDbgMod];

  // debug s
  assign s_axi_awready_arr_s [SIdxDbgM] = dbg_s_axi_resp_i.aw_ready;
  assign s_axi_arready_arr_s [SIdxDbgM] = dbg_s_axi_resp_i.ar_ready;
  assign s_axi_wready_arr_s  [SIdxDbgM] = dbg_s_axi_resp_i.w_ready;
  assign s_axi_bvalid_arr_s  [SIdxDbgM] = dbg_s_axi_resp_i.b_valid;
  assign s_axi_bid_arr_s     [SIdxDbgM] = dbg_s_axi_resp_i.b.id;
  assign s_axi_bresp_arr_s   [SIdxDbgM] = dbg_s_axi_resp_i.b.resp;
  assign s_axi_buser_arr_s   [SIdxDbgM] = dbg_s_axi_resp_i.b.user;
  assign s_axi_rvalid_arr_s  [SIdxDbgM] = dbg_s_axi_resp_i.r_valid;
  assign s_axi_rid_arr_s     [SIdxDbgM] = dbg_s_axi_resp_i.r.id;
  assign s_axi_rdata_arr_s   [SIdxDbgM] = dbg_s_axi_resp_i.r.data;
  assign s_axi_rresp_arr_s   [SIdxDbgM] = dbg_s_axi_resp_i.r.resp;
  assign s_axi_rlast_arr_s   [SIdxDbgM] = dbg_s_axi_resp_i.r.last;
  assign s_axi_ruser_arr_s   [SIdxDbgM] = dbg_s_axi_resp_i.r.user;

  assign dbg_s_axi_req_o.aw.id     = s_axi_awid_arr_s     [SIdxDbgM];
  assign dbg_s_axi_req_o.aw.addr   = s_axi_awaddr_arr_s   [SIdxDbgM];
  assign dbg_s_axi_req_o.aw.len    = s_axi_awlen_arr_s    [SIdxDbgM];
  assign dbg_s_axi_req_o.aw.size   = s_axi_awsize_arr_s   [SIdxDbgM];
  assign dbg_s_axi_req_o.aw.burst  = s_axi_awburst_arr_s  [SIdxDbgM];
  assign dbg_s_axi_req_o.aw.lock   = s_axi_awlock_arr_s   [SIdxDbgM];
  assign dbg_s_axi_req_o.aw.cache  = s_axi_awcache_arr_s  [SIdxDbgM];
  assign dbg_s_axi_req_o.aw.prot   = s_axi_awprot_arr_s   [SIdxDbgM];
  assign dbg_s_axi_req_o.aw.qos    = s_axi_awqos_arr_s    [SIdxDbgM];
  assign dbg_s_axi_req_o.aw.region = s_axi_awregion_arr_s [SIdxDbgM];
  assign dbg_s_axi_req_o.aw.atop   = s_axi_awatop_arr_s   [SIdxDbgM];
  assign dbg_s_axi_req_o.aw.user   = s_axi_awuser_arr_s   [SIdxDbgM];
  assign dbg_s_axi_req_o.aw_valid  = s_axi_awvalid_arr_s  [SIdxDbgM];
  assign dbg_s_axi_req_o.w.data    = s_axi_wdata_arr_s    [SIdxDbgM];
  assign dbg_s_axi_req_o.w.strb    = s_axi_wstrb_arr_s    [SIdxDbgM];
  assign dbg_s_axi_req_o.w.last    = s_axi_wlast_arr_s    [SIdxDbgM];
  assign dbg_s_axi_req_o.w.user    = s_axi_wuser_arr_s    [SIdxDbgM];
  assign dbg_s_axi_req_o.w_valid   = s_axi_wvalid_arr_s   [SIdxDbgM];
  assign dbg_s_axi_req_o.b_ready   = s_axi_bready_arr_s   [SIdxDbgM];
  assign dbg_s_axi_req_o.ar.id     = s_axi_arid_arr_s     [SIdxDbgM];
  assign dbg_s_axi_req_o.ar.addr   = s_axi_araddr_arr_s   [SIdxDbgM];
  assign dbg_s_axi_req_o.ar.len    = s_axi_arlen_arr_s    [SIdxDbgM];
  assign dbg_s_axi_req_o.ar.size   = s_axi_arsize_arr_s   [SIdxDbgM];
  assign dbg_s_axi_req_o.ar.burst  = s_axi_arburst_arr_s  [SIdxDbgM];
  assign dbg_s_axi_req_o.ar.lock   = s_axi_arlock_arr_s   [SIdxDbgM];
  assign dbg_s_axi_req_o.ar.cache  = s_axi_arcache_arr_s  [SIdxDbgM];
  assign dbg_s_axi_req_o.ar.prot   = s_axi_arprot_arr_s   [SIdxDbgM];
  assign dbg_s_axi_req_o.ar.qos    = s_axi_arqos_arr_s    [SIdxDbgM];
  assign dbg_s_axi_req_o.ar.region = s_axi_arregion_arr_s [SIdxDbgM];
  assign dbg_s_axi_req_o.ar.user   = s_axi_aruser_arr_s   [SIdxDbgM];
  assign dbg_s_axi_req_o.ar_valid  = s_axi_arvalid_arr_s  [SIdxDbgM];
  assign dbg_s_axi_req_o.r_ready   = s_axi_rready_arr_s   [SIdxDbgM];

  // uart s
  assign s_axi_awready_arr_s [SIdxUART] = uart_s_axi_resp_i.aw_ready;
  assign s_axi_arready_arr_s [SIdxUART] = uart_s_axi_resp_i.ar_ready;
  assign s_axi_wready_arr_s  [SIdxUART] = uart_s_axi_resp_i.w_ready;
  assign s_axi_bvalid_arr_s  [SIdxUART] = uart_s_axi_resp_i.b_valid;
  assign s_axi_bid_arr_s     [SIdxUART] = uart_s_axi_resp_i.b.id;
  assign s_axi_bresp_arr_s   [SIdxUART] = uart_s_axi_resp_i.b.resp;
  assign s_axi_buser_arr_s   [SIdxUART] = uart_s_axi_resp_i.b.user;
  assign s_axi_rvalid_arr_s  [SIdxUART] = uart_s_axi_resp_i.r_valid;
  assign s_axi_rid_arr_s     [SIdxUART] = uart_s_axi_resp_i.r.id;
  assign s_axi_rdata_arr_s   [SIdxUART] = uart_s_axi_resp_i.r.data;
  assign s_axi_rresp_arr_s   [SIdxUART] = uart_s_axi_resp_i.r.resp;
  assign s_axi_rlast_arr_s   [SIdxUART] = uart_s_axi_resp_i.r.last;
  assign s_axi_ruser_arr_s   [SIdxUART] = uart_s_axi_resp_i.r.user;

  assign uart_s_axi_req_o.aw.id     = s_axi_awid_arr_s     [SIdxUART];
  assign uart_s_axi_req_o.aw.addr   = s_axi_awaddr_arr_s   [SIdxUART];
  assign uart_s_axi_req_o.aw.len    = s_axi_awlen_arr_s    [SIdxUART];
  assign uart_s_axi_req_o.aw.size   = s_axi_awsize_arr_s   [SIdxUART];
  assign uart_s_axi_req_o.aw.burst  = s_axi_awburst_arr_s  [SIdxUART];
  assign uart_s_axi_req_o.aw.lock   = s_axi_awlock_arr_s   [SIdxUART];
  assign uart_s_axi_req_o.aw.cache  = s_axi_awcache_arr_s  [SIdxUART];
  assign uart_s_axi_req_o.aw.prot   = s_axi_awprot_arr_s   [SIdxUART];
  assign uart_s_axi_req_o.aw.qos    = s_axi_awqos_arr_s    [SIdxUART];
  assign uart_s_axi_req_o.aw.region = s_axi_awregion_arr_s [SIdxUART];
  assign uart_s_axi_req_o.aw.atop   = s_axi_awatop_arr_s   [SIdxUART];
  assign uart_s_axi_req_o.aw.user   = s_axi_awuser_arr_s   [SIdxUART];
  assign uart_s_axi_req_o.aw_valid  = s_axi_awvalid_arr_s  [SIdxUART];
  assign uart_s_axi_req_o.w.data    = s_axi_wdata_arr_s    [SIdxUART];
  assign uart_s_axi_req_o.w.strb    = s_axi_wstrb_arr_s    [SIdxUART];
  assign uart_s_axi_req_o.w.last    = s_axi_wlast_arr_s    [SIdxUART];
  assign uart_s_axi_req_o.w.user    = s_axi_wuser_arr_s    [SIdxUART];
  assign uart_s_axi_req_o.w_valid   = s_axi_wvalid_arr_s   [SIdxUART];
  assign uart_s_axi_req_o.b_ready   = s_axi_bready_arr_s   [SIdxUART];
  assign uart_s_axi_req_o.ar.id     = s_axi_arid_arr_s     [SIdxUART];
  assign uart_s_axi_req_o.ar.addr   = s_axi_araddr_arr_s   [SIdxUART];
  assign uart_s_axi_req_o.ar.len    = s_axi_arlen_arr_s    [SIdxUART];
  assign uart_s_axi_req_o.ar.size   = s_axi_arsize_arr_s   [SIdxUART];
  assign uart_s_axi_req_o.ar.burst  = s_axi_arburst_arr_s  [SIdxUART];
  assign uart_s_axi_req_o.ar.lock   = s_axi_arlock_arr_s   [SIdxUART];
  assign uart_s_axi_req_o.ar.cache  = s_axi_arcache_arr_s  [SIdxUART];
  assign uart_s_axi_req_o.ar.prot   = s_axi_arprot_arr_s   [SIdxUART];
  assign uart_s_axi_req_o.ar.qos    = s_axi_arqos_arr_s    [SIdxUART];
  assign uart_s_axi_req_o.ar.region = s_axi_arregion_arr_s [SIdxUART];
  assign uart_s_axi_req_o.ar.user   = s_axi_aruser_arr_s   [SIdxUART];
  assign uart_s_axi_req_o.ar_valid  = s_axi_arvalid_arr_s  [SIdxUART];
  assign uart_s_axi_req_o.r_ready   = s_axi_rready_arr_s   [SIdxUART];

  // qspi s
  assign s_axi_awready_arr_s [SIdxQSPI] = qspi_s_axi_resp_i.aw_ready;
  assign s_axi_arready_arr_s [SIdxQSPI] = qspi_s_axi_resp_i.ar_ready;
  assign s_axi_wready_arr_s  [SIdxQSPI] = qspi_s_axi_resp_i.w_ready;
  assign s_axi_bvalid_arr_s  [SIdxQSPI] = qspi_s_axi_resp_i.b_valid;
  assign s_axi_bid_arr_s     [SIdxQSPI] = qspi_s_axi_resp_i.b.id;
  assign s_axi_bresp_arr_s   [SIdxQSPI] = qspi_s_axi_resp_i.b.resp;
  assign s_axi_buser_arr_s   [SIdxQSPI] = qspi_s_axi_resp_i.b.user;
  assign s_axi_rvalid_arr_s  [SIdxQSPI] = qspi_s_axi_resp_i.r_valid;
  assign s_axi_rid_arr_s     [SIdxQSPI] = qspi_s_axi_resp_i.r.id;
  assign s_axi_rdata_arr_s   [SIdxQSPI] = qspi_s_axi_resp_i.r.data;
  assign s_axi_rresp_arr_s   [SIdxQSPI] = qspi_s_axi_resp_i.r.resp;
  assign s_axi_rlast_arr_s   [SIdxQSPI] = qspi_s_axi_resp_i.r.last;
  assign s_axi_ruser_arr_s   [SIdxQSPI] = qspi_s_axi_resp_i.r.user;

  assign qspi_s_axi_req_o.aw.id     = s_axi_awid_arr_s     [SIdxQSPI];
  assign qspi_s_axi_req_o.aw.addr   = s_axi_awaddr_arr_s   [SIdxQSPI];
  assign qspi_s_axi_req_o.aw.len    = s_axi_awlen_arr_s    [SIdxQSPI];
  assign qspi_s_axi_req_o.aw.size   = s_axi_awsize_arr_s   [SIdxQSPI];
  assign qspi_s_axi_req_o.aw.burst  = s_axi_awburst_arr_s  [SIdxQSPI];
  assign qspi_s_axi_req_o.aw.lock   = s_axi_awlock_arr_s   [SIdxQSPI];
  assign qspi_s_axi_req_o.aw.cache  = s_axi_awcache_arr_s  [SIdxQSPI];
  assign qspi_s_axi_req_o.aw.prot   = s_axi_awprot_arr_s   [SIdxQSPI];
  assign qspi_s_axi_req_o.aw.qos    = s_axi_awqos_arr_s    [SIdxQSPI];
  assign qspi_s_axi_req_o.aw.region = s_axi_awregion_arr_s [SIdxQSPI];
  assign qspi_s_axi_req_o.aw.atop   = s_axi_awatop_arr_s   [SIdxQSPI];
  assign qspi_s_axi_req_o.aw.user   = s_axi_awuser_arr_s   [SIdxQSPI];
  assign qspi_s_axi_req_o.aw_valid  = s_axi_awvalid_arr_s  [SIdxQSPI];
  assign qspi_s_axi_req_o.w.data    = s_axi_wdata_arr_s    [SIdxQSPI];
  assign qspi_s_axi_req_o.w.strb    = s_axi_wstrb_arr_s    [SIdxQSPI];
  assign qspi_s_axi_req_o.w.last    = s_axi_wlast_arr_s    [SIdxQSPI];
  assign qspi_s_axi_req_o.w.user    = s_axi_wuser_arr_s    [SIdxQSPI];
  assign qspi_s_axi_req_o.w_valid   = s_axi_wvalid_arr_s   [SIdxQSPI];
  assign qspi_s_axi_req_o.b_ready   = s_axi_bready_arr_s   [SIdxQSPI];
  assign qspi_s_axi_req_o.ar.id     = s_axi_arid_arr_s     [SIdxQSPI];
  assign qspi_s_axi_req_o.ar.addr   = s_axi_araddr_arr_s   [SIdxQSPI];
  assign qspi_s_axi_req_o.ar.len    = s_axi_arlen_arr_s    [SIdxQSPI];
  assign qspi_s_axi_req_o.ar.size   = s_axi_arsize_arr_s   [SIdxQSPI];
  assign qspi_s_axi_req_o.ar.burst  = s_axi_arburst_arr_s  [SIdxQSPI];
  assign qspi_s_axi_req_o.ar.lock   = s_axi_arlock_arr_s   [SIdxQSPI];
  assign qspi_s_axi_req_o.ar.cache  = s_axi_arcache_arr_s  [SIdxQSPI];
  assign qspi_s_axi_req_o.ar.prot   = s_axi_arprot_arr_s   [SIdxQSPI];
  assign qspi_s_axi_req_o.ar.qos    = s_axi_arqos_arr_s    [SIdxQSPI];
  assign qspi_s_axi_req_o.ar.region = s_axi_arregion_arr_s [SIdxQSPI];
  assign qspi_s_axi_req_o.ar.user   = s_axi_aruser_arr_s   [SIdxQSPI];
  assign qspi_s_axi_req_o.ar_valid  = s_axi_arvalid_arr_s  [SIdxQSPI];
  assign qspi_s_axi_req_o.r_ready   = s_axi_rready_arr_s   [SIdxQSPI];

  // gpio s
  assign s_axi_awready_arr_s [SIdxGPIO] = gpio_s_axi_resp_i.aw_ready;
  assign s_axi_arready_arr_s [SIdxGPIO] = gpio_s_axi_resp_i.ar_ready;
  assign s_axi_wready_arr_s  [SIdxGPIO] = gpio_s_axi_resp_i.w_ready;
  assign s_axi_bvalid_arr_s  [SIdxGPIO] = gpio_s_axi_resp_i.b_valid;
  assign s_axi_bid_arr_s     [SIdxGPIO] = gpio_s_axi_resp_i.b.id;
  assign s_axi_bresp_arr_s   [SIdxGPIO] = gpio_s_axi_resp_i.b.resp;
  assign s_axi_buser_arr_s   [SIdxGPIO] = gpio_s_axi_resp_i.b.user;
  assign s_axi_rvalid_arr_s  [SIdxGPIO] = gpio_s_axi_resp_i.r_valid;
  assign s_axi_rid_arr_s     [SIdxGPIO] = gpio_s_axi_resp_i.r.id;
  assign s_axi_rdata_arr_s   [SIdxGPIO] = gpio_s_axi_resp_i.r.data;
  assign s_axi_rresp_arr_s   [SIdxGPIO] = gpio_s_axi_resp_i.r.resp;
  assign s_axi_rlast_arr_s   [SIdxGPIO] = gpio_s_axi_resp_i.r.last;
  assign s_axi_ruser_arr_s   [SIdxGPIO] = gpio_s_axi_resp_i.r.user;

  assign gpio_s_axi_req_o.aw.id     = s_axi_awid_arr_s     [SIdxGPIO];
  assign gpio_s_axi_req_o.aw.addr   = s_axi_awaddr_arr_s   [SIdxGPIO];
  assign gpio_s_axi_req_o.aw.len    = s_axi_awlen_arr_s    [SIdxGPIO];
  assign gpio_s_axi_req_o.aw.size   = s_axi_awsize_arr_s   [SIdxGPIO];
  assign gpio_s_axi_req_o.aw.burst  = s_axi_awburst_arr_s  [SIdxGPIO];
  assign gpio_s_axi_req_o.aw.lock   = s_axi_awlock_arr_s   [SIdxGPIO];
  assign gpio_s_axi_req_o.aw.cache  = s_axi_awcache_arr_s  [SIdxGPIO];
  assign gpio_s_axi_req_o.aw.prot   = s_axi_awprot_arr_s   [SIdxGPIO];
  assign gpio_s_axi_req_o.aw.qos    = s_axi_awqos_arr_s    [SIdxGPIO];
  assign gpio_s_axi_req_o.aw.region = s_axi_awregion_arr_s [SIdxGPIO];
  assign gpio_s_axi_req_o.aw.atop   = s_axi_awatop_arr_s   [SIdxGPIO];
  assign gpio_s_axi_req_o.aw.user   = s_axi_awuser_arr_s   [SIdxGPIO];
  assign gpio_s_axi_req_o.aw_valid  = s_axi_awvalid_arr_s  [SIdxGPIO];
  assign gpio_s_axi_req_o.w.data    = s_axi_wdata_arr_s    [SIdxGPIO];
  assign gpio_s_axi_req_o.w.strb    = s_axi_wstrb_arr_s    [SIdxGPIO];
  assign gpio_s_axi_req_o.w.last    = s_axi_wlast_arr_s    [SIdxGPIO];
  assign gpio_s_axi_req_o.w.user    = s_axi_wuser_arr_s    [SIdxGPIO];
  assign gpio_s_axi_req_o.w_valid   = s_axi_wvalid_arr_s   [SIdxGPIO];
  assign gpio_s_axi_req_o.b_ready   = s_axi_bready_arr_s   [SIdxGPIO];
  assign gpio_s_axi_req_o.ar.id     = s_axi_arid_arr_s     [SIdxGPIO];
  assign gpio_s_axi_req_o.ar.addr   = s_axi_araddr_arr_s   [SIdxGPIO];
  assign gpio_s_axi_req_o.ar.len    = s_axi_arlen_arr_s    [SIdxGPIO];
  assign gpio_s_axi_req_o.ar.size   = s_axi_arsize_arr_s   [SIdxGPIO];
  assign gpio_s_axi_req_o.ar.burst  = s_axi_arburst_arr_s  [SIdxGPIO];
  assign gpio_s_axi_req_o.ar.lock   = s_axi_arlock_arr_s   [SIdxGPIO];
  assign gpio_s_axi_req_o.ar.cache  = s_axi_arcache_arr_s  [SIdxGPIO];
  assign gpio_s_axi_req_o.ar.prot   = s_axi_arprot_arr_s   [SIdxGPIO];
  assign gpio_s_axi_req_o.ar.qos    = s_axi_arqos_arr_s    [SIdxGPIO];
  assign gpio_s_axi_req_o.ar.region = s_axi_arregion_arr_s [SIdxGPIO];
  assign gpio_s_axi_req_o.ar.user   = s_axi_aruser_arr_s   [SIdxGPIO];
  assign gpio_s_axi_req_o.ar_valid  = s_axi_arvalid_arr_s  [SIdxGPIO];
  assign gpio_s_axi_req_o.r_ready   = s_axi_rready_arr_s   [SIdxGPIO];

  // timer s
  assign s_axi_awready_arr_s [SIdxTimr] = timer_s_axi_resp_i.aw_ready;
  assign s_axi_arready_arr_s [SIdxTimr] = timer_s_axi_resp_i.ar_ready;
  assign s_axi_wready_arr_s  [SIdxTimr] = timer_s_axi_resp_i.w_ready;
  assign s_axi_bvalid_arr_s  [SIdxTimr] = timer_s_axi_resp_i.b_valid;
  assign s_axi_bid_arr_s     [SIdxTimr] = timer_s_axi_resp_i.b.id;
  assign s_axi_bresp_arr_s   [SIdxTimr] = timer_s_axi_resp_i.b.resp;
  assign s_axi_buser_arr_s   [SIdxTimr] = timer_s_axi_resp_i.b.user;
  assign s_axi_rvalid_arr_s  [SIdxTimr] = timer_s_axi_resp_i.r_valid;
  assign s_axi_rid_arr_s     [SIdxTimr] = timer_s_axi_resp_i.r.id;
  assign s_axi_rdata_arr_s   [SIdxTimr] = timer_s_axi_resp_i.r.data;
  assign s_axi_rresp_arr_s   [SIdxTimr] = timer_s_axi_resp_i.r.resp;
  assign s_axi_rlast_arr_s   [SIdxTimr] = timer_s_axi_resp_i.r.last;
  assign s_axi_ruser_arr_s   [SIdxTimr] = timer_s_axi_resp_i.r.user;

  assign timer_s_axi_req_o.aw.id     = s_axi_awid_arr_s     [SIdxTimr];
  assign timer_s_axi_req_o.aw.addr   = s_axi_awaddr_arr_s   [SIdxTimr];
  assign timer_s_axi_req_o.aw.len    = s_axi_awlen_arr_s    [SIdxTimr];
  assign timer_s_axi_req_o.aw.size   = s_axi_awsize_arr_s   [SIdxTimr];
  assign timer_s_axi_req_o.aw.burst  = s_axi_awburst_arr_s  [SIdxTimr];
  assign timer_s_axi_req_o.aw.lock   = s_axi_awlock_arr_s   [SIdxTimr];
  assign timer_s_axi_req_o.aw.cache  = s_axi_awcache_arr_s  [SIdxTimr];
  assign timer_s_axi_req_o.aw.prot   = s_axi_awprot_arr_s   [SIdxTimr];
  assign timer_s_axi_req_o.aw.qos    = s_axi_awqos_arr_s    [SIdxTimr];
  assign timer_s_axi_req_o.aw.region = s_axi_awregion_arr_s [SIdxTimr];
  assign timer_s_axi_req_o.aw.atop   = s_axi_awatop_arr_s   [SIdxTimr];
  assign timer_s_axi_req_o.aw.user   = s_axi_awuser_arr_s   [SIdxTimr];
  assign timer_s_axi_req_o.aw_valid  = s_axi_awvalid_arr_s  [SIdxTimr];
  assign timer_s_axi_req_o.w.data    = s_axi_wdata_arr_s    [SIdxTimr];
  assign timer_s_axi_req_o.w.strb    = s_axi_wstrb_arr_s    [SIdxTimr];
  assign timer_s_axi_req_o.w.last    = s_axi_wlast_arr_s    [SIdxTimr];
  assign timer_s_axi_req_o.w.user    = s_axi_wuser_arr_s    [SIdxTimr];
  assign timer_s_axi_req_o.w_valid   = s_axi_wvalid_arr_s   [SIdxTimr];
  assign timer_s_axi_req_o.b_ready   = s_axi_bready_arr_s   [SIdxTimr];
  assign timer_s_axi_req_o.ar.id     = s_axi_arid_arr_s     [SIdxTimr];
  assign timer_s_axi_req_o.ar.addr   = s_axi_araddr_arr_s   [SIdxTimr];
  assign timer_s_axi_req_o.ar.len    = s_axi_arlen_arr_s    [SIdxTimr];
  assign timer_s_axi_req_o.ar.size   = s_axi_arsize_arr_s   [SIdxTimr];
  assign timer_s_axi_req_o.ar.burst  = s_axi_arburst_arr_s  [SIdxTimr];
  assign timer_s_axi_req_o.ar.lock   = s_axi_arlock_arr_s   [SIdxTimr];
  assign timer_s_axi_req_o.ar.cache  = s_axi_arcache_arr_s  [SIdxTimr];
  assign timer_s_axi_req_o.ar.prot   = s_axi_arprot_arr_s   [SIdxTimr];
  assign timer_s_axi_req_o.ar.qos    = s_axi_arqos_arr_s    [SIdxTimr];
  assign timer_s_axi_req_o.ar.region = s_axi_arregion_arr_s [SIdxTimr];
  assign timer_s_axi_req_o.ar.user   = s_axi_aruser_arr_s   [SIdxTimr];
  assign timer_s_axi_req_o.ar_valid  = s_axi_arvalid_arr_s  [SIdxTimr];
  assign timer_s_axi_req_o.r_ready   = s_axi_rready_arr_s   [SIdxTimr];

  // memory s
  assign s_axi_awready_arr_s [SIdxDRAM] = memory_s_axi_resp_i.aw_ready;
  assign s_axi_arready_arr_s [SIdxDRAM] = memory_s_axi_resp_i.ar_ready;
  assign s_axi_wready_arr_s  [SIdxDRAM] = memory_s_axi_resp_i.w_ready;
  assign s_axi_bvalid_arr_s  [SIdxDRAM] = memory_s_axi_resp_i.b_valid;
  assign s_axi_bid_arr_s     [SIdxDRAM] = memory_s_axi_resp_i.b.id;
  assign s_axi_bresp_arr_s   [SIdxDRAM] = memory_s_axi_resp_i.b.resp;
  assign s_axi_buser_arr_s   [SIdxDRAM] = memory_s_axi_resp_i.b.user;
  assign s_axi_rvalid_arr_s  [SIdxDRAM] = memory_s_axi_resp_i.r_valid;
  assign s_axi_rid_arr_s     [SIdxDRAM] = memory_s_axi_resp_i.r.id;
  assign s_axi_rdata_arr_s   [SIdxDRAM] = memory_s_axi_resp_i.r.data;
  assign s_axi_rresp_arr_s   [SIdxDRAM] = memory_s_axi_resp_i.r.resp;
  assign s_axi_rlast_arr_s   [SIdxDRAM] = memory_s_axi_resp_i.r.last;
  assign s_axi_ruser_arr_s   [SIdxDRAM] = memory_s_axi_resp_i.r.user;

  assign memory_s_axi_req_o.aw.id     = s_axi_awid_arr_s     [SIdxDRAM];
  assign memory_s_axi_req_o.aw.addr   = s_axi_awaddr_arr_s   [SIdxDRAM];
  assign memory_s_axi_req_o.aw.len    = s_axi_awlen_arr_s    [SIdxDRAM];
  assign memory_s_axi_req_o.aw.size   = s_axi_awsize_arr_s   [SIdxDRAM];
  assign memory_s_axi_req_o.aw.burst  = s_axi_awburst_arr_s  [SIdxDRAM];
  assign memory_s_axi_req_o.aw.lock   = s_axi_awlock_arr_s   [SIdxDRAM];
  assign memory_s_axi_req_o.aw.cache  = s_axi_awcache_arr_s  [SIdxDRAM];
  assign memory_s_axi_req_o.aw.prot   = s_axi_awprot_arr_s   [SIdxDRAM];
  assign memory_s_axi_req_o.aw.qos    = s_axi_awqos_arr_s    [SIdxDRAM];
  assign memory_s_axi_req_o.aw.region = s_axi_awregion_arr_s [SIdxDRAM];
  assign memory_s_axi_req_o.aw.atop   = s_axi_awatop_arr_s   [SIdxDRAM];
  assign memory_s_axi_req_o.aw.user   = s_axi_awuser_arr_s   [SIdxDRAM];
  assign memory_s_axi_req_o.aw_valid  = s_axi_awvalid_arr_s  [SIdxDRAM];
  assign memory_s_axi_req_o.w.data    = s_axi_wdata_arr_s    [SIdxDRAM];
  assign memory_s_axi_req_o.w.strb    = s_axi_wstrb_arr_s    [SIdxDRAM];
  assign memory_s_axi_req_o.w.last    = s_axi_wlast_arr_s    [SIdxDRAM];
  assign memory_s_axi_req_o.w.user    = s_axi_wuser_arr_s    [SIdxDRAM];
  assign memory_s_axi_req_o.w_valid   = s_axi_wvalid_arr_s   [SIdxDRAM];
  assign memory_s_axi_req_o.b_ready   = s_axi_bready_arr_s   [SIdxDRAM];
  assign memory_s_axi_req_o.ar.id     = s_axi_arid_arr_s     [SIdxDRAM];
  assign memory_s_axi_req_o.ar.addr   = s_axi_araddr_arr_s   [SIdxDRAM];
  assign memory_s_axi_req_o.ar.len    = s_axi_arlen_arr_s    [SIdxDRAM];
  assign memory_s_axi_req_o.ar.size   = s_axi_arsize_arr_s   [SIdxDRAM];
  assign memory_s_axi_req_o.ar.burst  = s_axi_arburst_arr_s  [SIdxDRAM];
  assign memory_s_axi_req_o.ar.lock   = s_axi_arlock_arr_s   [SIdxDRAM];
  assign memory_s_axi_req_o.ar.cache  = s_axi_arcache_arr_s  [SIdxDRAM];
  assign memory_s_axi_req_o.ar.prot   = s_axi_arprot_arr_s   [SIdxDRAM];
  assign memory_s_axi_req_o.ar.qos    = s_axi_arqos_arr_s    [SIdxDRAM];
  assign memory_s_axi_req_o.ar.region = s_axi_arregion_arr_s [SIdxDRAM];
  assign memory_s_axi_req_o.ar.user   = s_axi_aruser_arr_s   [SIdxDRAM];
  assign memory_s_axi_req_o.ar_valid  = s_axi_arvalid_arr_s  [SIdxDRAM];
  assign memory_s_axi_req_o.r_ready   = s_axi_rready_arr_s   [SIdxDRAM];

  // cast one dimensional values into slices
  // AXI-M ->  Xbar AXI-S
  assign s_axi_awid_s     = m_axi_awid_arr_s;
  assign s_axi_awaddr_s   = m_axi_awaddr_arr_s;
  assign s_axi_awlen_s    = m_axi_awlen_arr_s;
  assign s_axi_awsize_s   = m_axi_awsize_arr_s;
  assign s_axi_awburst_s  = m_axi_awburst_arr_s;
  assign s_axi_awlock_s   = m_axi_awlock_arr_s;
  assign s_axi_awcache_s  = m_axi_awcache_arr_s;
  assign s_axi_awprot_s   = m_axi_awprot_arr_s;
  assign s_axi_awqos_s    = m_axi_awqos_arr_s;
  assign s_axi_awuser_s   = m_axi_awuser_arr_s;
  assign s_axi_awvalid_s  = m_axi_awvalid_arr_s;
  assign s_axi_wdata_s    = m_axi_wdata_arr_s;
  assign s_axi_wstrb_s    = m_axi_wstrb_arr_s;
  assign s_axi_wlast_s    = m_axi_wlast_arr_s;
  assign s_axi_wuser_s    = m_axi_wuser_arr_s;
  assign s_axi_wvalid_s   = m_axi_wvalid_arr_s;
  assign s_axi_bready_s   = m_axi_bready_arr_s;
  assign s_axi_arid_s     = m_axi_arid_arr_s;
  assign s_axi_araddr_s   = m_axi_araddr_arr_s;
  assign s_axi_arlen_s    = m_axi_arlen_arr_s;
  assign s_axi_arsize_s   = m_axi_arsize_arr_s;
  assign s_axi_arburst_s  = m_axi_arburst_arr_s;
  assign s_axi_arlock_s   = m_axi_arlock_arr_s;
  assign s_axi_arcache_s  = m_axi_arcache_arr_s;
  assign s_axi_arprot_s   = m_axi_arprot_arr_s;
  assign s_axi_arqos_s    = m_axi_arqos_arr_s;
  assign s_axi_aruser_s   = m_axi_aruser_arr_s;
  assign s_axi_arvalid_s  = m_axi_arvalid_arr_s;
  assign s_axi_rready_s   = m_axi_rready_arr_s;

  assign m_axi_awready_arr_s = s_axi_awready_s;
  assign m_axi_arready_arr_s = s_axi_arready_s;
  assign m_axi_wready_arr_s  = s_axi_wready_s;
  assign m_axi_bvalid_arr_s  = s_axi_bvalid_s;
  assign m_axi_bid_arr_s     = s_axi_bid_s;
  assign m_axi_bresp_arr_s   = s_axi_bresp_s;
  assign m_axi_buser_arr_s   = s_axi_buser_s;
  assign m_axi_rvalid_arr_s  = s_axi_rvalid_s;
  assign m_axi_rid_arr_s     = s_axi_rid_s;
  assign m_axi_rdata_arr_s   = s_axi_rdata_s;
  assign m_axi_rresp_arr_s   = s_axi_rresp_s;
  assign m_axi_rlast_arr_s   = s_axi_rlast_s;
  assign m_axi_ruser_arr_s   = s_axi_ruser_s;

  // AXI-M ->  Xbar AXI-S
  assign s_axi_awid_arr_s     = m_axi_awid_s;
  assign s_axi_awaddr_arr_s   = m_axi_awaddr_s;
  assign s_axi_awlen_arr_s    = m_axi_awlen_s;
  assign s_axi_awsize_arr_s   = m_axi_awsize_s;
  assign s_axi_awburst_arr_s  = m_axi_awburst_s;
  assign s_axi_awlock_arr_s   = m_axi_awlock_s;
  assign s_axi_awcache_arr_s  = m_axi_awcache_s;
  assign s_axi_awprot_arr_s   = m_axi_awprot_s;
  assign s_axi_awqos_arr_s    = m_axi_awqos_s;
  assign s_axi_awregion_arr_s = m_axi_awregion_s;
  assign s_axi_awatop_arr_s   = '0; // not connected used to xbar
  assign s_axi_awuser_arr_s   = m_axi_awuser_s;
  assign s_axi_awvalid_arr_s  = m_axi_awvalid_s;
  assign s_axi_wdata_arr_s    = m_axi_wdata_s;
  assign s_axi_wstrb_arr_s    = m_axi_wstrb_s;
  assign s_axi_wlast_arr_s    = m_axi_wlast_s;
  assign s_axi_wuser_arr_s    = m_axi_wuser_s;
  assign s_axi_wvalid_arr_s   = m_axi_wvalid_s;
  assign s_axi_bready_arr_s   = m_axi_bready_s;
  assign s_axi_arid_arr_s     = m_axi_arid_s;
  assign s_axi_araddr_arr_s   = m_axi_araddr_s;
  assign s_axi_arlen_arr_s    = m_axi_arlen_s;
  assign s_axi_arsize_arr_s   = m_axi_arsize_s;
  assign s_axi_arburst_arr_s  = m_axi_arburst_s;
  assign s_axi_arlock_arr_s   = m_axi_arlock_s;
  assign s_axi_arcache_arr_s  = m_axi_arcache_s;
  assign s_axi_arprot_arr_s   = m_axi_arprot_s;
  assign s_axi_arqos_arr_s    = m_axi_arqos_s;
  assign s_axi_arregion_arr_s = m_axi_arregion_s;
  assign s_axi_aruser_arr_s   = m_axi_aruser_s;
  assign s_axi_arvalid_arr_s  = m_axi_arvalid_s;
  assign s_axi_rready_arr_s   = m_axi_rready_s;

  assign m_axi_awready_s = s_axi_awready_arr_s;
  assign m_axi_arready_s = s_axi_arready_arr_s;
  assign m_axi_wready_s  = s_axi_wready_arr_s;
  assign m_axi_bvalid_s  = s_axi_bvalid_arr_s;
  assign m_axi_bid_s     = s_axi_bid_arr_s;
  assign m_axi_bresp_s   = s_axi_bresp_arr_s;
  assign m_axi_buser_s   = s_axi_buser_arr_s;
  assign m_axi_rvalid_s  = s_axi_rvalid_arr_s;
  assign m_axi_rid_s     = s_axi_rid_arr_s;
  assign m_axi_rdata_s   = s_axi_rdata_arr_s;
  assign m_axi_rresp_s   = s_axi_rresp_arr_s;
  assign m_axi_rlast_s   = s_axi_rlast_arr_s;
  assign m_axi_ruser_s   = s_axi_ruser_arr_s;

  // AXI 128b xbar
  axi_xbar_128 i_axi_xbar (
    .aclk           ( clk_i            ),
    .aresetn        ( rstn_i           ),
    .s_axi_awid     ( s_axi_awid_s     ),
    .s_axi_awaddr   ( s_axi_awaddr_s   ),
    .s_axi_awlen    ( s_axi_awlen_s    ),
    .s_axi_awsize   ( s_axi_awsize_s   ),
    .s_axi_awburst  ( s_axi_awburst_s  ),
    .s_axi_awlock   ( s_axi_awlock_s   ),
    .s_axi_awcache  ( s_axi_awcache_s  ),
    .s_axi_awprot   ( s_axi_awprot_s   ),
    .s_axi_awqos    ( s_axi_awqos_s    ),
    .s_axi_awuser   ( s_axi_awuser_s   ),
    .s_axi_awvalid  ( s_axi_awvalid_s  ),
    .s_axi_awready  ( s_axi_awready_s  ),
    .s_axi_wdata    ( s_axi_wdata_s    ),
    .s_axi_wstrb    ( s_axi_wstrb_s    ),
    .s_axi_wlast    ( s_axi_wlast_s    ),
    .s_axi_wuser    ( s_axi_wuser_s    ),
    .s_axi_wvalid   ( s_axi_wvalid_s   ),
    .s_axi_wready   ( s_axi_wready_s   ),
    .s_axi_bid      ( s_axi_bid_s      ),
    .s_axi_bresp    ( s_axi_bresp_s    ),
    .s_axi_buser    ( s_axi_buser_s    ),
    .s_axi_bvalid   ( s_axi_bvalid_s   ),
    .s_axi_bready   ( s_axi_bready_s   ),
    .s_axi_arid     ( s_axi_arid_s     ),
    .s_axi_araddr   ( s_axi_araddr_s   ),
    .s_axi_arlen    ( s_axi_arlen_s    ),
    .s_axi_arsize   ( s_axi_arsize_s   ),
    .s_axi_arburst  ( s_axi_arburst_s  ),
    .s_axi_arlock   ( s_axi_arlock_s   ),
    .s_axi_arcache  ( s_axi_arcache_s  ),
    .s_axi_arprot   ( s_axi_arprot_s   ),
    .s_axi_arqos    ( s_axi_arqos_s    ),
    .s_axi_aruser   ( s_axi_aruser_s   ),
    .s_axi_arvalid  ( s_axi_arvalid_s  ),
    .s_axi_arready  ( s_axi_arready_s  ),
    .s_axi_rid      ( s_axi_rid_s      ),
    .s_axi_rdata    ( s_axi_rdata_s    ),
    .s_axi_rresp    ( s_axi_rresp_s    ),
    .s_axi_rlast    ( s_axi_rlast_s    ),
    .s_axi_ruser    ( s_axi_ruser_s    ),
    .s_axi_rvalid   ( s_axi_rvalid_s   ),
    .s_axi_rready   ( s_axi_rready_s   ),
    .m_axi_awid     ( m_axi_awid_s     ),
    .m_axi_awaddr   ( m_axi_awaddr_s   ),
    .m_axi_awlen    ( m_axi_awlen_s    ),
    .m_axi_awsize   ( m_axi_awsize_s   ),
    .m_axi_awburst  ( m_axi_awburst_s  ),
    .m_axi_awlock   ( m_axi_awlock_s   ),
    .m_axi_awcache  ( m_axi_awcache_s  ),
    .m_axi_awprot   ( m_axi_awprot_s   ),
    .m_axi_awregion ( m_axi_awregion_s ),
    .m_axi_awqos    ( m_axi_awqos_s    ),
    .m_axi_awuser   ( m_axi_awuser_s   ),
    .m_axi_awvalid  ( m_axi_awvalid_s  ),
    .m_axi_awready  ( m_axi_awready_s  ),
    .m_axi_wdata    ( m_axi_wdata_s    ),
    .m_axi_wstrb    ( m_axi_wstrb_s    ),
    .m_axi_wlast    ( m_axi_wlast_s    ),
    .m_axi_wuser    ( m_axi_wuser_s    ),
    .m_axi_wvalid   ( m_axi_wvalid_s   ),
    .m_axi_wready   ( m_axi_wready_s   ),
    .m_axi_bid      ( m_axi_bid_s      ),
    .m_axi_bresp    ( m_axi_bresp_s    ),
    .m_axi_buser    ( m_axi_buser_s    ),
    .m_axi_bvalid   ( m_axi_bvalid_s   ),
    .m_axi_bready   ( m_axi_bready_s   ),
    .m_axi_arid     ( m_axi_arid_s     ),
    .m_axi_araddr   ( m_axi_araddr_s   ),
    .m_axi_arlen    ( m_axi_arlen_s    ),
    .m_axi_arsize   ( m_axi_arsize_s   ),
    .m_axi_arburst  ( m_axi_arburst_s  ),
    .m_axi_arlock   ( m_axi_arlock_s   ),
    .m_axi_arcache  ( m_axi_arcache_s  ),
    .m_axi_arprot   ( m_axi_arprot_s   ),
    .m_axi_arregion ( m_axi_arregion_s ),
    .m_axi_arqos    ( m_axi_arqos_s    ),
    .m_axi_aruser   ( m_axi_aruser_s   ),
    .m_axi_arvalid  ( m_axi_arvalid_s  ),
    .m_axi_arready  ( m_axi_arready_s  ),
    .m_axi_rid      ( m_axi_rid_s      ),
    .m_axi_rdata    ( m_axi_rdata_s    ),
    .m_axi_rresp    ( m_axi_rresp_s    ),
    .m_axi_rlast    ( m_axi_rlast_s    ),
    .m_axi_ruser    ( m_axi_ruser_s    ),
    .m_axi_rvalid   ( m_axi_rvalid_s   ),
    .m_axi_rready   ( m_axi_rready_s   )
  );

endmodule
