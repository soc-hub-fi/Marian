//------------------------------------------------------------------------------
// Module   : axi_gpio8_wrapper
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 12-jan-2024
//
// Description: SV wrapper for the Xilinx AXI GPIO IP.
//              Accessed via 32b AXI-Lite peripheral interface.
//
// Parameters:
//  - GPIO_PIN_COUNT: Number of GPIO pins
//
// Inputs:
//  - clk_i: Clock in
//  - rstn_i: Active-low asynchronous reset
//  - periph_lite_req_i: AXI request signals coming in from system xbar (32b)
//
// Outputs:
//  - periph_lite_resp_o: AXI response signals going out to system xbar (32b)
//
// InOuts:
//  - gpio_io: GPIO signals
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

import marian_fpga_pkg::*;

module axi_gpio8_wrapper #(
  parameter unsigned GPIO_PIN_COUNT = 8
) (
  input  logic                     clk_i,
  input  logic                     rstn_i,
  // axi-lite signals
  input  periph_lite_req_t         periph_lite_req_i,
  output periph_lite_resp_t        periph_lite_resp_o,
  // GPIO signals
  inout logic [GPIO_PIN_COUNT-1:0] gpio_io
);

  wire [ 8:0] s_axi_awaddr_s;
  wire        s_axi_awvalid_s;
  wire        s_axi_awready_s;
  wire [31:0] s_axi_wdata_s;
  wire [ 3:0] s_axi_wstrb_s;
  wire        s_axi_wvalid_s;
  wire        s_axi_wready_s;
  wire [ 1:0] s_axi_bresp_s;
  wire        s_axi_bvalid_s;
  wire        s_axi_bready_s;
  wire [ 8:0] s_axi_araddr_s;
  wire        s_axi_arvalid_s;
  wire        s_axi_arready_s;
  wire [31:0] s_axi_rdata_s;
  wire [ 1:0] s_axi_rresp_s;
  wire        s_axi_rvalid_s;
  wire        s_axi_rready_s;

  wire [GPIO_PIN_COUNT-1:0] gpio_io_i_s;
  wire [GPIO_PIN_COUNT-1:0] gpio_io_o_s;
  wire [GPIO_PIN_COUNT-1:0] gpio_io_t_s;

  // axi assignments
  assign periph_lite_resp_o.aw_ready = s_axi_awready_s;
  assign periph_lite_resp_o.ar_ready = s_axi_arready_s;
  assign periph_lite_resp_o.w_ready  = s_axi_wready_s;
  assign periph_lite_resp_o.b_valid  = s_axi_bvalid_s;
  assign periph_lite_resp_o.b.resp   = s_axi_bresp_s;
  assign periph_lite_resp_o.r_valid  = s_axi_rvalid_s;
  assign periph_lite_resp_o.r.data   = s_axi_rdata_s;
  assign periph_lite_resp_o.r.resp   = s_axi_rresp_s;

  assign s_axi_awaddr_s  = periph_lite_req_i.aw.addr[8:0];
  assign s_axi_awvalid_s = periph_lite_req_i.aw_valid;
  assign s_axi_wdata_s   = periph_lite_req_i.w.data;
  assign s_axi_wstrb_s   = periph_lite_req_i.w.strb;
  assign s_axi_wvalid_s  = periph_lite_req_i.w_valid;
  assign s_axi_bready_s  = periph_lite_req_i.b_ready;
  assign s_axi_araddr_s  = periph_lite_req_i.ar.addr[8:0];
  assign s_axi_arvalid_s = periph_lite_req_i.ar_valid;
  assign s_axi_rready_s  = periph_lite_req_i.r_ready;

  // IO assignments
  genvar pin_idx;
  for (pin_idx = 0; pin_idx < GPIO_PIN_COUNT; pin_idx++) begin : g_gpio_pin_idx
    assign gpio_io[pin_idx] = (gpio_io_t_s[pin_idx]) ? 1'bz : gpio_io_o_s[pin_idx];
    assign gpio_io_i_s[pin_idx] = gpio_io[pin_idx];
  end

  axi_gpio8 i_axi_gpio8 (
    .s_axi_aclk    ( clk_i_s         ),
    .s_axi_aresetn ( rstn_i_s        ),
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
    .gpio_io_i     ( gpio_io_i_s     ),
    .gpio_io_o     ( gpio_io_o_s     ),
    .gpio_io_t     ( gpio_io_t_s     )
  );

endmodule

