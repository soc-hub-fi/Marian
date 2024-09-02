//------------------------------------------------------------------------------
// Module   : crypto_unit_tb.sv
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
//            Endrit Isufi <endrit.isufi@tuni.fi>
// Created  : 29-apr-2024
//
// Description: Directed TB for the crypto unit used within Marian
//
// Parameters:
//  - CLOCK_PERIOD: Period of TB clock
//  - RESET_DELAY_CYCLES: Number of cycles that design is initial held in reset
//
// Inputs:
//  - None
//
// Outputs:
//  - None
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

module crypto_unit_tb;

  import ara_pkg::*;
  import rvv_pkg::*;
  import crypto_unit_tb_pkg::*;

/********************************
 *  TB Parameters               *
 ********************************/

  // TB config
  parameter time    CLOCK_PERIOD       = 10ns;
  parameter integer RESET_DELAY_CYCLES = 5; // # of cycles that design is held in reset
  parameter time    TB_RUNTIME         = 100ms;

/*************
 *  Signals  *
 *************/

  // TB controls
  bit tb_clk;
  bit tb_rstn;

/**************************************
 *  TB Init + Clock/Reset Generation  *
 **************************************/

  // set time format for TB
  initial begin
    $timeformat(-9, 0, "ns");
  end

  // Controlling the reset
  initial begin

    tb_rstn = 1'b0;

    repeat (RESET_DELAY_CYCLES) begin
      #(CLOCK_PERIOD);
    end

    // release reset
    tb_rstn = 1'b1;
  end

  // Controlling the clock
  initial begin

    tb_clk  = 1'b0;

    forever begin
      #(CLOCK_PERIOD/2);
      tb_clk = ~tb_clk;
    end

  end

/*********
 *  DUT  *
 *********/

  crypto_if dut_if(
    .clk_i  ( tb_clk  ),
    .rstn_i ( tb_rstn )
  );

  crypto_unit #(
    .NrLanes( NrLanes ),
    .vaddr_t( vaddr_t )
  ) i_dut (
  .clk_i                     ( dut_if.clk_i                     ),
  .rst_ni                    ( dut_if.rstn_i                    ),
  .pe_req_i                  ( dut_if.pe_req_i                  ),
  .pe_req_valid_i            ( dut_if.pe_req_valid_i            ),
  .pe_vinsn_running_i        ( dut_if.pe_vinsn_running_i        ),
  .pe_req_ready_o            ( dut_if.pe_req_ready_o            ),
  .pe_resp_o                 ( dut_if.pe_resp_o                 ),
  .crypto_operand_i          ( dut_if.crypto_operand_i          ),
  .crypto_operand_valid_i    ( dut_if.crypto_operand_valid_i    ),
  .crypto_operand_ready_o    ( dut_if.crypto_operand_ready_o    ),
  .crypto_result_req_o       ( dut_if.crypto_result_req_o       ),
  .crypto_result_id_o        ( dut_if.crypto_result_id_o        ),
  .crypto_result_addr_o      ( dut_if.crypto_result_addr_o      ),
  .crypto_result_wdata_o     ( dut_if.crypto_result_wdata_o     ),
  .crypto_result_be_o        ( dut_if.crypto_result_be_o        ),
  .crypto_result_gnt_i       ( dut_if.crypto_result_gnt_i       ),
  .crypto_result_final_gnt_i ( dut_if.crypto_result_final_gnt_i )
  );

/************
 * TB LOGIC *
 ************/

  initial begin

    // mialbox to pass data from driver -> scoreboard
    automatic mailbox scoreboard_mbx = new();

    // request params
    automatic int unsigned id        = 1;
    automatic ara_op_e     op        = VAESK1;
    automatic int unsigned vs1       = 0;
    automatic int unsigned vs2       = 1;
    automatic int unsigned vd        = 2;
    automatic int unsigned scalar_op = 1;
    automatic int unsigned vl        = 20;
    automatic int unsigned vl_8      = 24; //multiple of 8
    automatic int unsigned vstart    = 0;
    // vtype vals
    automatic logic   vill  = 0;
    automatic logic   vma   = 0;
    automatic logic   vta   = 1;
    automatic vew_e   vsew  = EW32;
    automatic vlmul_e vlmul = LMUL_1;

    automatic Driver driver          = new(dut_if, scoreboard_mbx);
    automatic Scoreboard scoreboard  = new(scoreboard_mbx);

    automatic CryptoRequest vaesfk1_req;
    automatic CryptoRequest vaesfk2_req;
    automatic CryptoRequest vaesz_vs_req;
    automatic CryptoRequest vaesem_vv_req;
    automatic CryptoRequest vaesef_vv_req;
    automatic CryptoRequest vaesdm_vv_req;
    automatic CryptoRequest vaesdf_vv_req;
    automatic CryptoRequest vaesem_vs_req;
    automatic CryptoRequest vaesef_vs_req;
    automatic CryptoRequest vaesdm_vs_req;
    automatic CryptoRequest vaesdf_vs_req;
    automatic CryptoRequest vsha2ch_req;
    automatic CryptoRequest vsha2cl_req;
    automatic CryptoRequest vsha2ms_req;
    automatic CryptoRequest vghsh_req;
    automatic CryptoRequest vgmul_req;
    automatic CryptoRequest vsm4k_req;
    automatic CryptoRequest vsm4r_vv_req;
    automatic CryptoRequest vsm4r_vs_req;
    automatic CryptoRequest vsm3me_req;
    automatic CryptoRequest vsm3c_req;

    // populate requests
    vaesfk1_req   = new(id, VAESK1,    vs1, vs2, vd, scalar_op, vl, vstart);
    vaesfk2_req   = new(id, VAESK2,    vs1, vs2, vd, scalar_op, vl, vstart);
    vaesz_vs_req  = new(id, VAESZ_VS,  vs1, vs2, vd, scalar_op, vl, vstart);
    vaesem_vv_req = new(id, VAESEM_VV, vs1, vs2, vd, scalar_op, vl, vstart);
    vaesef_vv_req = new(id, VAESEF_VV, vs1, vs2, vd, scalar_op, vl, vstart);
    vaesdm_vv_req = new(id, VAESDM_VV, vs1, vs2, vd, scalar_op, vl, vstart);
    vaesdf_vv_req = new(id, VAESDF_VV, vs1, vs2, vd, scalar_op, vl, vstart);
    vaesem_vs_req = new(id, VAESEM_VS, vs1, vs2, vd, scalar_op, vl, vstart);
    vaesef_vs_req = new(id, VAESEF_VS, vs1, vs2, vd, scalar_op, vl, vstart);
    vaesdm_vs_req = new(id, VAESDM_VS, vs1, vs2, vd, scalar_op, vl, vstart);
    vaesdf_vs_req = new(id, VAESDF_VS, vs1, vs2, vd, scalar_op, vl, vstart);
    vsha2ch_req   = new(id, VSHA2CH,   vs1, vs2, vd, scalar_op, vl, vstart);
    vsha2cl_req   = new(id, VSHA2CL,   vs1, vs2, vd, scalar_op, vl, vstart);
    vsha2ms_req   = new(id, VSHA2MS,   vs1, vs2, vd, scalar_op, vl, vstart);
    vghsh_req     = new(id, VGHSH,     vs1, vs2, vd, scalar_op, vl, vstart);
    vgmul_req     = new(id, VGMUL,     vs1, vs2, vd, scalar_op, vl, vstart);
    vsm4k_req     = new(id, VSM4K,     vs1, vs2, vd, scalar_op, vl, vstart);
    vsm4r_vv_req  = new(id, VSM4R_VV,  vs1, vs2, vd, scalar_op, vl, vstart);
    vsm4r_vs_req  = new(id, VSM4R_VS,  vs1, vs2, vd, scalar_op, vl, vstart);
    vsm3me_req    = new(id, VSM3ME,    vs1, vs2, vd, scalar_op, vl_8, vstart);
    vsm3c_req     = new(id, VSM3C,     vs1, vs2, vd, scalar_op, vl_8, vstart);

    while (~tb_rstn) begin
      @(negedge tb_clk);
    end

    #(2*CLOCK_PERIOD);

    fork
      begin

        driver.seq.add_request(vaesfk1_req);
        driver.seq.add_request(vaesfk2_req);
        driver.seq.add_request(vaesz_vs_req);
        driver.seq.add_request(vaesem_vv_req);
        driver.seq.add_request(vaesef_vv_req);
        driver.seq.add_request(vaesdm_vv_req);
        driver.seq.add_request(vaesdf_vv_req);
        driver.seq.add_request(vaesem_vs_req);
        driver.seq.add_request(vaesef_vs_req);
        driver.seq.add_request(vaesdm_vs_req);
        driver.seq.add_request(vaesdf_vs_req);
        driver.seq.add_request(vsha2ch_req);
        driver.seq.add_request(vsha2cl_req);
        driver.seq.add_request(vsha2ms_req);
        driver.seq.add_request(vsm4k_req);
        driver.seq.add_request(vsm4r_vv_req);
        driver.seq.add_request(vsm4r_vs_req);
        driver.seq.add_request(vsm3me_req);
        driver.seq.add_request(vsm3c_req);

        // configure VP state
        driver.seq.set_vtype(vill, vma, vta, vsew, vlmul);

        driver.run_all_req();

        vsew = EW64;

        // update VP state -> 64b elems
        driver.seq.set_vtype(vill, vma, vta, vsew, vlmul);

        driver.seq.add_request(vsha2ch_req);
        driver.seq.add_request(vsha2cl_req);
        driver.seq.add_request(vsha2ms_req);

        driver.run_all_req();

        vsew = EW32;

        // update VP state -> 32b elems
        driver.seq.set_vtype(vill, vma, vta, vsew, vlmul);

        driver.seq.add_request(vghsh_req);
        driver.seq.add_request(vgmul_req);

        driver.run_all_req();

      end

      begin
        scoreboard.run();
      end
    join
  end

  // TTB timeout checks
  initial begin
    while ($time < TB_RUNTIME) begin
      @(posedge tb_clk);
    end
    $display("[%s:%4d @ %7t] Test Runtime Exceeded!", `__FILE__, `__LINE__, $realtime);
    $finish;
  end

endmodule
