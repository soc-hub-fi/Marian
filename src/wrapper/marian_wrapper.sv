//------------------------------------------------------------------------------
// Module   : marian_wrapper
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 15-dec-2023
// Updated  : 23-apr-2024
//
// Description: Temporary wrapper for the top module of the Vector-Crypto
// Subsystem. Will be replaced by Kactus generated wrapper.
//
// Revision History:
//  - Version 1.0: Initial release
//  - Version 1.1: Updated port list to match Kactus2 generated wrapper signals
//                 [tzs:23-apr-2024]
//
//------------------------------------------------------------------------------

module marian_wrapper
import marian_pkg ::*;
(
  input  logic        clk_i ,
  input  logic        rst_ni ,
  // Interface: axi_manager
  input  logic        marian_axi_m_ar_ready_i,
  input  logic        marian_axi_m_aw_ready_i,
  input  logic [ 5:0] marian_axi_m_b_id_i,
  input  logic [ 1:0] marian_axi_m_b_resp_i,
  input  logic [ 3:0] marian_axi_m_b_user_i,
  input  logic        marian_axi_m_b_valid_i,
  input  logic [63:0] marian_axi_m_r_data_i,
  input  logic [ 5:0] marian_axi_m_r_id_i,
  input  logic        marian_axi_m_r_last_i,
  input  logic [ 1:0] marian_axi_m_r_resp_i,
  input  logic [ 3:0] marian_axi_m_r_user_i,
  input  logic        marian_axi_m_r_valid_i,
  input  logic        marian_axi_m_w_ready_i,
  output logic [31:0] marian_axi_m_ar_addr_o,
  output logic [ 1:0] marian_axi_m_ar_burst_o,
  output logic [ 3:0] marian_axi_m_ar_cache_o,
  output logic [ 5:0] marian_axi_m_ar_id_o,
  output logic [ 7:0] marian_axi_m_ar_len_o,
  output logic        marian_axi_m_ar_lock_o,
  output logic [ 2:0] marian_axi_m_ar_prot_o,
  output logic [ 3:0] marian_axi_m_ar_qos_o,
  output logic [ 3:0] marian_axi_m_ar_region_o,
  output logic [ 2:0] marian_axi_m_ar_size_o,
  output logic [ 3:0] marian_axi_m_ar_user_o,
  output logic        marian_axi_m_ar_valid_o,
  output logic [31:0] marian_axi_m_aw_addr_o,
  output logic [ 5:0] marian_axi_m_aw_atop_o,
  output logic [ 1:0] marian_axi_m_aw_burst_o,
  output logic [ 3:0] marian_axi_m_aw_cache_o,
  output logic [ 5:0] marian_axi_m_aw_id_o,
  output logic [ 7:0] marian_axi_m_aw_len_o,
  output logic        marian_axi_m_aw_lock_o,
  output logic [ 2:0] marian_axi_m_aw_prot_o,
  output logic [ 3:0] marian_axi_m_aw_qos_o,
  output logic [ 3:0] marian_axi_m_aw_region_o,
  output logic [ 2:0] marian_axi_m_aw_size_o,
  output logic [ 3:0] marian_axi_m_aw_user_o,
  output logic        marian_axi_m_aw_valid_o,
  output logic        marian_axi_m_b_ready_o,
  output logic        marian_axi_m_r_ready_o,
  output logic [63:0] marian_axi_m_w_data_o,
  output logic        marian_axi_m_w_last_o,
  output logic [ 7:0] marian_axi_m_w_strb_o,
  output logic [ 3:0] marian_axi_m_w_user_o,
  output logic        marian_axi_m_w_valid_o,
  // Interface: axi_subordinate
  input  logic [31:0] marian_axi_s_ar_addr_i,
  input  logic [ 1:0] marian_axi_s_ar_burst_i,
  input  logic [ 3:0] marian_axi_s_ar_cache_i,
  input  logic [ 5:0] marian_axi_s_ar_id_i,
  input  logic [ 7:0] marian_axi_s_ar_len_i,
  input  logic        marian_axi_s_ar_lock_i,
  input  logic [ 2:0] marian_axi_s_ar_prot_i,
  input  logic [ 3:0] marian_axi_s_ar_qos_i,
  input  logic [ 3:0] marian_axi_s_ar_region_i,
  input  logic [ 2:0] marian_axi_s_ar_size_i,
  input  logic [ 3:0] marian_axi_s_ar_user_i,
  input  logic        marian_axi_s_ar_valid_i,
  input  logic [31:0] marian_axi_s_aw_addr_i,
  input  logic [ 5:0] marian_axi_s_aw_atop_i,
  input  logic [ 1:0] marian_axi_s_aw_burst_i,
  input  logic [ 3:0] marian_axi_s_aw_cache_i,
  input  logic [ 5:0] marian_axi_s_aw_id_i,
  input  logic [ 7:0] marian_axi_s_aw_len_i,
  input  logic        marian_axi_s_aw_lock_i,
  input  logic [ 2:0] marian_axi_s_aw_prot_i,
  input  logic [ 3:0] marian_axi_s_aw_qos_i,
  input  logic [ 3:0] marian_axi_s_aw_region_i,
  input  logic [ 2:0] marian_axi_s_aw_size_i,
  input  logic [ 3:0] marian_axi_s_aw_user_i,
  input  logic        marian_axi_s_aw_valid_i,
  input  logic        marian_axi_s_b_ready_i,
  input  logic        marian_axi_s_r_ready_i,
  input  logic [63:0] marian_axi_s_w_data_i,
  input  logic        marian_axi_s_w_last_i,
  input  logic [ 7:0] marian_axi_s_w_strb_i,
  input  logic [ 3:0] marian_axi_s_w_user_i,
  input  logic        marian_axi_s_w_valid_i,
  output logic        marian_axi_s_ar_ready_o,
  output logic        marian_axi_s_aw_ready_o,
  output logic [ 5:0] marian_axi_s_b_id_o,
  output logic [ 1:0] marian_axi_s_b_resp_o,
  output logic [ 3:0] marian_axi_s_b_user_o,
  output logic        marian_axi_s_b_valid_o,
  output logic [63:0] marian_axi_s_r_data_o,
  output logic [ 5:0] marian_axi_s_r_id_o,
  output logic        marian_axi_s_r_last_o,
  output logic [ 1:0] marian_axi_s_r_resp_o,
  output logic [ 3:0] marian_axi_s_r_user_o,
  output logic        marian_axi_s_r_valid_o,
  output logic        marian_axi_s_w_ready_o,
  // GPIO
  input  logic [ 1:0] marian_gpio_i,
  output logic [ 1:0] marian_gpio_o,
  output logic [ 1:0] marian_gpio_oe,
  // IRQ
  input  logic        marian_ext_irq_i,
  output logic        marian_ext_irq_o,
  // QSPI
  input  logic [ 3:0] marian_qspi_data_i,
  output logic        marian_qspi_csn_o,
  output logic [ 3:0] marian_qspi_data_o,
  output logic        marian_qspi_oe,
  output logic        marian_qspi_sclk_o,
  // UART interface
  input  logic        marian_uart_rx_i,
  output logic        marian_uart_tx_o,
  // JTAG
  input  logic        marian_jtag_tck_i,
  input  logic        marian_jtag_tms_i,
  input  logic        marian_jtag_trstn_i,
  input  logic        marian_jtag_tdi_i,
  output logic        marian_jtag_tdo_o

);

/*********************************
 *  Vector-Crypto Subsytem Top  *
 ********************************/

  marian_top i_marian_top(
    .clk_in              (clk_i),
    .rstn_in             (rst_ni),
    // Interface: axi_master
    .ar_ready_1          ( marian_axi_m_ar_ready_i ),
    .aw_ready_1          ( marian_axi_m_aw_ready_i ),
    .b_id_1              ( marian_axi_m_b_id_i     ),
    .b_resp_1            ( marian_axi_m_b_resp_i   ),
    .b_user_1            ( marian_axi_m_b_user_i   ),
    .b_valid_1           ( marian_axi_m_b_valid_i  ),
    .r_data_1            ( marian_axi_m_r_data_i   ),
    .r_id_1              ( marian_axi_m_r_id_i     ),
    .r_last_1            ( marian_axi_m_r_last_i   ),
    .r_resp_1            ( marian_axi_m_r_resp_i   ),
    .r_user_1            ( marian_axi_m_r_user_i   ),
    .r_valid_1           ( marian_axi_m_r_valid_i  ),
    .w_ready_1           ( marian_axi_m_w_ready_i  ),
    .ar_addr_1           ( marian_axi_m_ar_addr_o  ),
    .ar_burst_1          ( marian_axi_m_ar_burst_o ),
    .ar_cache_1          ( marian_axi_m_ar_cache_o ),
    .ar_id_1             ( marian_axi_m_ar_id_o    ),
    .ar_len_1            ( marian_axi_m_ar_len_o   ),
    .ar_lock_1           ( marian_axi_m_ar_lock_o  ),
    .ar_prot_1           ( marian_axi_m_ar_prot_o  ),
    .ar_qos_1            ( marian_axi_m_ar_qos_o   ),
    .ar_region_1         ( marian_axi_m_ar_region_o),
    .ar_size_1           ( marian_axi_m_ar_size_o  ),
    .ar_user_1           ( marian_axi_m_ar_user_o  ),
    .ar_valid_1          ( marian_axi_m_ar_valid_o ),
    .aw_addr_1           ( marian_axi_m_aw_addr_o  ),
    .aw_atop_1           ( marian_axi_m_aw_atop_o  ),
    .aw_burst_1          ( marian_axi_m_aw_burst_o ),
    .aw_cache_1          ( marian_axi_m_aw_cache_o ),
    .aw_id_1             ( marian_axi_m_aw_id_o    ),
    .aw_len_1            ( marian_axi_m_aw_len_o   ),
    .aw_lock_1           ( marian_axi_m_aw_lock_o  ),
    .aw_prot_1           ( marian_axi_m_aw_prot_o  ),
    .aw_qos_1            ( marian_axi_m_aw_qos_o   ),
    .aw_region_1         ( marian_axi_m_aw_region_o),
    .aw_size_1           ( marian_axi_m_aw_size_o  ),
    .aw_user_1           ( marian_axi_m_aw_user_o  ),
    .aw_valid_1          ( marian_axi_m_aw_valid_o ),
    .b_ready_1           ( marian_axi_m_b_ready_o  ),
    .r_ready_1           ( marian_axi_m_r_ready_o  ),
    .w_data_1            ( marian_axi_m_w_data_o   ),
    .w_last_1            ( marian_axi_m_w_last_o   ),
    .w_strb_1            ( marian_axi_m_w_strb_o   ),
    .w_user_1            ( marian_axi_m_w_user_o   ),
    .w_valid_1           ( marian_axi_m_w_valid_o  ),
    // Interface: axi_slave
    .ar_addr             ( marian_axi_s_ar_addr_i   ),
    .ar_burst            ( marian_axi_s_ar_burst_i  ),
    .ar_cache            ( marian_axi_s_ar_cache_i  ),
    .ar_id               ( marian_axi_s_ar_id_i     ),
    .ar_len              ( marian_axi_s_ar_len_i    ),
    .ar_lock             ( marian_axi_s_ar_lock_i   ),
    .ar_prot             ( marian_axi_s_ar_prot_i   ),
    .ar_qos              ( marian_axi_s_ar_qos_i    ),
    .ar_region           ( marian_axi_s_ar_region_i ),
    .ar_size             ( marian_axi_s_ar_size_i   ),
    .ar_user             ( marian_axi_s_ar_user_i   ),
    .ar_valid            ( marian_axi_s_ar_valid_i  ),
    .aw_addr             ( marian_axi_s_aw_addr_i   ),
    .aw_atop             ( marian_axi_s_aw_atop_i   ),
    .aw_burst            ( marian_axi_s_aw_burst_i  ),
    .aw_cache            ( marian_axi_s_aw_cache_i  ),
    .aw_id               ( marian_axi_s_aw_id_i     ),
    .aw_len              ( marian_axi_s_aw_len_i    ),
    .aw_lock             ( marian_axi_s_aw_lock_i   ),
    .aw_prot             ( marian_axi_s_aw_prot_i   ),
    .aw_qos              ( marian_axi_s_aw_qos_i    ),
    .aw_region           ( marian_axi_s_aw_region_i ),
    .aw_size             ( marian_axi_s_aw_size_i   ),
    .aw_user             ( marian_axi_s_aw_user_i   ),
    .aw_valid            ( marian_axi_s_aw_valid_i  ),
    .b_ready             ( marian_axi_s_b_ready_i   ),
    .r_ready             ( marian_axi_s_r_ready_i   ),
    .w_data              ( marian_axi_s_w_data_i    ),
    .w_last              ( marian_axi_s_w_last_i    ),
    .w_strb              ( marian_axi_s_w_strb_i    ),
    .w_user              ( marian_axi_s_w_user_i    ),
    .w_valid             ( marian_axi_s_w_valid_i   ),
    .ar_ready            ( marian_axi_s_ar_ready_o  ),
    .aw_ready            ( marian_axi_s_aw_ready_o  ),
    .b_id                ( marian_axi_s_b_id_o      ),
    .b_resp              ( marian_axi_s_b_resp_o    ),
    .b_user              ( marian_axi_s_b_user_o    ),
    .b_valid             ( marian_axi_s_b_valid_o   ),
    .r_data              ( marian_axi_s_r_data_o    ),
    .r_id                ( marian_axi_s_r_id_o      ),
    .r_last              ( marian_axi_s_r_last_o    ),
    .r_resp              ( marian_axi_s_r_resp_o    ),
    .r_user              ( marian_axi_s_r_user_o    ),
    .r_valid             ( marian_axi_s_r_valid_o   ),
    .w_ready             ( marian_axi_s_w_ready_o   ),
    // Interface: gpio
    .gpio_i              ( '0                ),
    .gpio_o              ( /* UNCONNECTED */ ),
    .gpio_oe             ( /* UNCONNECTED */ ),
    // Interface: irq_i
    .ext_irq_in          ( '0 ),
    // Interface: irq_o
    .vc_ss_ext_irq_o     ( /* UNCONNECTED */ ),
    // Interface: jtag
    .jtag_TCK            ( jtag_tck_i   ),
    .jtag_TDI            ( jtag_tdi_i   ),
    .jtag_TMS            ( jtag_tms_i   ),
    .jtag_TRST           ( jtag_trstn_i ),
    .jtag_TDO            ( jtag_tdo_o   ),
    // Interface: qspi
    .qspi_data_i         ( '0 ),
    .qspi_csn_o          ( /* UNCONNECTED */ ),
    .qspi_data_o         ( /* UNCONNECTED */ ),
    .qspi_oe             ( /* UNCONNECTED */ ),
    .qspi_sclk_o         ( /* UNCONNECTED */ ),
    // Interface: uart
    .uart_rx_i           (uart_rx_i),
    .uart_tx_o           (uart_tx_o)
    );

endmodule
