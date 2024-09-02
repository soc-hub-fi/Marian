//------------------------------------------------------------------------------
// Module   : vector_crypto_ss_wrapper_tieoff
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 26-apr-2024
//
// Description: Tie-off version of vc-ss wrapper
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

module vector_crypto_ss_wrapper_0(
  // Interface: axi_cdc_64b_master
  input                [1:0]          vcss_64b_m_ar_rd_data_ptr_dst2src_i,
  input                [2:0]          vcss_64b_m_ar_rd_ptr_gray_dst2src_i,
  input                [1:0]          vcss_64b_m_aw_rd_data_ptr_dst2src_i,
  input                [2:0]          vcss_64b_m_aw_rd_ptr_gray_dst2src_i,
  input                [11:0]         vcss_64b_m_b_data_dst2src_i,
  input                [2:0]          vcss_64b_m_b_wr_ptr_gray_dst2src_i,
  input                [76:0]         vcss_64b_m_r_data_dst2src_i,
  input                [2:0]          vcss_64b_m_r_wr_ptr_gray_dst2src_i,
  input                [1:0]          vcss_64b_m_w_rd_data_ptr_dst2src_i,
  input                [2:0]          vcss_64b_m_w_rd_ptr_gray_dst2src_i,
  output               [70:0]         vcss_64b_m_ar_data_src2dst_o,
  output               [2:0]          vcss_64b_m_ar_wr_ptr_gray_src2dst_o,
  output               [76:0]         vcss_64b_m_aw_data_src2dst_o,
  output               [2:0]          vcss_64b_m_aw_wr_ptr_gray_src2dst_o,
  output               [1:0]          vcss_64b_m_b_rd_data_ptr_src2dst_o,
  output               [2:0]          vcss_64b_m_b_rd_ptr_gray_src2dst_o,
  output               [1:0]          vcss_64b_m_r_rd_data_ptr_src2dst_o,
  output               [2:0]          vcss_64b_m_r_rd_ptr_gray_src2dst_o,
  output               [73:0]         vcss_64b_m_w_data_src2dst_o,
  output               [2:0]          vcss_64b_m_w_wr_ptr_gray_src2dst_o,

  // Interface: axi_cdc_64b_slave
  input                [70:0]         vcss_64b_s_ar_data_src2dst_i,
  input                [2:0]          vcss_64b_s_ar_wr_ptr_gray_src2dst_i,
  input                [76:0]         vcss_64b_s_aw_data_src2dst_i,
  input                [2:0]          vcss_64b_s_aw_wr_ptr_gray_src2dst_o,
  input                [1:0]          vcss_64b_s_b_rd_data_ptr_src2dst_i,
  input                [2:0]          vcss_64b_s_b_rd_ptr_gray_src2dst_i,
  input                [1:0]          vcss_64b_s_r_rd_data_ptr_src2dst_i,
  input                [2:0]          vcss_64b_s_r_rd_ptr_gray_src2dst_i,
  input                [73:0]         vcss_64b_s_w_data_src2dst_i,
  input                [2:0]          vcss_64b_s_w_wr_ptr_gray_src2dst_i,
  output               [1:0]          vcss_64b_s_ar_rd_data_ptr_dst2src_o,
  output               [2:0]          vcss_64b_s_ar_rd_ptr_gray_dst2src_o,
  output               [1:0]          vcss_64b_s_aw_rd_data_ptr_dst2src_o,
  output               [2:0]          vcss_64b_s_aw_rd_ptr_gray_dst2src_o,
  output               [11:0]         vcss_64b_s_b_data_dst2src_o,
  output               [2:0]          vcss_64b_s_b_wr_ptr_gray_dst2src_o,
  output               [76:0]         vcss_64b_s_r_data_dst2src_o,
  output               [2:0]          vcss_64b_s_r_wr_ptr_gray_dst2src_o,
  output               [1:0]          vcss_64b_s_w_rd_data_ptr_dst2src_o,
  output               [2:0]          vcss_64b_s_w_rd_ptr_gray_dst2src_o,

  // Interface: clk_ctrl
  input  logic         [7:0]          vcss_clk_ctrl_i,

  // Interface: gpio
  input                [1:0]          vcss_gpio_i,
  output               [1:0]          vcss_gpio_o,
  output               [1:0]          vcss_gpio_oe_o,

  // Interface: icn_rst_n
  input  logic                        vcss_rst_ni,

  // Interface: irq_i
  input  logic                        vcss_ext_irq_i,    // level sensitive IRQ lines. 3 interrupt IDs are available for external
  // interrupts. INT ID 8,9,14

  // Interface: irq_o
  output                              vcss_ext_irq_o,

  // Interface: jtag
  input  logic                        vcss_jtag_tck_i,
  input                               vcss_jtag_tdi_i,
  input  logic                        vcss_jtag_tms_i,
  input  logic                        vcss_jtag_trst_i,
  output                              vcss_jtag_tdo_o,

  // Interface: pll_ctrl
  input  logic         [7:0]          vcss_pll_debug_ctrl_i,
  input  logic         [16:0]         vcss_pll_div_i,
  input  logic         [7:0]          vcss_pll_enable_i,
  input  logic         [31:0]         vcss_pll_loop_ctrl_i,
  input  logic         [31:0]         vcss_pll_spare_ctrl_i,
  input  logic         [7:0]          vcss_pll_tmux_sel_i,
  input  logic                        vcss_pll_valid_i,

  // Interface: pll_status
  output logic         [31:0]         vcss_pll_status_1_o,
  output logic         [31:0]         vcss_pll_status_2_o,

  // Interface: qspi
  input                [3:0]          vcss_qspi_data_i,
  output                              vcss_qspi_csn_o,
  output               [3:0]          vcss_qspi_data_o,
  output                              vcss_qspi_oe_o,
  output                              vcss_qspi_sclk_o,

  // Interface: ref_clk
  input  logic                        vcss_refclk_i,

  // Interface: ref_rst_n
  input  logic                        vcss_ref_rst_ni,

  // Interface: uart
  input                               vcss_uart_rx_i,
  output                              vcss_uart_tx_o
);

assign vcss_64b_m_ar_data_src2dst_o        = '0;
assign vcss_64b_m_ar_wr_ptr_gray_src2dst_o = '0;
assign vcss_64b_m_aw_data_src2dst_o        = '0;
assign vcss_64b_m_aw_wr_ptr_gray_src2dst_o = '0;
assign vcss_64b_m_b_rd_data_ptr_src2dst_o  = '0;
assign vcss_64b_m_b_rd_ptr_gray_src2dst_o  = '0;
assign vcss_64b_m_r_rd_data_ptr_src2dst_o  = '0;
assign vcss_64b_m_r_rd_ptr_gray_src2dst_o  = '0;
assign vcss_64b_m_w_data_src2dst_o         = '0;
assign vcss_64b_m_w_wr_ptr_gray_src2dst_o  = '0;
assign vcss_64b_s_ar_rd_data_ptr_dst2src_o = '0;
assign vcss_64b_s_ar_rd_ptr_gray_dst2src_o = '0;
assign vcss_64b_s_aw_rd_data_ptr_dst2src_o = '0;
assign vcss_64b_s_aw_rd_ptr_gray_dst2src_o = '0;
assign vcss_64b_s_b_data_dst2src_o         = '0;
assign vcss_64b_s_b_wr_ptr_gray_dst2src_o  = '0;
assign vcss_64b_s_r_data_dst2src_o         = '0;
assign vcss_64b_s_r_wr_ptr_gray_dst2src_o  = '0;
assign vcss_64b_s_w_rd_data_ptr_dst2src_o  = '0;
assign vcss_64b_s_w_rd_ptr_gray_dst2src_o  = '0;
assign vcss_gpio_o                         = '0;
assign vcss_gpio_oe_o                      = '0;
assign vcss_ext_irq_o                      = '0;
assign vcss_jtag_tdo_o                     = '0;
assign vcss_pll_status_1_o                 = '0;
assign vcss_pll_status_2_o                 = '0;
assign vcss_qspi_csn_o                     = '0;
assign vcss_qspi_data_o                    = '0;
assign vcss_qspi_oe_o                      = '0;
assign vcss_qspi_sclk_o                    = '0;
assign vcss_uart_tx_o                      = '0;

endmodule
