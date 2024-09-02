//------------------------------------------------------------------------------
// Module   : crypto_unit_tb.sv
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Endrit Isufi <endrit.isufi@tuni.fi>
// Created  : 12-July-2024
//
// Description: Simple Directed TB for the crypto unit ShangMi modules used within Marian
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

module crypto_unit_sm_tb;

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

operand_buff_t crypto_args_buff_sm4_s;
operand_buff_t crypto_args_buff_sm3_s;
//SM4
logic [EGW128-1:0] smfk_result_s;
logic [EGW128-1:0] sm_encdec_result_s;
//SM3
logic [EGW256-1:0] sm3_next_state_s;
logic [EGW256-1:0] sm3_msg_exp_words_s;

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

/******************************
*  golden & reference values  *
*******************************/
// SM4
logic [127:0] vs2_tb = 128'h00225A11_0044B422_00896844_0112D088;
logic [127:0] vs2_tb_2= 128'hf6e69c2c_fd22871d_699cbf0a_d06d3438;
logic [127:0] vd_tb = 128'hA9A11002_15422005_2A84400A_55088014;
logic [127:0] scalar_tb = 4'h1;
logic [127:0] smfk_res_tb = 128'h49F7BCA7_25DD6513_1280FBA6_C47A45DC;
logic [127:0] sm_encdec_tb = 128'h0x8A763C50_1E6F627D_9B61960F_ABA873C8;

//Message expansion VSM3ME
logic [255:0] vsm3me_vd_tb = 256'h1B679E72_A7343641_2037FB27_929FCBF4_A9A11002_15422005_2A84400A_55088014;
logic [255:0] vsm3me_vs2_tb = 256'h0662016E_2A3700CE_997F3172_8CD978C3_00225A11_0044B422_00896844_0112D088;
logic [255:0] vsm3me_vs1_tb = 256'h0F27E1C2_8FB4C921_713605E7_309C3674_A9834A13_15069427_2A0D284E_541A509C;
logic [255:0] golden_vsm3me_res = 256'hC4F5A44B_28C698BA_A941945B_D5E5C4AB_8FAF7E29_E6A869E9_193C56B8_A244AB4D;
// Compression VSM3C
logic [255:0] vsm3c_vd_tb = 256'h1B679E72_A7343641_2037FB27_929FCBF4_A9A11002_15422005_2A84400A_55088014;
logic [255:0] vsm3c_vs2_tb = 256'h0662016E_2A3700CE_997F3172_8CD978C3_00225A11_0044B422_00896844_0112D088;
logic [255:0] golden_vsm3c_res = 256'hD93F01B9_5CA697FC_6C16224B_92FEDBC8_14540881_29AA1000_460A22AB_E42C15AF;


/*******************************
*  Reference value assignments *
********************************/

assign crypto_args_buff_sm4_s.vs2 = vs2_tb;
assign crypto_args_buff_sm4_s.vd  = vd_tb;
assign crypto_args_buff_sm4_s.scalar = scalar_tb;

assign crypto_args_buff_sm3_s.vd = vsm3me_vd_tb;
assign crypto_args_buff_sm3_s.vs2 = vsm3me_vs2_tb;
assign crypto_args_buff_sm3_s.vs1 = vsm3me_vs1_tb;
assign crypto_args_buff_sm3_s.scalar = scalar_tb;


/***********
*  DUT(s)  *
************/

  sm4 i_sm4 (
    .crypto_args_buff_i (crypto_args_buff_sm4_s),
    .smfk_result_o      (smfk_result_s     ),
    .encdec_result_o    (sm_encdec_result_s)
  );

  sm3 i_sm3 (
    .crypto_args_buff_i (crypto_args_buff_sm3_s),
    //compression
    .next_state_o       (sm3_next_state_s),
    //msg expansion
    .msg_exp_words_o    (sm3_msg_exp_words_s)
  );

  crypto_if dut_if(
    .clk_i  ( tb_clk  ),
    .rstn_i ( tb_rstn )
  );

/************
  * TB LOGIC *
************/

initial begin
  
  while (~tb_rstn) begin
    @(negedge tb_clk);
  end

  #(2*CLOCK_PERIOD);
  $display("### VSM4K ###");
  $display("DUT result   : %X", smfk_result_s);
  $display("golden result: %X", smfk_res_tb);
  $display("");
  $display("### VSM4R ###");
  $display("DUT result   : %X", sm_encdec_result_s);
  $display("golden result: %X", sm_encdec_tb);
  $display("");
  $display("### VSM3C.vi ###");
  $display("DUT result   : %X", sm3_next_state_s);
  $display("golden result: %X", golden_vsm3c_res);
  $display("");
  $display("### VSM3ME.vv ###");
  $display("vs1          : %X", vsm3me_vs1_tb);
  $display("vs2          : %X", vsm3me_vs2_tb);
  $display("DUT result   : %X", sm3_msg_exp_words_s);
  $display("golden result: %X", golden_vsm3me_res);
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
