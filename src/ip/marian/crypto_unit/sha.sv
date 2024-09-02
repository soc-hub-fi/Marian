//------------------------------------------------------------------------------
// Module   : sha
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 23-may-2024
//
// Description: Holds all modules related to SHA-2 operations
//
// Parameters:
//
// Inputs:
//  - crypto_args_i: Input arguments for crypto ops
//  - pe_crypto_req_i: crypto request
//
// Outputs:
//  - msg_sched_result_o: Result from SHA-2 message schedule
//  - compr_result_o: Result from SHA-2 compression
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

module sha
  import ara_pkg::*;
(
  input  operand_buff_t                crypto_args_buff_i,
  input  pe_crypto_req_t               pe_crypto_req_i,

  output logic           [EGW256-1:0]  msg_sched_result_o,
  output logic           [EGW256-1:0]  compr_result_o
);

/***********
 * SIGNALS *
 ***********/

  logic [1:0] sha_op_s;

/*************
 * OP DECODE *
 *************/

  // SHA-512 when sha_op_s[0] = 1
  // SHA-256 when sha_op_s[0] = 0
  assign sha_op_s[0] = (pe_crypto_req_i.vtype.vsew == rvv_pkg::EW64) ? 1'b1 : 1'b0;
  // VSHA2CL when sha_op_s[1] = 1
  // VSHA2CH when sha_op_s[1] = 0
  assign sha_op_s[1] = (pe_crypto_req_i.op == VSHA2CL) ? 1'b1 : 1'b0;

/***************
 * COMPRESSION *
 ***************/
  compression i_compression (
    .c_state_0_i    ( crypto_args_buff_i.vd  ),
    .c_state_1_i    ( crypto_args_buff_i.vs2 ),
    .msg_sched_pc_i ( crypto_args_buff_i.vs1 ),
    .sha_op_i       ( sha_op_s               ),
    .n_state_o      ( compr_result_o         )
  );

/********************
 * MESSAGE SCHEDULE *
 ********************/

  msg_schedule i_msg_schedule (
    .msg_words_0_i ( crypto_args_buff_i.vd  ),
    .msg_words_1_i ( crypto_args_buff_i.vs2 ),
    .msg_words_2_i ( crypto_args_buff_i.vs1 ),
    .sha_op_i      ( sha_op_s[0]            ),
    .msg_words_o   ( msg_sched_result_o     )
  );

endmodule
