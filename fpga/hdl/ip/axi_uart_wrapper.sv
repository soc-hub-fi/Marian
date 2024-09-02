//------------------------------------------------------------------------------
// Module   : axi_uart_wrapper
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 12-jan-2024
//
// Description: SV wrapper for the Xilinx AXI UART IP.
//              Accessed via 32b AXI-Lite peripheral interface.
//
// Parameters:
//  - None
//
// Inputs:
//  - clk_i: Clock in
//  - rstn_i: Active-low asynchronous reset
//  - periph_lite_req_i: AXI request signals coming in from system xbar (32b)
//  - uart_rx_i: UART Rx
//
// Outputs:
//  - periph_lite_resp_o: AXI response signals going out to system xbar (32b)
//  - uart_tx_o: UART Tx
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

import marian_fpga_pkg::*;

module axi_uart_wrapper(
  input  logic              clk_i,
  input  logic              rstn_i,
  // axi-lite signals
  input  periph_lite_req_t  periph_lite_req_i,
  output periph_lite_resp_t periph_lite_resp_o,
  // uart signals
  input  logic              uart_rx_i,
  output logic              uart_tx_o
);

  wire [12:0] s_axi_awaddr_s;
  wire        s_axi_awvalid_s;
  wire        s_axi_awready_s;
  wire [31:0] s_axi_wdata_s;
  wire [ 3:0] s_axi_wstrb_s;
  wire        s_axi_wvalid_s;
  wire        s_axi_wready_s;
  wire [ 1:0] s_axi_bresp_s;
  wire        s_axi_bvalid_s;
  wire        s_axi_bready_s;
  wire [12:0] s_axi_araddr_s;
  wire        s_axi_arvalid_s;
  wire        s_axi_arready_s;
  wire [31:0] s_axi_rdata_s;
  wire [ 1:0] s_axi_rresp_s;
  wire        s_axi_rvalid_s;
  wire        s_axi_rready_s;

  wire        freeze_s;
  wire        ctsn_s;
  wire        dcdn_s;
  wire        dsrn_s;
  wire        rin_s;
  wire        sin_s;
  wire        sout_s;

  // axi assignments
  assign periph_lite_resp_o.aw_ready = s_axi_awready_s;
  assign periph_lite_resp_o.ar_ready = s_axi_arready_s;
  assign periph_lite_resp_o.w_ready  = s_axi_wready_s;
  assign periph_lite_resp_o.b_valid  = s_axi_bvalid_s;
  assign periph_lite_resp_o.b.resp   = s_axi_bresp_s;
  assign periph_lite_resp_o.r_valid  = s_axi_rvalid_s;
  assign periph_lite_resp_o.r.data   = s_axi_rdata_s;
  assign periph_lite_resp_o.r.resp   = s_axi_rresp_s;

  assign s_axi_awaddr_s  = periph_lite_req_i.aw.addr[12:0];
  assign s_axi_awvalid_s = periph_lite_req_i.aw_valid;
  assign s_axi_wdata_s   = periph_lite_req_i.w.data;
  assign s_axi_wstrb_s   = periph_lite_req_i.w.strb;
  assign s_axi_wvalid_s  = periph_lite_req_i.w_valid;
  assign s_axi_bready_s  = periph_lite_req_i.b_ready;
  assign s_axi_araddr_s  = periph_lite_req_i.ar.addr[12:0];
  assign s_axi_arvalid_s = periph_lite_req_i.ar_valid;
  assign s_axi_rready_s  = periph_lite_req_i.r_ready;

  // functional signal assignments
  assign freeze_s  = 1'b0; //  If 1, interrupts are disabled and UART becomes idle
  assign ctsn_s    = 1'b0; // Clear to send (active-Low)
  assign dcdn_s    = 1'b0; // Data carrier detect (active-Low).
  assign dsrn_s    = 1'b0; // Data set ready (active-Low).
  assign rin_s     = 1'b0; // Ring indicator (active-Low).
  assign sin_s     = uart_rx_i;
  assign uart_tx_o = sout_s;


  axi_uart i_axi_uart (
    .s_axi_aclk    ( clk_i           ),
    .s_axi_aresetn ( rstn_i          ),
    .ip2intc_irpt  ( /* unused */    ),
    .freeze        ( freeze_s        ),
    .s_axi_awaddr  ( s_axi_awaddr_s  ),
    .s_axi_awvalid ( s_axi_awvalid_s ),
    .s_axi_awready ( s_axi_awready_s ),
    .s_axi_wdata   ( s_axi_wdata_s   ),
    .s_axi_wstrb   ( s_axi_wstrb_s   ),
    .s_axi_wvalid  ( s_axi_wvalid_s  ),
    .s_axi_wready  ( s_axi_wready_s  ),
    .s_axi_bresp   ( s_axi_bresp_s   ),
    .s_axi_bvalid  ( s_axi_bvalid_s  ),
    .s_axi_bready  ( s_axi_bready_s  ),
    .s_axi_araddr  ( s_axi_araddr_s  ),
    .s_axi_arvalid ( s_axi_arvalid_s ),
    .s_axi_arready ( s_axi_arready_s ),
    .s_axi_rdata   ( s_axi_rdata_s   ),
    .s_axi_rresp   ( s_axi_rresp_s   ),
    .s_axi_rvalid  ( s_axi_rvalid_s  ),
    .s_axi_rready  ( s_axi_rready_s  ),
    .baudoutn      ( /* unused */    ),
    .ctsn          ( ctsn_s          ),
    .dcdn          ( dcdn_s          ),
    .ddis          ( /* unused */    ),
    .dsrn          ( dsrn_s          ),
    .dtrn          ( /* unused */    ),
    .out1n         ( /* unused */    ),
    .out2n         ( /* unused */    ),
    .rin           ( rin_s           ),
    .rtsn          ( /* unused */    ),
    .rxrdyn        ( /* unused */    ),
    .sin           ( sin_s           ),
    .sout          ( sout_s          ),
    .txrdyn        ( /* unused */    )
  );

endmodule
