//------------------------------------------------------------------------------
// Module   : axi_bram_2MiB_wrapper
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 26-feb-2024
//
// Description: SV wrapper for the Xilinx AXI BRAM IP Controller and BRAM.
//
// Parameters:
//  - None
//
// Inputs:
//  - clk_i: Clock
//  - rst_ni Asynchronous active-low reset
//  - memory_axi_req_i: 128b AXI request lines from xbar (M) to Memory (S)
//
// Outputs:
//  - memory_axi_resp_o: 128b AXI response lines from Memory (S) to xbar (M)
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

`define STRINGIFY(x) `"x`"

module axi_bram_2MiB_wrapper
import marian_fpga_pkg::*;
(
  input  logic         clk_i,
  input  logic         rst_ni,
  input  system_req_t  memory_axi_req_i,

  output system_resp_t memory_axi_resp_o
);

/*************
 * CONSTANTS *
 *************/

  localparam int unsigned AxiDataWidthBytes = AxiDataWidth / 8;
  // NOTE THIS MUST MATCH BRAM_DEPTH within the axi_bram_2MiB_ip_run.tcl script
  localparam int unsigned BRAMWidth          =    128;
  localparam int unsigned BRAMWidthBytes     = BRAMWidth / 8;
  localparam int unsigned BRAMDepth          = `L2_NUM_ROWS;
  localparam int unsigned BRAMAddrWidth      = $clog2(BRAMDepth-1);


`ifndef XSIM
  // always load init file in synthesis
  localparam string L2MemInitFile = `STRINGIFY(`L2_MEM_INIT_FILE);

`else
  // In behavioural simulation, select init from test file or init file
  // depending on whether JTAG is selected or not
  localparam string L2InitMethod = `STRINGIFY(`L2_INIT_METHOD);

  // set L2_INIT_METHOD to loop.mem unless memory is to be initialised
  // using a specific test file
  localparam string L2MemInitFile = (L2InitMethod == "FILE") ?
    `STRINGIFY(`L2_MEM_TEST_FILE) : `STRINGIFY(`L2_MEM_INIT_FILE);

`endif

/***********
 * SIGNALS *
 ***********/

  // translated AXI address signals
  axi_addr_t axi_aw_addr_trans_s;
  axi_addr_t axi_ar_addr_trans_s;

  // translated BRAM address signals
  logic [BRAMAddrWidth-1:0] bram_addr_translated_s;

  // axi signals to BRAM
  wire [    4:0] s_axi_awid_s;
  wire [   17:0] s_axi_awaddr_s;
  wire [    7:0] s_axi_awlen_s;
  wire [    2:0] s_axi_awsize_s;
  wire [    1:0] s_axi_awburst_s;
  wire           s_axi_awlock_s;
  wire [    3:0] s_axi_awcache_s;
  wire [    2:0] s_axi_awprot_s;
  wire           s_axi_awvalid_s;
  wire           s_axi_awready_s;
  wire [  127:0] s_axi_wdata_s;
  wire [   15:0] s_axi_wstrb_s;
  wire           s_axi_wlast_s;
  wire           s_axi_wvalid_s;
  wire           s_axi_wready_s;
  wire [    4:0] s_axi_bid_s;
  wire [    1:0] s_axi_bresp_s;
  wire           s_axi_bvalid_s;
  wire           s_axi_bready_s;
  wire [    4:0] s_axi_arid_s;
  wire [   17:0] s_axi_araddr_s;
  wire [    7:0] s_axi_arlen_s;
  wire [    2:0] s_axi_arsize_s;
  wire [    1:0] s_axi_arburst_s;
  wire           s_axi_arlock_s;
  wire [    3:0] s_axi_arcache_s;
  wire [    2:0] s_axi_arprot_s;
  wire           s_axi_arvalid_s;
  wire           s_axi_arready_s;
  wire [    4:0] s_axi_rid_s;
  wire [  127:0] s_axi_rdata_s;
  wire [    1:0] s_axi_rresp_s;
  wire           s_axi_rlast_s;
  wire           s_axi_rvalid_s;
  wire           s_axi_rready_s;

  // memory signals
  wire           bram_rst_a_s;
  wire           bram_clk_a_s;
  wire           bram_en_a_s;
  wire           bram_regcea_s;
  wire [   15:0] bram_be_a_s;
  wire [   17:0] bram_addr_s;
  wire [  127:0] bram_wrdata_s;
  wire [  127:0] bram_rdata_s;

/***************
 * Assignments *
 ***************/

  // subtract DRAM base address if valid request is present as base address of
  // memory is 0
  assign axi_aw_addr_trans_s = (memory_axi_req_i.aw_valid == 1'b1) ?
    memory_axi_req_i.aw.addr - DRAMBase : '0;
  assign axi_ar_addr_trans_s = (memory_axi_req_i.ar_valid == 1'b1) ?
    memory_axi_req_i.ar.addr - DRAMBase : '0;

  // axi assignments
  assign s_axi_awid_s    = memory_axi_req_i.aw.id;
  assign s_axi_awaddr_s  = axi_aw_addr_trans_s[20:0];
  assign s_axi_awlen_s   = memory_axi_req_i.aw.len;
  assign s_axi_awsize_s  = memory_axi_req_i.aw.size;
  assign s_axi_awburst_s = memory_axi_req_i.aw.burst;
  assign s_axi_awlock_s  = memory_axi_req_i.aw.lock;
  assign s_axi_awcache_s = memory_axi_req_i.aw.cache;
  assign s_axi_awprot_s  = memory_axi_req_i.aw.prot;
  assign s_axi_awvalid_s = memory_axi_req_i.aw_valid;
  assign s_axi_wdata_s   = memory_axi_req_i.w.data;
  assign s_axi_wstrb_s   = memory_axi_req_i.w.strb;
  assign s_axi_wlast_s   = memory_axi_req_i.w.last;
  assign s_axi_wvalid_s  = memory_axi_req_i.w_valid;
  assign s_axi_bready_s  = memory_axi_req_i.b_ready;
  assign s_axi_arid_s    = memory_axi_req_i.ar.id;
  assign s_axi_araddr_s  = axi_ar_addr_trans_s[20:0];
  assign s_axi_arlen_s   = memory_axi_req_i.ar.len;
  assign s_axi_arsize_s  = memory_axi_req_i.ar.size;
  assign s_axi_arburst_s = memory_axi_req_i.ar.burst;
  assign s_axi_arlock_s  = memory_axi_req_i.ar.lock;
  assign s_axi_arcache_s = memory_axi_req_i.ar.cache;
  assign s_axi_arprot_s  = memory_axi_req_i.ar.prot;
  assign s_axi_arvalid_s = memory_axi_req_i.ar_valid;
  assign s_axi_rready_s  = memory_axi_req_i.r_ready;

  assign memory_axi_resp_o.aw_ready = s_axi_awready_s;
  assign memory_axi_resp_o.ar_ready = s_axi_arready_s;
  assign memory_axi_resp_o.w_ready  = s_axi_wready_s;
  assign memory_axi_resp_o.b.id     = s_axi_bid_s;
  assign memory_axi_resp_o.b.user   = 1'b0;
  assign memory_axi_resp_o.b_valid  = s_axi_bvalid_s;
  assign memory_axi_resp_o.b.resp   = s_axi_bresp_s;
  assign memory_axi_resp_o.r_valid  = s_axi_rvalid_s;
  assign memory_axi_resp_o.r.id     = s_axi_rid_s;
  assign memory_axi_resp_o.r.user   = 1'b0;
  assign memory_axi_resp_o.r.data   = s_axi_rdata_s;
  assign memory_axi_resp_o.r.resp   = s_axi_rresp_s;
  assign memory_axi_resp_o.r.last   = s_axi_rlast_s;

  // bram assignments
  assign bram_regcea_s = 1'b0;
  assign bram_we_a_s   = |bram_be_a_s;

  // AXI BRAM controller does not translate addresses from Byte -> word.
  // Shift address to correct for this.
  assign bram_addr_translated_s = (bram_addr_s[BRAMAddrWidth-1:0] >> $clog2(BRAMWidthBytes));

/******************************
 * Xilinx AXI BRAM Controller *
 ******************************/

  axi_bram_2MiB i_axi_bram_controller (
    .s_axi_aclk    ( clk_i           ),
    .s_axi_aresetn ( rst_ni          ),
    .s_axi_awid    ( s_axi_awid_s    ),
    .s_axi_awaddr  ( s_axi_awaddr_s  ),
    .s_axi_awlen   ( s_axi_awlen_s   ),
    .s_axi_awsize  ( s_axi_awsize_s  ),
    .s_axi_awburst ( s_axi_awburst_s ),
    .s_axi_awlock  ( s_axi_awlock_s  ),
    .s_axi_awcache ( s_axi_awcache_s ),
    .s_axi_awprot  ( s_axi_awprot_s  ),
    .s_axi_awvalid ( s_axi_awvalid_s ),
    .s_axi_awready ( s_axi_awready_s ),
    .s_axi_wdata   ( s_axi_wdata_s   ),
    .s_axi_wstrb   ( s_axi_wstrb_s   ),
    .s_axi_wlast   ( s_axi_wlast_s   ),
    .s_axi_wvalid  ( s_axi_wvalid_s  ),
    .s_axi_wready  ( s_axi_wready_s  ),
    .s_axi_bid     ( s_axi_bid_s     ),
    .s_axi_bresp   ( s_axi_bresp_s   ),
    .s_axi_bvalid  ( s_axi_bvalid_s  ),
    .s_axi_bready  ( s_axi_bready_s  ),
    .s_axi_arid    ( s_axi_arid_s    ),
    .s_axi_araddr  ( s_axi_araddr_s  ),
    .s_axi_arlen   ( s_axi_arlen_s   ),
    .s_axi_arsize  ( s_axi_arsize_s  ),
    .s_axi_arburst ( s_axi_arburst_s ),
    .s_axi_arlock  ( s_axi_arlock_s  ),
    .s_axi_arcache ( s_axi_arcache_s ),
    .s_axi_arprot  ( s_axi_arprot_s  ),
    .s_axi_arvalid ( s_axi_arvalid_s ),
    .s_axi_arready ( s_axi_arready_s ),
    .s_axi_rid     ( s_axi_rid_s     ),
    .s_axi_rdata   ( s_axi_rdata_s   ),
    .s_axi_rresp   ( s_axi_rresp_s   ),
    .s_axi_rlast   ( s_axi_rlast_s   ),
    .s_axi_rvalid  ( s_axi_rvalid_s  ),
    .s_axi_rready  ( s_axi_rready_s  ),
    .bram_rst_a    ( bram_rst_a_s    ),
    .bram_clk_a    ( bram_clk_a_s    ),
    .bram_en_a     ( bram_en_a_s     ),
    .bram_we_a     ( bram_be_a_s     ),
    .bram_addr_a   ( bram_addr_s     ),
    .bram_wrdata_a ( bram_wrdata_s   ),
    .bram_rddata_a ( bram_rdata_s    )
  );

/***************
 * Xilinx BRAM *
 ***************/

  sram #(
    .INIT_FILE  ( L2MemInitFile ),
    .DATA_WIDTH ( BRAMWidth     ),
    .NUM_WORDS  ( BRAMDepth     )
  ) i_sp_sram (
    .clk_i   ( bram_clk_a_s           ),
    .rst_ni  ( bram_rst_a_s           ),
    .req_i   ( bram_en_a_s            ),
    .we_i    ( bram_we_a_s            ),
    .addr_i  ( bram_addr_translated_s ),
    .wdata_i ( bram_wrdata_s          ),
    .be_i    ( bram_be_a_s            ),
    .rdata_o ( bram_rdata_s           )
  );

endmodule
