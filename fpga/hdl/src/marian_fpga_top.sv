//------------------------------------------------------------------------------
// Module   : marian_fpga_top
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 22-dec-2023
//
// Description: Top-level wrapper to be used in FPGA Prototype of Vector-Crypto
// Subsystem, using actual RTL peripherals used in Marian ASIC.
//
// Parameters:
//  - None
//
// Inputs:
//  - clk_p_i: External clock (+ve)
//  - clk_n_i: External clock (-ve)
//  - rst_i: Asynchronous active-high reset
//  - uart_rx_i: UART Rx
//  - jtag_tck_i: JTAG test clock
//  - jtag_tms_i: JTAG test mode select signal
//  - jtag_trst_i: JTAG test reset (async, actve-high)
//  - jtag_tdi_i: JTAG test data in
//
// Outputs:
//  - uart_tx_o: UART tx
//  - jtag_tdo_o: JTAG test data out
//
// Revision History:
//  - Version 1.0: Initial release
//  - Version 1.1: Added GPIO [TZS:21-jul-2024]
//
//------------------------------------------------------------------------------

module marian_fpga_top (
  input  logic clk_p_i,
  input  logic clk_n_i,
  input  logic rst_i,
  // UART
  input  logic uart_rx_i,
  output logic uart_tx_o,
  // JTAG
  input  logic jtag_tck_i,
  input  logic jtag_tms_i,
  input  logic jtag_trst_i,
  input  logic jtag_tdi_i,
  output logic jtag_tdo_o,
  // GPIO
  input  logic [1:0] gpio_i,
  output logic [1:0] gpio_o,
  // PMOD output for level shifting
  output logic pmod_o
);

  logic locked;
  logic rstn_s;
  logic top_clk;
  logic jtag_trstn_s;

  logic [2:0] hart_id_s;
  logic       debug_req_irq_s;

  // constant 1 on PMOD output
  assign pmod_o = 1'b1;

  assign hart_id_s = '0;
  assign rstn_s    = locked & ~rst_i;
  // invert JTAG reset as buttons on VCU118 are active-high
  assign jtag_trstn_s = ~jtag_trst_i;

// Bypass top_clock in behavioural simulation
`ifndef XSIM

  // top clock instance
  top_clock i_top_clock (
    .clk_in1_p ( clk_p_i  ),
    .clk_in1_n ( clk_n_i  ),
    .locked    ( locked   ), // output locked, used for reset
    .clk_out1  ( top_clk  )
  );

`else

  assign top_clk = clk_p_i;
  assign locked  = ~rst_i;

`endif

  marian_top marian_top(
    // AXI M
    .marian_axi_m_ar_ready_i  ( '0                ),
    .marian_axi_m_aw_ready_i  ( '0                ),
    .marian_axi_m_b_id_i      ( '0                ),
    .marian_axi_m_b_resp_i    ( '0                ),
    .marian_axi_m_b_user_i    ( '0                ),
    .marian_axi_m_b_valid_i   ( '0                ),
    .marian_axi_m_r_data_i    ( '0                ),
    .marian_axi_m_r_id_i      ( '0                ),
    .marian_axi_m_r_last_i    ( '0                ),
    .marian_axi_m_r_resp_i    ( '0                ),
    .marian_axi_m_r_user_i    ( '0                ),
    .marian_axi_m_r_valid_i   ( '0                ),
    .marian_axi_m_w_ready_i   ( '0                ),
    .marian_axi_m_ar_addr_o   ( /* UNCONNECTED */ ),
    .marian_axi_m_ar_burst_o  ( /* UNCONNECTED */ ),
    .marian_axi_m_ar_cache_o  ( /* UNCONNECTED */ ),
    .marian_axi_m_ar_id_o     ( /* UNCONNECTED */ ),
    .marian_axi_m_ar_len_o    ( /* UNCONNECTED */ ),
    .marian_axi_m_ar_lock_o   ( /* UNCONNECTED */ ),
    .marian_axi_m_ar_prot_o   ( /* UNCONNECTED */ ),
    .marian_axi_m_ar_qos_o    ( /* UNCONNECTED */ ),
    .marian_axi_m_ar_region_o ( /* UNCONNECTED */ ),
    .marian_axi_m_ar_size_o   ( /* UNCONNECTED */ ),
    .marian_axi_m_ar_user_o   ( /* UNCONNECTED */ ),
    .marian_axi_m_ar_valid_o  ( /* UNCONNECTED */ ),
    .marian_axi_m_aw_addr_o   ( /* UNCONNECTED */ ),
    .marian_axi_m_aw_atop_o   ( /* UNCONNECTED */ ),
    .marian_axi_m_aw_burst_o  ( /* UNCONNECTED */ ),
    .marian_axi_m_aw_cache_o  ( /* UNCONNECTED */ ),
    .marian_axi_m_aw_id_o     ( /* UNCONNECTED */ ),
    .marian_axi_m_aw_len_o    ( /* UNCONNECTED */ ),
    .marian_axi_m_aw_lock_o   ( /* UNCONNECTED */ ),
    .marian_axi_m_aw_prot_o   ( /* UNCONNECTED */ ),
    .marian_axi_m_aw_qos_o    ( /* UNCONNECTED */ ),
    .marian_axi_m_aw_region_o ( /* UNCONNECTED */ ),
    .marian_axi_m_aw_size_o   ( /* UNCONNECTED */ ),
    .marian_axi_m_aw_user_o   ( /* UNCONNECTED */ ),
    .marian_axi_m_aw_valid_o  ( /* UNCONNECTED */ ),
    .marian_axi_m_b_ready_o   ( /* UNCONNECTED */ ),
    .marian_axi_m_r_ready_o   ( /* UNCONNECTED */ ),
    .marian_axi_m_w_data_o    ( /* UNCONNECTED */ ),
    .marian_axi_m_w_last_o    ( /* UNCONNECTED */ ),
    .marian_axi_m_w_strb_o    ( /* UNCONNECTED */ ),
    .marian_axi_m_w_user_o    ( /* UNCONNECTED */ ),
    .marian_axi_m_w_valid_o   ( /* UNCONNECTED */ ),
    // AXI S
    .marian_axi_s_ar_addr_i   ( '0                ),
    .marian_axi_s_ar_burst_i  ( '0                ),
    .marian_axi_s_ar_cache_i  ( '0                ),
    .marian_axi_s_ar_id_i     ( '0                ),
    .marian_axi_s_ar_len_i    ( '0                ),
    .marian_axi_s_ar_lock_i   ( '0                ),
    .marian_axi_s_ar_prot_i   ( '0                ),
    .marian_axi_s_ar_qos_i    ( '0                ),
    .marian_axi_s_ar_region_i ( '0                ),
    .marian_axi_s_ar_size_i   ( '0                ),
    .marian_axi_s_ar_user_i   ( '0                ),
    .marian_axi_s_ar_valid_i  ( '0                ),
    .marian_axi_s_aw_addr_i   ( '0                ),
    .marian_axi_s_aw_atop_i   ( '0                ),
    .marian_axi_s_aw_burst_i  ( '0                ),
    .marian_axi_s_aw_cache_i  ( '0                ),
    .marian_axi_s_aw_id_i     ( '0                ),
    .marian_axi_s_aw_len_i    ( '0                ),
    .marian_axi_s_aw_lock_i   ( '0                ),
    .marian_axi_s_aw_prot_i   ( '0                ),
    .marian_axi_s_aw_qos_i    ( '0                ),
    .marian_axi_s_aw_region_i ( '0                ),
    .marian_axi_s_aw_size_i   ( '0                ),
    .marian_axi_s_aw_user_i   ( '0                ),
    .marian_axi_s_aw_valid_i  ( '0                ),
    .marian_axi_s_b_ready_i   ( '0                ),
    .marian_axi_s_r_ready_i   ( '0                ),
    .marian_axi_s_w_data_i    ( '0                ),
    .marian_axi_s_w_last_i    ( '0                ),
    .marian_axi_s_w_strb_i    ( '0                ),
    .marian_axi_s_w_user_i    ( '0                ),
    .marian_axi_s_w_valid_i   ( '0                ),
    .marian_axi_s_ar_ready_o  ( /* UNCONNECTED */ ),
    .marian_axi_s_aw_ready_o  ( /* UNCONNECTED */ ),
    .marian_axi_s_b_id_o      ( /* UNCONNECTED */ ),
    .marian_axi_s_b_resp_o    ( /* UNCONNECTED */ ),
    .marian_axi_s_b_user_o    ( /* UNCONNECTED */ ),
    .marian_axi_s_b_valid_o   ( /* UNCONNECTED */ ),
    .marian_axi_s_r_data_o    ( /* UNCONNECTED */ ),
    .marian_axi_s_r_id_o      ( /* UNCONNECTED */ ),
    .marian_axi_s_r_last_o    ( /* UNCONNECTED */ ),
    .marian_axi_s_r_resp_o    ( /* UNCONNECTED */ ),
    .marian_axi_s_r_user_o    ( /* UNCONNECTED */ ),
    .marian_axi_s_r_valid_o   ( /* UNCONNECTED */ ),
    .marian_axi_s_w_ready_o   ( /* UNCONNECTED */ ),
    // clk
    .clk_i                    ( top_clk           ),
    // gpio
    .marian_gpio_i            ( gpio_i            ),
    .marian_gpio_o            ( gpio_o            ),
    .marian_gpio_oe           ( /* UNCONNECTED */ ),
    // Interface: irq_i
    .marian_ext_irq_i         ( '0                ),
    // Interface: irq_o
    .marian_ext_irq_o         ( /* UNCONNECTED */ ),
    // Interface: jtag
    .marian_jtag_tck_i        ( jtag_tck_i        ),
    .marian_jtag_tdi_i        ( jtag_tdi_i        ),
    .marian_jtag_tms_i        ( jtag_tms_i        ),
    .marian_jtag_trstn_i      ( jtag_trstn_s      ),
    .marian_jtag_tdo_o        ( jtag_tdo_o        ),
    // Interface: qspi
    .marian_qspi_data_i       ( '0                ),
    .marian_qspi_csn_o        ( /* UNCONNECTED */ ),
    .marian_qspi_data_o       ( /* UNCONNECTED */ ),
    .marian_qspi_oe           ( /* UNCONNECTED */ ),
    .marian_qspi_sclk_o       ( /* UNCONNECTED */ ),
    // Interface: rst_ni
    .rst_ni                   ( rstn_s            ),
    // Interface: uart
    .marian_uart_rx_i         ( uart_rx_i         ),
    .marian_uart_tx_o         ( uart_tx_o         )
  );

endmodule

