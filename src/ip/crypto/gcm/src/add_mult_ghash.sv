//------------------------------------------------------------------------------
// Module   : add_mult_ghash
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 05-jun-2024
//
// Description: AES GCM Operation module, containing logic to perform Vector
//              Add-Multiply over GHASH Galois-Field.
//              Taken from Sail code listed within:
//              RISC-V Cryptography Extensions Volume II : Vector Instructions
//              Version v1.0.0, 22 August 2023 RC3,
//              Chapter 3.16 vghsh.vv
//
// Parameters:
//  - None
//
// Inputs:
//  - clk_i : Clock in
//  - rst_ni : Active low async reset in
//  - partial_hash_i : Partial Hash/Y(i) (vd)
//  - hash_subkey_i : Hash Subkey/H (vs2)
//  - cipher_text_i : Cypher Text/X(i) (vs1)
//  - valid_i : input data ready flag
//
// Outputs:
//  - partial_hash_o : Partial Hash/Y(i+1)
//  - done_o         : Done signal to indicate result is ready
//
// Revision History:
//  - Version 1.0: Initial release
//  - Version 1.1: Modify const in brev8 to localparam [TZS:12-aug-2024]
//
//------------------------------------------------------------------------------

module add_mult_ghash
import ara_pkg::*;
(
  input  logic              clk_i,
  input  logic              rst_ni,
  input  logic [EGW128-1:0] partial_hash_i,
  input  logic [EGW128-1:0] hash_subkey_i,
  input  logic [EGW128-1:0] cipher_text_i,
  input  logic              valid_i,

  output logic [EGW128-1:0] partial_hash_o,
  output logic              done_o
);

  localparam logic [EGW128-1:0] Polynomial = 128'h87; // x^7 + x^2 + x^1 + 1 polynomial

/***********
 * SIGNALS *
 ***********/

  logic           [EGW128-1:0] X_s;
  logic           [EGW128-1:0] Y_s;
  logic           [EGW128-1:0] S_s;
  logic [EGW128:0][EGW128-1:0] H_s;
  logic [EGW128:0][EGW128-1:0] Z_s;

  logic [EGW128:0] reduce_s;

/**********************
 * ADD-MULT OPERATION *
 **********************/

  assign X_s         = cipher_text_i;
  assign Y_s         = partial_hash_i;
  assign S_s         = brev8((Y_s ^ X_s));
  assign H_s[0]      = brev8(hash_subkey_i);
  assign Z_s[0]      = '0;
  assign reduce_s[0] = 1'b0;

  genvar i;

  for (i = 1; i <= 128; i++) begin : gen_gmul

    always_comb begin

      // default assignments
      Z_s[i]        = Z_s[i-1];
      H_s[i]        = H_s[i-1];
      reduce_s[i]   = 1'b0;

      if (S_s[i-1] == 1'b1) begin
        Z_s[i] ^= H_s[i-1];
      end

      reduce_s[i] = H_s[i-1][127];

      H_s[i] = H_s[i-1] << 1;

      if (reduce_s[i] == 1'b1) begin
        H_s[i] ^= Polynomial;
      end

    end

  end

/*********************
 * OUTPUT ASSIGNMENT *
 *********************/

  assign done_o         = valid_i; // completes within 1 cycle
  assign partial_hash_o = brev8(Z_s[EGW128]);

/************************
 * FUNCTION DEFINITIONS *
 ************************/

  // perform bit reversal of every byte within 128b word
  function automatic logic [EGW128-1:0] brev8( logic [EGW128-1:0] words_i);

    localparam int ByteCount = EGW128/8;

    // create tmp vars
    automatic logic [(EGW128/8)-1:0][7:0] words_in_s, words_out_s;
    automatic logic [EGW128-1:0] ret_word_s;

    // assign bytes into "iterable" format
    words_in_s  = words_i;
    words_out_s = '0;

    for(int byte_idx = 0; byte_idx < ByteCount; byte_idx++) begin
      for(int bit_idx = 0; bit_idx < 8; bit_idx++) begin
        words_out_s[byte_idx][7-bit_idx] = words_in_s[byte_idx][bit_idx];
      end
    end

    ret_word_s = words_out_s;

    return ret_word_s;

  endfunction;

endmodule
