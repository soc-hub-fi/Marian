//------------------------------------------------------------------------------
// Module   : encdec
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 10-may-2024
//
// Description: AES key encryption/decryption module, supporting operations
//              for both AES-128 and AES-256.
//              Implemented using Sail specification defined within :
//              RISC-V Cryptography Extensions Volume II Vector Instructions
//              Version v1.0.0, 22 August 2023: RC3
//
//              Encoding of operation select:
//
//                   bit│ 2  1  0
//                   ---│---------
//              aes_op_i│ 0  0  0
//                        ▲  ▲
//                        │  │
//                       dec │
//                          enc
//
// Parameters:
//  - None
//
// Inputs:
//  - aes_op_i: Controls for AES enc/dec:
//    0 = round zero enc/dec
//    2 = middle round enc
//    3 = final round enc
//    4 = middle round dec
//    5 = final round dec
//  - rnd_state_i: Round state
//  - rnd_key_i: Round key
//
// Outputs:
//  - rnd_state_o: new round state
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

module encdec
import ara_pkg::*;
(
  input  logic [       2:0] aes_op_i,
  input  logic [EGW128-1:0] rnd_state_i,
  input  logic [EGW128-1:0] rnd_key_i,

  output logic [EGW128-1:0] rnd_state_o
);

/*********
 * TYPES *
 *********/

  typedef enum logic [2:0] {
    ZERO_RND  = 3'b000,
    ENC_M_RND = 3'b010,
    ENC_F_RND = 3'b011,
    DEC_M_RND = 3'b100,
    DEC_F_RND = 3'b101
  } aes_op_t;

/***********
 * SIGNALS *
 ***********/

  logic [3:0][31:0] words_s;
  logic [3:0][31:0] rnd_state_s;
  logic [3:0][31:0] rnd_key_s;

  logic [3:0][31:0] sub_state_in_s;
  logic [3:0][31:0] sub_state_out_s;
  logic [3:0][31:0] shift_state_s;
  logic [3:0][31:0] ark_state_s;
  logic [3:0][31:0] mix_state_s;

  logic sbox_encdec_sel_s;

/***************
 * AES ENC/DEC *
 ***************/

  assign sbox_encdec_sel_s = aes_op_i[1];

  always_comb begin

    // default assignments
    shift_state_s     = '0;
    ark_state_s       = '0;
    mix_state_s       = '0;
    sub_state_in_s    = '0;
    words_s           = '{default: 0};

    // convert inputs into element form
    for (int word = 0; word < 4; word++) begin
      rnd_state_s[word] = rnd_state_i[(word*32) +: 32];
      rnd_key_s[word]   = rnd_key_i[(word*32)   +: 32];
    end

    case (aes_op_i)

      ZERO_RND: begin // zero round (enc + dec)

        for (int word = 0; word < 4; word++) begin
          words_s[word] = rnd_state_s[word] ^ rnd_key_s[word];
        end

      end

      ENC_M_RND: begin // middle round enc

        sub_state_in_s    = rnd_state_s;
        shift_state_s     = shift_rows(sub_state_out_s, sbox_encdec_sel_s);
        mix_state_s       = mix_columns(shift_state_s, sbox_encdec_sel_s);

        for (int word = 0; word < 4; word++) begin
          words_s[word] = mix_state_s[word] ^ rnd_key_s[word];
        end

      end


      ENC_F_RND: begin // final round enc

        sub_state_in_s    = rnd_state_s;
        shift_state_s     = shift_rows(sub_state_out_s, sbox_encdec_sel_s);

        for (int word = 0; word < 4; word++) begin
          words_s[word] = shift_state_s[word] ^ rnd_key_s[word];
        end

      end

      DEC_M_RND: begin // middle round dec

        shift_state_s  = shift_rows(rnd_state_s, sbox_encdec_sel_s);
        sub_state_in_s = shift_state_s;

        for (int word = 0; word < 4; word++) begin
          ark_state_s[word] = sub_state_out_s[word] ^ rnd_key_s[word];
        end

        mix_state_s = mix_columns(ark_state_s, sbox_encdec_sel_s);
        words_s     = mix_state_s;

      end

      DEC_F_RND: begin // final round dec

        shift_state_s  = shift_rows(rnd_state_s, sbox_encdec_sel_s);
        sub_state_in_s = shift_state_s;

        for (int word = 0; word < 4; word++) begin
          ark_state_s[word] = sub_state_out_s[word] ^ rnd_key_s[word];
        end

        words_s = ark_state_s;

      end

      default: begin
        // do nothing
      end

    endcase

  end

  // assign output
  assign rnd_state_o = {words_s[3], words_s[2], words_s[1], words_s[0]};

/********************
 * S-BOX INSTANCES  *
 ********************/

  for (genvar state_word = 0; state_word < 4; state_word++) begin : gen_sbox_word
    for (genvar state_byte = 0; state_byte < 4; state_byte++) begin : gen_sbox_byte

    canright_sbox i_sbox (
     .sbox_byte_i   ( sub_state_in_s [state_word][(state_byte*8) +: 8] ),
     .encrypt_sel_i ( sbox_encdec_sel_s                                  ),
     .sbox_byte_o   ( sub_state_out_s[state_word][(state_byte*8) +: 8] )
    );

    end : gen_sbox_byte
  end : gen_sbox_word

/************************
 * FUNCTION DEFINITIONS *
 ************************/

  // perform mix rows (fed/inv)
  function automatic logic [3:0][31:0] shift_rows (
    logic [3:0][31:0] curr_state,
    logic             enc_dec_sel
  );

    automatic logic [3:0][ 3:0][7:0] c_state_bytes;
    automatic logic [3:0][31:0]      shifted_state;

    // transform word array into byte array for easy reference
    for (int word_idx = 0; word_idx < 4; word_idx++) begin
      for (int byte_idx = 0; byte_idx < 4; byte_idx++) begin
        c_state_bytes[word_idx][byte_idx] = curr_state[word_idx][(byte_idx*8) +: 8];
      end
    end

    if (enc_dec_sel) begin // encrypt

      shifted_state[0] = {c_state_bytes[3][3], c_state_bytes[2][2],
                          c_state_bytes[1][1], c_state_bytes[0][0]};
      shifted_state[1] = {c_state_bytes[0][3], c_state_bytes[3][2],
                          c_state_bytes[2][1], c_state_bytes[1][0]};
      shifted_state[2] = {c_state_bytes[1][3], c_state_bytes[0][2],
                          c_state_bytes[3][1], c_state_bytes[2][0]};
      shifted_state[3] = {c_state_bytes[2][3], c_state_bytes[1][2],
                          c_state_bytes[0][1], c_state_bytes[3][0]};

    end else begin // decrypt

      shifted_state[0] = {c_state_bytes[1][3], c_state_bytes[2][2],
                          c_state_bytes[3][1], c_state_bytes[0][0]};
      shifted_state[1] = {c_state_bytes[2][3], c_state_bytes[3][2],
                          c_state_bytes[0][1], c_state_bytes[1][0]};
      shifted_state[2] = {c_state_bytes[3][3], c_state_bytes[0][2],
                          c_state_bytes[1][1], c_state_bytes[2][0]};
      shifted_state[3] = {c_state_bytes[0][3], c_state_bytes[1][2],
                          c_state_bytes[2][1], c_state_bytes[3][0]};

    end

    return shifted_state;

  endfunction

  // perform mix columns (fwd/inv)
  function automatic logic [3:0][31:0] mix_columns (
    logic [3:0][31:0] curr_state,
    logic             enc_dec_sel
  );

    automatic logic [3:0][ 3:0][7:0] c_state_bytes;
    automatic logic [3:0][31:0]      mixed_state;

    // transform word array into byte array for easy reference
    for (int word_idx = 0; word_idx < 4; word_idx++) begin
      for (int byte_idx = 0; byte_idx < 4; byte_idx++) begin
        c_state_bytes[word_idx][byte_idx] = curr_state[word_idx][(byte_idx*8) +: 8];
      end
    end

    for (int word = 0; word < 4; word++) begin

      if (enc_dec_sel) begin // encrypt

        mixed_state[word][  7:0] = xt2(c_state_bytes[word][0]) ^
                                   xt3(c_state_bytes[word][1]) ^
                                   c_state_bytes[word][2]      ^
                                   c_state_bytes[word][3];
        mixed_state[word][ 15:8] = c_state_bytes[word][0]      ^
                                   xt2(c_state_bytes[word][1]) ^
                                   xt3(c_state_bytes[word][2]) ^
                                   c_state_bytes[word][3];
        mixed_state[word][23:16] = c_state_bytes[word][0]      ^
                                   c_state_bytes[word][1]      ^
                                   xt2(c_state_bytes[word][2]) ^
                                   xt3(c_state_bytes[word][3]);
        mixed_state[word][31:24] = xt3(c_state_bytes[word][0]) ^
                                   c_state_bytes[word][1]      ^
                                   c_state_bytes[word][2]      ^
                                   xt2(c_state_bytes[word][3]);

      end else begin // decrypt

        mixed_state[word][  7:0] = gfmul(c_state_bytes[word][0], 4'hE) ^
                                   gfmul(c_state_bytes[word][1], 4'hB) ^
                                   gfmul(c_state_bytes[word][2], 4'hD) ^
                                   gfmul(c_state_bytes[word][3], 4'h9);
        mixed_state[word][ 15:8] = gfmul(c_state_bytes[word][0], 4'h9) ^
                                   gfmul(c_state_bytes[word][1], 4'hE) ^
                                   gfmul(c_state_bytes[word][2], 4'hB) ^
                                   gfmul(c_state_bytes[word][3], 4'hD);
        mixed_state[word][23:16] = gfmul(c_state_bytes[word][0], 4'hD) ^
                                   gfmul(c_state_bytes[word][1], 4'h9) ^
                                   gfmul(c_state_bytes[word][2], 4'hE) ^
                                   gfmul(c_state_bytes[word][3], 4'hB);
        mixed_state[word][31:24] = gfmul(c_state_bytes[word][0], 4'hB) ^
                                   gfmul(c_state_bytes[word][1], 4'hD) ^
                                   gfmul(c_state_bytes[word][2], 4'h9) ^
                                   gfmul(c_state_bytes[word][3], 4'hE);

      end
    end

    return mixed_state;

  endfunction

  // Auxiliary function for performing GF multiplication
  function automatic logic [7:0] xt2 (
    logic [7:0] x
  );
    xt2 = (x[7]) ? (x << 1) ^ 8'h1B : (x << 1) ^ 8'h00;
  endfunction

  // Auxiliary function for performing GF multiplication
  function automatic logic [7:0] xt3 (
    logic [7:0] x
  );
    xt3 = x ^ xt2(x);
  endfunction

  // Multiply 8-bit field element by 4-bit value for AES MixCols step
  function automatic logic [7:0] gfmul (
    logic [7:0] x,
    logic [3:0] y
  );
    automatic logic [7:0] x0, x1, x2, x3;

    x0 = (y[0]) ? x : 8'h00;
    x1 = (y[1]) ? xt2(x) : 8'h00;
    x2 = (y[2]) ? xt2(xt2(x)) : 8'h00;
    x3 = (y[3]) ? xt2(xt2(xt2(x))) : 8'h00;

    gfmul = x0 ^ x1 ^ x2 ^ x3;

  endfunction

endmodule
