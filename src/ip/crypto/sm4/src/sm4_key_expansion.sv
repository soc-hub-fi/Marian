//------------------------------------------------------------------------------
// Module   : sm4_key_expansion
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Endrit Isufi <endrit.isufi@tuni.fi>
// Created  : 10-July-2024
//
// Description: Vector SM4 Key expansion, where four rounds of SM4 key expansions are performed.
//              Implemented using Sail specification defined within :
//              RISC-V Cryptography Extensions Volume II Vector Instructions
//              Version v1.0.0, 5 October 2023: RC3
//
// Parameters:
//  - None
//
// Inputs:
//  - rnd_i: Round group (rnd)
//  - curr_rnd_key_i: Current 4 round keys rK[0:3]
//
// Outputs:
//  - next_rnd_key_o: Next 4 round keys rK'[0:3]

//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

module sm4_key_expansion
import ara_pkg::*;
(
  input  logic [       2:0] rnd_i,
  input  logic [EGW128-1:0] curr_rnd_key_i,

  output logic [EGW128-1:0] next_rnd_key_o
);

/***********
 * SIGNALS *
 ***********/

 logic [3:0][31:0] words_s;
 logic [3:0][31:0] curr_key_s;
 logic [3:0][31:0] next_key_s;

 logic [ 2:0] r_s;

 logic [31:0] B;
 logic [31:0] S;
 logic [31:0] rk0;
 logic [31:0] rk1;
 logic [31:0] rk2;
 logic [31:0] rk3;
 logic [31:0] rk4;
 logic [31:0] rk5;
 logic [31:0] rk6;
 logic [31:0] rk7;
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

/*********************
 * SM4 KEY EXPANSION *
 *********************/
 always_comb begin
    //default assignments
    r_s = rnd_i;
    B   = '0;
    S   = '0;
    rk0 = '0;
    rk1 = '0;
    rk2 = '0;
    rk3 = '0;
    rk4 = '0;
    rk5 = '0;
    rk6 = '0;
    rk7 = '0;  
    // SM4 key expansion logic
    curr_key_s = curr_rnd_key_i;
    {rk3, rk2, rk1, rk0} = curr_key_s;
    
    B = rk1 ^ rk2 ^ rk3 ^ sm_constant_key(4 * r_s);
    S = sm_subword(B);
    rk4 = sm_round_key(rk0, S);
    
    B = rk2 ^ rk3 ^ rk4 ^ sm_constant_key((4 * r_s) + 1);
    S = sm_subword(B);
    rk5 = sm_round_key(rk1, S);
    
    B = rk3 ^ rk4 ^ rk5 ^ sm_constant_key((4 * r_s) + 2);
    S = sm_subword(B);
    rk6 = sm_round_key(rk2, S);
    
    B = rk4 ^ rk5 ^ rk6 ^ sm_constant_key((4 * r_s) + 3);
    S = sm_subword(B);
    rk7 = sm_round_key(rk3, S);
    
    next_key_s = {rk7, rk6, rk5, rk4};
 end

 // output generated 4 round keys
  assign  next_rnd_key_o = next_key_s;

 /************************
 * FUNCTION DEFINITIONS *
 ************************/
 // SM4 lookup Constant Key (CK)
  function logic [31:0] sm_constant_key(logic [4:0] r);
    case(r)
      5'h00: return 32'h00070E15;
      5'h01: return 32'h1C232A31;
      5'h02: return 32'h383F464D;
      5'h03: return 32'h545B6269;
      5'h04: return 32'h70777E85;
      5'h05: return 32'h8C939AA1;
      5'h06: return 32'hA8AFB6BD;
      5'h07: return 32'hC4CBD2D9;
      5'h08: return 32'hE0E7EEF5;
      5'h09: return 32'hFC030A11;
      5'h0A: return 32'h181F262D;
      5'h0B: return 32'h343B4249;
      5'h0C: return 32'h50575E65;
      5'h0D: return 32'h6C737A81;
      5'h0E: return 32'h888F969D;
      5'h0F: return 32'hA4ABB2B9;
      5'h10: return 32'hC0C7CED5;
      5'h11: return 32'hDCE3EAF1;
      5'h12: return 32'hF8FF060D;
      5'h13: return 32'h141B2229;
      5'h14: return 32'h30373E45;
      5'h15: return 32'h4C535A61;
      5'h16: return 32'h686F767D;
      5'h17: return 32'h848B9299;
      5'h18: return 32'hA0A7AEB5;
      5'h19: return 32'hBCC3CAD1;
      5'h1A: return 32'hD8DFE6ED;
      5'h1B: return 32'hF4FB0209;
      5'h1C: return 32'h10171E25;
      5'h1D: return 32'h2C333A41;
      5'h1E: return 32'h484F565D;
      5'h1F: return 32'h646B7279;
      default: return 32'h0;
    endcase
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

  //rotate X by a factor of S
  function bit [31:0] sm_ROL32(bit [31:0] X, int unsigned S);
  return ((X << S) | (X >> (32 - S)));
  endfunction

  /* generate round key*/
  function bit [31:0] sm_round_key(bit [31:0] X, bit [31:0] S);
    return (X ^ (S ^ sm_ROL32(S, 13) ^ sm_ROL32(S, 23)));
  endfunction

endmodule