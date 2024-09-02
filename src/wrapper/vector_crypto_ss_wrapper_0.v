//-----------------------------------------------------------------------------
// File          : vector_crypto_ss_wrapper_0.v
// Creation date : 12.06.2024
// Creation time : 23:19:28
// Description   : 
// Created by    : 
// Tool : Kactus2 3.10.15 64-bit
// Plugin : Verilog generator 2.4
// This file was generated based on IP-XACT component tuni.fi:subsystem.wrapper:vector_crypto_ss_wrapper:1.0
// whose XML file is ./ips/vc-ss/ipxact/tuni.fi/subsystem.wrapper/vector_crypto_ss_wrapper/1.0/vector_crypto_ss_wrapper.1.0.xml
//-----------------------------------------------------------------------------

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
    input                [2:0]          vcss_64b_s_aw_wr_ptr_gray_src2dst_i,
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
    input  logic                        vcss_jtag_tms_i,
    input  logic                        vcss_jtag_trst_i,

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
    output               [3:0]          vcss_qspi_oe_o,
    output                              vcss_qspi_sclk_o,

    // Interface: ref_clk
    input  logic                        vcss_refclk_i,

    // Interface: ref_rst_n
    input  logic                        vcss_ref_rst_ni,

    // Interface: uart
    input                               vcss_uart_rx_i,
    output                              vcss_uart_tx_o,

    // These ports are not in any interface
    input                               vcss_jtag_tdi_i,
    output                              vcss_jtag_tdo_o
);

    // subsystem_clock_control_0_ref_clk_to_ref_clk wires:
    wire       subsystem_clock_control_0_ref_clk_to_ref_clk_clk;
    // subsystem_clock_control_0_clk_ctrl_to_clk_ctrl wires:
    wire [7:0] subsystem_clock_control_0_clk_ctrl_to_clk_ctrl_CLK_CTRL;
    // subsystem_clock_control_0_ref_rstn_to_ref_rst_n wires:
    wire       subsystem_clock_control_0_ref_rstn_to_ref_rst_n_rst_n;
    // clkpll_0_pll_clk_to_subsystem_clock_control_0_pll_clk wires:
    wire       clkpll_0_pll_clk_to_subsystem_clock_control_0_pll_clk_clk;
    // axi_cdc_intf_dst_0_icn_rstn_to_icn_rst_n wires:
    wire       axi_cdc_intf_dst_0_icn_rstn_to_icn_rst_n_rst_n;
    // subsystem_clock_control_0_pll_ctrl_latched_to_clkpll_0_pll_ctrl_latched wires:
    wire [7:0] subsystem_clock_control_0_pll_ctrl_latched_to_clkpll_0_pll_ctrl_latched_DEBUG_CTRL;
    wire [16:0] subsystem_clock_control_0_pll_ctrl_latched_to_clkpll_0_pll_ctrl_latched_DIV;
    wire [7:0] subsystem_clock_control_0_pll_ctrl_latched_to_clkpll_0_pll_ctrl_latched_ENABLE;
    wire [31:0] subsystem_clock_control_0_pll_ctrl_latched_to_clkpll_0_pll_ctrl_latched_LOOP_CTRL;
    wire [31:0] subsystem_clock_control_0_pll_ctrl_latched_to_clkpll_0_pll_ctrl_latched_SPARE_CTRL;
    wire [7:0] subsystem_clock_control_0_pll_ctrl_latched_to_clkpll_0_pll_ctrl_latched_TMUX_SEL;
    // subsystem_clock_control_0_clk_to_marian_top_clk wires:
    wire       subsystem_clock_control_0_clk_to_marian_top_clk_clk;
    // subsystem_clock_control_0_rst_n_to_marian_top_rst_ni wires:
    wire       subsystem_clock_control_0_rst_n_to_marian_top_rst_ni_rst_n;
    // marian_top_irq_o_to_irq_o wires:
    wire       marian_top_irq_o_to_irq_o_IRQ;
    // marian_top_uart_to_uart wires:
    wire       marian_top_uart_to_uart_uart_rx;
    wire       marian_top_uart_to_uart_uart_tx;
    // marian_top_gpio_to_gpio wires:
    wire [1:0] marian_top_gpio_to_gpio_gpio_core;
    wire [1:0] marian_top_gpio_to_gpio_gpio_oe;
    wire [1:0] marian_top_gpio_to_gpio_gpio_offchip;
    // marian_top_jtag_to_jtag wires:
    wire       marian_top_jtag_to_jtag_TCK;
    wire       marian_top_jtag_to_jtag_TMS;
    wire       marian_top_jtag_to_jtag_TRST;
    // clkpll_0_pll_status_to_pll_status wires:
    wire [31:0] clkpll_0_pll_status_to_pll_status_pll_status_1;
    wire [31:0] clkpll_0_pll_status_to_pll_status_pll_status_2;
    // subsystem_clock_control_0_pll_ctrl_to_pll_ctrl wires:
    wire [7:0] subsystem_clock_control_0_pll_ctrl_to_pll_ctrl_DEBUG_CTRL;
    wire [16:0] subsystem_clock_control_0_pll_ctrl_to_pll_ctrl_DIV;
    wire [7:0] subsystem_clock_control_0_pll_ctrl_to_pll_ctrl_ENABLE;
    wire [31:0] subsystem_clock_control_0_pll_ctrl_to_pll_ctrl_LOOP_CTRL;
    wire [31:0] subsystem_clock_control_0_pll_ctrl_to_pll_ctrl_SPARE_CTRL;
    wire [7:0] subsystem_clock_control_0_pll_ctrl_to_pll_ctrl_TMUX_SEL;
    wire       subsystem_clock_control_0_pll_ctrl_to_pll_ctrl_VALID;
    // marian_top_irq_i_to_irq_i wires:
    wire       marian_top_irq_i_to_irq_i_IRQ;
    // axi_cdc_intf_src_0_src_to_axi_cdc_64b_master wires:
    wire [70:0] axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_AR_DATA_SRC2DST;
    wire [1:0] axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_AR_RD_DATA_PTR_DST2SRC;
    wire [2:0] axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_AR_RD_PTR_GRAY_DST2SRC;
    wire [2:0] axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_AR_WR_PTR_GRAY_SRC2DST;
    wire [76:0] axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_AW_DATA_SRC2DST;
    wire [1:0] axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_AW_RD_DATA_PTR_DST2SRC;
    wire [2:0] axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_AW_RD_PTR_GRAY_DST2SRC;
    wire [2:0] axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_AW_WR_PTR_GRAY_SRC2DST;
    wire [11:0] axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_B_DATA_DST2SRC;
    wire [1:0] axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_B_RD_DATA_PTR_SRC2DST;
    wire [2:0] axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_B_RD_PTR_GRAY_SRC2DST;
    wire [2:0] axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_B_WR_PTR_GRAY_DST2SRC;
    wire [76:0] axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_R_DATA_DST2SRC;
    wire [1:0] axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_R_RD_DATA_PTR_SRC2DST;
    wire [2:0] axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_R_RD_PTR_GRAY_SRC2DST;
    wire [2:0] axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_R_WR_PTR_GRAY_DST2SRC;
    wire [73:0] axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_W_DATA_SRC2DST;
    wire [1:0] axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_W_RD_DATA_PTR_DST2SRC;
    wire [2:0] axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_W_RD_PTR_GRAY_DST2SRC;
    wire [2:0] axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_W_WR_PTR_GRAY_SRC2DST;
    // axi_cdc_intf_src_0_dst_to_marian_top_axi_master wires:
    wire [31:0] axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_ADDR;
    wire [1:0] axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_BURST;
    wire [3:0] axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_CACHE;
    wire [8:0] axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_ID;
    wire [7:0] axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_LEN;
    wire       axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_LOCK;
    wire [2:0] axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_PROT;
    wire [3:0] axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_QOS;
    wire       axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_READY;
    wire [3:0] axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_REGION;
    wire [2:0] axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_SIZE;
    wire       axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_USER;
    wire       axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_VALID;
    wire [31:0] axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_ADDR;
    wire [5:0] axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_ATOP;
    wire [1:0] axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_BURST;
    wire [3:0] axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_CACHE;
    wire [8:0] axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_ID;
    wire [7:0] axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_LEN;
    wire       axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_LOCK;
    wire [2:0] axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_PROT;
    wire [3:0] axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_QOS;
    wire       axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_READY;
    wire [3:0] axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_REGION;
    wire [2:0] axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_SIZE;
    wire       axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_USER;
    wire       axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_VALID;
    wire [8:0] axi_cdc_intf_src_0_dst_to_marian_top_axi_master_B_ID;
    wire       axi_cdc_intf_src_0_dst_to_marian_top_axi_master_B_READY;
    wire [1:0] axi_cdc_intf_src_0_dst_to_marian_top_axi_master_B_RESP;
    wire       axi_cdc_intf_src_0_dst_to_marian_top_axi_master_B_USER;
    wire       axi_cdc_intf_src_0_dst_to_marian_top_axi_master_B_VALID;
    wire [63:0] axi_cdc_intf_src_0_dst_to_marian_top_axi_master_R_DATA;
    wire [8:0] axi_cdc_intf_src_0_dst_to_marian_top_axi_master_R_ID;
    wire       axi_cdc_intf_src_0_dst_to_marian_top_axi_master_R_LAST;
    wire       axi_cdc_intf_src_0_dst_to_marian_top_axi_master_R_READY;
    wire [1:0] axi_cdc_intf_src_0_dst_to_marian_top_axi_master_R_RESP;
    wire       axi_cdc_intf_src_0_dst_to_marian_top_axi_master_R_USER;
    wire       axi_cdc_intf_src_0_dst_to_marian_top_axi_master_R_VALID;
    wire [63:0] axi_cdc_intf_src_0_dst_to_marian_top_axi_master_W_DATA;
    wire       axi_cdc_intf_src_0_dst_to_marian_top_axi_master_W_LAST;
    wire       axi_cdc_intf_src_0_dst_to_marian_top_axi_master_W_READY;
    wire [7:0] axi_cdc_intf_src_0_dst_to_marian_top_axi_master_W_STRB;
    wire       axi_cdc_intf_src_0_dst_to_marian_top_axi_master_W_USER;
    wire       axi_cdc_intf_src_0_dst_to_marian_top_axi_master_W_VALID;
    // marian_top_axi_slave_to_axi_cdc_intf_dst_0_src wires:
    wire [31:0] marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_ADDR;
    wire [1:0] marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_BURST;
    wire [3:0] marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_CACHE;
    wire [8:0] marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_ID;
    wire [7:0] marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_LEN;
    wire       marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_LOCK;
    wire [2:0] marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_PROT;
    wire [3:0] marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_QOS;
    wire       marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_READY;
    wire [3:0] marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_REGION;
    wire [2:0] marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_SIZE;
    wire       marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_USER;
    wire       marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_VALID;
    wire [31:0] marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_ADDR;
    wire [5:0] marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_ATOP;
    wire [1:0] marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_BURST;
    wire [3:0] marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_CACHE;
    wire [8:0] marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_ID;
    wire [7:0] marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_LEN;
    wire       marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_LOCK;
    wire [2:0] marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_PROT;
    wire [3:0] marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_QOS;
    wire       marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_READY;
    wire [3:0] marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_REGION;
    wire [2:0] marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_SIZE;
    wire       marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_USER;
    wire       marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_VALID;
    wire [8:0] marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_B_ID;
    wire       marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_B_READY;
    wire [1:0] marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_B_RESP;
    wire       marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_B_USER;
    wire       marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_B_VALID;
    wire [63:0] marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_R_DATA;
    wire [8:0] marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_R_ID;
    wire       marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_R_LAST;
    wire       marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_R_READY;
    wire [1:0] marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_R_RESP;
    wire       marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_R_USER;
    wire       marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_R_VALID;
    wire [63:0] marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_W_DATA;
    wire       marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_W_LAST;
    wire       marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_W_READY;
    wire [7:0] marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_W_STRB;
    wire       marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_W_USER;
    wire       marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_W_VALID;
    // axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave wires:
    wire [70:0] axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_AR_DATA_SRC2DST;
    wire [1:0] axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_AR_RD_DATA_PTR_DST2SRC;
    wire [2:0] axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_AR_RD_PTR_GRAY_DST2SRC;
    wire [2:0] axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_AR_WR_PTR_GRAY_SRC2DST;
    wire [76:0] axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_AW_DATA_SRC2DST;
    wire [1:0] axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_AW_RD_DATA_PTR_DST2SRC;
    wire [2:0] axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_AW_RD_PTR_GRAY_DST2SRC;
    wire [2:0] axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_AW_WR_PTR_GRAY_SRC2DST;
    wire [11:0] axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_B_DATA_DST2SRC;
    wire [1:0] axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_B_RD_DATA_PTR_SRC2DST;
    wire [2:0] axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_B_RD_PTR_GRAY_SRC2DST;
    wire [2:0] axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_B_WR_PTR_GRAY_DST2SRC;
    wire [76:0] axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_R_DATA_DST2SRC;
    wire [1:0] axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_R_RD_DATA_PTR_SRC2DST;
    wire [2:0] axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_R_RD_PTR_GRAY_SRC2DST;
    wire [2:0] axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_R_WR_PTR_GRAY_DST2SRC;
    wire [73:0] axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_W_DATA_SRC2DST;
    wire [1:0] axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_W_RD_DATA_PTR_DST2SRC;
    wire [2:0] axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_W_RD_PTR_GRAY_DST2SRC;
    wire [2:0] axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_W_WR_PTR_GRAY_SRC2DST;
    // marian_top_qspi_to_qspi wires:
    wire       marian_top_qspi_to_qspi_csn;
    wire [3:0] marian_top_qspi_to_qspi_data_oe;
    wire [3:0] marian_top_qspi_to_qspi_miso;
    wire [3:0] marian_top_qspi_to_qspi_mosi;
    wire       marian_top_qspi_to_qspi_sck;

    // Ad-hoc wires:
    wire       clkpll_0_CLK_PLL_LOCK_to_subsystem_clock_control_0_pll_lock;
    wire       marian_top_marian_jtag_tdo_o_to_vcss_jtag_tdo_o;
    wire       marian_top_marian_jtag_tdi_i_to_vcss_jtag_tdi_i;

    // axi_cdc_intf_dst_0 port wires:
    wire [31:0] axi_cdc_intf_dst_0_ar_addr;
    wire [1:0] axi_cdc_intf_dst_0_ar_burst;
    wire [3:0] axi_cdc_intf_dst_0_ar_cache;
    wire [70:0] axi_cdc_intf_dst_0_ar_data_src2dst;
    wire [8:0] axi_cdc_intf_dst_0_ar_id;
    wire [7:0] axi_cdc_intf_dst_0_ar_len;
    wire       axi_cdc_intf_dst_0_ar_lock;
    wire [2:0] axi_cdc_intf_dst_0_ar_prot;
    wire [3:0] axi_cdc_intf_dst_0_ar_qos;
    wire [1:0] axi_cdc_intf_dst_0_ar_rd_data_ptr_dst2src;
    wire [2:0] axi_cdc_intf_dst_0_ar_rd_ptr_gray_dst2src;
    wire       axi_cdc_intf_dst_0_ar_ready;
    wire [3:0] axi_cdc_intf_dst_0_ar_region;
    wire [2:0] axi_cdc_intf_dst_0_ar_size;
    wire       axi_cdc_intf_dst_0_ar_user;
    wire       axi_cdc_intf_dst_0_ar_valid;
    wire [2:0] axi_cdc_intf_dst_0_ar_wr_ptr_gray_src2dst;
    wire [31:0] axi_cdc_intf_dst_0_aw_addr;
    wire [5:0] axi_cdc_intf_dst_0_aw_atop;
    wire [1:0] axi_cdc_intf_dst_0_aw_burst;
    wire [3:0] axi_cdc_intf_dst_0_aw_cache;
    wire [76:0] axi_cdc_intf_dst_0_aw_data_src2dst;
    wire [8:0] axi_cdc_intf_dst_0_aw_id;
    wire [7:0] axi_cdc_intf_dst_0_aw_len;
    wire       axi_cdc_intf_dst_0_aw_lock;
    wire [2:0] axi_cdc_intf_dst_0_aw_prot;
    wire [3:0] axi_cdc_intf_dst_0_aw_qos;
    wire [1:0] axi_cdc_intf_dst_0_aw_rd_data_ptr_dst2src;
    wire [2:0] axi_cdc_intf_dst_0_aw_rd_ptr_gray_dst2src;
    wire       axi_cdc_intf_dst_0_aw_ready;
    wire [3:0] axi_cdc_intf_dst_0_aw_region;
    wire [2:0] axi_cdc_intf_dst_0_aw_size;
    wire       axi_cdc_intf_dst_0_aw_user;
    wire       axi_cdc_intf_dst_0_aw_valid;
    wire [2:0] axi_cdc_intf_dst_0_aw_wr_ptr_gray_src2dst;
    wire [11:0] axi_cdc_intf_dst_0_b_data_dst2src;
    wire [8:0] axi_cdc_intf_dst_0_b_id;
    wire [1:0] axi_cdc_intf_dst_0_b_rd_data_ptr_src2dst;
    wire [2:0] axi_cdc_intf_dst_0_b_rd_ptr_gray_src2dst;
    wire       axi_cdc_intf_dst_0_b_ready;
    wire [1:0] axi_cdc_intf_dst_0_b_resp;
    wire       axi_cdc_intf_dst_0_b_user;
    wire       axi_cdc_intf_dst_0_b_valid;
    wire [2:0] axi_cdc_intf_dst_0_b_wr_ptr_gray_dst2src;
    wire       axi_cdc_intf_dst_0_dst_clk_i;
    wire       axi_cdc_intf_dst_0_dst_rst_ni;
    wire       axi_cdc_intf_dst_0_icn_rst_ni;
    wire [63:0] axi_cdc_intf_dst_0_r_data;
    wire [76:0] axi_cdc_intf_dst_0_r_data_dst2src;
    wire [8:0] axi_cdc_intf_dst_0_r_id;
    wire       axi_cdc_intf_dst_0_r_last;
    wire [1:0] axi_cdc_intf_dst_0_r_rd_data_ptr_src2dst;
    wire [2:0] axi_cdc_intf_dst_0_r_rd_ptr_gray_src2dst;
    wire       axi_cdc_intf_dst_0_r_ready;
    wire [1:0] axi_cdc_intf_dst_0_r_resp;
    wire       axi_cdc_intf_dst_0_r_user;
    wire       axi_cdc_intf_dst_0_r_valid;
    wire [2:0] axi_cdc_intf_dst_0_r_wr_ptr_gray_dst2src;
    wire [63:0] axi_cdc_intf_dst_0_w_data;
    wire [73:0] axi_cdc_intf_dst_0_w_data_src2dst;
    wire       axi_cdc_intf_dst_0_w_last;
    wire [1:0] axi_cdc_intf_dst_0_w_rd_data_ptr_dst2src;
    wire [2:0] axi_cdc_intf_dst_0_w_rd_ptr_gray_dst2src;
    wire       axi_cdc_intf_dst_0_w_ready;
    wire [7:0] axi_cdc_intf_dst_0_w_strb;
    wire       axi_cdc_intf_dst_0_w_user;
    wire       axi_cdc_intf_dst_0_w_valid;
    wire [2:0] axi_cdc_intf_dst_0_w_wr_ptr_gray_src2dst;
    // axi_cdc_intf_src_0 port wires:
    wire [31:0] axi_cdc_intf_src_0_ar_addr;
    wire [1:0] axi_cdc_intf_src_0_ar_burst;
    wire [3:0] axi_cdc_intf_src_0_ar_cache;
    wire [70:0] axi_cdc_intf_src_0_ar_data_src2dst;
    wire [8:0] axi_cdc_intf_src_0_ar_id;
    wire [7:0] axi_cdc_intf_src_0_ar_len;
    wire       axi_cdc_intf_src_0_ar_lock;
    wire [2:0] axi_cdc_intf_src_0_ar_prot;
    wire [3:0] axi_cdc_intf_src_0_ar_qos;
    wire [1:0] axi_cdc_intf_src_0_ar_rd_data_ptr_dst2src;
    wire [2:0] axi_cdc_intf_src_0_ar_rd_ptr_gray_dst2src;
    wire       axi_cdc_intf_src_0_ar_ready;
    wire [3:0] axi_cdc_intf_src_0_ar_region;
    wire [2:0] axi_cdc_intf_src_0_ar_size;
    wire       axi_cdc_intf_src_0_ar_user;
    wire       axi_cdc_intf_src_0_ar_valid;
    wire [2:0] axi_cdc_intf_src_0_ar_wr_ptr_gray_src2dst;
    wire [31:0] axi_cdc_intf_src_0_aw_addr;
    wire [5:0] axi_cdc_intf_src_0_aw_atop;
    wire [1:0] axi_cdc_intf_src_0_aw_burst;
    wire [3:0] axi_cdc_intf_src_0_aw_cache;
    wire [76:0] axi_cdc_intf_src_0_aw_data_src2dst;
    wire [8:0] axi_cdc_intf_src_0_aw_id;
    wire [7:0] axi_cdc_intf_src_0_aw_len;
    wire       axi_cdc_intf_src_0_aw_lock;
    wire [2:0] axi_cdc_intf_src_0_aw_prot;
    wire [3:0] axi_cdc_intf_src_0_aw_qos;
    wire [1:0] axi_cdc_intf_src_0_aw_rd_data_ptr_dst2src;
    wire [2:0] axi_cdc_intf_src_0_aw_rd_ptr_gray_dst2src;
    wire       axi_cdc_intf_src_0_aw_ready;
    wire [3:0] axi_cdc_intf_src_0_aw_region;
    wire [2:0] axi_cdc_intf_src_0_aw_size;
    wire       axi_cdc_intf_src_0_aw_user;
    wire       axi_cdc_intf_src_0_aw_valid;
    wire [2:0] axi_cdc_intf_src_0_aw_wr_ptr_gray_src2dst;
    wire [11:0] axi_cdc_intf_src_0_b_data_dst2src;
    wire [8:0] axi_cdc_intf_src_0_b_id;
    wire [1:0] axi_cdc_intf_src_0_b_rd_data_ptr_src2dst;
    wire [2:0] axi_cdc_intf_src_0_b_rd_ptr_gray_src2dst;
    wire       axi_cdc_intf_src_0_b_ready;
    wire [1:0] axi_cdc_intf_src_0_b_resp;
    wire       axi_cdc_intf_src_0_b_user;
    wire       axi_cdc_intf_src_0_b_valid;
    wire [2:0] axi_cdc_intf_src_0_b_wr_ptr_gray_dst2src;
    wire       axi_cdc_intf_src_0_icn_rst_ni;
    wire [63:0] axi_cdc_intf_src_0_r_data;
    wire [76:0] axi_cdc_intf_src_0_r_data_dst2src;
    wire [8:0] axi_cdc_intf_src_0_r_id;
    wire       axi_cdc_intf_src_0_r_last;
    wire [1:0] axi_cdc_intf_src_0_r_rd_data_ptr_src2dst;
    wire [2:0] axi_cdc_intf_src_0_r_rd_ptr_gray_src2dst;
    wire       axi_cdc_intf_src_0_r_ready;
    wire [1:0] axi_cdc_intf_src_0_r_resp;
    wire       axi_cdc_intf_src_0_r_user;
    wire       axi_cdc_intf_src_0_r_valid;
    wire [2:0] axi_cdc_intf_src_0_r_wr_ptr_gray_dst2src;
    wire       axi_cdc_intf_src_0_src_clk_i;
    wire       axi_cdc_intf_src_0_src_rst_ni;
    wire [63:0] axi_cdc_intf_src_0_w_data;
    wire [73:0] axi_cdc_intf_src_0_w_data_src2dst;
    wire       axi_cdc_intf_src_0_w_last;
    wire [1:0] axi_cdc_intf_src_0_w_rd_data_ptr_dst2src;
    wire [2:0] axi_cdc_intf_src_0_w_rd_ptr_gray_dst2src;
    wire       axi_cdc_intf_src_0_w_ready;
    wire [7:0] axi_cdc_intf_src_0_w_strb;
    wire       axi_cdc_intf_src_0_w_user;
    wire       axi_cdc_intf_src_0_w_valid;
    wire [2:0] axi_cdc_intf_src_0_w_wr_ptr_gray_src2dst;
    // clkpll_0 port wires:
    wire       clkpll_0_CLK_PLL_LOCK;
    wire       clkpll_0_CLK_PLL_OUT;
    wire       clkpll_0_CLK_REF;
    wire [7:0] clkpll_0_DEBUG_CTRL;
    wire [7:0] clkpll_0_ENABLE;
    wire [31:0] clkpll_0_LOOP_CTRL;
    wire [2:0] clkpll_0_M_DIV;
    wire [9:0] clkpll_0_N_DIV;
    wire [3:0] clkpll_0_R_DIV;
    wire [31:0] clkpll_0_SPARE_CTRL;
    wire [31:0] clkpll_0_STATUS1;
    wire [31:0] clkpll_0_STATUS2;
    wire [3:0] clkpll_0_TMUX_1_SEL;
    wire [3:0] clkpll_0_TMUX_2_SEL;
    // marian_top port wires:
    wire       marian_top_clk_i;
    wire [31:0] marian_top_marian_axi_m_ar_addr_o;
    wire [1:0] marian_top_marian_axi_m_ar_burst_o;
    wire [3:0] marian_top_marian_axi_m_ar_cache_o;
    wire [8:0] marian_top_marian_axi_m_ar_id_o;
    wire [7:0] marian_top_marian_axi_m_ar_len_o;
    wire       marian_top_marian_axi_m_ar_lock_o;
    wire [2:0] marian_top_marian_axi_m_ar_prot_o;
    wire [3:0] marian_top_marian_axi_m_ar_qos_o;
    wire       marian_top_marian_axi_m_ar_ready_i;
    wire [3:0] marian_top_marian_axi_m_ar_region_o;
    wire [2:0] marian_top_marian_axi_m_ar_size_o;
    wire       marian_top_marian_axi_m_ar_user_o;
    wire       marian_top_marian_axi_m_ar_valid_o;
    wire [31:0] marian_top_marian_axi_m_aw_addr_o;
    wire [5:0] marian_top_marian_axi_m_aw_atop_o;
    wire [1:0] marian_top_marian_axi_m_aw_burst_o;
    wire [3:0] marian_top_marian_axi_m_aw_cache_o;
    wire [8:0] marian_top_marian_axi_m_aw_id_o;
    wire [7:0] marian_top_marian_axi_m_aw_len_o;
    wire       marian_top_marian_axi_m_aw_lock_o;
    wire [2:0] marian_top_marian_axi_m_aw_prot_o;
    wire [3:0] marian_top_marian_axi_m_aw_qos_o;
    wire       marian_top_marian_axi_m_aw_ready_i;
    wire [3:0] marian_top_marian_axi_m_aw_region_o;
    wire [2:0] marian_top_marian_axi_m_aw_size_o;
    wire       marian_top_marian_axi_m_aw_user_o;
    wire       marian_top_marian_axi_m_aw_valid_o;
    wire [8:0] marian_top_marian_axi_m_b_id_i;
    wire       marian_top_marian_axi_m_b_ready_o;
    wire [1:0] marian_top_marian_axi_m_b_resp_i;
    wire       marian_top_marian_axi_m_b_user_i;
    wire       marian_top_marian_axi_m_b_valid_i;
    wire [63:0] marian_top_marian_axi_m_r_data_i;
    wire [8:0] marian_top_marian_axi_m_r_id_i;
    wire       marian_top_marian_axi_m_r_last_i;
    wire       marian_top_marian_axi_m_r_ready_o;
    wire [1:0] marian_top_marian_axi_m_r_resp_i;
    wire       marian_top_marian_axi_m_r_user_i;
    wire       marian_top_marian_axi_m_r_valid_i;
    wire [63:0] marian_top_marian_axi_m_w_data_o;
    wire       marian_top_marian_axi_m_w_last_o;
    wire       marian_top_marian_axi_m_w_ready_i;
    wire [7:0] marian_top_marian_axi_m_w_strb_o;
    wire       marian_top_marian_axi_m_w_user_o;
    wire       marian_top_marian_axi_m_w_valid_o;
    wire [31:0] marian_top_marian_axi_s_ar_addr_i;
    wire [1:0] marian_top_marian_axi_s_ar_burst_i;
    wire [3:0] marian_top_marian_axi_s_ar_cache_i;
    wire [8:0] marian_top_marian_axi_s_ar_id_i;
    wire [7:0] marian_top_marian_axi_s_ar_len_i;
    wire       marian_top_marian_axi_s_ar_lock_i;
    wire [2:0] marian_top_marian_axi_s_ar_prot_i;
    wire [3:0] marian_top_marian_axi_s_ar_qos_i;
    wire       marian_top_marian_axi_s_ar_ready_o;
    wire [3:0] marian_top_marian_axi_s_ar_region_i;
    wire [2:0] marian_top_marian_axi_s_ar_size_i;
    wire       marian_top_marian_axi_s_ar_user_i;
    wire       marian_top_marian_axi_s_ar_valid_i;
    wire [31:0] marian_top_marian_axi_s_aw_addr_i;
    wire [5:0] marian_top_marian_axi_s_aw_atop_i;
    wire [1:0] marian_top_marian_axi_s_aw_burst_i;
    wire [3:0] marian_top_marian_axi_s_aw_cache_i;
    wire [8:0] marian_top_marian_axi_s_aw_id_i;
    wire [7:0] marian_top_marian_axi_s_aw_len_i;
    wire       marian_top_marian_axi_s_aw_lock_i;
    wire [2:0] marian_top_marian_axi_s_aw_prot_i;
    wire [3:0] marian_top_marian_axi_s_aw_qos_i;
    wire       marian_top_marian_axi_s_aw_ready_o;
    wire [3:0] marian_top_marian_axi_s_aw_region_i;
    wire [2:0] marian_top_marian_axi_s_aw_size_i;
    wire       marian_top_marian_axi_s_aw_user_i;
    wire       marian_top_marian_axi_s_aw_valid_i;
    wire [8:0] marian_top_marian_axi_s_b_id_o;
    wire       marian_top_marian_axi_s_b_ready_i;
    wire [1:0] marian_top_marian_axi_s_b_resp_o;
    wire       marian_top_marian_axi_s_b_user_o;
    wire       marian_top_marian_axi_s_b_valid_o;
    wire [63:0] marian_top_marian_axi_s_r_data_o;
    wire [8:0] marian_top_marian_axi_s_r_id_o;
    wire       marian_top_marian_axi_s_r_last_o;
    wire       marian_top_marian_axi_s_r_ready_i;
    wire [1:0] marian_top_marian_axi_s_r_resp_o;
    wire       marian_top_marian_axi_s_r_user_o;
    wire       marian_top_marian_axi_s_r_valid_o;
    wire [63:0] marian_top_marian_axi_s_w_data_i;
    wire       marian_top_marian_axi_s_w_last_i;
    wire       marian_top_marian_axi_s_w_ready_o;
    wire [7:0] marian_top_marian_axi_s_w_strb_i;
    wire       marian_top_marian_axi_s_w_user_i;
    wire       marian_top_marian_axi_s_w_valid_i;
    wire       marian_top_marian_ext_irq_i;
    wire       marian_top_marian_ext_irq_o;
    wire [1:0] marian_top_marian_gpio_i;
    wire [1:0] marian_top_marian_gpio_o;
    wire [1:0] marian_top_marian_gpio_oe;
    wire       marian_top_marian_jtag_tck_i;
    wire       marian_top_marian_jtag_tdi_i;
    wire       marian_top_marian_jtag_tdo_o;
    wire       marian_top_marian_jtag_tms_i;
    wire       marian_top_marian_jtag_trstn_i;
    wire       marian_top_marian_qspi_csn_o;
    wire [3:0] marian_top_marian_qspi_data_i;
    wire [3:0] marian_top_marian_qspi_data_o;
    wire [3:0] marian_top_marian_qspi_oe;
    wire       marian_top_marian_qspi_sclk_o;
    wire       marian_top_marian_uart_rx_i;
    wire       marian_top_marian_uart_tx_o;
    wire       marian_top_rst_ni;
    // subsystem_clock_control_0 port wires:
    wire       subsystem_clock_control_0_clk_out;
    wire       subsystem_clock_control_0_force_cka;
    wire       subsystem_clock_control_0_force_ckb;
    wire [104:0] subsystem_clock_control_0_pll_ctrl_in;
    wire [104:0] subsystem_clock_control_0_pll_ctrl_out;
    wire       subsystem_clock_control_0_pll_ctrl_valid;
    wire       subsystem_clock_control_0_pll_lock;
    wire       subsystem_clock_control_0_pllclk;
    wire       subsystem_clock_control_0_refclk;
    wire       subsystem_clock_control_0_refrstn;
    wire       subsystem_clock_control_0_rstn_out;
    wire       subsystem_clock_control_0_sel_cka;
    wire       subsystem_clock_control_0_subsys_clkena;

    // Assignments for the ports of the encompassing component:
    assign vcss_64b_m_ar_data_src2dst_o = axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_AR_DATA_SRC2DST;
    assign axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_AR_RD_DATA_PTR_DST2SRC = vcss_64b_m_ar_rd_data_ptr_dst2src_i;
    assign axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_AR_RD_PTR_GRAY_DST2SRC = vcss_64b_m_ar_rd_ptr_gray_dst2src_i;
    assign vcss_64b_m_ar_wr_ptr_gray_src2dst_o = axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_AR_WR_PTR_GRAY_SRC2DST;
    assign vcss_64b_m_aw_data_src2dst_o = axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_AW_DATA_SRC2DST;
    assign axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_AW_RD_DATA_PTR_DST2SRC = vcss_64b_m_aw_rd_data_ptr_dst2src_i;
    assign axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_AW_RD_PTR_GRAY_DST2SRC = vcss_64b_m_aw_rd_ptr_gray_dst2src_i;
    assign vcss_64b_m_aw_wr_ptr_gray_src2dst_o = axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_AW_WR_PTR_GRAY_SRC2DST;
    assign axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_B_DATA_DST2SRC = vcss_64b_m_b_data_dst2src_i;
    assign vcss_64b_m_b_rd_data_ptr_src2dst_o = axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_B_RD_DATA_PTR_SRC2DST;
    assign vcss_64b_m_b_rd_ptr_gray_src2dst_o = axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_B_RD_PTR_GRAY_SRC2DST;
    assign axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_B_WR_PTR_GRAY_DST2SRC = vcss_64b_m_b_wr_ptr_gray_dst2src_i;
    assign axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_R_DATA_DST2SRC = vcss_64b_m_r_data_dst2src_i;
    assign vcss_64b_m_r_rd_data_ptr_src2dst_o = axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_R_RD_DATA_PTR_SRC2DST;
    assign vcss_64b_m_r_rd_ptr_gray_src2dst_o = axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_R_RD_PTR_GRAY_SRC2DST;
    assign axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_R_WR_PTR_GRAY_DST2SRC = vcss_64b_m_r_wr_ptr_gray_dst2src_i;
    assign vcss_64b_m_w_data_src2dst_o = axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_W_DATA_SRC2DST;
    assign axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_W_RD_DATA_PTR_DST2SRC = vcss_64b_m_w_rd_data_ptr_dst2src_i;
    assign axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_W_RD_PTR_GRAY_DST2SRC = vcss_64b_m_w_rd_ptr_gray_dst2src_i;
    assign vcss_64b_m_w_wr_ptr_gray_src2dst_o = axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_W_WR_PTR_GRAY_SRC2DST;
    assign axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_AR_DATA_SRC2DST = vcss_64b_s_ar_data_src2dst_i;
    assign vcss_64b_s_ar_rd_data_ptr_dst2src_o = axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_AR_RD_DATA_PTR_DST2SRC;
    assign vcss_64b_s_ar_rd_ptr_gray_dst2src_o = axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_AR_RD_PTR_GRAY_DST2SRC;
    assign axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_AR_WR_PTR_GRAY_SRC2DST = vcss_64b_s_ar_wr_ptr_gray_src2dst_i;
    assign axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_AW_DATA_SRC2DST = vcss_64b_s_aw_data_src2dst_i;
    assign vcss_64b_s_aw_rd_data_ptr_dst2src_o = axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_AW_RD_DATA_PTR_DST2SRC;
    assign vcss_64b_s_aw_rd_ptr_gray_dst2src_o = axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_AW_RD_PTR_GRAY_DST2SRC;
    assign axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_AW_WR_PTR_GRAY_SRC2DST = vcss_64b_s_aw_wr_ptr_gray_src2dst_i;
    assign vcss_64b_s_b_data_dst2src_o = axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_B_DATA_DST2SRC;
    assign axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_B_RD_DATA_PTR_SRC2DST = vcss_64b_s_b_rd_data_ptr_src2dst_i;
    assign axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_B_RD_PTR_GRAY_SRC2DST = vcss_64b_s_b_rd_ptr_gray_src2dst_i;
    assign vcss_64b_s_b_wr_ptr_gray_dst2src_o = axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_B_WR_PTR_GRAY_DST2SRC;
    assign vcss_64b_s_r_data_dst2src_o = axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_R_DATA_DST2SRC;
    assign axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_R_RD_DATA_PTR_SRC2DST = vcss_64b_s_r_rd_data_ptr_src2dst_i;
    assign axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_R_RD_PTR_GRAY_SRC2DST = vcss_64b_s_r_rd_ptr_gray_src2dst_i;
    assign vcss_64b_s_r_wr_ptr_gray_dst2src_o = axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_R_WR_PTR_GRAY_DST2SRC;
    assign axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_W_DATA_SRC2DST = vcss_64b_s_w_data_src2dst_i;
    assign vcss_64b_s_w_rd_data_ptr_dst2src_o = axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_W_RD_DATA_PTR_DST2SRC;
    assign vcss_64b_s_w_rd_ptr_gray_dst2src_o = axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_W_RD_PTR_GRAY_DST2SRC;
    assign axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_W_WR_PTR_GRAY_SRC2DST = vcss_64b_s_w_wr_ptr_gray_src2dst_i;
    assign subsystem_clock_control_0_clk_ctrl_to_clk_ctrl_CLK_CTRL = vcss_clk_ctrl_i;
    assign marian_top_irq_i_to_irq_i_IRQ = vcss_ext_irq_i;
    assign vcss_ext_irq_o = marian_top_irq_o_to_irq_o_IRQ;
    assign marian_top_gpio_to_gpio_gpio_core = vcss_gpio_i;
    assign vcss_gpio_o = marian_top_gpio_to_gpio_gpio_offchip;
    assign vcss_gpio_oe_o = marian_top_gpio_to_gpio_gpio_oe;
    assign marian_top_jtag_to_jtag_TCK = vcss_jtag_tck_i;
    assign marian_top_marian_jtag_tdi_i_to_vcss_jtag_tdi_i = vcss_jtag_tdi_i;
    assign vcss_jtag_tdo_o = marian_top_marian_jtag_tdo_o_to_vcss_jtag_tdo_o;
    assign marian_top_jtag_to_jtag_TMS = vcss_jtag_tms_i;
    assign marian_top_jtag_to_jtag_TRST = vcss_jtag_trst_i;
    assign subsystem_clock_control_0_pll_ctrl_to_pll_ctrl_DEBUG_CTRL = vcss_pll_debug_ctrl_i;
    assign subsystem_clock_control_0_pll_ctrl_to_pll_ctrl_DIV = vcss_pll_div_i;
    assign subsystem_clock_control_0_pll_ctrl_to_pll_ctrl_ENABLE = vcss_pll_enable_i;
    assign subsystem_clock_control_0_pll_ctrl_to_pll_ctrl_LOOP_CTRL = vcss_pll_loop_ctrl_i;
    assign subsystem_clock_control_0_pll_ctrl_to_pll_ctrl_SPARE_CTRL = vcss_pll_spare_ctrl_i;
    assign vcss_pll_status_1_o = clkpll_0_pll_status_to_pll_status_pll_status_1;
    assign vcss_pll_status_2_o = clkpll_0_pll_status_to_pll_status_pll_status_2;
    assign subsystem_clock_control_0_pll_ctrl_to_pll_ctrl_TMUX_SEL = vcss_pll_tmux_sel_i;
    assign subsystem_clock_control_0_pll_ctrl_to_pll_ctrl_VALID = vcss_pll_valid_i;
    assign vcss_qspi_csn_o = marian_top_qspi_to_qspi_csn;
    assign marian_top_qspi_to_qspi_miso[2] = vcss_qspi_data_i[2];
    assign marian_top_qspi_to_qspi_miso[1] = vcss_qspi_data_i[1];
    assign marian_top_qspi_to_qspi_miso[0] = vcss_qspi_data_i[0];
    assign marian_top_qspi_to_qspi_miso[3] = vcss_qspi_data_i[3];
    assign vcss_qspi_data_o[2] = marian_top_qspi_to_qspi_mosi[2];
    assign vcss_qspi_data_o[1] = marian_top_qspi_to_qspi_mosi[1];
    assign vcss_qspi_data_o[0] = marian_top_qspi_to_qspi_mosi[0];
    assign vcss_qspi_data_o[3] = marian_top_qspi_to_qspi_mosi[3];
    assign vcss_qspi_oe_o[3] = marian_top_qspi_to_qspi_data_oe[3];
    assign vcss_qspi_oe_o[0] = marian_top_qspi_to_qspi_data_oe[0];
    assign vcss_qspi_oe_o[1] = marian_top_qspi_to_qspi_data_oe[1];
    assign vcss_qspi_oe_o[2] = marian_top_qspi_to_qspi_data_oe[2];
    assign vcss_qspi_sclk_o = marian_top_qspi_to_qspi_sck;
    assign subsystem_clock_control_0_ref_rstn_to_ref_rst_n_rst_n = vcss_ref_rst_ni;
    assign subsystem_clock_control_0_ref_clk_to_ref_clk_clk = vcss_refclk_i;
    assign axi_cdc_intf_dst_0_icn_rstn_to_icn_rst_n_rst_n = vcss_rst_ni;
    assign marian_top_uart_to_uart_uart_rx = vcss_uart_rx_i;
    assign vcss_uart_tx_o = marian_top_uart_to_uart_uart_tx;

    // axi_cdc_intf_dst_0 assignments:
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_ADDR = axi_cdc_intf_dst_0_ar_addr;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_BURST = axi_cdc_intf_dst_0_ar_burst;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_CACHE = axi_cdc_intf_dst_0_ar_cache;
    assign axi_cdc_intf_dst_0_ar_data_src2dst = axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_AR_DATA_SRC2DST;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_ID = axi_cdc_intf_dst_0_ar_id;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_LEN = axi_cdc_intf_dst_0_ar_len;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_LOCK = axi_cdc_intf_dst_0_ar_lock;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_PROT = axi_cdc_intf_dst_0_ar_prot;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_QOS = axi_cdc_intf_dst_0_ar_qos;
    assign axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_AR_RD_DATA_PTR_DST2SRC = axi_cdc_intf_dst_0_ar_rd_data_ptr_dst2src;
    assign axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_AR_RD_PTR_GRAY_DST2SRC = axi_cdc_intf_dst_0_ar_rd_ptr_gray_dst2src;
    assign axi_cdc_intf_dst_0_ar_ready = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_READY;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_REGION = axi_cdc_intf_dst_0_ar_region;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_SIZE = axi_cdc_intf_dst_0_ar_size;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_USER = axi_cdc_intf_dst_0_ar_user;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_VALID = axi_cdc_intf_dst_0_ar_valid;
    assign axi_cdc_intf_dst_0_ar_wr_ptr_gray_src2dst = axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_AR_WR_PTR_GRAY_SRC2DST;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_ADDR = axi_cdc_intf_dst_0_aw_addr;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_ATOP = axi_cdc_intf_dst_0_aw_atop;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_BURST = axi_cdc_intf_dst_0_aw_burst;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_CACHE = axi_cdc_intf_dst_0_aw_cache;
    assign axi_cdc_intf_dst_0_aw_data_src2dst = axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_AW_DATA_SRC2DST;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_ID = axi_cdc_intf_dst_0_aw_id;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_LEN = axi_cdc_intf_dst_0_aw_len;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_LOCK = axi_cdc_intf_dst_0_aw_lock;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_PROT = axi_cdc_intf_dst_0_aw_prot;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_QOS = axi_cdc_intf_dst_0_aw_qos;
    assign axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_AW_RD_DATA_PTR_DST2SRC = axi_cdc_intf_dst_0_aw_rd_data_ptr_dst2src;
    assign axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_AW_RD_PTR_GRAY_DST2SRC = axi_cdc_intf_dst_0_aw_rd_ptr_gray_dst2src;
    assign axi_cdc_intf_dst_0_aw_ready = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_READY;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_REGION = axi_cdc_intf_dst_0_aw_region;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_SIZE = axi_cdc_intf_dst_0_aw_size;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_USER = axi_cdc_intf_dst_0_aw_user;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_VALID = axi_cdc_intf_dst_0_aw_valid;
    assign axi_cdc_intf_dst_0_aw_wr_ptr_gray_src2dst = axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_AW_WR_PTR_GRAY_SRC2DST;
    assign axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_B_DATA_DST2SRC = axi_cdc_intf_dst_0_b_data_dst2src;
    assign axi_cdc_intf_dst_0_b_id = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_B_ID;
    assign axi_cdc_intf_dst_0_b_rd_data_ptr_src2dst = axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_B_RD_DATA_PTR_SRC2DST;
    assign axi_cdc_intf_dst_0_b_rd_ptr_gray_src2dst = axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_B_RD_PTR_GRAY_SRC2DST;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_B_READY = axi_cdc_intf_dst_0_b_ready;
    assign axi_cdc_intf_dst_0_b_resp = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_B_RESP;
    assign axi_cdc_intf_dst_0_b_user = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_B_USER;
    assign axi_cdc_intf_dst_0_b_valid = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_B_VALID;
    assign axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_B_WR_PTR_GRAY_DST2SRC = axi_cdc_intf_dst_0_b_wr_ptr_gray_dst2src;
    assign axi_cdc_intf_dst_0_dst_clk_i = subsystem_clock_control_0_clk_to_marian_top_clk_clk;
    assign axi_cdc_intf_dst_0_dst_rst_ni = subsystem_clock_control_0_rst_n_to_marian_top_rst_ni_rst_n;
    assign axi_cdc_intf_dst_0_icn_rst_ni = axi_cdc_intf_dst_0_icn_rstn_to_icn_rst_n_rst_n;
    assign axi_cdc_intf_dst_0_r_data = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_R_DATA;
    assign axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_R_DATA_DST2SRC = axi_cdc_intf_dst_0_r_data_dst2src;
    assign axi_cdc_intf_dst_0_r_id = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_R_ID;
    assign axi_cdc_intf_dst_0_r_last = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_R_LAST;
    assign axi_cdc_intf_dst_0_r_rd_data_ptr_src2dst = axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_R_RD_DATA_PTR_SRC2DST;
    assign axi_cdc_intf_dst_0_r_rd_ptr_gray_src2dst = axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_R_RD_PTR_GRAY_SRC2DST;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_R_READY = axi_cdc_intf_dst_0_r_ready;
    assign axi_cdc_intf_dst_0_r_resp = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_R_RESP;
    assign axi_cdc_intf_dst_0_r_user = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_R_USER;
    assign axi_cdc_intf_dst_0_r_valid = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_R_VALID;
    assign axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_R_WR_PTR_GRAY_DST2SRC = axi_cdc_intf_dst_0_r_wr_ptr_gray_dst2src;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_W_DATA = axi_cdc_intf_dst_0_w_data;
    assign axi_cdc_intf_dst_0_w_data_src2dst = axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_W_DATA_SRC2DST;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_W_LAST = axi_cdc_intf_dst_0_w_last;
    assign axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_W_RD_DATA_PTR_DST2SRC = axi_cdc_intf_dst_0_w_rd_data_ptr_dst2src;
    assign axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_W_RD_PTR_GRAY_DST2SRC = axi_cdc_intf_dst_0_w_rd_ptr_gray_dst2src;
    assign axi_cdc_intf_dst_0_w_ready = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_W_READY;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_W_STRB = axi_cdc_intf_dst_0_w_strb;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_W_USER = axi_cdc_intf_dst_0_w_user;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_W_VALID = axi_cdc_intf_dst_0_w_valid;
    assign axi_cdc_intf_dst_0_w_wr_ptr_gray_src2dst = axi_cdc_intf_dst_0_dst_to_axi_cdc_64b_slave_W_WR_PTR_GRAY_SRC2DST;
    // axi_cdc_intf_src_0 assignments:
    assign axi_cdc_intf_src_0_ar_addr = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_ADDR;
    assign axi_cdc_intf_src_0_ar_burst = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_BURST;
    assign axi_cdc_intf_src_0_ar_cache = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_CACHE;
    assign axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_AR_DATA_SRC2DST = axi_cdc_intf_src_0_ar_data_src2dst;
    assign axi_cdc_intf_src_0_ar_id = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_ID;
    assign axi_cdc_intf_src_0_ar_len = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_LEN;
    assign axi_cdc_intf_src_0_ar_lock = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_LOCK;
    assign axi_cdc_intf_src_0_ar_prot = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_PROT;
    assign axi_cdc_intf_src_0_ar_qos = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_QOS;
    assign axi_cdc_intf_src_0_ar_rd_data_ptr_dst2src = axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_AR_RD_DATA_PTR_DST2SRC;
    assign axi_cdc_intf_src_0_ar_rd_ptr_gray_dst2src = axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_AR_RD_PTR_GRAY_DST2SRC;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_READY = axi_cdc_intf_src_0_ar_ready;
    assign axi_cdc_intf_src_0_ar_region = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_REGION;
    assign axi_cdc_intf_src_0_ar_size = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_SIZE;
    assign axi_cdc_intf_src_0_ar_user = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_USER;
    assign axi_cdc_intf_src_0_ar_valid = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_VALID;
    assign axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_AR_WR_PTR_GRAY_SRC2DST = axi_cdc_intf_src_0_ar_wr_ptr_gray_src2dst;
    assign axi_cdc_intf_src_0_aw_addr = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_ADDR;
    assign axi_cdc_intf_src_0_aw_atop = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_ATOP;
    assign axi_cdc_intf_src_0_aw_burst = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_BURST;
    assign axi_cdc_intf_src_0_aw_cache = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_CACHE;
    assign axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_AW_DATA_SRC2DST = axi_cdc_intf_src_0_aw_data_src2dst;
    assign axi_cdc_intf_src_0_aw_id = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_ID;
    assign axi_cdc_intf_src_0_aw_len = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_LEN;
    assign axi_cdc_intf_src_0_aw_lock = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_LOCK;
    assign axi_cdc_intf_src_0_aw_prot = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_PROT;
    assign axi_cdc_intf_src_0_aw_qos = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_QOS;
    assign axi_cdc_intf_src_0_aw_rd_data_ptr_dst2src = axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_AW_RD_DATA_PTR_DST2SRC;
    assign axi_cdc_intf_src_0_aw_rd_ptr_gray_dst2src = axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_AW_RD_PTR_GRAY_DST2SRC;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_READY = axi_cdc_intf_src_0_aw_ready;
    assign axi_cdc_intf_src_0_aw_region = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_REGION;
    assign axi_cdc_intf_src_0_aw_size = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_SIZE;
    assign axi_cdc_intf_src_0_aw_user = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_USER;
    assign axi_cdc_intf_src_0_aw_valid = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_VALID;
    assign axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_AW_WR_PTR_GRAY_SRC2DST = axi_cdc_intf_src_0_aw_wr_ptr_gray_src2dst;
    assign axi_cdc_intf_src_0_b_data_dst2src = axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_B_DATA_DST2SRC;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_B_ID = axi_cdc_intf_src_0_b_id;
    assign axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_B_RD_DATA_PTR_SRC2DST = axi_cdc_intf_src_0_b_rd_data_ptr_src2dst;
    assign axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_B_RD_PTR_GRAY_SRC2DST = axi_cdc_intf_src_0_b_rd_ptr_gray_src2dst;
    assign axi_cdc_intf_src_0_b_ready = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_B_READY;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_B_RESP = axi_cdc_intf_src_0_b_resp;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_B_USER = axi_cdc_intf_src_0_b_user;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_B_VALID = axi_cdc_intf_src_0_b_valid;
    assign axi_cdc_intf_src_0_b_wr_ptr_gray_dst2src = axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_B_WR_PTR_GRAY_DST2SRC;
    assign axi_cdc_intf_src_0_icn_rst_ni = axi_cdc_intf_dst_0_icn_rstn_to_icn_rst_n_rst_n;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_R_DATA = axi_cdc_intf_src_0_r_data;
    assign axi_cdc_intf_src_0_r_data_dst2src = axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_R_DATA_DST2SRC;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_R_ID = axi_cdc_intf_src_0_r_id;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_R_LAST = axi_cdc_intf_src_0_r_last;
    assign axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_R_RD_DATA_PTR_SRC2DST = axi_cdc_intf_src_0_r_rd_data_ptr_src2dst;
    assign axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_R_RD_PTR_GRAY_SRC2DST = axi_cdc_intf_src_0_r_rd_ptr_gray_src2dst;
    assign axi_cdc_intf_src_0_r_ready = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_R_READY;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_R_RESP = axi_cdc_intf_src_0_r_resp;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_R_USER = axi_cdc_intf_src_0_r_user;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_R_VALID = axi_cdc_intf_src_0_r_valid;
    assign axi_cdc_intf_src_0_r_wr_ptr_gray_dst2src = axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_R_WR_PTR_GRAY_DST2SRC;
    assign axi_cdc_intf_src_0_src_clk_i = subsystem_clock_control_0_clk_to_marian_top_clk_clk;
    assign axi_cdc_intf_src_0_src_rst_ni = subsystem_clock_control_0_rst_n_to_marian_top_rst_ni_rst_n;
    assign axi_cdc_intf_src_0_w_data = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_W_DATA;
    assign axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_W_DATA_SRC2DST = axi_cdc_intf_src_0_w_data_src2dst;
    assign axi_cdc_intf_src_0_w_last = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_W_LAST;
    assign axi_cdc_intf_src_0_w_rd_data_ptr_dst2src = axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_W_RD_DATA_PTR_DST2SRC;
    assign axi_cdc_intf_src_0_w_rd_ptr_gray_dst2src = axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_W_RD_PTR_GRAY_DST2SRC;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_W_READY = axi_cdc_intf_src_0_w_ready;
    assign axi_cdc_intf_src_0_w_strb = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_W_STRB;
    assign axi_cdc_intf_src_0_w_user = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_W_USER;
    assign axi_cdc_intf_src_0_w_valid = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_W_VALID;
    assign axi_cdc_intf_src_0_src_to_axi_cdc_64b_master_W_WR_PTR_GRAY_SRC2DST = axi_cdc_intf_src_0_w_wr_ptr_gray_src2dst;
    // clkpll_0 assignments:
    assign clkpll_0_CLK_PLL_LOCK_to_subsystem_clock_control_0_pll_lock = clkpll_0_CLK_PLL_LOCK;
    assign clkpll_0_pll_clk_to_subsystem_clock_control_0_pll_clk_clk = clkpll_0_CLK_PLL_OUT;
    assign clkpll_0_CLK_REF = subsystem_clock_control_0_ref_clk_to_ref_clk_clk;
    assign clkpll_0_DEBUG_CTRL = subsystem_clock_control_0_pll_ctrl_latched_to_clkpll_0_pll_ctrl_latched_DEBUG_CTRL;
    assign clkpll_0_ENABLE = subsystem_clock_control_0_pll_ctrl_latched_to_clkpll_0_pll_ctrl_latched_ENABLE;
    assign clkpll_0_LOOP_CTRL = subsystem_clock_control_0_pll_ctrl_latched_to_clkpll_0_pll_ctrl_latched_LOOP_CTRL;
    assign clkpll_0_M_DIV[2:0] = subsystem_clock_control_0_pll_ctrl_latched_to_clkpll_0_pll_ctrl_latched_DIV[16:14];
    assign clkpll_0_N_DIV[9:0] = subsystem_clock_control_0_pll_ctrl_latched_to_clkpll_0_pll_ctrl_latched_DIV[13:4];
    assign clkpll_0_R_DIV = subsystem_clock_control_0_pll_ctrl_latched_to_clkpll_0_pll_ctrl_latched_DIV[3:0];
    assign clkpll_0_SPARE_CTRL = subsystem_clock_control_0_pll_ctrl_latched_to_clkpll_0_pll_ctrl_latched_SPARE_CTRL;
    assign clkpll_0_pll_status_to_pll_status_pll_status_1 = clkpll_0_STATUS1;
    assign clkpll_0_pll_status_to_pll_status_pll_status_2 = clkpll_0_STATUS2;
    assign clkpll_0_TMUX_1_SEL = subsystem_clock_control_0_pll_ctrl_latched_to_clkpll_0_pll_ctrl_latched_TMUX_SEL[3:0];
    assign clkpll_0_TMUX_2_SEL[3:0] = subsystem_clock_control_0_pll_ctrl_latched_to_clkpll_0_pll_ctrl_latched_TMUX_SEL[7:4];
    // marian_top assignments:
    assign marian_top_clk_i = subsystem_clock_control_0_clk_to_marian_top_clk_clk;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_ADDR = marian_top_marian_axi_m_ar_addr_o;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_BURST = marian_top_marian_axi_m_ar_burst_o;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_CACHE = marian_top_marian_axi_m_ar_cache_o;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_ID = marian_top_marian_axi_m_ar_id_o;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_LEN = marian_top_marian_axi_m_ar_len_o;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_LOCK = marian_top_marian_axi_m_ar_lock_o;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_PROT = marian_top_marian_axi_m_ar_prot_o;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_QOS = marian_top_marian_axi_m_ar_qos_o;
    assign marian_top_marian_axi_m_ar_ready_i = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_READY;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_REGION = marian_top_marian_axi_m_ar_region_o;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_SIZE = marian_top_marian_axi_m_ar_size_o;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_USER = marian_top_marian_axi_m_ar_user_o;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AR_VALID = marian_top_marian_axi_m_ar_valid_o;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_ADDR = marian_top_marian_axi_m_aw_addr_o;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_ATOP = marian_top_marian_axi_m_aw_atop_o;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_BURST = marian_top_marian_axi_m_aw_burst_o;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_CACHE = marian_top_marian_axi_m_aw_cache_o;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_ID = marian_top_marian_axi_m_aw_id_o;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_LEN = marian_top_marian_axi_m_aw_len_o;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_LOCK = marian_top_marian_axi_m_aw_lock_o;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_PROT = marian_top_marian_axi_m_aw_prot_o;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_QOS = marian_top_marian_axi_m_aw_qos_o;
    assign marian_top_marian_axi_m_aw_ready_i = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_READY;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_REGION = marian_top_marian_axi_m_aw_region_o;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_SIZE = marian_top_marian_axi_m_aw_size_o;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_USER = marian_top_marian_axi_m_aw_user_o;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_AW_VALID = marian_top_marian_axi_m_aw_valid_o;
    assign marian_top_marian_axi_m_b_id_i = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_B_ID;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_B_READY = marian_top_marian_axi_m_b_ready_o;
    assign marian_top_marian_axi_m_b_resp_i = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_B_RESP;
    assign marian_top_marian_axi_m_b_user_i = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_B_USER;
    assign marian_top_marian_axi_m_b_valid_i = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_B_VALID;
    assign marian_top_marian_axi_m_r_data_i = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_R_DATA;
    assign marian_top_marian_axi_m_r_id_i = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_R_ID;
    assign marian_top_marian_axi_m_r_last_i = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_R_LAST;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_R_READY = marian_top_marian_axi_m_r_ready_o;
    assign marian_top_marian_axi_m_r_resp_i = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_R_RESP;
    assign marian_top_marian_axi_m_r_user_i = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_R_USER;
    assign marian_top_marian_axi_m_r_valid_i = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_R_VALID;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_W_DATA = marian_top_marian_axi_m_w_data_o;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_W_LAST = marian_top_marian_axi_m_w_last_o;
    assign marian_top_marian_axi_m_w_ready_i = axi_cdc_intf_src_0_dst_to_marian_top_axi_master_W_READY;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_W_STRB = marian_top_marian_axi_m_w_strb_o;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_W_USER = marian_top_marian_axi_m_w_user_o;
    assign axi_cdc_intf_src_0_dst_to_marian_top_axi_master_W_VALID = marian_top_marian_axi_m_w_valid_o;
    assign marian_top_marian_axi_s_ar_addr_i = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_ADDR;
    assign marian_top_marian_axi_s_ar_burst_i = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_BURST;
    assign marian_top_marian_axi_s_ar_cache_i = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_CACHE;
    assign marian_top_marian_axi_s_ar_id_i = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_ID;
    assign marian_top_marian_axi_s_ar_len_i = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_LEN;
    assign marian_top_marian_axi_s_ar_lock_i = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_LOCK;
    assign marian_top_marian_axi_s_ar_prot_i = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_PROT;
    assign marian_top_marian_axi_s_ar_qos_i = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_QOS;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_READY = marian_top_marian_axi_s_ar_ready_o;
    assign marian_top_marian_axi_s_ar_region_i = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_REGION;
    assign marian_top_marian_axi_s_ar_size_i = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_SIZE;
    assign marian_top_marian_axi_s_ar_user_i = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_USER;
    assign marian_top_marian_axi_s_ar_valid_i = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AR_VALID;
    assign marian_top_marian_axi_s_aw_addr_i = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_ADDR;
    assign marian_top_marian_axi_s_aw_atop_i = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_ATOP;
    assign marian_top_marian_axi_s_aw_burst_i = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_BURST;
    assign marian_top_marian_axi_s_aw_cache_i = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_CACHE;
    assign marian_top_marian_axi_s_aw_id_i = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_ID;
    assign marian_top_marian_axi_s_aw_len_i = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_LEN;
    assign marian_top_marian_axi_s_aw_lock_i = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_LOCK;
    assign marian_top_marian_axi_s_aw_prot_i = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_PROT;
    assign marian_top_marian_axi_s_aw_qos_i = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_QOS;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_READY = marian_top_marian_axi_s_aw_ready_o;
    assign marian_top_marian_axi_s_aw_region_i = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_REGION;
    assign marian_top_marian_axi_s_aw_size_i = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_SIZE;
    assign marian_top_marian_axi_s_aw_user_i = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_USER;
    assign marian_top_marian_axi_s_aw_valid_i = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_AW_VALID;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_B_ID = marian_top_marian_axi_s_b_id_o;
    assign marian_top_marian_axi_s_b_ready_i = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_B_READY;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_B_RESP = marian_top_marian_axi_s_b_resp_o;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_B_USER = marian_top_marian_axi_s_b_user_o;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_B_VALID = marian_top_marian_axi_s_b_valid_o;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_R_DATA = marian_top_marian_axi_s_r_data_o;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_R_ID = marian_top_marian_axi_s_r_id_o;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_R_LAST = marian_top_marian_axi_s_r_last_o;
    assign marian_top_marian_axi_s_r_ready_i = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_R_READY;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_R_RESP = marian_top_marian_axi_s_r_resp_o;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_R_USER = marian_top_marian_axi_s_r_user_o;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_R_VALID = marian_top_marian_axi_s_r_valid_o;
    assign marian_top_marian_axi_s_w_data_i = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_W_DATA;
    assign marian_top_marian_axi_s_w_last_i = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_W_LAST;
    assign marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_W_READY = marian_top_marian_axi_s_w_ready_o;
    assign marian_top_marian_axi_s_w_strb_i = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_W_STRB;
    assign marian_top_marian_axi_s_w_user_i = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_W_USER;
    assign marian_top_marian_axi_s_w_valid_i = marian_top_axi_slave_to_axi_cdc_intf_dst_0_src_W_VALID;
    assign marian_top_marian_ext_irq_i = marian_top_irq_i_to_irq_i_IRQ;
    assign marian_top_irq_o_to_irq_o_IRQ = marian_top_marian_ext_irq_o;
    assign marian_top_marian_gpio_i = marian_top_gpio_to_gpio_gpio_core;
    assign marian_top_gpio_to_gpio_gpio_offchip = marian_top_marian_gpio_o;
    assign marian_top_gpio_to_gpio_gpio_oe = marian_top_marian_gpio_oe;
    assign marian_top_marian_jtag_tck_i = marian_top_jtag_to_jtag_TCK;
    assign marian_top_marian_jtag_tdi_i = marian_top_marian_jtag_tdi_i_to_vcss_jtag_tdi_i;
    assign marian_top_marian_jtag_tdo_o_to_vcss_jtag_tdo_o = marian_top_marian_jtag_tdo_o;
    assign marian_top_marian_jtag_tms_i = marian_top_jtag_to_jtag_TMS;
    assign marian_top_marian_jtag_trstn_i = marian_top_jtag_to_jtag_TRST;
    assign marian_top_qspi_to_qspi_csn = marian_top_marian_qspi_csn_o;
    assign marian_top_marian_qspi_data_i[2] = marian_top_qspi_to_qspi_miso[2];
    assign marian_top_marian_qspi_data_i[1] = marian_top_qspi_to_qspi_miso[1];
    assign marian_top_marian_qspi_data_i[0] = marian_top_qspi_to_qspi_miso[0];
    assign marian_top_marian_qspi_data_i[3] = marian_top_qspi_to_qspi_miso[3];
    assign marian_top_qspi_to_qspi_mosi[2] = marian_top_marian_qspi_data_o[2];
    assign marian_top_qspi_to_qspi_mosi[1] = marian_top_marian_qspi_data_o[1];
    assign marian_top_qspi_to_qspi_mosi[0] = marian_top_marian_qspi_data_o[0];
    assign marian_top_qspi_to_qspi_mosi[3] = marian_top_marian_qspi_data_o[3];
    assign marian_top_qspi_to_qspi_data_oe[0] = marian_top_marian_qspi_oe[0];
    assign marian_top_qspi_to_qspi_data_oe[2] = marian_top_marian_qspi_oe[2];
    assign marian_top_qspi_to_qspi_data_oe[1] = marian_top_marian_qspi_oe[1];
    assign marian_top_qspi_to_qspi_data_oe[3] = marian_top_marian_qspi_oe[3];
    assign marian_top_qspi_to_qspi_sck = marian_top_marian_qspi_sclk_o;
    assign marian_top_marian_uart_rx_i = marian_top_uart_to_uart_uart_rx;
    assign marian_top_uart_to_uart_uart_tx = marian_top_marian_uart_tx_o;
    assign marian_top_rst_ni = subsystem_clock_control_0_rst_n_to_marian_top_rst_ni_rst_n;
    // subsystem_clock_control_0 assignments:
    assign subsystem_clock_control_0_clk_to_marian_top_clk_clk = subsystem_clock_control_0_clk_out;
    assign subsystem_clock_control_0_force_cka = subsystem_clock_control_0_clk_ctrl_to_clk_ctrl_CLK_CTRL[1];
    assign subsystem_clock_control_0_force_ckb = subsystem_clock_control_0_clk_ctrl_to_clk_ctrl_CLK_CTRL[2];
    assign subsystem_clock_control_0_pll_ctrl_in[55:48] = subsystem_clock_control_0_pll_ctrl_to_pll_ctrl_DEBUG_CTRL;
    assign subsystem_clock_control_0_pll_ctrl_in[104:88] = subsystem_clock_control_0_pll_ctrl_to_pll_ctrl_DIV;
    assign subsystem_clock_control_0_pll_ctrl_in[47:40] = subsystem_clock_control_0_pll_ctrl_to_pll_ctrl_ENABLE;
    assign subsystem_clock_control_0_pll_ctrl_in[87:56] = subsystem_clock_control_0_pll_ctrl_to_pll_ctrl_LOOP_CTRL;
    assign subsystem_clock_control_0_pll_ctrl_in[39:8] = subsystem_clock_control_0_pll_ctrl_to_pll_ctrl_SPARE_CTRL;
    assign subsystem_clock_control_0_pll_ctrl_in[7:0] = subsystem_clock_control_0_pll_ctrl_to_pll_ctrl_TMUX_SEL;
    assign subsystem_clock_control_0_pll_ctrl_latched_to_clkpll_0_pll_ctrl_latched_DEBUG_CTRL = subsystem_clock_control_0_pll_ctrl_out[55:48];
    assign subsystem_clock_control_0_pll_ctrl_latched_to_clkpll_0_pll_ctrl_latched_DIV = subsystem_clock_control_0_pll_ctrl_out[104:88];
    assign subsystem_clock_control_0_pll_ctrl_latched_to_clkpll_0_pll_ctrl_latched_ENABLE = subsystem_clock_control_0_pll_ctrl_out[47:40];
    assign subsystem_clock_control_0_pll_ctrl_latched_to_clkpll_0_pll_ctrl_latched_LOOP_CTRL = subsystem_clock_control_0_pll_ctrl_out[87:56];
    assign subsystem_clock_control_0_pll_ctrl_latched_to_clkpll_0_pll_ctrl_latched_SPARE_CTRL = subsystem_clock_control_0_pll_ctrl_out[39:8];
    assign subsystem_clock_control_0_pll_ctrl_latched_to_clkpll_0_pll_ctrl_latched_TMUX_SEL = subsystem_clock_control_0_pll_ctrl_out[7:0];
    assign subsystem_clock_control_0_pll_ctrl_valid = subsystem_clock_control_0_pll_ctrl_to_pll_ctrl_VALID;
    assign subsystem_clock_control_0_pll_lock = clkpll_0_CLK_PLL_LOCK_to_subsystem_clock_control_0_pll_lock;
    assign subsystem_clock_control_0_pllclk = clkpll_0_pll_clk_to_subsystem_clock_control_0_pll_clk_clk;
    assign subsystem_clock_control_0_refclk = subsystem_clock_control_0_ref_clk_to_ref_clk_clk;
    assign subsystem_clock_control_0_refrstn = subsystem_clock_control_0_ref_rstn_to_ref_rst_n_rst_n;
    assign subsystem_clock_control_0_rst_n_to_marian_top_rst_ni_rst_n = subsystem_clock_control_0_rstn_out;
    assign subsystem_clock_control_0_sel_cka = subsystem_clock_control_0_clk_ctrl_to_clk_ctrl_CLK_CTRL[0];
    assign subsystem_clock_control_0_subsys_clkena = subsystem_clock_control_0_clk_ctrl_to_clk_ctrl_CLK_CTRL[3];

    // IP-XACT VLNV: tuni.fi:subsystem.axi_cdc_split:axi_cdc_intf_dst:1.0
    axi_cdc_split_intf_dst #(
        .AXI_ID_WIDTH        (9),
        .AXI_ADDR_WIDTH      (32),
        .AXI_DATA_WIDTH      (64),
        .AXI_USER_WIDTH      (1),
        .LOG_DEPTH           (2))
    axi_cdc_intf_dst_0(
        // Interface: dst
        .ar_data_src2dst     (axi_cdc_intf_dst_0_ar_data_src2dst),
        .ar_wr_ptr_gray_src2dst(axi_cdc_intf_dst_0_ar_wr_ptr_gray_src2dst),
        .aw_data_src2dst     (axi_cdc_intf_dst_0_aw_data_src2dst),
        .aw_wr_ptr_gray_src2dst(axi_cdc_intf_dst_0_aw_wr_ptr_gray_src2dst),
        .b_rd_data_ptr_src2dst(axi_cdc_intf_dst_0_b_rd_data_ptr_src2dst),
        .b_rd_ptr_gray_src2dst(axi_cdc_intf_dst_0_b_rd_ptr_gray_src2dst),
        .r_rd_data_ptr_src2dst(axi_cdc_intf_dst_0_r_rd_data_ptr_src2dst),
        .r_rd_ptr_gray_src2dst(axi_cdc_intf_dst_0_r_rd_ptr_gray_src2dst),
        .w_data_src2dst      (axi_cdc_intf_dst_0_w_data_src2dst),
        .w_wr_ptr_gray_src2dst(axi_cdc_intf_dst_0_w_wr_ptr_gray_src2dst),
        .ar_rd_data_ptr_dst2src(axi_cdc_intf_dst_0_ar_rd_data_ptr_dst2src),
        .ar_rd_ptr_gray_dst2src(axi_cdc_intf_dst_0_ar_rd_ptr_gray_dst2src),
        .aw_rd_data_ptr_dst2src(axi_cdc_intf_dst_0_aw_rd_data_ptr_dst2src),
        .aw_rd_ptr_gray_dst2src(axi_cdc_intf_dst_0_aw_rd_ptr_gray_dst2src),
        .b_data_dst2src      (axi_cdc_intf_dst_0_b_data_dst2src),
        .b_wr_ptr_gray_dst2src(axi_cdc_intf_dst_0_b_wr_ptr_gray_dst2src),
        .r_data_dst2src      (axi_cdc_intf_dst_0_r_data_dst2src),
        .r_wr_ptr_gray_dst2src(axi_cdc_intf_dst_0_r_wr_ptr_gray_dst2src),
        .w_rd_data_ptr_dst2src(axi_cdc_intf_dst_0_w_rd_data_ptr_dst2src),
        .w_rd_ptr_gray_dst2src(axi_cdc_intf_dst_0_w_rd_ptr_gray_dst2src),
        // Interface: dst_clk
        .dst_clk_i           (axi_cdc_intf_dst_0_dst_clk_i),
        // Interface: dst_rstn
        .dst_rst_ni          (axi_cdc_intf_dst_0_dst_rst_ni),
        // Interface: icn_rstn
        .icn_rst_ni          (axi_cdc_intf_dst_0_icn_rst_ni),
        // Interface: src
        .ar_ready            (axi_cdc_intf_dst_0_ar_ready),
        .aw_ready            (axi_cdc_intf_dst_0_aw_ready),
        .b_id                (axi_cdc_intf_dst_0_b_id),
        .b_resp              (axi_cdc_intf_dst_0_b_resp),
        .b_user              (axi_cdc_intf_dst_0_b_user),
        .b_valid             (axi_cdc_intf_dst_0_b_valid),
        .r_data              (axi_cdc_intf_dst_0_r_data),
        .r_id                (axi_cdc_intf_dst_0_r_id),
        .r_last              (axi_cdc_intf_dst_0_r_last),
        .r_resp              (axi_cdc_intf_dst_0_r_resp),
        .r_user              (axi_cdc_intf_dst_0_r_user),
        .r_valid             (axi_cdc_intf_dst_0_r_valid),
        .w_ready             (axi_cdc_intf_dst_0_w_ready),
        .ar_addr             (axi_cdc_intf_dst_0_ar_addr),
        .ar_burst            (axi_cdc_intf_dst_0_ar_burst),
        .ar_cache            (axi_cdc_intf_dst_0_ar_cache),
        .ar_id               (axi_cdc_intf_dst_0_ar_id),
        .ar_len              (axi_cdc_intf_dst_0_ar_len),
        .ar_lock             (axi_cdc_intf_dst_0_ar_lock),
        .ar_prot             (axi_cdc_intf_dst_0_ar_prot),
        .ar_qos              (axi_cdc_intf_dst_0_ar_qos),
        .ar_region           (axi_cdc_intf_dst_0_ar_region),
        .ar_size             (axi_cdc_intf_dst_0_ar_size),
        .ar_user             (axi_cdc_intf_dst_0_ar_user),
        .ar_valid            (axi_cdc_intf_dst_0_ar_valid),
        .aw_addr             (axi_cdc_intf_dst_0_aw_addr),
        .aw_atop             (axi_cdc_intf_dst_0_aw_atop),
        .aw_burst            (axi_cdc_intf_dst_0_aw_burst),
        .aw_cache            (axi_cdc_intf_dst_0_aw_cache),
        .aw_id               (axi_cdc_intf_dst_0_aw_id),
        .aw_len              (axi_cdc_intf_dst_0_aw_len),
        .aw_lock             (axi_cdc_intf_dst_0_aw_lock),
        .aw_prot             (axi_cdc_intf_dst_0_aw_prot),
        .aw_qos              (axi_cdc_intf_dst_0_aw_qos),
        .aw_region           (axi_cdc_intf_dst_0_aw_region),
        .aw_size             (axi_cdc_intf_dst_0_aw_size),
        .aw_user             (axi_cdc_intf_dst_0_aw_user),
        .aw_valid            (axi_cdc_intf_dst_0_aw_valid),
        .b_ready             (axi_cdc_intf_dst_0_b_ready),
        .r_ready             (axi_cdc_intf_dst_0_r_ready),
        .w_data              (axi_cdc_intf_dst_0_w_data),
        .w_last              (axi_cdc_intf_dst_0_w_last),
        .w_strb              (axi_cdc_intf_dst_0_w_strb),
        .w_user              (axi_cdc_intf_dst_0_w_user),
        .w_valid             (axi_cdc_intf_dst_0_w_valid));

    // IP-XACT VLNV: tuni.fi:subsystem.axi_cdc_split:axi_cdc_intf_src:1.0
    axi_cdc_split_intf_src #(
        .AXI_ID_WIDTH        (9),
        .AXI_ADDR_WIDTH      (32),
        .AXI_DATA_WIDTH      (64),
        .AXI_USER_WIDTH      (1),
        .LOG_DEPTH           (2))
    axi_cdc_intf_src_0(
        // Interface: dst
        .ar_addr             (axi_cdc_intf_src_0_ar_addr),
        .ar_burst            (axi_cdc_intf_src_0_ar_burst),
        .ar_cache            (axi_cdc_intf_src_0_ar_cache),
        .ar_id               (axi_cdc_intf_src_0_ar_id),
        .ar_len              (axi_cdc_intf_src_0_ar_len),
        .ar_lock             (axi_cdc_intf_src_0_ar_lock),
        .ar_prot             (axi_cdc_intf_src_0_ar_prot),
        .ar_qos              (axi_cdc_intf_src_0_ar_qos),
        .ar_region           (axi_cdc_intf_src_0_ar_region),
        .ar_size             (axi_cdc_intf_src_0_ar_size),
        .ar_user             (axi_cdc_intf_src_0_ar_user),
        .ar_valid            (axi_cdc_intf_src_0_ar_valid),
        .aw_addr             (axi_cdc_intf_src_0_aw_addr),
        .aw_atop             (axi_cdc_intf_src_0_aw_atop),
        .aw_burst            (axi_cdc_intf_src_0_aw_burst),
        .aw_cache            (axi_cdc_intf_src_0_aw_cache),
        .aw_id               (axi_cdc_intf_src_0_aw_id),
        .aw_len              (axi_cdc_intf_src_0_aw_len),
        .aw_lock             (axi_cdc_intf_src_0_aw_lock),
        .aw_prot             (axi_cdc_intf_src_0_aw_prot),
        .aw_qos              (axi_cdc_intf_src_0_aw_qos),
        .aw_region           (axi_cdc_intf_src_0_aw_region),
        .aw_size             (axi_cdc_intf_src_0_aw_size),
        .aw_user             (axi_cdc_intf_src_0_aw_user),
        .aw_valid            (axi_cdc_intf_src_0_aw_valid),
        .b_ready             (axi_cdc_intf_src_0_b_ready),
        .r_ready             (axi_cdc_intf_src_0_r_ready),
        .w_data              (axi_cdc_intf_src_0_w_data),
        .w_last              (axi_cdc_intf_src_0_w_last),
        .w_strb              (axi_cdc_intf_src_0_w_strb),
        .w_user              (axi_cdc_intf_src_0_w_user),
        .w_valid             (axi_cdc_intf_src_0_w_valid),
        .ar_ready            (axi_cdc_intf_src_0_ar_ready),
        .aw_ready            (axi_cdc_intf_src_0_aw_ready),
        .b_id                (axi_cdc_intf_src_0_b_id),
        .b_resp              (axi_cdc_intf_src_0_b_resp),
        .b_user              (axi_cdc_intf_src_0_b_user),
        .b_valid             (axi_cdc_intf_src_0_b_valid),
        .r_data              (axi_cdc_intf_src_0_r_data),
        .r_id                (axi_cdc_intf_src_0_r_id),
        .r_last              (axi_cdc_intf_src_0_r_last),
        .r_resp              (axi_cdc_intf_src_0_r_resp),
        .r_user              (axi_cdc_intf_src_0_r_user),
        .r_valid             (axi_cdc_intf_src_0_r_valid),
        .w_ready             (axi_cdc_intf_src_0_w_ready),
        // Interface: icn_rstn
        .icn_rst_ni          (axi_cdc_intf_src_0_icn_rst_ni),
        // Interface: src
        .ar_rd_data_ptr_dst2src(axi_cdc_intf_src_0_ar_rd_data_ptr_dst2src),
        .ar_rd_ptr_gray_dst2src(axi_cdc_intf_src_0_ar_rd_ptr_gray_dst2src),
        .aw_rd_data_ptr_dst2src(axi_cdc_intf_src_0_aw_rd_data_ptr_dst2src),
        .aw_rd_ptr_gray_dst2src(axi_cdc_intf_src_0_aw_rd_ptr_gray_dst2src),
        .b_data_dst2src      (axi_cdc_intf_src_0_b_data_dst2src),
        .b_wr_ptr_gray_dst2src(axi_cdc_intf_src_0_b_wr_ptr_gray_dst2src),
        .r_data_dst2src      (axi_cdc_intf_src_0_r_data_dst2src),
        .r_wr_ptr_gray_dst2src(axi_cdc_intf_src_0_r_wr_ptr_gray_dst2src),
        .w_rd_data_ptr_dst2src(axi_cdc_intf_src_0_w_rd_data_ptr_dst2src),
        .w_rd_ptr_gray_dst2src(axi_cdc_intf_src_0_w_rd_ptr_gray_dst2src),
        .ar_data_src2dst     (axi_cdc_intf_src_0_ar_data_src2dst),
        .ar_wr_ptr_gray_src2dst(axi_cdc_intf_src_0_ar_wr_ptr_gray_src2dst),
        .aw_data_src2dst     (axi_cdc_intf_src_0_aw_data_src2dst),
        .aw_wr_ptr_gray_src2dst(axi_cdc_intf_src_0_aw_wr_ptr_gray_src2dst),
        .b_rd_data_ptr_src2dst(axi_cdc_intf_src_0_b_rd_data_ptr_src2dst),
        .b_rd_ptr_gray_src2dst(axi_cdc_intf_src_0_b_rd_ptr_gray_src2dst),
        .r_rd_data_ptr_src2dst(axi_cdc_intf_src_0_r_rd_data_ptr_src2dst),
        .r_rd_ptr_gray_src2dst(axi_cdc_intf_src_0_r_rd_ptr_gray_src2dst),
        .w_data_src2dst      (axi_cdc_intf_src_0_w_data_src2dst),
        .w_wr_ptr_gray_src2dst(axi_cdc_intf_src_0_w_wr_ptr_gray_src2dst),
        // Interface: src_clk
        .src_clk_i           (axi_cdc_intf_src_0_src_clk_i),
        // Interface: src_rstn
        .src_rst_ni          (axi_cdc_intf_src_0_src_rst_ni));

    // IP-XACT VLNV: corehw.com:subsystem.clock:clkpll:1.0
    CLKPLL clkpll_0(
        // Interface: pll_clk
        .CLK_PLL_OUT         (clkpll_0_CLK_PLL_OUT),
        // Interface: pll_ctrl_latched
        .DEBUG_CTRL          (clkpll_0_DEBUG_CTRL),
        .ENABLE              (clkpll_0_ENABLE),
        .LOOP_CTRL           (clkpll_0_LOOP_CTRL),
        .M_DIV               (clkpll_0_M_DIV),
        .N_DIV               (clkpll_0_N_DIV),
        .R_DIV               (clkpll_0_R_DIV),
        .SPARE_CTRL          (clkpll_0_SPARE_CTRL),
        .TMUX_1_SEL          (clkpll_0_TMUX_1_SEL),
        .TMUX_2_SEL          (clkpll_0_TMUX_2_SEL),
        // Interface: pll_status
        .STATUS1             (clkpll_0_STATUS1),
        .STATUS2             (clkpll_0_STATUS2),
        // Interface: ref_clk
        .CLK_REF             (clkpll_0_CLK_REF),
        // These ports are not in any interface
        .SCAN_EN             (1'b0),
        .SCAN_IN             (1'b0),
        .SCAN_MODE           (2'h0),
        .CLK_PLL_LOCK        (clkpll_0_CLK_PLL_LOCK),
        .CLK_REF_BUF_OUT     (),
        .SCAN_OUT            (),
        .TOUT1               (),
        .TOUT2               ());

    // IP-XACT VLNV: tuni.fi:ip:marian_top:1.0
    marian_top marian_top(
        // Interface: axi_master
        .marian_axi_m_ar_ready_i(marian_top_marian_axi_m_ar_ready_i),
        .marian_axi_m_aw_ready_i(marian_top_marian_axi_m_aw_ready_i),
        .marian_axi_m_b_id_i (marian_top_marian_axi_m_b_id_i),
        .marian_axi_m_b_resp_i(marian_top_marian_axi_m_b_resp_i),
        .marian_axi_m_b_user_i(marian_top_marian_axi_m_b_user_i),
        .marian_axi_m_b_valid_i(marian_top_marian_axi_m_b_valid_i),
        .marian_axi_m_r_data_i(marian_top_marian_axi_m_r_data_i),
        .marian_axi_m_r_id_i (marian_top_marian_axi_m_r_id_i),
        .marian_axi_m_r_last_i(marian_top_marian_axi_m_r_last_i),
        .marian_axi_m_r_resp_i(marian_top_marian_axi_m_r_resp_i),
        .marian_axi_m_r_user_i(marian_top_marian_axi_m_r_user_i),
        .marian_axi_m_r_valid_i(marian_top_marian_axi_m_r_valid_i),
        .marian_axi_m_w_ready_i(marian_top_marian_axi_m_w_ready_i),
        .marian_axi_m_ar_addr_o(marian_top_marian_axi_m_ar_addr_o),
        .marian_axi_m_ar_burst_o(marian_top_marian_axi_m_ar_burst_o),
        .marian_axi_m_ar_cache_o(marian_top_marian_axi_m_ar_cache_o),
        .marian_axi_m_ar_id_o(marian_top_marian_axi_m_ar_id_o),
        .marian_axi_m_ar_len_o(marian_top_marian_axi_m_ar_len_o),
        .marian_axi_m_ar_lock_o(marian_top_marian_axi_m_ar_lock_o),
        .marian_axi_m_ar_prot_o(marian_top_marian_axi_m_ar_prot_o),
        .marian_axi_m_ar_qos_o(marian_top_marian_axi_m_ar_qos_o),
        .marian_axi_m_ar_region_o(marian_top_marian_axi_m_ar_region_o),
        .marian_axi_m_ar_size_o(marian_top_marian_axi_m_ar_size_o),
        .marian_axi_m_ar_user_o(marian_top_marian_axi_m_ar_user_o),
        .marian_axi_m_ar_valid_o(marian_top_marian_axi_m_ar_valid_o),
        .marian_axi_m_aw_addr_o(marian_top_marian_axi_m_aw_addr_o),
        .marian_axi_m_aw_atop_o(marian_top_marian_axi_m_aw_atop_o),
        .marian_axi_m_aw_burst_o(marian_top_marian_axi_m_aw_burst_o),
        .marian_axi_m_aw_cache_o(marian_top_marian_axi_m_aw_cache_o),
        .marian_axi_m_aw_id_o(marian_top_marian_axi_m_aw_id_o),
        .marian_axi_m_aw_len_o(marian_top_marian_axi_m_aw_len_o),
        .marian_axi_m_aw_lock_o(marian_top_marian_axi_m_aw_lock_o),
        .marian_axi_m_aw_prot_o(marian_top_marian_axi_m_aw_prot_o),
        .marian_axi_m_aw_qos_o(marian_top_marian_axi_m_aw_qos_o),
        .marian_axi_m_aw_region_o(marian_top_marian_axi_m_aw_region_o),
        .marian_axi_m_aw_size_o(marian_top_marian_axi_m_aw_size_o),
        .marian_axi_m_aw_user_o(marian_top_marian_axi_m_aw_user_o),
        .marian_axi_m_aw_valid_o(marian_top_marian_axi_m_aw_valid_o),
        .marian_axi_m_b_ready_o(marian_top_marian_axi_m_b_ready_o),
        .marian_axi_m_r_ready_o(marian_top_marian_axi_m_r_ready_o),
        .marian_axi_m_w_data_o(marian_top_marian_axi_m_w_data_o),
        .marian_axi_m_w_last_o(marian_top_marian_axi_m_w_last_o),
        .marian_axi_m_w_strb_o(marian_top_marian_axi_m_w_strb_o),
        .marian_axi_m_w_user_o(marian_top_marian_axi_m_w_user_o),
        .marian_axi_m_w_valid_o(marian_top_marian_axi_m_w_valid_o),
        // Interface: axi_slave
        .marian_axi_s_ar_addr_i(marian_top_marian_axi_s_ar_addr_i),
        .marian_axi_s_ar_burst_i(marian_top_marian_axi_s_ar_burst_i),
        .marian_axi_s_ar_cache_i(marian_top_marian_axi_s_ar_cache_i),
        .marian_axi_s_ar_id_i(marian_top_marian_axi_s_ar_id_i),
        .marian_axi_s_ar_len_i(marian_top_marian_axi_s_ar_len_i),
        .marian_axi_s_ar_lock_i(marian_top_marian_axi_s_ar_lock_i),
        .marian_axi_s_ar_prot_i(marian_top_marian_axi_s_ar_prot_i),
        .marian_axi_s_ar_qos_i(marian_top_marian_axi_s_ar_qos_i),
        .marian_axi_s_ar_region_i(marian_top_marian_axi_s_ar_region_i),
        .marian_axi_s_ar_size_i(marian_top_marian_axi_s_ar_size_i),
        .marian_axi_s_ar_user_i(marian_top_marian_axi_s_ar_user_i),
        .marian_axi_s_ar_valid_i(marian_top_marian_axi_s_ar_valid_i),
        .marian_axi_s_aw_addr_i(marian_top_marian_axi_s_aw_addr_i),
        .marian_axi_s_aw_atop_i(marian_top_marian_axi_s_aw_atop_i),
        .marian_axi_s_aw_burst_i(marian_top_marian_axi_s_aw_burst_i),
        .marian_axi_s_aw_cache_i(marian_top_marian_axi_s_aw_cache_i),
        .marian_axi_s_aw_id_i(marian_top_marian_axi_s_aw_id_i),
        .marian_axi_s_aw_len_i(marian_top_marian_axi_s_aw_len_i),
        .marian_axi_s_aw_lock_i(marian_top_marian_axi_s_aw_lock_i),
        .marian_axi_s_aw_prot_i(marian_top_marian_axi_s_aw_prot_i),
        .marian_axi_s_aw_qos_i(marian_top_marian_axi_s_aw_qos_i),
        .marian_axi_s_aw_region_i(marian_top_marian_axi_s_aw_region_i),
        .marian_axi_s_aw_size_i(marian_top_marian_axi_s_aw_size_i),
        .marian_axi_s_aw_user_i(marian_top_marian_axi_s_aw_user_i),
        .marian_axi_s_aw_valid_i(marian_top_marian_axi_s_aw_valid_i),
        .marian_axi_s_b_ready_i(marian_top_marian_axi_s_b_ready_i),
        .marian_axi_s_r_ready_i(marian_top_marian_axi_s_r_ready_i),
        .marian_axi_s_w_data_i(marian_top_marian_axi_s_w_data_i),
        .marian_axi_s_w_last_i(marian_top_marian_axi_s_w_last_i),
        .marian_axi_s_w_strb_i(marian_top_marian_axi_s_w_strb_i),
        .marian_axi_s_w_user_i(marian_top_marian_axi_s_w_user_i),
        .marian_axi_s_w_valid_i(marian_top_marian_axi_s_w_valid_i),
        .marian_axi_s_ar_ready_o(marian_top_marian_axi_s_ar_ready_o),
        .marian_axi_s_aw_ready_o(marian_top_marian_axi_s_aw_ready_o),
        .marian_axi_s_b_id_o (marian_top_marian_axi_s_b_id_o),
        .marian_axi_s_b_resp_o(marian_top_marian_axi_s_b_resp_o),
        .marian_axi_s_b_user_o(marian_top_marian_axi_s_b_user_o),
        .marian_axi_s_b_valid_o(marian_top_marian_axi_s_b_valid_o),
        .marian_axi_s_r_data_o(marian_top_marian_axi_s_r_data_o),
        .marian_axi_s_r_id_o (marian_top_marian_axi_s_r_id_o),
        .marian_axi_s_r_last_o(marian_top_marian_axi_s_r_last_o),
        .marian_axi_s_r_resp_o(marian_top_marian_axi_s_r_resp_o),
        .marian_axi_s_r_user_o(marian_top_marian_axi_s_r_user_o),
        .marian_axi_s_r_valid_o(marian_top_marian_axi_s_r_valid_o),
        .marian_axi_s_w_ready_o(marian_top_marian_axi_s_w_ready_o),
        // Interface: clk
        .clk_i               (marian_top_clk_i),
        // Interface: gpio
        .marian_gpio_i       (marian_top_marian_gpio_i),
        .marian_gpio_o       (marian_top_marian_gpio_o),
        .marian_gpio_oe      (marian_top_marian_gpio_oe),
        // Interface: irq_i
        .marian_ext_irq_i    (marian_top_marian_ext_irq_i),
        // Interface: irq_o
        .marian_ext_irq_o    (marian_top_marian_ext_irq_o),
        // Interface: jtag
        .marian_jtag_tck_i   (marian_top_marian_jtag_tck_i),
        .marian_jtag_tms_i   (marian_top_marian_jtag_tms_i),
        .marian_jtag_trstn_i (marian_top_marian_jtag_trstn_i),
        // Interface: qspi
        .marian_qspi_data_i  (marian_top_marian_qspi_data_i),
        .marian_qspi_csn_o   (marian_top_marian_qspi_csn_o),
        .marian_qspi_data_o  (marian_top_marian_qspi_data_o),
        .marian_qspi_oe      (marian_top_marian_qspi_oe),
        .marian_qspi_sclk_o  (marian_top_marian_qspi_sclk_o),
        // Interface: rst_ni
        .rst_ni              (marian_top_rst_ni),
        // Interface: uart
        .marian_uart_rx_i    (marian_top_marian_uart_rx_i),
        .marian_uart_tx_o    (marian_top_marian_uart_tx_o),
        // These ports are not in any interface
        .marian_jtag_tdi_i   (marian_top_marian_jtag_tdi_i),
        .marian_jtag_tdo_o   (marian_top_marian_jtag_tdo_o));

    // IP-XACT VLNV: tuni.fi:subsystem.clock:subsystem_clock_control:1.0
    subsystem_clock_control #(
        .PLL_CTRL_WIDTH      (105),
        .CLK_CTRL_WIDTH      (8))
    subsystem_clock_control_0(
        // Interface: clk
        .clk_out             (subsystem_clock_control_0_clk_out),
        // Interface: clk_ctrl
        .force_cka           (subsystem_clock_control_0_force_cka),
        .force_ckb           (subsystem_clock_control_0_force_ckb),
        .sel_cka             (subsystem_clock_control_0_sel_cka),
        .subsys_clkena       (subsystem_clock_control_0_subsys_clkena),
        // Interface: pll_clk
        .pllclk              (subsystem_clock_control_0_pllclk),
        // Interface: pll_ctrl
        .pll_ctrl_in         (subsystem_clock_control_0_pll_ctrl_in),
        .pll_ctrl_valid      (subsystem_clock_control_0_pll_ctrl_valid),
        // Interface: pll_ctrl_latched
        .pll_ctrl_out        (subsystem_clock_control_0_pll_ctrl_out),
        // Interface: ref_clk
        .refclk              (subsystem_clock_control_0_refclk),
        // Interface: ref_rstn
        .refrstn             (subsystem_clock_control_0_refrstn),
        // Interface: rst_n
        .rstn_out            (subsystem_clock_control_0_rstn_out),
        // These ports are not in any interface
        .pll_lock            (subsystem_clock_control_0_pll_lock));


endmodule
