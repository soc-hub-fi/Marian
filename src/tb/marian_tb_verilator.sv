//------------------------------------------------------------------------------
// Module   : marian_tb_verilator
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 02-sep-2024
//
// Description: Testbench for the Vector-Crypto Subsytem for use with Verilator.
//
// Parameters:
//  - CLOCK_PERIOD: Testbench clock period
//  - TB_TIMEOUT: Execution time of testbench
//  - RESET_DELAY_CYCLES:  Number of cycles at the start of the test in which
//    the design is held in reset
//  - L2_INIT_METHOD: Selection of initialisation method for BootRAM (Currently,
//                    FILE is the only valid option)
//  - L2_MEM_INIT_FILE: Filename of .mem/.hex file used to initialise bootRAM
//  - L2Words: Number of rows in bootRAM memory (128b wide)
//
// Inputs:
//  - None
//
// Outputs:
//  - None
//
// Revision History:
//  - Version 1.0: Initial release
//------------------------------------------------------------------------------

`define STRINGIFY(x) `"x`"

module marian_tb_verilator;

  timeunit 1ns/1ps;

  import marian_pkg::*;
  import marian_tb_pkg::*;

/********************************
 *  TB Parameters               *
 ********************************/

  // TB config
  parameter realtime CLOCK_PERIOD       = `CLK_PERIOD;
  parameter realtime TB_TIMEOUT         = 50ms;
  parameter integer  RESET_DELAY_CYCLES = 50; // # of cycles that design is held in reset
  parameter string   L2_INIT_METHOD     = `STRINGIFY(`L2_INIT_METHOD);
  parameter string   L2_MEM_INIT_FILE   = `STRINGIFY(`L2_MEM_INIT_FILE);
  parameter integer  L2Words            = `L2_NUM_ROWS;

  // boot address used by debug module
  localparam logic [riscv::XLEN-1:0] CVA6BootAddress = marian_pkg::DRAMBase;
  // core ID used for debug module testing
  localparam integer CoreID = 0;

/***********
 *  Types  *
 ***********/

  typedef enum logic [1:0] {
    OKAY   = 2'b00,
    EXOKAY = 2'b01,
    SLVERR = 2'b10,
    DECERR = 2'b11
  } axi_resp_e;

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

  // tb mgmt signals
  logic [AxiNarrowDataWidth-1:0] exit_s;

  // utility signals
  logic [AxiDataWidth-1:0] mem_init_arr [L2Words];

  // AXI interface used to drive external AXI bus
  // AXI DV master -> Marian Slave
  axi_external_m_req_t  axi_dv_m_req_s = '0;
  axi_external_m_resp_t axi_dv_m_resp_s;
  // Marian Master -> AXI DV Slave
  axi_external_s_req_t  axi_dv_s_req_s;
  axi_external_s_resp_t axi_dv_s_resp_s = '0;

/***********************************
 *  Clock/Reset/Signal Generation  *
 ***********************************/

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

  // initialise memory array for use in JTAG load
  initial begin
    $readmemh(L2_MEM_INIT_FILE, mem_init_arr);
  end

/********
 *  DUT *
 ********/

  marian_top i_dut (
    .ext_axi_m_req_i     ( axi_dv_m_req_s  ),
    .ext_axi_m_resp_o    ( axi_dv_m_resp_s ),
    .ext_axi_s_req_o     ( axi_dv_s_req_s  ),
    .ext_axi_s_resp_i    ( axi_dv_s_resp_s ),
    // Interface: clk
    .clk_i               ( tb_clk       ),
    // Interface: gpio
    .marian_gpio_i       ( '0           ),
    .marian_gpio_o       ( /* UNUSED */ ),
    .marian_gpio_oe      ( /* UNUSED */ ),
    // Interface: irq_i
    .marian_ext_irq_i    ( '0           ),
    // Interface: irq_o
    .marian_ext_irq_o    ( /* UNUSED */ ),
    // Interface: jtag
    .marian_jtag_tck_i   ( jtag_tck_s   ),
    .marian_jtag_tms_i   ( jtag_tms_s   ),
    .marian_jtag_trstn_i ( jtag_trstn_s ),
    // Interface: qspi
    .marian_qspi_data_i  ( '0           ),
    .marian_qspi_csn_o   ( /* UNUSED */ ),
    .marian_qspi_data_o  ( /* UNUSED */ ),
    .marian_qspi_oe      ( /* UNUSED */ ),
    .marian_qspi_sclk_o  ( /* UNUSED */ ),
    // Interface: rst_ni
    .rst_ni              ( tb_rstn      ),
    // Interface: uart
    .marian_uart_rx_i    ( uart_rx_s    ),
    .marian_uart_tx_o    ( uart_tx_s    ),
    // These ports are not in any interface
    .marian_jtag_tdi_i   ( jtag_tdi_s   ),
    .marian_jtag_tdo_o   ( jtag_tdo_s   )
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

  assign jtag_tck_s   = 1'b0;
  assign jtag_tms_s   = 1'b0;
  assign jtag_trstn_s = 1'b1;
  assign jtag_tdi_s   = 1'b0;

  initial begin

    automatic logic [    AxiExtAddrWidth-1:0] axi_addr = marian_pkg::CTRLBase + 48;
    automatic logic [    AxiExtDataWidth-1:0] axi_data = 'h1;
    automatic logic [(AxiExtDataWidth/8)-1:0] axi_strb = '1;

    int word_idx = 0;

    $display("[VERILATOR_TB @ %7t] - Initialising test using FILE.", $realtime);

    // sram is initialised on reset, wait 2 cycles and overwrite contents
    repeat(2)
    @(posedge tb_clk);

    $display("[VERILATOR_TB @ %7t] - Writing file %s to i_dut.i_bootram.ram...",
      $realtime, L2_MEM_INIT_FILE);

    // iterate through each word of the memory variable
    for(word_idx = 0; word_idx < L2Words; word_idx++) begin
      // write word of memory into packed init value of the i_bootram SRAM
      i_dut.i_bootram.ram[word_idx] = mem_init_arr[word_idx];
    end

    // check whether RAM is full
    a_mem_limit: assert (word_idx != (L2Words-1))
    else $fatal("[VERILATOR_TB @ %7t] - [ERROR] - L2 initialisation file is larger than L2 ",
      $realtime, "(%d Bytes)!", (L2Words*(AxiDataWidth/8)));

    #(4*RESET_DELAY_CYCLES*CLOCK_PERIOD);

    // write bootram ready so that CVA6 starts executing from bootram
    axi_write_single_beat(0, axi_addr, axi_data, axi_strb);

  end

end else begin : gen_tb_jtag_init

      $fatal("[VERILATOR_TB @ %7t] - ERROR: Invalid L2_INIT_METHOD defined.");

end

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

      $finish(exit_s >> 1);
    end
  end

  initial begin
    #(TB_TIMEOUT);
    $display("[VERILATOR_TB @ %7t] - Simulation Complete!", $time);
    $finish;
  end

  // set time printing format
  initial begin
    $timeformat(-9, 0, " ns", 10);
  end

  // dump vars for trace
  initial begin
    $dumpfile("marian_verilator.wave");
    $dumpvars;
  end

/****************
 *  Subroutines *
 ****************/

  task automatic axi_write_single_beat(
    input  bit                                  print_en=0,
    input  logic      [    AxiExtAddrWidth-1:0] addr_i,
    input  logic      [    AxiExtDataWidth-1:0] data_i,
    input  logic      [(AxiExtDataWidth/8)-1:0] strb_i
  );

    automatic axi_resp_e axi_b_resp;

    @(negedge tb_clk);

    if(print_en) begin
      $display("[%0t - axi_write_single_beat] Vals:", $time);
      $display("\tAddr: %016H", addr_i);
      $display("\tData: %016H", data_i);
      $display("\tStrb: %016H", strb_i);
    end

    @(posedge tb_clk);
    @(negedge tb_clk);

    // clear all relevant signals
    axi_dv_m_req_s.aw       = '0;
    axi_dv_m_req_s.w        = '0;
    axi_dv_m_req_s.aw_valid = 1'b0;
    axi_dv_m_req_s.w_valid  = 1'b0;
    axi_dv_m_req_s.b_ready  = 1'b0;

    // set aw valid
    axi_dv_m_req_s.aw_valid = 1'b1;
    axi_dv_m_req_s.aw.addr  = addr_i;

    // wait for ready
    while(axi_dv_m_resp_s.aw_ready == 1'b0)
      @(negedge tb_clk);

    if(print_en)
      $display("[%0t - axi_write_single_beat] Sent Address", $time);

    @(negedge tb_clk);

    axi_dv_m_req_s.aw_valid = 1'b0;
    axi_dv_m_req_s.aw       = '0;

    // set w valid
    axi_dv_m_req_s.w_valid = 1'b1;
    axi_dv_m_req_s.w.data  = data_i;
    axi_dv_m_req_s.w.strb  = strb_i;
    axi_dv_m_req_s.w.last  = 1'b1; // last as single beat

    // wait for w ready
    while(axi_dv_m_resp_s.w_ready == 1'b0)
      @(negedge tb_clk);

    if(print_en)
      $display("[%0t - axi_write_single_beat] Sent Data", $time);

    @(negedge tb_clk);

    axi_dv_m_req_s.w_valid = 1'b0;
    axi_dv_m_req_s.w        = '0;

    // wait for b valid
    axi_dv_m_req_s.b_ready = 1'b1;

    while(axi_dv_m_resp_s.b_valid == 1'b0)
      @(negedge tb_clk);

    axi_b_resp = axi_resp_e'(axi_dv_m_resp_s.b.resp);

    if(print_en)
      $display("[%0t - axi_write_single_beat] Got reponse: %0s", $time, axi_b_resp.name);

    @(negedge tb_clk);
    axi_dv_m_req_s.b_ready = 1'b0;

  endtask // axi_write_single_beat

  task automatic axi_read_single_beat(
    input  bit                         print_en=0,
    input  logic [   AxiAddrWidth-1:0] addr_i,
    output logic [AxiExtDataWidth-1:0] data_o
  );

    automatic axi_resp_e axi_r_resp;

    data_o = 0;

    @(negedge tb_clk);

    if(print_en) begin
      $display("[%0t - axi_read_single_beat] Vals:", $time);
      $display("\tAddr: %016H", addr_i);
    end

    @(posedge tb_clk);
    @(negedge tb_clk);

    // clear all relevant signals
    axi_dv_m_req_s.ar       = '0;
    axi_dv_m_req_s.ar_valid = 1'b0;
    axi_dv_m_req_s.r_ready  = 1'b0;


    // set ar valid
    axi_dv_m_req_s.ar_valid = 1'b1;
    axi_dv_m_req_s.ar.addr  = addr_i;

    @(negedge tb_clk);
    // wait for ready
    while(axi_dv_m_resp_s.ar_ready == 1'b0)
      @(negedge tb_clk);

    if(print_en)
      $display("[%0t - axi_read_single_beat] Sent Address", $time);


    @(posedge tb_clk);
    axi_dv_m_req_s.ar_valid = 1'b0;
    axi_dv_m_req_s.ar       = '0;

    // wait for r valid
    axi_dv_m_req_s.r_ready = 1'b1;

    @(negedge tb_clk);

    while(axi_dv_m_resp_s.r_valid == 1'b0)
      @(negedge tb_clk);

    axi_r_resp = axi_resp_e'(axi_dv_m_resp_s.r.resp);

    if(print_en) begin
      $display("[%0t - axi_read_single_beat] Got reponse: %0s", $time, axi_r_resp.name);
      $display("\tData = %016H", axi_dv_m_resp_s.r.data);
    end

    data_o = axi_dv_m_resp_s.r.data;

    @(posedge tb_clk);
    axi_dv_m_req_s.r_ready = 1'b0;

  endtask // axi_read_single_beat

endmodule
