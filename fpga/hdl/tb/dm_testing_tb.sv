//------------------------------------------------------------------------------
// Module   : dm_testing_tb
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 27-apr-2024
//
// Description: Testbench for the debug module testing.
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

module dm_testing_tb;

  timeunit 1ns/1ps;

  // TB config
  parameter time    CLOCK_PERIOD       = 8ns; // 125MHz to match external clock of VCU118
  parameter integer RESET_DELAY_CYCLES = 50; // # of cycles that design is held in reset

  /*************
   *  Signals  *
   *************/

  // clock and reset
  logic tb_clk_p;
  logic tb_clk_n;
  logic tb_rst;

  // JTAG
  logic jtag_tck_s;
  logic jtag_tms_s;
  logic jtag_trstn_s;
  logic jtag_trst_s;
  logic jtag_tdi_s;
  logic jtag_tdo_s;

  // debug irq
  logic debug_req_irq_s;

  // objects used to control debug module tasks
  marian_jtag_pkg::debug_mode_if_t #(
    .PROG_LEN ( 1024      ),
    .NR_LANES ( `NR_LANES )
    ) debug_if = new;

  dm::dmstatus_t dmstatus;

  assign jtag_trst_s = ~jtag_trstn_s;

  /***********************************
 *  Clock/Reset/Signal Generation  *
 ***********************************/

  // set time format for TB
  initial begin
    $timeformat(-9, 0, "ns");
  end

  // Controlling the reset
  initial begin

    tb_clk_p  = 1'b0;
    tb_rst    = 1'b1;

    repeat (RESET_DELAY_CYCLES) begin
      #(CLOCK_PERIOD);
    end

    // release reset
    tb_rst = 1'b0;

  end

  // Toggling the clock
  always #(CLOCK_PERIOD/2) tb_clk_p = ~tb_clk_p;

  assign tb_clk_n = ~tb_clk_p;

  /**** DUT ****/
  dm_testing_top i_dut(
    .clk_p_i         ( tb_clk_p        ),
    .clk_n_i         ( tb_clk_n        ),
    .rst_i           ( tb_rst          ),
    .debug_req_irq_o ( debug_req_irq_s ),
    .jtag_tck_i      ( jtag_tck_s      ),
    .jtag_tms_i      ( jtag_tms_s      ),
    .jtag_trst_i     ( jtag_trst_s     ),
    .jtag_tdi_i      ( jtag_tdi_s      ),
    .jtag_tdo_o      ( jtag_tdo_s      )
  );

  /*******************
   * Testbench Logic *
   *******************/

  initial begin

    $display("[DBG_TB @ %7t] - Test Start...", $realtime);

    jtag_tck_s   = 1'b1;
    jtag_tms_s   = 1'b1;
    jtag_trstn_s = 1'b0;
    jtag_tdi_s   = 1'b1;

    #(CLOCK_PERIOD);

    // loop until PLL lock is gained
    while (i_dut.locked_s != 1'b1) begin
      @(posedge tb_clk_p);
    end

    $display("[DBG_TB @ %7t] - Initialising JTAG TAP for DMI Access.", $realtime);
    debug_if.init_dmi_access(jtag_tck_s, jtag_tms_s, jtag_trstn_s, jtag_tdi_s);

    $display("[DBG_TB @ %7t] - Setting DM to active.", $realtime);
    debug_if.set_dmactive(1'b1, jtag_tck_s, jtag_tms_s, jtag_trstn_s, jtag_tdi_s,
      jtag_tdo_s);

    $display("[DBG_TB @ %7t] - Selecting the hart 0 to be halted.", $realtime);
    debug_if.set_hartsel(9'b0, jtag_tck_s, jtag_tms_s, jtag_trstn_s, jtag_tdi_s,
      jtag_tdo_s);

    $display("[DBG_TB @ %7t] - Attempting to halt the HART.", $realtime);
    debug_if.halt_harts(jtag_tck_s, jtag_tms_s, jtag_trstn_s, jtag_tdi_s, jtag_tdo_s);

  end

  // detect debug_req
  initial begin

    #(CLOCK_PERIOD);

    while (debug_req_irq_s != 1'b1) begin
      @(posedge tb_clk_p);
    end

    $display("[DBG_TB @ %7t] - Debug Request Active - Test Complete.", $realtime);
    $finish;
  end

endmodule
