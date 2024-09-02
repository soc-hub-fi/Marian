//------------------------------------------------------------------------------
// Module   : axi_hw_timer_wrapper
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 12-jan-2024
//
// Description: SV wrapper for the Xilinx AXI Timer IP.
//              Accessed via 32b AXI-Lite peripheral interface.
//              NOTE THAT ALL SIGNALS ARE CURRENTLY NOT CONNECTED. ONCE THE
//              DESIGN IS MORE MATURE, THESE WILL BE CONNECTED.
//
// Parameters:
//  - None
//
// Inputs:
//  - clk_i: Clock in
//  - rstn_i: Active-low asynchronous reset
//  - periph_lite_req_i: AXI request signals coming in from system xbar (32b)
//
// Outputs:
//  - periph_lite_resp_o: AXI response signals going out to system xbar (32b)
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

import marian_fpga_pkg::*;

module axi_hw_timer_wrapper(
  input  logic                     clk_i,
  input  logic                     rstn_i,
  // axi-lite signals
  input  periph_lite_req_t         periph_lite_req_i,
  output periph_lite_resp_t        periph_lite_resp_o
);

  wire [ 4:0] s_axi_awaddr_s;
  wire        s_axi_awvalid_s;
  wire        s_axi_awready_s;
  wire [31:0] s_axi_wdata_s;
  wire [ 3:0] s_axi_wstrb_s;
  wire        s_axi_wvalid_s;
  wire        s_axi_wready_s;
  wire [ 1:0] s_axi_bresp_s;
  wire        s_axi_bvalid_s;
  wire        s_axi_bready_s;
  wire [ 4:0] s_axi_araddr_s;
  wire        s_axi_arvalid_s;
  wire        s_axi_arready_s;
  wire [31:0] s_axi_rdata_s;
  wire [ 1:0] s_axi_rresp_s;
  wire        s_axi_rvalid_s;
  wire        s_axi_rready_s;

  wire capturetrig0_s;
  wire capturetrig1_s;
  wire generateout0_s;
  wire generateout1_s;
  wire pwm0_s;
  wire interrupt_s;
  wire freeze_s;

  // axi assignments
  assign periph_lite_resp_o.aw_ready = s_axi_awready_s;
  assign periph_lite_resp_o.ar_ready = s_axi_arready_s;
  assign periph_lite_resp_o.w_ready  = s_axi_wready_s;
  assign periph_lite_resp_o.b_valid  = s_axi_bvalid_s;
  assign periph_lite_resp_o.b.resp   = s_axi_bresp_s;
  assign periph_lite_resp_o.r_valid  = s_axi_rvalid_s;
  assign periph_lite_resp_o.r.data   = s_axi_rdata_s;
  assign periph_lite_resp_o.r.resp   = s_axi_rresp_s;

  assign s_axi_awaddr_s  = periph_lite_req_i.aw.addr[4:0];
  assign s_axi_awvalid_s = periph_lite_req_i.aw_valid;
  assign s_axi_wdata_s   = periph_lite_req_i.w.data;
  assign s_axi_wstrb_s   = periph_lite_req_i.w.strb;
  assign s_axi_wvalid_s  = periph_lite_req_i.w_valid;
  assign s_axi_bready_s  = periph_lite_req_i.b_ready;
  assign s_axi_araddr_s  = periph_lite_req_i.ar.addr[4:0];
  assign s_axi_arvalid_s = periph_lite_req_i.ar_valid;
  assign s_axi_rready_s  = periph_lite_req_i.r_ready;

  // functional signal assignments
  assign capturetrig0_s = 1'b0;
  assign capturetrig1_s = 1'b0;
  assign freeze_s       = 1'b0;

  axi_hw_timer your_instance_name (
    .capturetrig0  ( capturetrig0_s  ), // input wire capturetrig0
    .capturetrig1  ( capturetrig1_s  ), // input wire capturetrig1
    .generateout0  ( generateout0_s  ), // output wire generateout0
    .generateout1  ( generateout1_s  ), // output wire generateout1
    .pwm0          ( pwm0_s          ), // output wire pwm0
    .interrupt     ( interrupt_s     ), // output wire interrupt
    .freeze        ( freeze_s        ), // input wire freeze
    .s_axi_aclk    ( s_axi_aclk_s    ), // input wire s_axi_aclk
    .s_axi_aresetn ( s_axi_aresetn_s ), // input wire s_axi_aresetn
    .s_axi_awaddr  ( s_axi_awaddr_s  ), // input wire [4 : 0] s_axi_awaddr
    .s_axi_awvalid ( s_axi_awvalid_s ), // input wire s_axi_awvalid
    .s_axi_awready ( s_axi_awready_s ), // output wire s_axi_awready
    .s_axi_wdata   ( s_axi_wdata_s   ), // input wire [31 : 0] s_axi_wdata
    .s_axi_wstrb   ( s_axi_wstrb_s   ), // input wire [3 : 0] s_axi_wstrb
    .s_axi_wvalid  ( s_axi_wvalid_s  ), // input wire s_axi_wvalid
    .s_axi_wready  ( s_axi_wready_s  ), // output wire s_axi_wready
    .s_axi_bresp   ( s_axi_bresp_s   ), // output wire [1 : 0] s_axi_bresp
    .s_axi_bvalid  ( s_axi_bvalid_s  ), // output wire s_axi_bvalid
    .s_axi_bready  ( s_axi_bready_s  ), // input wire s_axi_bready
    .s_axi_araddr  ( s_axi_araddr_s  ), // input wire [4 : 0] s_axi_araddr
    .s_axi_arvalid ( s_axi_arvalid_s ), // input wire s_axi_arvalid
    .s_axi_arready ( s_axi_arready_s ), // output wire s_axi_arready
    .s_axi_rdata   ( s_axi_rdata_s   ), // output wire [31 : 0] s_axi_rdata
    .s_axi_rresp   ( s_axi_rresp_s   ), // output wire [1 : 0] s_axi_rresp
    .s_axi_rvalid  ( s_axi_rvalid_s  ), // output wire s_axi_rvalid
    .s_axi_rready  ( s_axi_rready_s  )  // input wire s_axi_rready
  );

endmodule

