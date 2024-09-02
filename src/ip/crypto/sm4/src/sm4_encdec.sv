//------------------------------------------------------------------------------
// Module   : sm4_encdec
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Endrit Isufi <endrit.isufi@tuni.fi>
// Created  : 10-July-2024
//
// Description: Vector SM4 Rounds, where four rounds of SM4 Encryption/decryption are performed.
//              Implemented using Sail specification defined within :
//              RISC-V Cryptography Extensions Volume II Vector Instructions
//              Version v1.0.0, 5 October 2023: RC3
//
// Parameters:
//  - None
//
// Inputs:
//  - rnd_state_i    : Current state X[0:3]
//  - rnd_key_i      : Round keys rk[0:3]
//
// Outputs:
//  - rnd_state_o    : Next state X'[0:3]
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

module sm4_encdec
import ara_pkg::*;
(
  input  logic [EGW128-1:0] rnd_state_i,
  input  logic [EGW128-1:0] rnd_key_i,

  output logic [EGW128-1:0] rnd_state_o
);

 /***********
  * SIGNALS *
  ***********/

  localparam logic [7:0] SMSbox [256] = '{
    8'hD6, 8'h90, 8'hE9, 8'hFE, 8'hCC, 8'hE1, 8'h3D, 8'hB7,
    8'h16, 8'hB6, 8'h14, 8'hC2, 8'h28, 8'hFB, 8'h2C, 8'h05,

    8'h2B, 8'h67, 8'h9A, 8'h76, 8'h2A, 8'hBE, 8'h04, 8'hC3,
    8'hAA, 8'h44, 8'h13, 8'h26, 8'h49, 8'h86, 8'h06, 8'h99,

    8'h9C, 8'h42, 8'h50, 8'hF4, 8'h91, 8'hEF, 8'h98, 8'h7A,
    8'h33, 8'h54, 8'h0B, 8'h43, 8'hED, 8'hCF, 8'hAC, 8'h62,

    8'hE4, 8'hB3, 8'h1C, 8'hA9, 8'hC9, 8'h08, 8'hE8, 8'h95,
    8'h80, 8'hDF, 8'h94, 8'hFA, 8'h75, 8'h8F, 8'h3F, 8'hA6,

    8'h47, 8'h07, 8'hA7, 8'hFC, 8'hF3, 8'h73, 8'h17, 8'hBA,
    8'h83, 8'h59, 8'h3C, 8'h19, 8'hE6, 8'h85, 8'h4F, 8'hA8,

    8'h68, 8'h6B, 8'h81, 8'hB2, 8'h71, 8'h64, 8'hDA, 8'h8B,
    8'hF8, 8'hEB, 8'h0F, 8'h4B, 8'h70, 8'h56, 8'h9D, 8'h35,

    8'h1E, 8'h24, 8'h0E, 8'h5E, 8'h63, 8'h58, 8'hD1, 8'hA2,
    8'h25, 8'h22, 8'h7C, 8'h3B, 8'h01, 8'h21, 8'h78, 8'h87,

    8'hD4, 8'h00, 8'h46, 8'h57, 8'h9F, 8'hD3, 8'h27, 8'h52,
    8'h4C, 8'h36, 8'h02, 8'hE7, 8'hA0, 8'hC4, 8'hC8, 8'h9E,

    8'hEA, 8'hBF, 8'h8A, 8'hD2, 8'h40, 8'hC7, 8'h38, 8'hB5,
    8'hA3, 8'hF7, 8'hF2, 8'hCE, 8'hF9, 8'h61, 8'h15, 8'hA1,

    8'hE0, 8'hAE, 8'h5D, 8'hA4, 8'h9B, 8'h34, 8'h1A, 8'h55,
    8'hAD, 8'h93, 8'h32, 8'h30, 8'hF5, 8'h8C, 8'hB1, 8'hE3,

    8'h1D, 8'hF6, 8'hE2, 8'h2E, 8'h82, 8'h66, 8'hCA, 8'h60,
    8'hC0, 8'h29, 8'h23, 8'hAB, 8'h0D, 8'h53, 8'h4E, 8'h6F,

    8'hD5, 8'hDB, 8'h37, 8'h45, 8'hDE, 8'hFD, 8'h8E, 8'h2F,
    8'h03, 8'hFF, 8'h6A, 8'h72, 8'h6D, 8'h6C, 8'h5B, 8'h51,

    8'h8D, 8'h1B, 8'hAF, 8'h92, 8'hBB, 8'hDD, 8'hBC, 8'h7F,
    8'h11, 8'hD9, 8'h5C, 8'h41, 8'h1F, 8'h10, 8'h5A, 8'hD8,

    8'h0A, 8'hC1, 8'h31, 8'h88, 8'hA5, 8'hCD, 8'h7B, 8'hBD,
    8'h2D, 8'h74, 8'hD0, 8'h12, 8'hB8, 8'hE5, 8'hB4, 8'hB0,

    8'h89, 8'h69, 8'h97, 8'h4A, 8'h0C, 8'h96, 8'h77, 8'h7E,
    8'h65, 8'hB9, 8'hF1, 8'h09, 8'hC5, 8'h6E, 8'hC6, 8'h84,

    8'h18, 8'hF0, 8'h7D, 8'hEC, 8'h3A, 8'hDC, 8'h4D, 8'h20,
    8'h79, 8'hEE, 8'h5F, 8'h3E, 8'hD7, 8'hCB, 8'h39, 8'h48
  };
  logic [127:0] next_state_s;
  logic [3:0][31:0] rnd_keys_s;


  logic [31:0] B;
  logic [31:0] S;
  logic [31:0] rk0;
  logic [31:0] rk1;
  logic [31:0] rk2;
  logic [31:0] rk3;
  logic [31:0] x0;
  logic [31:0] x1;
  logic [31:0] x2;
  logic [31:0] x3;
  logic [31:0] x4;
  logic [31:0] x5;
  logic [31:0] x6;
  logic [31:0] x7;

  always_comb begin
    //default assignments
    next_state_s = '0;
    rnd_keys_s = '0;
    B   = 32'h0;
    S   = 32'h0;
    rk0 = 32'h0;
    rk1 = 32'h0;
    rk2 = 32'h0;
    rk3 = 32'h0;
    x0  = 32'h0;
    x1  = 32'h0;
    x2  = 32'h0;
    x3  = 32'h0;
    x4  = 32'h0;
    x5  = 32'h0;
    x6  = 32'h0;
    x7  = 32'h0;

    //SM4 encoding/decoding logic

      rnd_keys_s = rnd_key_i;
      {rk3, rk2, rk1, rk0} = rnd_keys_s;
      {x3, x2, x1, x0} = rnd_state_i;

      B = x1 ^ x2 ^ x3 ^ rk0;
      S = sm_subword(B);
      x4 = sm4_round(x0, S);

      B = x2 ^ x3 ^ x4 ^ rk1;
      S = sm_subword(B);
      x5 = sm4_round(x1, S);

      B = x3 ^ x4 ^ x5 ^ rk2;
      S = sm_subword(B);
      x6 = sm4_round(x2, S);

      B = x4 ^ x5 ^ x6 ^ rk3;
      S = sm_subword(B);
      x7 = sm4_round(x3, S);

      next_state_s = {x7, x6, x5, x4};
  end

  assign rnd_state_o = {next_state_s};

  /************************
   * FUNCTION DEFINITIONS *
   ************************/
    //rotate X by a factor of S
  function bit [31:0] sm_ROL32(bit [31:0] X, int unsigned S);
    return ((X << S) | (X >> (32 - S)));
  endfunction

  function logic [31:0] sm4_round(logic [31:0] X, bit [31:0] S);
    return X ^ (S ^ sm_ROL32(S, 2) ^ sm_ROL32(S, 10) ^ sm_ROL32(S, 18) ^ sm_ROL32(S, 24));
  endfunction

    /* Sbox substitute word */
  function bit [31:0] sm_subword (bit [31:0] word_i);
    automatic bit [31:0] word_o = '0;
    word_o = {SMSbox[int'(word_i[31:24])],
              SMSbox[int'(word_i[23:16])],
              SMSbox[int'(word_i[15:8])],
              SMSbox[int'(word_i[7:0])]};
    return word_o;
  endfunction

endmodule
