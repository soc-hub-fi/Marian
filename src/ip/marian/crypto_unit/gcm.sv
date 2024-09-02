//------------------------------------------------------------------------------
// Module   : gcm
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 25-may-2024
//
// Description: Holds all modules related to AES GCM operations
//
// Parameters:
//
// Inputs:
//  - clk_i: Clock
//  - rst_ni: Asynchronous active-low reset
//  - crypto_args_i: Input arguments for crypto ops
//  - pe_crypto_req_i: crypto request
//  - arg_valid_i: Handshaking for input args
//
// Outputs:
//  - arg_ready_o: Handshaking for argument
//  - result_valid_o:  Handshaking for result
//  - gmul_result_o: Result from AES GSM GHASH Mulitiply
//  - ghsh_result_o: Result from AES GSM GHASH Add-Mulitiply
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

module gcm
import ara_pkg::*;
(
  input  logic                         clk_i,
  input  logic                         rst_ni,
  input  logic                         arg_valid_i,
  input  operand_buff_t                crypto_args_buff_i,
  input  pe_crypto_req_t               pe_crypto_req_i,

  output logic                         gcm_valid_o,
  output logic           [EGW128-1:0]  gcm_result_o
);

/***********
 * SIGNALS *
 ***********/

  logic [EGW128-1:0]  gmul_result_s;
  logic [EGW128-1:0]  ghsh_result_s;

  logic ghsh_arg_vld_s, ghsh_res_vld_s;
  logic gmul_arg_vld_s, gmul_res_vld_s;

/*************
 * OP DECODE *
 *************/

  assign ghsh_arg_vld_s = (pe_crypto_req_i.op == VGHSH) ? arg_valid_i : '0;
  assign gmul_arg_vld_s = (pe_crypto_req_i.op == VGMUL) ? arg_valid_i : '0;

  assign gcm_result_o = (pe_crypto_req_i.op == VGMUL) ? gmul_result_s : ghsh_result_s;
  assign gcm_valid_o  = ghsh_res_vld_s | gmul_res_vld_s;

/********************
 * GCM ADD-MULTIPLY *
 ********************/
  add_mult_ghash i_add_mult_ghash (
    .clk_i          ( clk_i                              ),
    .rst_ni         ( rst_ni                             ),
    .partial_hash_i ( crypto_args_buff_i.vd[EGW128-1:0]  ),
    .hash_subkey_i  ( crypto_args_buff_i.vs2[EGW128-1:0] ),
    .cipher_text_i  ( crypto_args_buff_i.vs1[EGW128-1:0] ),
    .valid_i        ( ghsh_arg_vld_s                     ),
    .partial_hash_o ( ghsh_result_s                      ),
    .done_o         ( ghsh_res_vld_s                     )
  );

/****************
 * GCM MULTIPLY *
 ****************/

  mult_ghash i_mult_ghash (
    .clk_i          ( clk_i                              ),
    .rst_ni         ( rst_ni                             ),
    .multiplier_i   ( crypto_args_buff_i.vd[EGW128-1:0]  ),
    .multiplicand_i ( crypto_args_buff_i.vs2[EGW128-1:0] ),
    .valid_i        ( gmul_arg_vld_s                     ),
    .product_o      ( gmul_result_s                      ),
    .done_o         ( gmul_res_vld_s                     )
  );

endmodule
