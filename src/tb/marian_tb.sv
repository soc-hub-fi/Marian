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
//  - Version 1.2: Updated to use marian_top rather than wrapper
//                 [TZS:18-sep-2024]
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

  logic [1:0] gpio_out_s;
  logic [1:0] gpio_in_s;

  logic uart_tx_s;
  logic uart_rx_s;

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

  //external AXI M & AXI S
  // AXI DV master -> Marian Slave
  axi_external_m_req_t  axi_dv_m_req;
  axi_external_m_resp_t axi_dv_m_resp;
  // Marian Master -> AXI DV Slave
  axi_external_s_req_t  axi_dv_s_req;
  axi_external_s_resp_t axi_dv_s_resp;

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
  ) axi_drv_mst_t;
  axi_drv_mst_t axi_drv_mst = new (master_dv);

  // connect dv master axi bus to the dut ports
  `AXI_ASSIGN           (master,         master_dv     )
  `AXI_ASSIGN_TO_REQ    (axi_dv_m_req,   master        )
  `AXI_ASSIGN_FROM_RESP (master,         axi_dv_m_resp )

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
  `AXI_ASSIGN_FROM_REQ (slave,           axi_dv_s_req)
  `AXI_ASSIGN_TO_RESP  (axi_dv_s_resp, slave         )


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

  // Loop back GPIO for testing
  assign gpio_in_s = {gpio_out_s[0],gpio_out_s[1]};

  marian_top i_dut (
    .ext_axi_m_req_i     ( axi_dv_m_req       ),
    .ext_axi_m_resp_o    ( axi_dv_m_resp      ),
    .ext_axi_s_req_o     ( axi_dv_s_req       ),
    .ext_axi_s_resp_i    ( axi_dv_s_resp      ),
    // Interface: clk
    .clk_i               ( tb_clk             ),
    // Interface: gpio
    .marian_gpio_i       ( gpio_in_s          ),
    .marian_gpio_o       ( gpio_out_s         ),
    .marian_gpio_oe      ( /* UNUSED */       ),
    // Interface: irq_i
    .marian_ext_irq_i    ( '0                 ),
    // Interface: irq_o
    .marian_ext_irq_o    ( /* UNUSED */       ),
    // Interface: jtag
    .marian_jtag_tck_i   ( jtag_tck_s         ),
    .marian_jtag_tms_i   ( jtag_tms_s         ),
    .marian_jtag_trstn_i ( jtag_trstn_s       ),
    // Interface: qspi
    .marian_qspi_data_i  ( marian_qspi_data_i ),
    .marian_qspi_csn_o   ( marian_qspi_csn_o  ),
    .marian_qspi_data_o  ( marian_qspi_data_o ),
    .marian_qspi_oe      ( marian_qspi_oe     ),
    .marian_qspi_sclk_o  ( marian_qspi_sclk_o ),
    // Interface: rst_ni
    .rst_ni              ( tb_rstn            ),
    // Interface: uart
    .marian_uart_rx_i    ( uart_rx_s          ),
    .marian_uart_tx_o    ( uart_tx_s          ),
    // These ports are not in any interface
    .marian_jtag_tdi_i   ( jtag_tdi_s         ),
    .marian_jtag_tdo_o   ( jtag_tdo_s         )
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

      $display("[MARIAN_TB @ %7t] - Writing file %s to i_dut.i_bootram.ram...",
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
          i_dut.i_bootram.ram[word_idx] = mem_init_arr[word_idx];
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

  assign ara_axi_w      = i_dut.i_system.i_ara.i_vlsu.axi_req.w.data;
  assign ara_axi_w_strb = i_dut.i_system.i_ara.i_vlsu.axi_req.w.strb;
  assign ara_axi_w_vld  = i_dut.i_system.i_ara.i_vlsu.axi_req.w_valid;
  assign ara_axi_w_rdy  = i_dut.i_system.i_ara.i_vlsu.axi_resp.w_ready;

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

  assign exit_s = i_dut.exit_s;

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
