//------------------------------------------------------------------------------
// Module   : sm4
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Endrit Isufi <endrit.isufi@tuni.fi>
// Created  : 10-July-2024
//
// Description: Holds all modules related to ShangMi4 (SM4) operations
//
// Parameters:
//
// Inputs:
//  - crypto_args_buff_i: Input arguments for crypto ops
//  - pe_crypto_req_i: crypto request
//
// Outputs:
//  - smfk_result_o: SM4 key expansion operation result
//  - encdec_result_o: SM4 encryption/decryption operation result
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

module sm4
import ara_pkg::*;
(
input  operand_buff_t                crypto_args_buff_i,

output logic           [EGW128-1:0]  smfk_result_o,
output logic           [EGW128-1:0]  encdec_result_o
);

/****************
* KEY EXPANSION *
*****************/
sm4_key_expansion i_sm_key_expansion (
  .rnd_i          ( crypto_args_buff_i.scalar[2:0]     ),
  .curr_rnd_key_i ( crypto_args_buff_i.vs2[EGW128-1:0] ),
  .next_rnd_key_o ( smfk_result_o                      )
);

/*************************
* ENCRYPTION/DECRYPTION *
*************************/

sm4_encdec i_sm_encdec (
.rnd_state_i ( crypto_args_buff_i.vd[EGW128-1:0]  ),
.rnd_key_i   ( crypto_args_buff_i.vs2[EGW128-1:0] ),
.rnd_state_o ( encdec_result_o                    )
);

endmodule
