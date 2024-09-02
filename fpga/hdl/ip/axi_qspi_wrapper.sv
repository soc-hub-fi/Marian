//------------------------------------------------------------------------------
// Module   : axi_qspi_wrapper
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 12-jan-2024
//
// Description: SV wrapper for the Xilinx AXI Quad SPI IP.
//              Accessed via 32b full AXI interface.
//
// Parameters:
//  - None
//
// Inputs:
//  - clk_i: Clock in
//  - rstn_i: Active-low asynchronous reset
//  - periph_req_i: AXI request signals coming in from system xbar (32b)
//  - qspi_ext_clk_i: SPI logic clock. Must be 2x frequency of max SPI frequency
//
// Outputs:
//  - periph_resp_o: AXI response signals going out to system xbar (32b)
//
// InOuts:
//  - qspi_ss_io: QSPI slave select
//  - qspi_sck_io: QSPI clock
//  - qspi_data_io: QSPI data lines [3:0]
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

import marian_fpga_pkg::*;

module axi_qspi_wrapper(
  input  logic         clk_i,
  input  logic         rstn_i,
  // axi-lite signals
  input  periph_req_t  periph_req_i,
  output periph_resp_t periph_resp_o,
  // qspi signals
  input  logic         qspi_ext_clk_i,
  inout  logic         qspi_ss_io,
  inout  logic         qspi_sck_io,
  inout  logic [3:0]   qspi_data_io
);

  wire [ 3:0] s_axi4_awid_s;
  wire [23:0] s_axi4_awaddr_s;
  wire [ 7:0] s_axi4_awlen_s;
  wire [ 2:0] s_axi4_awsize_s;
  wire [ 1:0] s_axi4_awburst_s;
  wire        s_axi4_awlock_s;
  wire [ 3:0] s_axi4_awcache_s;
  wire [ 2:0] s_axi4_awprot_s;
  wire        s_axi4_awvalid_s;
  wire        s_axi4_awready_s;
  wire [31:0] s_axi4_wdata_s;
  wire [ 3:0] s_axi4_wstrb_s;
  wire        s_axi4_wlast_s;
  wire        s_axi4_wvalid_s;
  wire        s_axi4_wready_s;
  wire [ 3:0] s_axi4_bid_s;
  wire [ 1:0] s_axi4_bresp_s;
  wire        s_axi4_bvalid_s;
  wire        s_axi4_bready_s;
  wire [ 3:0] s_axi4_arid_s;
  wire [23:0] s_axi4_araddr_s;
  wire [ 7:0] s_axi4_arlen_s;
  wire [ 2:0] s_axi4_arsize_s;
  wire [ 1:0] s_axi4_arburst_s;
  wire        s_axi4_arlock_s;
  wire [ 3:0] s_axi4_arcache_s;
  wire [ 2:0] s_axi4_arprot_s;
  wire        s_axi4_arvalid_s;
  wire        s_axi4_arready_s;
  wire [ 3:0] s_axi4_rid_s;
  wire [31:0] s_axi4_rdata_s;
  wire [ 1:0] s_axi4_rresp_s;
  wire        s_axi4_rlast_s;
  wire        s_axi4_rvalid_s;
  wire        s_axi4_rready_s;

  wire        ext_spi_clk_s;
  wire [ 3:0] qspi_data_i_s;
  wire [ 3:0] qspi_data_o_s;
  wire [ 3:0] qspi_data_t_s;
  wire        qspi_sck_i_s;
  wire        qspi_sck_o_s;
  wire        qspi_sck_t_s;
  wire  [0:0] qspi_ss_i_s;
  wire  [0:0] qspi_ss_o_s;
  wire        qspi_ss_t_s;

  // axi assignments
  assign s_axi4_awid_s    = periph_req_i.aw.id;
  assign s_axi4_awaddr_s  = periph_req_i.aw.addr[23:0];
  assign s_axi4_awlen_s   = periph_req_i.aw.len;
  assign s_axi4_awsize_s  = periph_req_i.aw.size;
  assign s_axi4_awburst_s = periph_req_i.aw.burst;
  assign s_axi4_awlock_s  = periph_req_i.aw.lock;
  assign s_axi4_awcache_s = periph_req_i.aw.cache;
  assign s_axi4_awprot_s  = periph_req_i.aw.prot;
  assign s_axi4_awvalid_s = periph_req_i.aw_valid;
  assign s_axi4_wdata_s   = periph_req_i.w.data;
  assign s_axi4_wstrb_s   = periph_req_i.w.strb;
  assign s_axi4_wlast_s   = periph_req_i.w.last;
  assign s_axi4_wvalid_s  = periph_req_i.w_valid;
  assign s_axi4_bready_s  = periph_req_i.b_ready;
  assign s_axi4_arid_s    = periph_req_i.ar.id;
  assign s_axi4_araddr_s  = periph_req_i.ar.addr[23:0];
  assign s_axi4_arlen_s   = periph_req_i.ar.len;
  assign s_axi4_arsize_s  = periph_req_i.ar.size;
  assign s_axi4_arburst_s = periph_req_i.ar.burst;
  assign s_axi4_arlock_s  = periph_req_i.ar.lock;
  assign s_axi4_arcache_s = periph_req_i.ar.cache;
  assign s_axi4_arprot_s  = periph_req_i.ar.prot;
  assign s_axi4_arvalid_s = periph_req_i.ar_valid;
  assign s_axi4_rready_s  = periph_req_i.r_ready;

  assign periph_resp_o.aw_ready = s_axi4_awready_s;
  assign periph_resp_o.ar_ready = s_axi4_arready_s;
  assign periph_resp_o.w_ready  = s_axi4_wready_s;
  assign periph_req_o.b.id      = s_axi4_bid_s;
  assign periph_resp_o.b_valid  = s_axi4_bvalid_s;
  assign periph_resp_o.b.resp   = s_axi4_bresp_s;
  assign periph_resp_o.r_valid  = s_axi4_rvalid_s;
  assign periph_resp_o.r.data   = s_axi4_rdata_s;
  assign periph_resp_o.r.resp   = s_axi4_rresp_s;
  assign periph_resp_o.r.last   = s_axi4_rlast_s;

  // IO assignments
  genvar pin_idx;
  for (pin_idx = 0; pin_idx < 4; pin_idx++) begin : g_qspi_pin_idx
    assign qspi_data_io[pin_idx] = (qspi_data_t_s[pin_idx]) ? 1'bz : qspi_data_o_s[pin_idx];
    assign qspi_data_i_s[pin_idx] = qspi_data_io[pin_idx];
  end

  assign qspi_sck_io  = (qspi_sck_t_s) ? 1'bz : qspi_sck_o_s;
  assign qspi_sck_i_s = qspi_sck_io;

  assign qspi_ss_io     = (qspi_ss_t_s) ? 1'bz : qspi_ss_o_s[0];
  assign qspi_ss_i_s[0] = qspi_ss_io;

  // SPI logic clock, must be 2x max SPI frequency
  assign ext_spi_clk_s = qspi_ext_clk_i;

  axi_qspi i_axi_qspi (
    .ext_spi_clk    ( ext_spi_clk_s    ),
    .s_axi4_aclk    ( clk_i            ),
    .s_axi4_aresetn ( rstn_i           ),
    .s_axi4_awid    ( s_axi4_awid_s    ),
    .s_axi4_awaddr  ( s_axi4_awaddr_s  ),
    .s_axi4_awlen   ( s_axi4_awlen_s   ),
    .s_axi4_awsize  ( s_axi4_awsize_s  ),
    .s_axi4_awburst ( s_axi4_awburst_s ),
    .s_axi4_awlock  ( s_axi4_awlock_s  ),
    .s_axi4_awcache ( s_axi4_awcache_s ),
    .s_axi4_awprot  ( s_axi4_awprot_s  ),
    .s_axi4_awvalid ( s_axi4_awvalid_s ),
    .s_axi4_awready ( s_axi4_awready_s ),
    .s_axi4_wdata   ( s_axi4_wdata_s   ),
    .s_axi4_wstrb   ( s_axi4_wstrb_s   ),
    .s_axi4_wlast   ( s_axi4_wlast_s   ),
    .s_axi4_wvalid  ( s_axi4_wvalid_s  ),
    .s_axi4_wready  ( s_axi4_wready_s  ),
    .s_axi4_bid     ( s_axi4_bid_s     ),
    .s_axi4_bresp   ( s_axi4_bresp_s   ),
    .s_axi4_bvalid  ( s_axi4_bvalid_s  ),
    .s_axi4_bready  ( s_axi4_bready_s  ),
    .s_axi4_arid    ( s_axi4_arid_s    ),
    .s_axi4_araddr  ( s_axi4_araddr_s  ),
    .s_axi4_arlen   ( s_axi4_arlen_s   ),
    .s_axi4_arsize  ( s_axi4_arsize_s  ),
    .s_axi4_arburst ( s_axi4_arburst_s ),
    .s_axi4_arlock  ( s_axi4_arlock_s  ),
    .s_axi4_arcache ( s_axi4_arcache_s ),
    .s_axi4_arprot  ( s_axi4_arprot_s  ),
    .s_axi4_arvalid ( s_axi4_arvalid_s ),
    .s_axi4_arready ( s_axi4_arready_s ),
    .s_axi4_rid     ( s_axi4_rid_s     ),
    .s_axi4_rdata   ( s_axi4_rdata_s   ),
    .s_axi4_rresp   ( s_axi4_rresp_s   ),
    .s_axi4_rlast   ( s_axi4_rlast_s   ),
    .s_axi4_rvalid  ( s_axi4_rvalid_s  ),
    .s_axi4_rready  ( s_axi4_rready_s  ),
    .io0_i          ( qspi_data_i_s[0] ),
    .io0_o          ( qspi_data_o_s[0] ),
    .io0_t          ( qspi_data_t_s[0] ),
    .io1_i          ( qspi_data_i_s[1] ),
    .io1_o          ( qspi_data_o_s[1] ),
    .io1_t          ( qspi_data_t_s[1] ),
    .io2_i          ( qspi_data_i_s[2] ),
    .io2_o          ( qspi_data_o_s[2] ),
    .io2_t          ( qspi_data_t_s[2] ),
    .io3_i          ( qspi_data_i_s[3] ),
    .io3_o          ( qspi_data_o_s[3] ),
    .io3_t          ( qspi_data_t_s[3] ),
    .sck_i          ( qspi_sck_i_s     ),
    .sck_o          ( qspi_sck_o_s     ),
    .sck_t          ( qspi_sck_t_s     ),
    .ss_i           ( qspi_ss_i_s      ),
    .ss_o           ( qspi_ss_o_s      ),
    .ss_t           ( qspi_ss_t_s      ),
    .ip2intc_irpt   ( /* unused */     )
  );

endmodule
