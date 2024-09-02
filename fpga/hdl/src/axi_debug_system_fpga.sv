//------------------------------------------------------------------------------
// Module   : axi_debug_system_fpga
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 20-jan-2024
//
// Description: Contains AXI conversion and Marian debug module components.
// Used for Marian FPGA prototyping.
//
// Parameters:
//  - None
//
// Inputs:
//  - clk_i: Clock
//  - rst_ni Asynchronous active-low reset
//  - debug_axi_s_req_i: 128b AXI request lines from xbar (M) to dbg module (S)
//  - debug_axi_m_resp_i: 128b AXI response from xbar (S) to dbg module (S)
//  - jtag_tck_i: JTAG test clock
//  - jtag_tms_i: JTAG test mode select signal
//  - jtag_trstn_i: JTAG test reset (async, actve-low)
//  - jtag_tdi_i: JTAG test data in
//
// Outputs:
//  - debug_axi_s_resp_o: 128b AXI response from dbg module (S) to xbar (M)
//  - debug_axi_m_req_o: 128b AXI request lines from dbg module (M) to xbar (S)
//  - jtag_tdo_o: JTAG test data out
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

module axi_debug_system_fpga
  import marian_fpga_pkg::*;
(
  input logic clk_i,
  input logic rstn_i,
  // axi signals from xbar
  input  marian_fpga_pkg::system_req_t  debug_axi_s_req_i,
  output marian_fpga_pkg::system_resp_t debug_axi_s_resp_o,
  // axi signals from xbar
  input  marian_fpga_pkg::system_resp_t debug_axi_m_resp_i,
  output marian_fpga_pkg::system_req_t  debug_axi_m_req_o,
  // debug request irq
  output logic debug_req_irq_o,
  // jtag signals
  input  logic jtag_tck_i,
  input  logic jtag_tms_i,
  input  logic jtag_trstn_i,
  input  logic jtag_tdi_i,
  output logic jtag_tdo_o
);

  // AXI-S interface to debug module
  marian_fpga_pkg::debug_s_req_t  debug_axi_s_req;
  marian_fpga_pkg::debug_s_resp_t debug_axi_s_resp;
  // AXI-M interface to debug module
  marian_fpga_pkg::debug_m_req_t  debug_axi_m_req;
  marian_fpga_pkg::debug_m_resp_t debug_axi_m_resp;

  /***********************
   * Debug AXI Downsizer *
   ***********************/

   axi_dw_conv_down_dbg_wrapper i_axi_downsizer (
    .clk_i            ( clk_i              ),
    .rstn_i           ( rstn_i             ),
    .system_req_i     ( debug_axi_s_req_i  ),
    .system_resp_o    ( debug_axi_s_resp_o ),
    .debug_axi_resp_i ( debug_axi_s_resp   ),
    .debug_axi_req_o  ( debug_axi_s_req    )
   );

  /*********************
   * Debug AXI Upsizer *
   *********************/

  axi_dw_conv_up_dbg_wrapper i_axi_upsizer (
    .clk_i            ( clk_i              ),
    .rstn_i           ( rstn_i             ),
    .system_resp_i    ( debug_axi_m_resp_i ),
    .system_req_o     ( debug_axi_m_req_o  ),
    .debug_axi_req_i  ( debug_axi_m_req    ),
    .debug_axi_resp_o ( debug_axi_m_resp   )
  );

  /****************
   * Debug System *
   ****************/

  debug_system i_debug_system (
    .clk_i              ( clk_i             ),
    .rstn_i             ( rstn_i            ),
    .debug_axi_s_req_i  ( debug_axi_s_req   ),
    .debug_axi_s_resp_o ( debug_axi_s_resp  ),
    .debug_axi_m_resp_i ( debug_axi_m_resp  ),
    .debug_axi_m_req_o  ( debug_axi_m_req   ),
    .debug_req_irq_o    ( debug_req_irq_o   ),
    .jtag_tck_i         ( jtag_tck_i        ),
    .jtag_tms_i         ( jtag_tms_i        ),
    .jtag_trstn_i       ( jtag_trstn_i      ),
    .jtag_tdi_i         ( jtag_tdi_i        ),
    .jtag_tdo_o         ( jtag_tdo_o        )
  );

endmodule
