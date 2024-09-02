//------------------------------------------------------------------------------
// Module   : msg_schedule
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 22-may-2024
//
// Description: SHA-2 Operation module, containing logic to perform message
//              scheduling.
//              This module supports both SHA-256 and SHA-512 operations. In the
//              former case, only the first half of each word is used.
//              Taken from Sail code listed within:
//              RISC-V Cryptography Extensions Volume II : Vector Instructions
//              Version v1.0.0, 22 August 2023 RC3,
//              Chapter 3.22 vsha2ms.vv
//
// Parameters:
//  - None
//
// Inputs:
//  - msg_words_0_i : message words {W[3], W[2], W[1], W[0]} (vd)
//  - msg_words_1_i : message words {W[11], W[10], W[9], W[4]} (vs2)
//  - msg_words_2_i : message words {W[15], W[14], W[13], W[12]} (vs1)
//  - sha_op_i      :
//    0 = SEW32 (SHA256),
//    1 = SEW64 (SHA512)
//
// Outputs:
//  - msg_words_o : message words {W[19], W[18], W[17], W[16]}
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

module msg_schedule
import ara_pkg::*;
(
  input  logic [EGW256-1:0] msg_words_0_i,
  input  logic [EGW256-1:0] msg_words_1_i,
  input  logic [EGW256-1:0] msg_words_2_i,
  input  logic         sha_op_i,

  output logic [EGW256-1:0] msg_words_o
);

/*********
 * TYPES *
 *********/

  typedef logic [19:0][63:0] words_sew64_t;
  typedef logic [19:0][31:0] words_sew32_t;

/***********
 * SIGNALS *
 ***********/

 words_sew64_t w_sew64_s;
 words_sew32_t w_sew32_s;

 logic [255:0] res_words_s;


/*********************
 * MESSAGE SHEDULING *
 *********************/

  always_comb begin

    w_sew64_s = '0;
    w_sew32_s = '0;

    res_words_s = '0;

    if (sha_op_i == 1'b1) begin // SHA-512 (SEW64)

      // assign input words
      {w_sew64_s[ 3], w_sew64_s[ 2], w_sew64_s[ 1], w_sew64_s[ 0]} = msg_words_0_i;
      {w_sew64_s[11], w_sew64_s[10], w_sew64_s[ 9], w_sew64_s[ 4]} = msg_words_1_i;
      {w_sew64_s[15], w_sew64_s[14], w_sew64_s[13], w_sew64_s[12]} = msg_words_2_i;

      w_sew64_s[16] = sig1_64(w_sew64_s[14]) + w_sew64_s[ 9] +
        sig0_64(w_sew64_s[1]) + w_sew64_s[0];
      w_sew64_s[17] = sig1_64(w_sew64_s[15]) + w_sew64_s[10] +
        sig0_64(w_sew64_s[2]) + w_sew64_s[1];
      w_sew64_s[18] = sig1_64(w_sew64_s[16]) + w_sew64_s[11] +
        sig0_64(w_sew64_s[3]) + w_sew64_s[2];
      w_sew64_s[19] = sig1_64(w_sew64_s[17]) + w_sew64_s[12] +
        sig0_64(w_sew64_s[4]) + w_sew64_s[3];

      // entire buffer filled with SEW64
      res_words_s = {w_sew64_s[19], w_sew64_s[18], w_sew64_s[17], w_sew64_s[16]};

    end else begin // SHA-256 (SEW32)

      // only use lower 128b of input
      {w_sew32_s[ 3], w_sew32_s[ 2], w_sew32_s[ 1], w_sew32_s[ 0]} = msg_words_0_i[127:0];
      {w_sew32_s[11], w_sew32_s[10], w_sew32_s[ 9], w_sew32_s[ 4]} = msg_words_1_i[127:0];
      {w_sew32_s[15], w_sew32_s[14], w_sew32_s[13], w_sew32_s[12]} = msg_words_2_i[127:0];

      w_sew32_s[16] = sig1_32(w_sew32_s[14]) + w_sew32_s[ 9] +
        sig0_32(w_sew32_s[1]) + w_sew32_s[0];
      w_sew32_s[17] = sig1_32(w_sew32_s[15]) + w_sew32_s[10] +
        sig0_32(w_sew32_s[2]) + w_sew32_s[1];
      w_sew32_s[18] = sig1_32(w_sew32_s[16]) + w_sew32_s[11] +
        sig0_32(w_sew32_s[3]) + w_sew32_s[2];
      w_sew32_s[19] = sig1_32(w_sew32_s[17]) + w_sew32_s[12] +
        sig0_32(w_sew32_s[4]) + w_sew32_s[3];

      // only lower half of buffer filled with SEW32
      res_words_s[127:0] = {w_sew32_s[19], w_sew32_s[18], w_sew32_s[17], w_sew32_s[16]};

    end

  end

/*********************
 * OUTPUT ASSIGNMENT *
 *********************/

  assign msg_words_o = res_words_s;

/************************
 * FUNCTION DEFINITIONS *
 ************************/

  // Circular rotate right for SEW64
  function automatic logic [63:0] ROTR_64( logic [63:0] x, int n);

    return ((x >> n) | (x << (64 - n)));

  endfunction

  // Circular rotate right for SEW32
  function automatic logic [31:0] ROTR_32( logic [31:0] x, int n);

    return ((x >> n) | (x << (32 - n)));

  endfunction

  // sig0 definition for SEW64
  function automatic logic [63:0] sig0_64(logic [63:0] x);

      return (ROTR_64(x, 1) ^ ROTR_64(x, 8) ^ (x >> 7));

  endfunction

  // sig0 definition for SEW32
  function automatic logic [31:0] sig0_32(logic [31:0] x);

    return (ROTR_32(x, 7) ^ ROTR_32(x, 18) ^ (x >> 3));

  endfunction

  // sig1 definition for SEW64
  function automatic logic [63:0] sig1_64(logic [63:0] x);

      return (ROTR_64(x, 19) ^ ROTR_64(x, 61) ^ (x >> 6));

  endfunction

  // sig1 definition for SEW32
  function automatic logic [31:0] sig1_32(logic [31:0] x);

    return (ROTR_32(x, 17) ^ ROTR_32(x, 19) ^ (x >> 10));

  endfunction

endmodule
