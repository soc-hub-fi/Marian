//------------------------------------------------------------------------------
// Module   : sm3
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Endrit Isufi <endrit.isufi@tuni.fi>
// Created  : 10-July-2024
//
// Description: Holds all modules related to ShangMi4 (SM3) operations
//
// Parameters:
//
// Inputs:
//  - crypto_args_buff_i: Input arguments for crypto ops
//
// Outputs:
//  - next_state_o: SM3 compression results
//  - msg_exp_words_o: SM3 Message expansion result
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------


module sm3 import ara_pkg::*;
(
    input operand_buff_t  crypto_args_buff_i,
    //compresison
    output logic [EGW256-1:0] next_state_o,
    //msg expansion
    output logic [EGW256-1:0] msg_exp_words_o
);



sm3_compression i_sm3_compression
(
  .crnt_state_i  (crypto_args_buff_i.vd),
  .msg_words_i   (crypto_args_buff_i.vs2),
  .rnds_i        (crypto_args_buff_i.scalar[4:0]),
  .next_state_o  (next_state_o)
);

sm3_msg_expansion i_sm3_msg_expansion
(
  .msg_words_start_i (crypto_args_buff_i.vs1),
  .msg_words_end_i   (crypto_args_buff_i.vs2),
  .msg_words_o       (msg_exp_words_o)
);


endmodule