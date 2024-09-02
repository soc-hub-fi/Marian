//------------------------------------------------------------------------------
// Module   : axi_to_axi_lite_periph_wrapper
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 12-jan-2024
//
// Description: SV wrapper for the Xilinx AXI protocol converter IP used in
// the marian_fpga_system. Converts full AXI to AXI-Lite with a 32b data width.
//
// Parameters:
//  - None
//
// Inputs:
//  - clk_i: Clock in
//  - rstn_i: Active-low asynchronous reset
//  - ariane_axi_resp_i: AXI response signals coming in from top (128b)
//  - ariane_narrow_axi_req_i: AXI request signals coming in from ariane (64b)
//
// Outputs:
//  - ariane_axi_req_o: AXI request signals going out to top (128b)
//  - ariane_narrow_axi_resp_o: AXI response signals going back to Ariane (64b)
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

import marian_fpga_pkg::*;

module axi_to_axi_lite_periph_wrapper (
  input  logic              clk_i,
  input  logic              rstn_i,
  // peripheral full
  input  periph_req_t       periph_req_i,
  output periph_resp_t      periph_resp_o,
  // peripheral lite
  input  periph_lite_resp_t periph_lite_resp_i,
  output periph_lite_req_t  periph_lite_req_o
);

  // connecting signals
  logic [  4:0] s_axi_awid_s;
  logic [ 63:0] s_axi_awaddr_s;
  logic [  7:0] s_axi_awlen_s;
  logic [  2:0] s_axi_awsize_s;
  logic [  1:0] s_axi_awburst_s;
  logic [  0:0] s_axi_awlock_s;
  logic [  3:0] s_axi_awcache_s;
  logic [  2:0] s_axi_awprot_s;
  logic [  3:0] s_axi_awregion_s;
  logic [  3:0] s_axi_awqos_s;
  logic         s_axi_awvalid_s;
  logic         s_axi_awready_s;
  logic [ 31:0] s_axi_wdata_s;
  logic [  3:0] s_axi_wstrb_s;
  logic         s_axi_wlast_s;
  logic         s_axi_wvalid_s;
  logic         s_axi_wready_s;
  logic [  4:0] s_axi_bid_s;
  logic [  1:0] s_axi_bresp_s;
  logic         s_axi_bvalid_s;
  logic         s_axi_bready_s;
  logic [  4:0] s_axi_arid_s;
  logic [ 63:0] s_axi_araddr_s;
  logic [  7:0] s_axi_arlen_s;
  logic [  2:0] s_axi_arsize_s;
  logic [  1:0] s_axi_arburst_s;
  logic [  0:0] s_axi_arlock_s;
  logic [  3:0] s_axi_arcache_s;
  logic [  2:0] s_axi_arprot_s;
  logic [  3:0] s_axi_arregion_s;
  logic [  3:0] s_axi_arqos_s;
  logic         s_axi_arvalid_s;
  logic         s_axi_arready_s;
  logic [  4:0] s_axi_rid_s;
  logic [ 31:0] s_axi_rdata_s;
  logic [  1:0] s_axi_rresp_s;
  logic         s_axi_rlast_s;
  logic         s_axi_rvalid_s;
  logic         s_axi_rready_s;
  logic [ 63:0] m_axi_awaddr_s;
  logic [  2:0] m_axi_awprot_s;
  logic         m_axi_awvalid_s;
  logic         m_axi_awready_s;
  logic [ 31:0] m_axi_wdata_s;
  logic [  3:0] m_axi_wstrb_s;
  logic         m_axi_wvalid_s;
  logic         m_axi_wready_s;
  logic [  1:0] m_axi_bresp_s;
  logic         m_axi_bvalid_s;
  logic         m_axi_bready_s;
  logic [ 63:0] m_axi_araddr_s;
  logic [  2:0] m_axi_arprot_s;
  logic         m_axi_arvalid_s;
  logic         m_axi_arready_s;
  logic [ 31:0] m_axi_rdata_s;
  logic [  1:0] m_axi_rresp_s;
  logic         m_axi_rvalid_s;
  logic         m_axi_rready_s;

  // mst_resp_i
  assign m_axi_awready_s = periph_lite_resp_i.aw_ready;
  assign m_axi_arready_s = periph_lite_resp_i.ar_ready;
  assign m_axi_wready_s  = periph_lite_resp_i.w_ready;
  assign m_axi_bvalid_s  = periph_lite_resp_i.b_valid;
  assign m_axi_bresp_s   = periph_lite_resp_i.b.resp;
  assign m_axi_rvalid_s  = periph_lite_resp_i.r_valid;
  assign m_axi_rdata_s   = periph_lite_resp_i.r.data;
  assign m_axi_rresp_s   = periph_lite_resp_i.r.resp;

  // slv_req_i
  assign s_axi_awid_s     = periph_req_i.aw.id;
  assign s_axi_awaddr_s   = periph_req_i.aw.addr;
  assign s_axi_awlen_s    = periph_req_i.aw.len;
  assign s_axi_awsize_s   = periph_req_i.aw.size;
  assign s_axi_awburst_s  = periph_req_i.aw.burst;
  assign s_axi_awlock_s   = periph_req_i.aw.lock;
  assign s_axi_awcache_s  = periph_req_i.aw.cache;
  assign s_axi_awprot_s   = periph_req_i.aw.prot;
  assign s_axi_awqos_s    = periph_req_i.aw.qos;
  assign s_axi_awregion_s = periph_req_i.aw.region;
  assign s_axi_awvalid_s  = periph_req_i.aw_valid;
  assign s_axi_wdata_s    = periph_req_i.w.data;
  assign s_axi_wstrb_s    = periph_req_i.w.strb;
  assign s_axi_wlast_s    = periph_req_i.w.last;
  assign s_axi_wvalid_s   = periph_req_i.w_valid;
  assign s_axi_bready_s   = periph_req_i.b_ready;
  assign s_axi_arid_s     = periph_req_i.ar.id;
  assign s_axi_araddr_s   = periph_req_i.ar.addr;
  assign s_axi_arlen_s    = periph_req_i.ar.len;
  assign s_axi_arsize_s   = periph_req_i.ar.size;
  assign s_axi_arburst_s  = periph_req_i.ar.burst;
  assign s_axi_arlock_s   = periph_req_i.ar.lock;
  assign s_axi_arcache_s  = periph_req_i.ar.cache;
  assign s_axi_arprot_s   = periph_req_i.ar.prot;
  assign s_axi_arqos_s    = periph_req_i.ar.qos;
  assign s_axi_arregion_s = periph_req_i.ar.region;
  assign s_axi_arvalid_s  = periph_req_i.ar_valid;
  assign s_axi_rready_s   = periph_req_i.r_ready;

  // mst_req_o
  assign periph_lite_req_o.aw.addr   = m_axi_awaddr_s;
  assign periph_lite_req_o.aw.prot   = m_axi_awprot_s;
  assign periph_lite_req_o.aw_valid  = m_axi_awvalid_s;
  assign periph_lite_req_o.w.data    = m_axi_wdata_s;
  assign periph_lite_req_o.w.strb    = m_axi_wstrb_s;
  assign periph_lite_req_o.w_valid   = m_axi_wvalid_s;
  assign periph_lite_req_o.b_ready   = m_axi_bready_s;
  assign periph_lite_req_o.ar.addr   = m_axi_araddr_s;
  assign periph_lite_req_o.ar.prot   = m_axi_arprot_s;
  assign periph_lite_req_o.ar_valid  = m_axi_arvalid_s;
  assign periph_lite_req_o.r_ready   = m_axi_rready_s;

  // slv_resp_o
  assign periph_resp_o.aw_ready = s_axi_awready_s;
  assign periph_resp_o.ar_ready = s_axi_arready_s;
  assign periph_resp_o.w_ready  = s_axi_wready_s;
  assign periph_resp_o.b_valid  = s_axi_bvalid_s;
  assign periph_resp_o.b.id     = s_axi_bid_s;
  assign periph_resp_o.b.resp   = s_axi_bresp_s;
  assign periph_resp_o.b.user   = '0;
  assign periph_resp_o.r_valid  = s_axi_rvalid_s;
  assign periph_resp_o.r.id     = s_axi_rid_s;
  assign periph_resp_o.r.data   = s_axi_rdata_s;
  assign periph_resp_o.r.resp   = s_axi_rresp_s;
  assign periph_resp_o.r.last   = s_axi_rlast_s;
  assign periph_resp_o.r.user   = '0;


  axi_to_axi_lite_periph i_axi_to_axi_lite_periph (
    // subordinate
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
    .s_axi_awregion ( s_axi_awregion_s ),
    .s_axi_awqos    ( s_axi_awqos_s    ),
    .s_axi_awvalid  ( s_axi_awvalid_s  ),
    .s_axi_awready  ( s_axi_awready_s  ),
    .s_axi_wdata    ( s_axi_wdata_s    ),
    .s_axi_wstrb    ( s_axi_wstrb_s    ),
    .s_axi_wlast    ( s_axi_wlast_s    ),
    .s_axi_wvalid   ( s_axi_wvalid_s   ),
    .s_axi_wready   ( s_axi_wready_s   ),
    .s_axi_bid      ( s_axi_bid_s      ),
    .s_axi_bresp    ( s_axi_bresp_s    ),
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
    .s_axi_arregion ( s_axi_arregion_s ),
    .s_axi_arqos    ( s_axi_arqos_s    ),
    .s_axi_arvalid  ( s_axi_arvalid_s  ),
    .s_axi_arready  ( s_axi_arready_s  ),
    .s_axi_rid      ( s_axi_rid_s      ),
    .s_axi_rdata    ( s_axi_rdata_s    ),
    .s_axi_rresp    ( s_axi_rresp_s    ),
    .s_axi_rlast    ( s_axi_rlast_s    ),
    .s_axi_rvalid   ( s_axi_rvalid_s   ),
    .s_axi_rready   ( s_axi_rready_s   ),
    .m_axi_awaddr   ( m_axi_awaddr_s   ),
    .m_axi_awprot   ( m_axi_awprot_s   ),
    .m_axi_awvalid  ( m_axi_awvalid_s  ),
    .m_axi_awready  ( m_axi_awready_s  ),
    .m_axi_wdata    ( m_axi_wdata_s    ),
    .m_axi_wstrb    ( m_axi_wstrb_s    ),
    .m_axi_wvalid   ( m_axi_wvalid_s   ),
    .m_axi_wready   ( m_axi_wready_s   ),
    .m_axi_bresp    ( m_axi_bresp_s    ),
    .m_axi_bvalid   ( m_axi_bvalid_s   ),
    .m_axi_bready   ( m_axi_bready_s   ),
    .m_axi_araddr   ( m_axi_araddr_s   ),
    .m_axi_arprot   ( m_axi_arprot_s   ),
    .m_axi_arvalid  ( m_axi_arvalid_s  ),
    .m_axi_arready  ( m_axi_arready_s  ),
    .m_axi_rdata    ( m_axi_rdata_s    ),
    .m_axi_rresp    ( m_axi_rresp_s    ),
    .m_axi_rvalid   ( m_axi_rvalid_s   ),
    .m_axi_rready   ( m_axi_rready_s   )
  );

endmodule
