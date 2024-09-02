//------------------------------------------------------------------------------
// Module   : aes
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 14-feb-2024
//
// Description: Holds all modules related to AES operations
//
// Parameters:
//
// Inputs:
//  - crypto_args_i: Input arguments for crypto ops
//  - pe_crypto_req_i: crypto request
//
// Outputs:
//  - aesfk_result_o: AES key expansion operation result
//  - encdec_result_o: AES encryption/decryption operation result
//
// Revision History:
//  - Version 1.0: Initial release
//  - Version 1.1: Slice round immediate vals [TZS:26-Jul-2024]
//
//------------------------------------------------------------------------------

module aes
  import ara_pkg::*;
(
  input  operand_buff_t                crypto_args_buff_i,
  input  pe_crypto_req_t               pe_crypto_req_i,

  output logic           [EGW128-1:0]  aesfk_result_o,
  output logic           [EGW128-1:0]  encdec_result_o
);

/***********
 * SIGNALS *
 ***********/

  logic       aesfkop_s;
  logic [2:0] aes_op_s;

/*************
 * OP DECODE *
 *************/

  assign aesfkop_s = (pe_crypto_req_i.op == VAESK2) ? 1'b1 : // VAESK2
                                                      1'b0;  // VAESK1

  assign aes_op_s  = (pe_crypto_req_i.op == VAESEM_VV || pe_crypto_req_i.op == VAESEM_VS) ? 3'b010 : // VAESEM
                     (pe_crypto_req_i.op == VAESEF_VV || pe_crypto_req_i.op == VAESEF_VS) ? 3'b011 : // VAESEF
                     (pe_crypto_req_i.op == VAESDM_VV || pe_crypto_req_i.op == VAESDM_VS) ? 3'b100 : // VAESDM
                     (pe_crypto_req_i.op == VAESDF_VV || pe_crypto_req_i.op == VAESDF_VS) ? 3'b101 : // VAESDF
                      3'b000;  // VAESZ



/*****************
 * KEY EXPANSION *
 *****************/
  key_expansion i_key_expansion (
    .aes_kop_i      ( aesfkop_s                          ),
    .rnd_i          ( crypto_args_buff_i.scalar[3:0]     ),
    .curr_rnd_key_i ( crypto_args_buff_i.vs2[EGW128-1:0] ),
    .prev_rnd_key_i ( crypto_args_buff_i.vd[EGW128-1:0]  ),
    .next_rnd_key_o ( aesfk_result_o                     )
  );

/*************************
 * ENCRYPTION/DECRYPTION *
 *************************/

 encdec i_encdec (
  .aes_op_i    ( aes_op_s                           ),
  .rnd_state_i ( crypto_args_buff_i.vd[EGW128-1:0]  ),
  .rnd_key_i   ( crypto_args_buff_i.vs2[EGW128-1:0] ),
  .rnd_state_o ( encdec_result_o                    )
);

endmodule
