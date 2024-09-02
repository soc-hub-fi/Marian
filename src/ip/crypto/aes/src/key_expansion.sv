//------------------------------------------------------------------------------
// Module   : key_expansion
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 23-feb-2024
//
// Description: AES key expansion module, supporting key expansion operations
//              for both AES-128 and AES-256.
//              Implemented using Sail specification defined within :
//              RISC-V Cryptography Extensions Volume II Vector Instructions
//              Version v1.0.0, 22 August 2023: RC3
//
// Parameters:
//  - None
//
// Inputs:
//  - aes_kop_i: Controls for AES key expansion (0 = VAESFK1, 1 = VAESFK2)
//  - rnd_i: Round number
//  - curr_rnd_key_i: Current round key
//  - prev_rnd_key_i: Previous round key
//
// Outputs:
//  - next_rnd_key_o: next round key
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

module key_expansion
import ara_pkg::*;
(
  input  logic              aes_kop_i,
  input  logic [       3:0] rnd_i,
  input  logic [EGW128-1:0] curr_rnd_key_i,
  input  logic [EGW128-1:0] prev_rnd_key_i,

  output logic [EGW128-1:0] next_rnd_key_o
);

/***********
 * SIGNALS *
 ***********/

  logic [3:0][31:0] words_s;
  logic [3:0][31:0] curr_key_s;
  logic [3:0][31:0] prev_key_s;

  logic      [ 3:0] rnd_s, r_s;

  logic      [31:0] curr_key_3_sbox_in_s, curr_key_3_sbox_res_s;


/*********************
 * AES KEY EXPANSION *
 *********************/

  always_comb begin

    // default assignments
    r_s                  = 4'b0;
    curr_key_3_sbox_in_s = 32'b0;
    words_s              = '0;

    // common logic
    // convert inputs into element form
    for (int word = 0; word < 4; word++) begin
      curr_key_s[word] = curr_rnd_key_i[(word*32) +: 32];
      prev_key_s[word] = prev_rnd_key_i[(word*32) +: 32];
    end

    rnd_s[2:0] = rnd_i[2:0];

    // AES-256 key expansion logic
    if (aes_kop_i) begin

      rnd_s[3] = (rnd_i < 4'd2 || rnd_i > 4'd14) ? ~rnd_i[3] : rnd_i[3];

      if (rnd_s[0]) begin

        curr_key_3_sbox_in_s = curr_key_s[3];
        words_s[0] = curr_key_3_sbox_res_s ^ prev_key_s[0];

      end else begin

        r_s = (rnd_s >> 1) - 1;

        curr_key_3_sbox_in_s = aes_rotword(curr_key_s[3]);
        words_s[0] = curr_key_3_sbox_res_s ^ aes_decode_rcon(r_s) ^ prev_key_s[0];

      end

      words_s[1] = words_s[0] ^ prev_key_s[1];
      words_s[2] = words_s[1] ^ prev_key_s[2];
      words_s[3] = words_s[2] ^ prev_key_s[3];

    // AES-128 key expansion logic
    end else begin

      rnd_s[3]   = (rnd_i > 4'd10 || rnd_i == 4'd0) ? ~rnd_i[3] : rnd_i[3];

      r_s = rnd_s - 1;

      curr_key_3_sbox_in_s = aes_rotword(curr_key_s[3]);

      words_s[0] = curr_key_3_sbox_res_s ^ aes_decode_rcon(r_s) ^ curr_key_s[0];
      words_s[1] = words_s[0] ^ curr_key_s[1];
      words_s[2] = words_s[1] ^ curr_key_s[2];
      words_s[3] = words_s[2] ^ curr_key_s[3];
    end

  end

  // assign output
  assign next_rnd_key_o = {words_s[3], words_s[2], words_s[1], words_s[0]};


/********************
 * S-BOX INSTANCES  *
 ********************/

  canright_sbox i_sbox0 (
   .sbox_byte_i   ( curr_key_3_sbox_in_s[7:0]    ),
   .encrypt_sel_i (                       1'b1   ),
   .sbox_byte_o   ( curr_key_3_sbox_res_s[7:0]   )
  );

  canright_sbox i_sbox1 (
   .sbox_byte_i   ( curr_key_3_sbox_in_s[15:8]   ),
   .encrypt_sel_i (                        1'b1  ),
   .sbox_byte_o   ( curr_key_3_sbox_res_s[15:8]  )
  );

  canright_sbox i_sbox2 (
   .sbox_byte_i   ( curr_key_3_sbox_in_s[23:16]  ),
   .encrypt_sel_i (                         1'b1 ),
   .sbox_byte_o   ( curr_key_3_sbox_res_s[23:16] )
  );

  canright_sbox i_sbox3 (
   .sbox_byte_i   ( curr_key_3_sbox_in_s[31:24]  ),
   .encrypt_sel_i (                         1'b1 ),
   .sbox_byte_o   ( curr_key_3_sbox_res_s[31:24] )
  );

/************************
 * FUNCTION DEFINITIONS *
 ************************/

  // ROTWORD - one byte circular right shift
  function automatic logic [31:0] aes_rotword(
    logic [31:0] curr_rnd_key_3
  );

    return {curr_rnd_key_3[7:0],curr_rnd_key_3[31:8]};
  endfunction

  // RCON - lookup round constant
  function automatic logic [31:0] aes_decode_rcon(
    logic [3:0] r
  );

    case(r)
      4'h0: return 32'h00000001;
      4'h1: return 32'h00000002;
      4'h2: return 32'h00000004;
      4'h3: return 32'h00000008;
      4'h4: return 32'h00000010;
      4'h5: return 32'h00000020;
      4'h6: return 32'h00000040;
      4'h7: return 32'h00000080;
      4'h8: return 32'h0000001B;
      4'h9: return 32'h00000036;
      4'hA: return 32'h00000000;
      4'hB: return 32'h00000000;
      4'hC: return 32'h00000000;
      4'hD: return 32'h00000000;
      4'hE: return 32'h00000000;
      4'hF: return 32'h00000000;
      default: return 32'h0;

    endcase

  endfunction

endmodule
