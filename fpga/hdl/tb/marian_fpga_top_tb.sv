//------------------------------------------------------------------------------
// Module   : marian_fpga_top_tb
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 22-dec-2023
//
// Description: Testbench for the Vector-Crypto Subsytem FPGA prototype.
//
// Parameters:
//
// Inputs:
//
// Outputs:
//
// Revision History:
//  - Version 1.0: Initial release
//  - Version 1.1: Added GPIO to marian top instance [TZS:21-jul-2024]
//
//------------------------------------------------------------------------------

`define STRINGIFY(x) `"x`"

module marian_fpga_top_tb;

  timeunit 1ns/1ps;

  import marian_jtag_pkg::*;
  import marian_fpga_pkg::*;

/********************************
 *  TB Parameters               *
 ********************************/

  // TB config
  parameter time    CLOCK_PERIOD       = 3.333ns; // 50MHz to match output of MMCM
  parameter integer RESET_DELAY_CYCLES = 50; // # of cycles that design is held in reset
  parameter string  L2_INIT_METHOD     = `STRINGIFY(`L2_INIT_METHOD);
  parameter string  L2_MEM_TEST_FILE   = `STRINGIFY(`L2_MEM_TEST_FILE);
  parameter integer L2Words            = `L2_NUM_ROWS;

  // boot address used by debug module
  localparam logic [riscv::XLEN-1:0] CVA6BootAddress = marian_fpga_pkg::DRAMBase;
  // core ID used for debug module testing
  localparam integer CoreID = 0;

/*************
 *  Signals  *
 *************/

  // clock and reset
  logic tb_clk;
  logic tb_rstn;

  // UART
  logic uart_tx_s;
  logic uart_rx_s;

  // JTAG
  logic jtag_tck_s;
  logic jtag_tms_s;
  logic jtag_trstn_s;
  logic jtag_tdi_s;
  logic jtag_tdo_s;

  // utility signals
  logic [AxiDataWidth-1:0] mem_init_arr [L2Words];

  // objects used to control debug module tasks
  debug_mode_if_t #(
    .PROG_LEN ( L2Words ),
    .NR_LANES ( NrLanes )
    ) marian_debug_if = new;

  dm::dmstatus_t dmstatus;

/***********************************
 *  Clock/Reset/Signal Generation  *
 ***********************************/

  // set time format for TB
  initial begin
    $timeformat(-9, 0, "ns");
  end

  // Controlling the reset
  initial begin

    tb_clk  = 1'b0;
    tb_rstn = 1'b1;

    repeat (RESET_DELAY_CYCLES) begin
      #(CLOCK_PERIOD);
    end

    // release reset
    tb_rstn = 1'b0;

  end

  // Toggling the clock
  always #(CLOCK_PERIOD/2) tb_clk = ~tb_clk;

  // initialise memory array for use in JTAG load
  initial begin
    $readmemh(L2_MEM_TEST_FILE, mem_init_arr);
  end

/********
 *  DUT *
 ********/

   marian_fpga_top i_dut (
     .clk_p_i     ( tb_clk        ),
     .clk_n_i     ( ~tb_clk       ),
     .rst_i       ( tb_rstn       ),
     .uart_rx_i   ( uart_rx_s     ),
     .uart_tx_o   ( uart_tx_s     ),
     .jtag_tck_i  ( jtag_tck_s    ),
     .jtag_tms_i  ( jtag_tms_s    ),
     .jtag_trst_i ( ~jtag_trstn_s ), // invert reset to emulate buttons on VCU118
     .jtag_tdi_i  ( jtag_tdi_s    ),
     .jtag_tdo_o  ( jtag_tdo_s    ),
     .gpio_i      ( '0            ),
     .gpio_o      ( /*UNUSED */   ),
     .pmod_o      ( /*UNUSED */   )
   );

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

/********************************
 *  Testbench Logic             *
 ********************************/

if (L2_INIT_METHOD == "FILE") begin : gen_tb_file_init

    // nothing to be done
  initial begin
    $display("[FPGA_TB @ %7t] - Initialising test using FILE.", $realtime);
  end

  assign jtag_tck_s   = 1'b0;
  assign jtag_tms_s   = 1'b0;
  assign jtag_trstn_s = 1'b1;
  assign jtag_tdi_s   = 1'b0;

end else if (L2_INIT_METHOD == "JTAG") begin : gen_tb_jtag_init

  initial begin

    #(CLOCK_PERIOD);

    $display("[FPGA_TB @ %7t] - Initialising test using JTAG.", $realtime);
    $display("[FPGA_TB @ %7t] - Waiting for PLL Lock.", $realtime);

    // loop until lock is gained
    while (i_dut.locked != 1'b1) begin
      @(posedge tb_clk);
    end

    $display("[FPGA_TB @ %7t] - PLL Locked.", $realtime);

    /************************************
     * JTAG TAP sanity/connection tests *
     ************************************/

    $display("[FPGA_TB @ %7t] - Performing JTAG Reset Test.", $realtime);
    jtag_reset(jtag_tck_s, jtag_tms_s, jtag_trstn_s, jtag_tdi_s);

    $display("[FPGA_TB @ %7t] - Performing JTAG Soft-Reset Test.", $realtime);
    jtag_softreset(jtag_tck_s, jtag_tms_s, jtag_trstn_s, jtag_tdi_s);

    $display("[FPGA_TB @ %7t] - Performing JTAG Bypass Test.", $realtime);
    jtag_bypass_test(jtag_tck_s, jtag_tms_s, jtag_trstn_s, jtag_tdi_s, jtag_tdo_s);

    $display("[FPGA_TB @ %7t] - Performing JTAG Get IDCODE Test.", $realtime);
    jtag_get_idcode(jtag_tck_s, jtag_tms_s, jtag_trstn_s, jtag_tdi_s, jtag_tdo_s);

    /**********************
     * Debug Module tests *
     **********************/

    $display("[FPGA_TB @ %7t] - Initialising JTAG TAP for DMI Access.", $realtime);
    marian_debug_if.init_dmi_access(jtag_tck_s, jtag_tms_s, jtag_trstn_s, jtag_tdi_s);

    $display("[FPGA_TB @ %7t] - Setting DM to active.", $realtime);
    marian_debug_if.set_dmactive(1'b1, jtag_tck_s, jtag_tms_s, jtag_trstn_s, jtag_tdi_s,
      jtag_tdo_s);

    $display("[FPGA_TB @ %7t] - Selecting the hart 0 to be halted.", $realtime);
    marian_debug_if.set_hartsel(9'b0, jtag_tck_s, jtag_tms_s, jtag_trstn_s, jtag_tdi_s,
      jtag_tdo_s);

    $display("[FPGA_TB @ %7t] - Attempting to halt the HART.", $realtime);
    marian_debug_if.halt_harts(jtag_tck_s, jtag_tms_s, jtag_trstn_s, jtag_tdi_s, jtag_tdo_s);

    $display("[FPGA_TB @ %7t] - Checking that hart is halted.", $realtime);
    marian_debug_if.read_debug_reg(dm::DMStatus, dmstatus, jtag_tck_s, jtag_tms_s, jtag_trstn_s,
      jtag_tdi_s, jtag_tdo_s);

    if (dmstatus.allhalted != 1'b1) begin : gen_halt_failed
      $error("[FPGA_TB @ %7t] - [FAILED] to halt core.", $realtime);
    end else begin : gen_halt_success
      $display("[FPGA_TB @ %7t] - Core sucessfully halted.", $realtime);
    end

    $display("[FPGA_TB @ %7t] - Setting boot address to 0x%0x.", $realtime, CVA6BootAddress);
    marian_debug_if.write_reg_abstract_cmd(riscv::CSR_DPC, CVA6BootAddress,
      jtag_tck_s, jtag_tms_s, jtag_trstn_s, jtag_tdi_s, jtag_tdo_s );


    /*********************************************************************************************

    PLACEHOLDER: CURRENTLY FAIL WHEN EXECUTING AND REQUIRE INVESTIGATION

    $display("[FPGA_TB @ %7t] - Running DM tests.", $realtime, CVA6BootAddress);
    marian_debug_if.run_dm_tests(CoreID, CVA6BootAddress, dm_test_err, dm_test_err_count,
      jtag_tck_s, jtag_tms_s, jtag_trstn_s, jtag_tdi_s, jtag_tdo_s);

    if (dm_test_err_count != 0) begin
      $error("[FPGA_TB @ %7t] - Debug Module %0d tests failed!", $realtime, dm_test_err_count);
    end

    *********************************************************************************************/

    /*********************
    * Load L2 with JTAG *
    *********************/

    $display("[FPGA_TB @ %7t] - Loading L2", $realtime);
    marian_debug_if.load_L2(CVA6BootAddress, mem_init_arr,
      jtag_tck_s, jtag_tms_s, jtag_trstn_s, jtag_tdi_s, jtag_tdo_s);

    // initialise JTAG TAP for DMI Access
    marian_debug_if.init_dmi_access(jtag_tck_s, jtag_tms_s, jtag_trstn_s, jtag_tdi_s);

    // we have set dpc and loaded the binary, we can go now
    $display("[FPGA_TB @ %7t] - Resuming the CORE", $time);
    marian_debug_if.resume_harts(jtag_tck_s, jtag_tms_s, jtag_trstn_s, jtag_tdi_s, jtag_tdo_s);

  end

end else begin : gen_tb_err

      $fatal("[FPGA_TB @ %7t] - ERROR: Invalid L2_INIT_METHOD defined.");

end

  /**************************************
   * Logic to Identify Test Completion  *
   **************************************/
  initial begin
    #500ms;
    $display("[FPGA_TB @ %7t] - Simulation Complete!", $time);
    $finish;
  end




endmodule
