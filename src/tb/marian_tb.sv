//------------------------------------------------------------------------------
// Module   : marian_tb.sv
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
//            Endrit Isufi   <endrit.isufi@tuni.fi>
// Created  : 10-jan-2024
//
// Description: Subsystem testbench for Marian
//
// Parameters:
//  - CLOCK_PERIOD: Period of TB clock
//  - RESET_DELAY_CYCLES: Number of cycles that design is initial held in reset
//  - L2_INIT_METHOD: Method by which the L2 memory of CVA6 is initialised.
//  - L2_MEM_INIT_FILE: Path to the verilog memory file to be read by readmemh
//
// Inputs:
//  - None
//
// Outputs:
//  - None
//
// Revision History:
//  - Version 1.0: Initial release
//  - Version 1.1: Added GPIO loopback [TZS:20-jul-2024]
//
//------------------------------------------------------------------------------

`define STRINGIFY(x) `"x`"

module marian_tb;

  timeunit 1ns/1ps;

`ifndef VERILATOR
  // task references used in jtag_pkg are not supported by verilator v5.008
  import marian_jtag_pkg::*;
`endif

  import ara_pkg::*;
  import marian_tb_pkg::*;
  import marian_pkg::*; //right now only used to get types for the AXI M & AXI S
  import axi_test::*;  // utilities fro AXI M and AXI S verification
  `include "axi/assign.svh"
/********************************
 *  TB Parameters               *
 ********************************/
  // TB config
  parameter realtime CLOCK_PERIOD       = `CLK_PERIOD; //defined in vsim/Makefile, default value of 20ns
  parameter integer  RESET_DELAY_CYCLES = 50; // # of cycles that design is held in reset
  parameter string   L2_INIT_METHOD     = `STRINGIFY(`L2_INIT_METHOD);
  parameter string   L2_MEM_INIT_FILE   = `STRINGIFY(`L2_MEM_INIT_FILE);

  // DUT-related configuration
  localparam integer NrLanes            = `NR_LANES; // defined in vsim/Makefile
  localparam integer AxiDataWidth       = 64 * NrLanes / 2;
  localparam integer AxiBeWidth         = AxiDataWidth / 8;
  localparam integer AxiByteOffset      = $clog2(AxiBeWidth);
  localparam integer L2Words            = `L2_NUM_ROWS; // number of rows in BootRAM
  localparam integer AxiNarrowDataWidth = 64; // Ariane's AXI port data width (taken from ara_soc)
  // output of Ara AXI monitoring
  localparam string  IdealResultsFile   = `STRINGIFY(`IDEAL_RESULTS_FILE);

  // boot address used by debug module
  localparam logic [riscv::XLEN-1:0] CVA6BootAddress = marian_pkg::DRAMBase;
  // core ID used for debug module testing
  localparam integer CoreID = 0;

  //AXI config
//localparams for cdc src & dst
  localparam integer AXI_ADDR_WIDTH     = 32;
  localparam integer DUT_AXI_DATA_WIDTH = 64;
  localparam integer AXI_DATA_WIDTH     = 64;
  localparam integer AXI_ID_WIDTH       = 9;
  localparam integer AXI_USER_WIDTH     = 1;

  localparam integer AXI_LOG_DEPTH = 2;
  localparam integer AXI_AW_DATA_SIZE = AXI_ID_WIDTH
                                      + AXI_ADDR_WIDTH
                                      + 8 // len
                                      + 3 // size
                                      + 2 // burst
                                      + 1 // lock
                                      + 4 // cache
                                      + 3 // prot
                                      + 4 // qos
                                      + 4 // region
                                      + 6 // atop
                                      + AXI_USER_WIDTH;
  localparam integer AXI_AR_DATA_SIZE = AXI_ID_WIDTH
                                      + AXI_ADDR_WIDTH
                                      + 8 // len
                                      + 3 // size
                                      + 2 // burst
                                      + 1 // lock
                                      + 4 // cache
                                      + 3 // prot
                                      + 4 // qos
                                      + 4 // region
                                      + AXI_USER_WIDTH;
  localparam integer AXI_W_DATA_SIZE = DUT_AXI_DATA_WIDTH
                                     + (DUT_AXI_DATA_WIDTH/8) // strb
                                     + 1 // last
                                     + AXI_USER_WIDTH;
  localparam integer AXI_R_DATA_SIZE = DUT_AXI_DATA_WIDTH
                                     + AXI_ID_WIDTH
                                     + 2 // resp
                                     + 1 // last
                                     + AXI_USER_WIDTH;
  localparam integer AXI_B_DATA_SIZE = AXI_ID_WIDTH
                                     + 2 // resp
                                     + AXI_USER_WIDTH;
  localparam integer DST_AW_DATA_SIZE = AXI_AW_DATA_SIZE; // same as for 64-bit
  localparam integer DST_AR_DATA_SIZE = AXI_AR_DATA_SIZE; // same as for 64-bit
  localparam integer DST_W_DATA_SIZE = AXI_DATA_WIDTH
                                     + (AXI_DATA_WIDTH/8) // strb
                                     + 1 // last
                                     + AXI_USER_WIDTH;
  localparam integer DST_R_DATA_SIZE = AXI_DATA_WIDTH
                                     + AXI_ID_WIDTH
                                     + 2 // resp
                                     + 1 // last
                                     + AXI_USER_WIDTH;
  localparam integer DST_B_DATA_SIZE = AXI_B_DATA_SIZE; // same as for 64-bit
/*************
 *  Signals  *
 *************/

  // clock and reset
  logic tb_clk;
  logic tb_rstn;

  // subsystem clock controls
  logic [7:0] clk_ctrl_s;

  // JTAG
  logic jtag_tck_s;
  logic jtag_tms_s;
  logic jtag_trstn_s;
  logic jtag_tdi_s;
  logic jtag_tdo_s;

  //QSPI
  logic [3:0] marian_qspi_data_i;
  logic       marian_qspi_csn_o;
  logic [3:0] marian_qspi_data_o;
  logic [3:0] marian_qspi_oe;
  logic       marian_qspi_sclk_o;

  // tb mgmt signals
  logic [AxiNarrowDataWidth-1:0] exit_s;

  // signals used to monitor VLSU AXI IF in ideal dispatcher mode
  logic [AxiDataWidth-1:0] ara_axi_w;
  logic [  AxiBeWidth-1:0] ara_axi_w_strb;
  logic                    ara_axi_w_vld;
  logic                    ara_axi_w_rdy;

  // utility signals
  logic [AxiDataWidth-1:0] mem_init_arr [L2Words];
  int                      fd;
  int                      dm_test_err_count;
  logic                    dm_test_err;


/*************************************
*  TB Init + Clock/Reset Generation  *
**************************************/

`ifndef VERILATOR
  // set time format for TB
  initial begin
    $timeformat(-9, 0, "ns");
  end

  // objects used to control debug module tasks
  debug_mode_if_t #(
    .PROG_LEN ( L2Words ),
    .NR_LANES ( NrLanes )
    ) marian_debug_if = new;

  dm::dmstatus_t dmstatus;

  initial begin
    // read memory init file into temporary unpacked memory variable
    $readmemh(L2_MEM_INIT_FILE, mem_init_arr);
  end

`else

  initial begin
    $dumpfile("marian_tb.vcd");
    $dumpvars;
  end

`endif

  initial begin
    fd = $fopen(IdealResultsFile, "w");
    $display("%7t - Ideal Dispatcher Results written to: %s", $realtime, IdealResultsFile);
  end

  // Controlling the reset
  initial begin

    tb_clk  = 1'b0;
    tb_rstn = 1'b0;

    repeat (RESET_DELAY_CYCLES) begin
      #(CLOCK_PERIOD);
    end

    // release reset
    tb_rstn = 1'b1;

  end

  // Toggling the clock
  always #(CLOCK_PERIOD/2) tb_clk = ~tb_clk;


  // set clock controls to use ref_clock
  assign clk_ctrl_s = 8'h9;

  `ifndef SIM_UART
  /*****************
  * UART PRINTING *
  *****************/
  uart_bus #(
    .BAUD_RATE ( 115200 ),
    .PARITY_EN ( 0      )
    ) i_tb_uart (
      .rx    ( uart_tx_s ),
      .tx    ( uart_rx_s ),
      .rx_en ( tb_rstn   )
      );
  `else
      // drive unused signals low
      assign uart_rx_s    = 1'b0;
  `endif
/*********
 *  AXI  *
 *********/

 //external AXI M & AXI S
 // AXI DV master -> Marian Slave
 axi_dv_m_resp_t axi_dv_m_resp_i;
 axi_dv_m_req_t  axi_dv_m_req_o;
 // Marian Master -> AXI DV Slave
 axi_dv_s_resp_t axi_dv_s_resp_o;
 axi_dv_s_req_t  axi_dv_s_req_i;

//AXI Master Port
 AXI_BUS_DV #(
    .AXI_ADDR_WIDTH( AXI_DV_ADDR_WIDTH ),
    .AXI_DATA_WIDTH( AXI_DV_DATA_WIDTH ),
    .AXI_ID_WIDTH  ( AXI_DV_ID_WIDTH   ),
    .AXI_USER_WIDTH( AXI_DV_USER_WIDTH )
  ) master_dv (
    .clk_i(tb_clk)
  );
//instantiate AXI bus
  AXI_BUS #(
    .AXI_ADDR_WIDTH( AXI_DV_ADDR_WIDTH ),
    .AXI_DATA_WIDTH( AXI_DV_DATA_WIDTH ),
    .AXI_ID_WIDTH  ( AXI_DV_ID_WIDTH   ),
    .AXI_USER_WIDTH( AXI_DV_USER_WIDTH )
  ) master ();

  typedef axi_test::axi_driver #(
    // AXI interface parameters
  .AW ( AXI_DV_ADDR_WIDTH ),
  .DW ( AXI_DV_DATA_WIDTH ),
  .IW ( AXI_DV_ID_WIDTH   ),
  .UW ( AXI_DV_USER_WIDTH ),
  // Stimuli application and test time
  .TA (500ps),
  .TT (500ps)
  // Maximum number of read and write transactions in flight
  //.MAX_READ_TXNS  ( 8 ),
  //.MAX_WRITE_TXNS ( 8 ),
  //.AXI_EXCLS      (   ),
  //.AXI_ATOPS      (   ),
  //.UNIQUE_IDS     (   )
  ) axi_drv_mst_t;
  axi_drv_mst_t axi_drv_mst = new (master_dv);

  // connect dv master axi bus to the dut ports
  `AXI_ASSIGN           (master,         master_dv      )
  `AXI_ASSIGN_TO_REQ    (axi_dv_m_req_o, master         )
  `AXI_ASSIGN_FROM_RESP (master,         axi_dv_m_resp_i)

  //Axi slave port
  AXI_BUS_DV #(
    .AXI_ADDR_WIDTH( AXI_DV_ADDR_WIDTH ),
    .AXI_DATA_WIDTH( AXI_DV_DATA_WIDTH ),
    .AXI_ID_WIDTH  ( AXI_DV_ID_WIDTH   ),
    .AXI_USER_WIDTH( AXI_DV_USER_WIDTH )
  ) slave_dv (
    .clk_i(tb_clk)
  );

  AXI_BUS #(
    .AXI_ADDR_WIDTH( AXI_DV_ADDR_WIDTH ),
    .AXI_DATA_WIDTH( AXI_DV_DATA_WIDTH ),
    .AXI_ID_WIDTH  ( AXI_DV_ID_WIDTH   ),
    .AXI_USER_WIDTH( AXI_DV_USER_WIDTH )
  ) slave ();

  axi_test::axi_rand_slave #(
    .AW( AXI_DV_ADDR_WIDTH ),
    .DW( AXI_DV_DATA_WIDTH ),
    .IW( AXI_DV_ID_WIDTH   ),
    .UW( AXI_DV_USER_WIDTH ),
    .TA(  ),
    .TT( 500ps )
  ) axi_rand_slave = new (slave_dv);

  // connect dv slave axi bus to the dut ports
  `AXI_ASSIGN          (slave_dv,        slave         )
  `AXI_ASSIGN_FROM_REQ (slave,           axi_dv_s_req_i)
  `AXI_ASSIGN_TO_RESP  (axi_dv_s_resp_o, slave         )


/*********
 *  QSPI *
 *********/
 axi_dv_s_resp_t spi_dv_m_resp;
 axi_dv_s_req_t  spi_dv_m_req;
  //Axi slave port
 AXI_BUS_DV #(
  .AXI_ADDR_WIDTH( AXI_DV_ADDR_WIDTH ),
  .AXI_DATA_WIDTH( AXI_DV_DATA_WIDTH ),
  .AXI_ID_WIDTH  ( AXI_DV_ID_WIDTH   ),
  .AXI_USER_WIDTH( AXI_DV_USER_WIDTH )
 ) spi_axi_dv (
  .clk_i(tb_clk)
);

AXI_BUS #(
  .AXI_ADDR_WIDTH( AXI_DV_ADDR_WIDTH ),
  .AXI_DATA_WIDTH( AXI_DV_DATA_WIDTH ),
  .AXI_ID_WIDTH  ( AXI_DV_ID_WIDTH   ),
  .AXI_USER_WIDTH( AXI_DV_USER_WIDTH )
) spi_axi ();

axi_test::axi_rand_slave #(
    .AW( AXI_DV_ADDR_WIDTH ),
    .DW( AXI_DV_DATA_WIDTH ),
    .IW( AXI_DV_ID_WIDTH   ),
    .UW( AXI_DV_USER_WIDTH ),
    .TA(  ),
    .TT( 500ps )
  ) spi_rand_slave = new (spi_axi_dv);
// connect dv slave axi bus to the dut ports
`AXI_ASSIGN           (spi_axi_dv,  spi_axi    )
`AXI_ASSIGN_TO_RESP    (spi_dv_m_resp, spi_axi  )
`AXI_ASSIGN_FROM_REQ (spi_axi,  spi_dv_m_req)

  axi_spi_slave #(
      .AXI_ADDR_WIDTH(AXI_DV_ADDR_WIDTH),
      .AXI_DATA_WIDTH(AXI_DV_DATA_WIDTH),
      .AXI_USER_WIDTH(AXI_DV_USER_WIDTH),
      .AXI_ID_WIDTH  (AXI_DV_ID_WIDTH  ),
      .DUMMY_CYCLES  (                 )
  )i_axi_spi_slave(
      .test_mode('0                     ),
      .spi_sclk (marian_qspi_sclk_o   ),
      .spi_cs   (marian_qspi_csn_o    ),
      .spi_mode (                     ),
      .spi_sdi0 (marian_qspi_data_o[0]),
      .spi_sdi1 (marian_qspi_data_o[1]),
      .spi_sdi2 (marian_qspi_data_o[2]),
      .spi_sdi3 (marian_qspi_data_o[3]),
      .spi_sdo0 (marian_qspi_data_i[0]),
      .spi_sdo1 (marian_qspi_data_i[1]),
      .spi_sdo2 (marian_qspi_data_i[2]),
      .spi_sdo3 (marian_qspi_data_i[3]),
   
       // AXI4 MASTER
       //***************************************
       .axi_aclk           (tb_clk ),
       .axi_aresetn        (tb_rstn),
       // WRITE ADDRESS CHANNEL
       .axi_master_aw_valid(spi_dv_m_req.aw_valid  ),
       .axi_master_aw_addr (spi_dv_m_req.aw.addr   ),
       .axi_master_aw_prot (spi_dv_m_req.aw.prot   ),
       .axi_master_aw_region(spi_dv_m_req.aw.region),
       .axi_master_aw_len  (spi_dv_m_req.aw.len    ),
       .axi_master_aw_size (spi_dv_m_req.aw.size   ),
       .axi_master_aw_burst(spi_dv_m_req.aw.burst  ),
       .axi_master_aw_lock (spi_dv_m_req.aw.lock   ),
       .axi_master_aw_cache(spi_dv_m_req.aw.cache  ),
       .axi_master_aw_qos  (spi_dv_m_req.aw.qos    ),
       .axi_master_aw_id   (spi_dv_m_req.aw.id     ),
       .axi_master_aw_user (spi_dv_m_req.aw.user   ),
       .axi_master_aw_ready(spi_dv_m_resp.aw_ready  ),
   
       // READ ADDRESS CHANNEL
       .axi_master_ar_valid (spi_dv_m_req.ar_valid ),
       .axi_master_ar_addr  (spi_dv_m_req.ar.addr  ),
       .axi_master_ar_prot  (spi_dv_m_req.ar.prot  ),
       .axi_master_ar_region(spi_dv_m_req.ar.region),
       .axi_master_ar_len   (spi_dv_m_req.ar.len   ),
       .axi_master_ar_size  (spi_dv_m_req.ar.size  ),
       .axi_master_ar_burst (spi_dv_m_req.ar.burst ),
       .axi_master_ar_lock  (spi_dv_m_req.ar.lock  ),
       .axi_master_ar_cache (spi_dv_m_req.ar.cache ),
       .axi_master_ar_qos   (spi_dv_m_req.ar.qos   ),
       .axi_master_ar_id    (spi_dv_m_req.ar.id    ),
       .axi_master_ar_user  (spi_dv_m_req.ar.user  ),
       .axi_master_ar_ready (spi_dv_m_resp.ar_ready ),
   
       // WRITE DATA CHANNEL
       .axi_master_w_valid(spi_dv_m_req.w_valid),
       .axi_master_w_data (spi_dv_m_req.w.data ),
       .axi_master_w_strb (spi_dv_m_req.w.strb ),
       .axi_master_w_user (spi_dv_m_req.w.user ),
       .axi_master_w_last (spi_dv_m_req.w.last ),
       .axi_master_w_ready(spi_dv_m_resp.w_ready),
   
       // READ DATA CHANNEL
       .axi_master_r_valid(spi_dv_m_resp.r_valid),
       .axi_master_r_data (spi_dv_m_resp.r.data ),
       .axi_master_r_resp (spi_dv_m_resp.r.resp ),
       .axi_master_r_last (spi_dv_m_resp.r.last ),
       .axi_master_r_id   (spi_dv_m_resp.r.id   ),
       .axi_master_r_user (spi_dv_m_resp.r.user ),
       .axi_master_r_ready(spi_dv_m_req.r_ready),
   
       // WRITE RESPONSE CHANNEL
       .axi_master_b_valid(spi_dv_m_resp.b_valid),
       .axi_master_b_resp (spi_dv_m_resp.b.resp ),
       .axi_master_b_id   (spi_dv_m_resp.b.id   ),
       .axi_master_b_user (spi_dv_m_resp.b.user ),
       .axi_master_b_ready(spi_dv_m_req.b_ready)
  );
 
/*********
 * TASKS *
 *********/
  //Write to marian external AXI
  task axi_write_mst( input int addr, input longint data, input int strb, input logic print=0);
    automatic axi_drv_mst_t::ax_beat_t ax_beat = new;
    automatic axi_drv_mst_t::w_beat_t  w_beat  = new;
    automatic axi_drv_mst_t::b_beat_t b_beat;
    //send aw
    ax_beat.ax_addr = addr;
    ax_beat.ax_len  = 0;
    ax_beat.ax_size = $clog2(marian_pkg::AxiExtStrbWidth);
    ax_beat.ax_burst = axi_pkg::BURST_INCR;
    axi_drv_mst.send_aw(ax_beat);
    //send w
    w_beat.w_data = data;
    w_beat.w_strb = strb;
    w_beat.w_last =  1;
    axi_drv_mst.send_w(w_beat);
    if (print) $display("WRITE to ADDR %h, DATA %h \n", ax_beat.ax_addr, w_beat.w_data);
    // B
    axi_drv_mst.recv_b(b_beat);
    assert(b_beat.b_resp == axi_pkg::RESP_OKAY);
  endtask

  //Read from marian external AXI
  task axi_read_mst( input int addr, output longint data, input logic print=0 );
    automatic axi_drv_mst_t::ax_beat_t ax_beat = new;
    automatic axi_drv_mst_t::r_beat_t r_beat = new;

    ax_beat.ax_addr = addr;
    axi_drv_mst.send_ar(ax_beat);
    axi_drv_mst.recv_r(r_beat);
    if (print) $display("READ data: %h ", r_beat.r_data);
    data = r_beat.r_data;
  endtask

/*********
 *  DUT  *
 *********/
  // cdc_src -> wrapper
  logic [76:0] marian_axi_s_aw_data_src2dst;
  logic [1:0]  marian_axi_s_aw_rd_data_ptr_dst2src;
  logic [2:0]  marian_axi_s_aw_rd_ptr_gray_dst2src;
  logic [2:0]  marian_axi_s_aw_aw_wr_ptr_gray_src2dst;
  logic [70:0] marian_axi_s_ar_data_src2dst;
  logic [1:0]  marian_axi_s_ar_rd_data_ptr_dst2src;
  logic [2:0]  marian_axi_s_ar_rd_ptr_gray_dst2src;
  logic [2:0]  marian_axi_s_ar_wr_ptr_gray_src2dst;
  logic [73:0] marian_axi_s_w_data_src2dst;
  logic [1:0]  marian_axi_s_w_rd_data_ptr_dst2src;
  logic [2:0]  marian_axi_s_w_rd_ptr_gray_dst2src;
  logic [2:0]  marian_axi_s_w_wr_ptr_gray_src2dst;
  logic [76:0] marian_axi_s_r_data_dst2src;
  logic [1:0]  marian_axi_s_r_rd_data_ptr_src2dst;
  logic [2:0]  marian_axi_s_r_rd_ptr_gray_src2dst;
  logic [2:0]  marian_axi_s_r_wr_ptr_gray_dst2src;
  logic [11:0] marian_axi_s_b_data_dst2src;
  logic [1:0]  marian_axi_s_b_rd_data_ptr_src2dst;
  logic [2:0]  marian_axi_s_b_rd_ptr_gray_src2dst;
  logic [2:0]  marian_axi_s_b_wr_ptr_gray_dst2src;
  // wrapper -> cdc_dst
  logic [70:0] marian_axi_m_ar_data_src2dst;
  logic [2:0]  marian_axi_m_ar_wr_ptr_gray_src2dst;
  logic [76:0] marian_axi_m_aw_data_src2dst;
  logic [2:0]  marian_axi_m_aw_wr_ptr_gray_src2dst;
  logic [1:0]  marian_axi_m_b_rd_data_ptr_src2dst;
  logic [2:0]  marian_axi_m_b_rd_ptr_gray_src2dst;
  logic [1:0]  marian_axi_m_r_rd_data_ptr_src2dst;
  logic [2:0]  marian_axi_m_r_rd_ptr_gray_src2dst;
  logic [73:0] marian_axi_m_w_data_src2dst;
  logic [2:0]  marian_axi_m_w_wr_ptr_gray_src2dst;
  logic [1:0]  marian_axi_m_ar_rd_data_ptr_dst2src;
  logic [2:0]  marian_axi_m_ar_rd_ptr_gray_dst2src;
  logic [1:0]  marian_axi_m_aw_rd_data_ptr_dst2src;
  logic [2:0]  marian_axi_m_aw_rd_ptr_gray_dst2src;
  logic [11:0] marian_axi_m_b_data_dst2src;
  logic [2:0]  marian_axi_m_b_wr_ptr_gray_dst2src;
  logic [76:0] marian_axi_m_r_data_dst2src;
  logic [2:0]  marian_axi_m_r_wr_ptr_gray_dst2src;
  logic [1:0]  marian_axi_m_w_rd_data_ptr_dst2src;
  logic [2:0]  marian_axi_m_w_rd_ptr_gray_dst2src;

  logic [1:0] gpio_out_s;
  logic [1:0] gpio_in_s;

  // Loop back GPIO for testing
  assign gpio_in_s = {gpio_out_s[0],gpio_out_s[1]};

  axi_cdc_split_intf_src #(
    .AXI_ID_WIDTH  ( AXI_ID_WIDTH     ),
    .AXI_ADDR_WIDTH( AXI_ADDR_WIDTH   ),
    .AXI_DATA_WIDTH( AXI_DATA_WIDTH   ),
    .AXI_USER_WIDTH( AXI_USER_WIDTH   ),
    .LOG_DEPTH     ( AXI_LOG_DEPTH    ),
    .AW_DATA_SIZE  ( AXI_AW_DATA_SIZE ),
    .AR_DATA_SIZE  ( AXI_AR_DATA_SIZE ),
    .W_DATA_SIZE   ( AXI_W_DATA_SIZE  ),
    .R_DATA_SIZE   ( AXI_R_DATA_SIZE  ),
    .B_DATA_SIZE   ( AXI_B_DATA_SIZE  )
  ) i_axi_slave_cdc_split_intf_src (
    .src_clk_i  ( tb_clk  ),
    .src_rst_ni ( tb_rstn ),
    .icn_rst_ni ( tb_rstn ),

    .aw_id     ( axi_dv_m_req_o.aw.id     ),
    .aw_addr   ( axi_dv_m_req_o.aw.addr   ),
    .aw_len    ( axi_dv_m_req_o.aw.len    ),
    .aw_size   ( axi_dv_m_req_o.aw.size   ),
    .aw_burst  ( axi_dv_m_req_o.aw.burst  ),
    .aw_lock   ( axi_dv_m_req_o.aw.lock   ),
    .aw_cache  ( axi_dv_m_req_o.aw.cache  ),
    .aw_prot   ( axi_dv_m_req_o.aw.prot   ),
    .aw_qos    ( axi_dv_m_req_o.aw.qos    ),
    .aw_region ( axi_dv_m_req_o.aw.region ),
    .aw_atop   ( axi_dv_m_req_o.aw.atop   ),
    .aw_user   ( axi_dv_m_req_o.aw.user   ),
    .aw_valid  ( axi_dv_m_req_o.aw_valid  ),
    .aw_ready  ( axi_dv_m_resp_i.aw_ready ),

    .w_data    ( axi_dv_m_req_o.w.data    ),
    .w_strb    ( axi_dv_m_req_o.w.strb    ),
    .w_last    ( axi_dv_m_req_o.w.last    ),
    .w_user    ( axi_dv_m_req_o.w.user    ),
    .w_valid   ( axi_dv_m_req_o.w_valid   ),
    .w_ready   ( axi_dv_m_resp_i.w_ready  ),

    .b_id      ( axi_dv_m_resp_i.b.id     ),
    .b_resp    ( axi_dv_m_resp_i.b.resp   ),
    .b_user    ( axi_dv_m_resp_i.b.user   ),
    .b_valid   ( axi_dv_m_resp_i.b_valid  ),
    .b_ready   ( axi_dv_m_req_o.b_ready   ),

    .ar_id     ( axi_dv_m_req_o.ar.id     ),
    .ar_addr   ( axi_dv_m_req_o.ar.addr   ),
    .ar_len    ( axi_dv_m_req_o.ar.len    ),
    .ar_size   ( axi_dv_m_req_o.ar.size   ),
    .ar_burst  ( axi_dv_m_req_o.ar.burst  ),
    .ar_lock   ( axi_dv_m_req_o.ar.lock   ),
    .ar_cache  ( axi_dv_m_req_o.ar.cache  ),
    .ar_prot   ( axi_dv_m_req_o.ar.prot   ),
    .ar_qos    ( axi_dv_m_req_o.ar.qos    ),
    .ar_region ( axi_dv_m_req_o.ar.region ),
    .ar_user   ( axi_dv_m_req_o.ar.user   ),
    .ar_valid  ( axi_dv_m_req_o.ar_valid  ),
    .ar_ready  ( axi_dv_m_resp_i.ar_ready ),

    .r_id      ( axi_dv_m_resp_i.r.id     ),
    .r_data    ( axi_dv_m_resp_i.r.data   ),
    .r_resp    ( axi_dv_m_resp_i.r.resp   ),
    .r_last    ( axi_dv_m_resp_i.r.last   ),
    .r_user    ( axi_dv_m_resp_i.r.user   ),
    .r_valid   ( axi_dv_m_resp_i.r_valid  ),
    .r_ready   ( axi_dv_m_req_o.r_ready   ),

    .aw_data_src2dst        ( marian_axi_s_aw_data_src2dst           ),
    .aw_rd_data_ptr_dst2src ( marian_axi_s_aw_rd_data_ptr_dst2src    ),
    .aw_rd_ptr_gray_dst2src ( marian_axi_s_aw_rd_ptr_gray_dst2src    ),
    .aw_wr_ptr_gray_src2dst ( marian_axi_s_aw_aw_wr_ptr_gray_src2dst ),

    .ar_data_src2dst        ( marian_axi_s_ar_data_src2dst           ),
    .ar_rd_data_ptr_dst2src ( marian_axi_s_ar_rd_data_ptr_dst2src    ),
    .ar_rd_ptr_gray_dst2src ( marian_axi_s_ar_rd_ptr_gray_dst2src    ),
    .ar_wr_ptr_gray_src2dst ( marian_axi_s_ar_wr_ptr_gray_src2dst    ),

    .w_data_src2dst         ( marian_axi_s_w_data_src2dst            ),
    .w_rd_data_ptr_dst2src  ( marian_axi_s_w_rd_data_ptr_dst2src     ),
    .w_rd_ptr_gray_dst2src  ( marian_axi_s_w_rd_ptr_gray_dst2src     ),
    .w_wr_ptr_gray_src2dst  ( marian_axi_s_w_wr_ptr_gray_src2dst     ),

    .r_data_dst2src         ( marian_axi_s_r_data_dst2src            ),
    .r_rd_data_ptr_src2dst  ( marian_axi_s_r_rd_data_ptr_src2dst     ),
    .r_rd_ptr_gray_src2dst  ( marian_axi_s_r_rd_ptr_gray_src2dst     ),
    .r_wr_ptr_gray_dst2src  ( marian_axi_s_r_wr_ptr_gray_dst2src     ),

    .b_data_dst2src         ( marian_axi_s_b_data_dst2src            ),
    .b_rd_data_ptr_src2dst  ( marian_axi_s_b_rd_data_ptr_src2dst     ),
    .b_rd_ptr_gray_src2dst  ( marian_axi_s_b_rd_ptr_gray_src2dst     ),
    .b_wr_ptr_gray_dst2src  ( marian_axi_s_b_wr_ptr_gray_dst2src     )
  );

  axi_cdc_split_intf_dst #(
    .AXI_ID_WIDTH      ( AXI_ID_WIDTH     ),
    .AXI_ADDR_WIDTH    ( AXI_ADDR_WIDTH   ),
    .AXI_DATA_WIDTH    ( AXI_DATA_WIDTH   ),
    .AXI_USER_WIDTH    ( 1                ),
    .LOG_DEPTH         ( AXI_LOG_DEPTH    ),
    .AW_DATA_SIZE      ( DST_AW_DATA_SIZE ),
    .AR_DATA_SIZE      ( DST_AR_DATA_SIZE ),
    .W_DATA_SIZE       ( DST_W_DATA_SIZE  ),
    .R_DATA_SIZE       ( DST_R_DATA_SIZE  ),
    .B_DATA_SIZE       ( DST_B_DATA_SIZE  )
  ) i_axi_cdc_split_dst (
    .dst_clk_i   ( tb_clk   ),
    .dst_rst_ni  ( tb_rstn  ),
    .icn_rst_ni  ( tb_rstn  ),

    .aw_dst_data ( axi_dv_s_req_i.aw         ),
    .aw_id       ( axi_dv_s_req_i.aw.id      ),
    .aw_addr     ( axi_dv_s_req_i.aw.addr    ),
    .aw_len      ( axi_dv_s_req_i.aw.len     ),
    .aw_size     ( axi_dv_s_req_i.aw.size    ),
    .aw_burst    ( axi_dv_s_req_i.aw.burst   ),
    .aw_lock     ( axi_dv_s_req_i.aw.lock    ),
    .aw_cache    ( axi_dv_s_req_i.aw.cache   ),
    .aw_prot     ( axi_dv_s_req_i.aw.prot    ),
    .aw_qos      ( axi_dv_s_req_i.aw.qos     ),
    .aw_region   ( axi_dv_s_req_i.aw.region  ),
    .aw_atop     ( axi_dv_s_req_i.aw.atop    ),
    .aw_user     ( axi_dv_s_req_i.aw.user    ),
    .aw_valid    ( axi_dv_s_req_i.aw_valid   ),
    .aw_ready    ( axi_dv_s_resp_o.aw_ready  ),

    .w_data      ( axi_dv_s_req_i.w.data     ),
    .w_strb      ( axi_dv_s_req_i.w.strb     ),
    .w_last      ( axi_dv_s_req_i.w.last     ),
    .w_user      ( axi_dv_s_req_i.w.user     ),
    .w_valid     ( axi_dv_s_req_i.w_valid    ),
    .w_ready     ( axi_dv_s_resp_o.w_ready   ),

    .ar_id       ( axi_dv_s_req_i.ar.id      ),
    .ar_addr     ( axi_dv_s_req_i.ar.addr    ),
    .ar_len      ( axi_dv_s_req_i.ar.len     ),
    .ar_size     ( axi_dv_s_req_i.ar.size    ),
    .ar_burst    ( axi_dv_s_req_i.ar.burst   ),
    .ar_lock     ( axi_dv_s_req_i.ar.lock    ),
    .ar_cache    ( axi_dv_s_req_i.ar.cache   ),
    .ar_prot     ( axi_dv_s_req_i.ar.prot    ),
    .ar_qos      ( axi_dv_s_req_i.ar.qos     ),
    .ar_region   ( axi_dv_s_req_i.ar.region  ),
    .ar_user     ( axi_dv_s_req_i.ar.user    ),
    .ar_valid    ( axi_dv_s_req_i.ar_valid   ),
    .ar_ready    ( axi_dv_s_resp_o.ar_ready  ),

    .r_id        ( axi_dv_s_resp_o.r.id      ),
    .r_data      ( axi_dv_s_resp_o.r.data    ),
    .r_resp      ( axi_dv_s_resp_o.r.resp    ),
    .r_last      ( axi_dv_s_resp_o.r.last    ),
    .r_user      ( axi_dv_s_resp_o.r.user    ),
    .r_valid     ( axi_dv_s_resp_o.r_valid   ),
    .r_ready     ( axi_dv_s_req_i.r_ready    ),

    .b_id        ( axi_dv_s_resp_o.b.id      ),
    .b_resp      ( axi_dv_s_resp_o.b.resp    ),
    .b_user      ( axi_dv_s_resp_o.b.user    ),
    .b_valid     ( axi_dv_s_resp_o.b_valid   ),
    .b_ready     ( axi_dv_s_req_i.b_ready    ),

    .aw_data_src2dst        ( marian_axi_m_aw_data_src2dst        ),
    .aw_rd_data_ptr_dst2src ( marian_axi_m_aw_rd_data_ptr_dst2src ),
    .aw_rd_ptr_gray_dst2src ( marian_axi_m_aw_rd_ptr_gray_dst2src ),
    .aw_wr_ptr_gray_src2dst ( marian_axi_m_aw_wr_ptr_gray_src2dst ),

    .ar_data_src2dst        ( marian_axi_m_ar_data_src2dst        ),
    .ar_rd_data_ptr_dst2src ( marian_axi_m_ar_rd_data_ptr_dst2src ),
    .ar_rd_ptr_gray_dst2src ( marian_axi_m_ar_rd_ptr_gray_dst2src ),
    .ar_wr_ptr_gray_src2dst ( marian_axi_m_ar_wr_ptr_gray_src2dst ),

    .w_data_src2dst         ( marian_axi_m_w_data_src2dst         ),
    .w_rd_data_ptr_dst2src  ( marian_axi_m_w_rd_data_ptr_dst2src  ),
    .w_rd_ptr_gray_dst2src  ( marian_axi_m_w_rd_ptr_gray_dst2src  ),
    .w_wr_ptr_gray_src2dst  ( marian_axi_m_w_wr_ptr_gray_src2dst  ),

    .r_data_dst2src         ( marian_axi_m_r_data_dst2src         ),
    .r_rd_data_ptr_src2dst  ( marian_axi_m_r_rd_data_ptr_src2dst  ),
    .r_rd_ptr_gray_src2dst  ( marian_axi_m_r_rd_ptr_gray_src2dst  ),
    .r_wr_ptr_gray_dst2src  ( marian_axi_m_r_wr_ptr_gray_dst2src  ),

    .b_data_dst2src         ( marian_axi_m_b_data_dst2src         ),
    .b_rd_data_ptr_src2dst  ( marian_axi_m_b_rd_data_ptr_src2dst  ),
    .b_rd_ptr_gray_src2dst  ( marian_axi_m_b_rd_ptr_gray_src2dst  ),
    .b_wr_ptr_gray_dst2src  ( marian_axi_m_b_wr_ptr_gray_dst2src  )
  );

  vector_crypto_ss_wrapper_0 i_dut (
    .vcss_clk_ctrl_i                               ( clk_ctrl_s        ),
    .vcss_gpio_i                                   ( gpio_in_s         ),
    .vcss_gpio_o                                   ( gpio_out_s        ),
    .vcss_gpio_oe_o                                ( /* UNCONNECTED */ ),
    .vcss_rst_ni                                   ( tb_rstn           ),
    .vcss_ext_irq_i                                ( '0                ),
    .vcss_ext_irq_o                                ( /* UNCONNECTED */ ),
    .vcss_jtag_tck_i                               ( jtag_tck_s        ),
    .vcss_jtag_tdi_i                               ( jtag_tdi_s        ),
    .vcss_jtag_tms_i                               ( jtag_tms_s        ),
    .vcss_jtag_trst_i                              ( jtag_trstn_s      ),
    .vcss_jtag_tdo_o                               ( jtag_tdo_s        ),
    .vcss_64b_s_ar_rd_data_ptr_dst2src_o           ( marian_axi_s_ar_rd_data_ptr_dst2src),
    .vcss_64b_s_ar_rd_ptr_gray_dst2src_o           ( marian_axi_s_ar_rd_ptr_gray_dst2src),
    .vcss_64b_s_aw_rd_data_ptr_dst2src_o           ( marian_axi_s_aw_rd_data_ptr_dst2src),
    .vcss_64b_s_aw_rd_ptr_gray_dst2src_o           ( marian_axi_s_aw_rd_ptr_gray_dst2src),
    .vcss_64b_s_b_data_dst2src_o                   ( marian_axi_s_b_data_dst2src        ),
    .vcss_64b_s_b_wr_ptr_gray_dst2src_o            ( marian_axi_s_b_wr_ptr_gray_dst2src ),
    .vcss_64b_s_r_data_dst2src_o                   ( marian_axi_s_r_data_dst2src        ),
    .vcss_64b_s_r_wr_ptr_gray_dst2src_o            ( marian_axi_s_r_wr_ptr_gray_dst2src ),
    .vcss_64b_s_w_rd_data_ptr_dst2src_o            ( marian_axi_s_w_rd_data_ptr_dst2src ),
    .vcss_64b_s_w_rd_ptr_gray_dst2src_o            ( marian_axi_s_w_rd_ptr_gray_dst2src ),
    .vcss_64b_s_ar_data_src2dst_i                  ( marian_axi_s_ar_data_src2dst       ),
    .vcss_64b_s_ar_wr_ptr_gray_src2dst_i           ( marian_axi_s_ar_wr_ptr_gray_src2dst),
    .vcss_64b_s_aw_data_src2dst_i                  ( marian_axi_s_aw_data_src2dst       ),
    .vcss_64b_s_aw_wr_ptr_gray_src2dst_i           ( marian_axi_s_aw_aw_wr_ptr_gray_src2dst),
    .vcss_64b_s_b_rd_data_ptr_src2dst_i            ( marian_axi_s_b_rd_data_ptr_src2dst ),
    .vcss_64b_s_b_rd_ptr_gray_src2dst_i            ( marian_axi_s_b_rd_ptr_gray_src2dst ),
    .vcss_64b_s_r_rd_data_ptr_src2dst_i            ( marian_axi_s_r_rd_data_ptr_src2dst ),
    .vcss_64b_s_r_rd_ptr_gray_src2dst_i            ( marian_axi_s_r_rd_ptr_gray_src2dst ),
    .vcss_64b_s_w_data_src2dst_i                   ( marian_axi_s_w_data_src2dst        ),
    .vcss_64b_s_w_wr_ptr_gray_src2dst_i            ( marian_axi_s_w_wr_ptr_gray_src2dst ),
    .vcss_pll_debug_ctrl_i                         ( '0                ),
    .vcss_pll_div_i                                ( '0                ),
    .vcss_pll_enable_i                             ( '0                ),
    .vcss_pll_loop_ctrl_i                          ( '0                ),
    .vcss_pll_spare_ctrl_i                         ( '0                ),
    .vcss_pll_tmux_sel_i                           ( '0                ),
    .vcss_pll_valid_i                              ( '0                ),
    .vcss_pll_status_1_o                           ( /* UNCONNECTED */ ),
    .vcss_pll_status_2_o                           ( /* UNCONNECTED */ ),
    .vcss_qspi_data_i                              ( marian_qspi_data_i),
    .vcss_qspi_csn_o                               ( marian_qspi_csn_o ),
    .vcss_qspi_data_o                              ( marian_qspi_data_o),
    .vcss_qspi_oe_o                                ( marian_qspi_oe    ),
    .vcss_qspi_sclk_o                              ( marian_qspi_sclk_o),
    .vcss_refclk_i                                 ( tb_clk            ),
    .vcss_ref_rst_ni                               ( tb_rstn           ),
    .vcss_64b_m_ar_data_src2dst_o                  ( marian_axi_m_ar_data_src2dst       ),
    .vcss_64b_m_ar_wr_ptr_gray_src2dst_o           ( marian_axi_m_ar_wr_ptr_gray_src2dst),
    .vcss_64b_m_aw_data_src2dst_o                  ( marian_axi_m_aw_data_src2dst       ),
    .vcss_64b_m_aw_wr_ptr_gray_src2dst_o           ( marian_axi_m_aw_wr_ptr_gray_src2dst),
    .vcss_64b_m_b_rd_data_ptr_src2dst_o            ( marian_axi_m_b_rd_data_ptr_src2dst ),
    .vcss_64b_m_b_rd_ptr_gray_src2dst_o            ( marian_axi_m_b_rd_ptr_gray_src2dst ),
    .vcss_64b_m_r_rd_data_ptr_src2dst_o            ( marian_axi_m_r_rd_data_ptr_src2dst ),
    .vcss_64b_m_r_rd_ptr_gray_src2dst_o            ( marian_axi_m_r_rd_ptr_gray_src2dst ),
    .vcss_64b_m_w_data_src2dst_o                   ( marian_axi_m_w_data_src2dst        ),
    .vcss_64b_m_w_wr_ptr_gray_src2dst_o            ( marian_axi_m_w_wr_ptr_gray_src2dst ),
    .vcss_64b_m_ar_rd_data_ptr_dst2src_i           ( marian_axi_m_ar_rd_data_ptr_dst2src),
    .vcss_64b_m_ar_rd_ptr_gray_dst2src_i           ( marian_axi_m_ar_rd_ptr_gray_dst2src),
    .vcss_64b_m_aw_rd_data_ptr_dst2src_i           ( marian_axi_m_aw_rd_data_ptr_dst2src),
    .vcss_64b_m_aw_rd_ptr_gray_dst2src_i           ( marian_axi_m_aw_rd_ptr_gray_dst2src),
    .vcss_64b_m_b_data_dst2src_i                   ( marian_axi_m_b_data_dst2src        ),
    .vcss_64b_m_b_wr_ptr_gray_dst2src_i            ( marian_axi_m_b_wr_ptr_gray_dst2src ),
    .vcss_64b_m_r_data_dst2src_i                   ( marian_axi_m_r_data_dst2src        ),
    .vcss_64b_m_r_wr_ptr_gray_dst2src_i            ( marian_axi_m_r_wr_ptr_gray_dst2src ),
    .vcss_64b_m_w_rd_data_ptr_dst2src_i            ( marian_axi_m_w_rd_data_ptr_dst2src ),
    .vcss_64b_m_w_rd_ptr_gray_dst2src_i            ( marian_axi_m_w_rd_ptr_gray_dst2src ),
    .vcss_uart_rx_i                                ( uart_rx_s         ),
    .vcss_uart_tx_o                                ( uart_tx_s         )
  );




/***************************
 * Logic to initialise L2  *
 ***************************/
 `ifndef VERILATOR

  initial begin

    jtag_tck_s   = 1'b1;
    jtag_tdi_s   = 1'b0;
    jtag_tms_s   = 1'b1;
    jtag_trstn_s = 1'b1;

    $display("\n---- MEMORY INITIALISATION START ----");

    if (L2_INIT_METHOD == "FILE") begin
      // sram is initialised on reset, wait 2 cycles and overwrite contents
      repeat(2)
        @(posedge tb_clk);

      $display("[MARIAN_TB @ %7t] - Writing file %s to i_dut.marian_top.i_bootram.ram...",
        $realtime, L2_MEM_INIT_FILE);

      // iterate through each word of the memory variable
      for(int word_idx = 0; word_idx < L2Words; word_idx++) begin

        // note that when using verilator, x's will not be found and therefore utilisation
        // will not be reported. The entire array 'mem_init_arr' will be loaded into L2.
        if ($isunknown(mem_init_arr[word_idx])) begin
          $display("[MARIAN_TB @ %7t] - Finished writing %0d Bytes of data into RAM",
            $realtime, (word_idx*(AxiDataWidth/8)));
          $display("[MARIAN_TB @ %7t] - L2 Utilisation: %0.2f%%", $realtime,
            (real'(word_idx)/L2Words)*100.0);
          break; // break if reached uninitialised memory location
        end else begin
          // write word of memory into packed init value of the i_bootram SRAM
          i_dut.marian_top.i_bootram.ram[word_idx] = mem_init_arr[word_idx];
        end

        // check whether RAM is full
        a_mem_limit: assert (word_idx != (L2Words-1))
        else $fatal("[MARIAN_TB @ %7t] - [ERROR] - L2 initialisation file is larger than L2 ",
          $realtime, "(%d Bytes)!", (L2Words*(AxiDataWidth/8)));

      end

      $display("\n----- MEMORY INITIALISATION END -----\n");

    end else if (L2_INIT_METHOD == "JTAG") begin

  /************************************
   * JTAG TAP sanity/connection tests *
   ************************************/

      $display("[MARIAN_TB @ %7t] - Performing JTAG Reset Test.", $realtime);
      jtag_reset(jtag_tck_s, jtag_tms_s, jtag_trstn_s, jtag_tdi_s);

      $display("[MARIAN_TB @ %7t] - Performing JTAG Soft-Reset Test.", $realtime);
      jtag_softreset(jtag_tck_s, jtag_tms_s, jtag_trstn_s, jtag_tdi_s);

      $display("[MARIAN_TB @ %7t] - Performing JTAG Bypass Test.", $realtime);
      jtag_bypass_test(jtag_tck_s, jtag_tms_s, jtag_trstn_s, jtag_tdi_s, jtag_tdo_s);

      $display("[MARIAN_TB @ %7t] - Performing JTAG Get IDCODE Test.", $realtime);
      jtag_get_idcode(jtag_tck_s, jtag_tms_s, jtag_trstn_s, jtag_tdi_s, jtag_tdo_s);

  /**********************
   * Debug Module tests *
   **********************/

      $display("[MARIAN_TB @ %7t] - Initialising JTAG TAP for DMI Access.", $realtime);
      marian_debug_if.init_dmi_access(jtag_tck_s, jtag_tms_s, jtag_trstn_s, jtag_tdi_s);

      $display("[MARIAN_TB @ %7t] - Setting DM to active.", $realtime);
      marian_debug_if.set_dmactive(1'b1, jtag_tck_s, jtag_tms_s, jtag_trstn_s, jtag_tdi_s,
        jtag_tdo_s);

      $display("[MARIAN_TB @ %7t] - Selecting the hart 0 to be halted.", $realtime);
      marian_debug_if.set_hartsel(9'b0, jtag_tck_s, jtag_tms_s, jtag_trstn_s, jtag_tdi_s,
        jtag_tdo_s);

      $display("[MARIAN_TB @ %7t] - Attempting to halt the HART.", $realtime);
      marian_debug_if.halt_harts(jtag_tck_s, jtag_tms_s, jtag_trstn_s, jtag_tdi_s, jtag_tdo_s);

      $display("[MARIAN_TB @ %7t] - Checking that hart is halted.", $realtime);
      marian_debug_if.read_debug_reg(dm::DMStatus, dmstatus, jtag_tck_s, jtag_tms_s, jtag_trstn_s,
        jtag_tdi_s, jtag_tdo_s);

      if (dmstatus.allhalted != 1'b1) begin
        $error("[MARIAN_TB @ %7t] - [FAILED] to halt core.", $realtime);
      end else begin
        $display("[MARIAN_TB @ %7t] - Core sucessfully halted.", $realtime);
      end

      $display("[MARIAN_TB @ %7t] - Setting boot address to 0x%0x.", $realtime, CVA6BootAddress);
      marian_debug_if.write_reg_abstract_cmd(riscv::CSR_DPC, CVA6BootAddress,
        jtag_tck_s, jtag_tms_s, jtag_trstn_s, jtag_tdi_s, jtag_tdo_s );


      /*********************************************************************************************/

    `ifdef DM_TESTS

      // Debug module testing

      $display("[MARIAN_TB @ %7t] - Running DM tests.", $realtime, CVA6BootAddress);
      marian_debug_if.run_dm_tests(CoreID, CVA6BootAddress, dm_test_err, dm_test_err_count,
        jtag_tck_s, jtag_tms_s, jtag_trstn_s, jtag_tdi_s, jtag_tdo_s);

      if (dm_test_err_count != 0) begin
        $error("[MARIAN_TB @ %7t] - Debug Module %0d tests failed!", $realtime, dm_test_err_count);
      end

    `endif

      /*********************************************************************************************/

  /*********************
   * Load L2 with JTAG *
   *********************/

      $display("[MARIAN_TB @ %7t] - Loading L2", $realtime);
      marian_debug_if.load_L2(CVA6BootAddress, mem_init_arr,
        jtag_tck_s, jtag_tms_s, jtag_trstn_s, jtag_tdi_s, jtag_tdo_s);

      // initialise JTAG TAP for DMI Access
      marian_debug_if.init_dmi_access(jtag_tck_s, jtag_tms_s, jtag_trstn_s, jtag_tdi_s);

      // we have set dpc and loaded the binary, we can go now
      $display("[MARIAN_TB @ %7t] - Resuming the CORE", $time);
      marian_debug_if.resume_harts(jtag_tck_s, jtag_tms_s, jtag_trstn_s, jtag_tdi_s, jtag_tdo_s);

    end else begin
      $fatal("[MARIAN_TB @ %7t] - ERROR: Invalid L2_INIT_METHOD specified.", $realtime);
    end

    // set bootram_rdy to 1 to initiate boot from bootRAM
    axi_drv_mst.reset_master();
    @(posedge i_axi_cdc_split_dst.rstn_sync3); // sync to cdc rst sync3
    #(5*RESET_DELAY_CYCLES*CLOCK_PERIOD);
    axi_write_mst(marian_pkg::CTRLBase + 48 , 1, 9'h1, 1'b0);
    `ifdef EXT_AXI_TEST
    begin
      axi_rand_slave.reset();
      $display("[MARIAN_TB] - Running External AXI test");
      fork
        axi_rand_slave.run();
        begin
          #(5*RESET_DELAY_CYCLES*CLOCK_PERIOD);
          #100 axi_write_mst(marian_pkg::AXIBase + 32 , 10, 9'h1, 1'b1 );
          #100 axi_write_mst(marian_pkg::DBGBase, 20, 9'h1, 1'b1 );
          #100 axi_write_mst(marian_pkg::QSPIBase, 30, 9'h1, 1'b1 );
          #100 axi_write_mst(marian_pkg::UARTBase, 40, 9'h1, 1'b1 );
        end
      join
    end
    `endif
    `ifdef SPI_TEST
      $display("[MARIAN_TB] - Running QSPI test");
      spi_rand_slave.reset();
      spi_rand_slave.run();
    `endif
  end

`endif

/***************************
 *  ARA AXI Write Dumping  *
 ***************************/
`ifdef IDEAL_DISPATCHER

  /* AXI writes from the VLSU are stored in output file to help verify the
  results when running in ideal dispatcher mode */

  assign ara_axi_w      = i_dut.marian_top.i_system.i_ara.i_vlsu.axi_req.w.data;
  assign ara_axi_w_strb = i_dut.marian_top.i_system.i_ara.i_vlsu.axi_req.w.strb;
  assign ara_axi_w_vld  = i_dut.marian_top.i_system.i_ara.i_vlsu.axi_req.w_valid;
  assign ara_axi_w_rdy  = i_dut.marian_top.i_system.i_ara.i_vlsu.axi_resp.w_ready;

  always_ff @(posedge tb_clk) begin
    if (ara_axi_w_vld && ara_axi_w_rdy)
      for (int b = 0; b < AxiBeWidth; b++)
        if (ara_axi_w_strb[b])
          $fdisplay(fd, "%0x", ara_axi_w[b*8 +: 8]);
  end

`endif

/**************************************
 * Logic to Identify Test Completion  *
 **************************************/

  assign exit_s = i_dut.marian_top.exit_s;

  always @(posedge tb_clk) begin
    if (exit_s[0]) begin
      if (exit_s >> 1) begin
        $info("Test ", $sformatf("*** [FAILED] *** (tohost = %0d)", (exit_s >> 1)));
      end else begin
        $info("Test ", $sformatf("*** [PASSED] *** (tohost = %0d)", (exit_s >> 1)));
      end

      $fclose(fd);
      $finish(exit_s >> 1);
    end
  end

endmodule
