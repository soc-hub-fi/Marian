//------------------------------------------------------------------------------
// Module   : sm3_msg_expansion
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Endrit Isufi <endrit.isufi@tuni.fi>
// Created  : 10-July-2024
//
// Description: Vector SM3 Message expansion, containing logic to perform
//              eight rounds of SM3 message expansions.
//              Implemented using Sail specification defined within :
//              RISC-V Cryptography Extensions Volume II Vector Instructions
//              Version v1.0.0, 5 October 2023: RC3
//
// Parameters:
//  - None
//
// Inputs:
//  - msg_words_start_i: Message words W[7:0]
//  - msg_words_end_i  : Message words W[15:8]
//
// Outputs:
//  - msg_words_o      : Message words W[23:16]
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

module sm3_msg_expansion
import ara_pkg::*;
(
    input  logic [EGW256-1:0] msg_words_start_i,
    input  logic [EGW256-1:0] msg_words_end_i,
  
    output logic [EGW256-1:0] msg_words_o
);

/***********
 * SIGNALS *
 ***********/

 logic [23:0][31:0] w;
 logic [EGW256-1:0] msg_words_start_s;
 logic [EGW256-1:0] msg_words_end_s;
 logic [EGW256-1:0] res_msg_words_s;

 logic [31:0] w0;
 logic [31:0] w1;
 logic [31:0] w2;
 logic [31:0] w3;
 logic [31:0] w4;
 logic [31:0] w5;
 logic [31:0] w6;
 logic [31:0] w7;
 logic [31:0] w8;
 logic [31:0] w9;
 logic [31:0] w10;
 logic [31:0] w11;
 logic [31:0] w12;
 logic [31:0] w13;
 logic [31:0] w14;
 logic [31:0] w15;

 logic [31:0] w16;
 logic [31:0] w17;
 logic [31:0] w18;
 logic [31:0] w19;
 logic [31:0] w20;
 logic [31:0] w21;
 logic [31:0] w22;
 logic [31:0] w23;

 /************************
 * SM3 MESSAGE EXPANSION *
 ************************/

 always_comb begin
   //initial assignments
   w   = '0;
   w0  = '0;
   w1  = '0;
   w2  = '0;
   w3  = '0;
   w4  = '0;
   w5  = '0;
   w6  = '0;
   w7  = '0;
   w8  = '0;
   w9  = '0;
   w10  = '0;
   w11  = '0;
   w12  = '0;
   w13  = '0;
   w14  = '0;
   w15  = '0;
   w17 = 32'h0;
   w18 = 32'h0;
   w16 = 32'h0;
   w19 = 32'h0;
   w20 = 32'h0;
   w21 = 32'h0;
   w22 = 32'h0;
   w23 = 32'h0;
   msg_words_start_s = '0;
   msg_words_end_s   = '0;
   res_msg_words_s   = '0;

   // SM3 message expansion logic
   msg_words_start_s = msg_words_start_i;
   msg_words_end_s   = msg_words_end_i;
   w[7:0] = msg_words_start_s;
   w[15:8] = msg_words_end_s;
   
   w15 = sm_rev8(w[15]);
   w14 = sm_rev8(w[14]);
   w13 = sm_rev8(w[13]);
   w12 = sm_rev8(w[12]);
   w11 = sm_rev8(w[11]);
   w10 = sm_rev8(w[10]);
   w9 = sm_rev8(w[9]);
   w8 = sm_rev8(w[8]);
   w7 = sm_rev8(w[7]);
   w6 = sm_rev8(w[6]);
   w5 = sm_rev8(w[5]);
   w4 = sm_rev8(w[4]);
   w3 = sm_rev8(w[3]);
   w2 = sm_rev8(w[2]);
   w1 = sm_rev8(w[1]);
   w0 = sm_rev8(w[0]);
   
   w[16] = sm_zvksh_w(w0, w7,  w13, w3,  w10);
   w[17] = sm_zvksh_w(w1, w8,  w14, w4,  w11);
   w[18] = sm_zvksh_w(w2, w9,  w15, w5,  w12);
   w[19] = sm_zvksh_w(w3, w10, w[16], w6,  w13);
   w[20] = sm_zvksh_w(w4, w11, w[17], w7,  w14);
   w[21] = sm_zvksh_w(w5, w12, w[18], w8,  w15);
   w[22] = sm_zvksh_w(w6, w13, w[19], w9,  w[16]);
   w[23] = sm_zvksh_w(w7, w14, w[20], w10, w[17]);
   

   w16 = sm_rev8(w[16]);
   w17 = sm_rev8(w[17]);
   w18 = sm_rev8(w[18]);
   w19 = sm_rev8(w[19]);
   w20 = sm_rev8(w[20]);
   w21 = sm_rev8(w[21]);
   w22 = sm_rev8(w[22]);
   w23 = sm_rev8(w[23]);

   res_msg_words_s = {w23, w22, w21, w20, w19, w18, w17, w16};

 end

  assign msg_words_o = res_msg_words_s;

 /***********************
 * FUNCTION DEFINITIONS *
 ************************/

  //rotate X by a factor of S
 function bit [31:0] sm_ROL32(bit [31:0] X, int S);
    return ((X << S) | (X >> (32 - S)));
 endfunction

 // permutation
 function bit [31:0] sm_p_1(bit [31:0] X);
  return (X ^ sm_ROL32(X, 15) ^ sm_ROL32(X, 23));
 endfunction

 /*endian byte swap */
 function bit [31:0] sm_rev8(bit [31:0] word_i);
    return  (word_i >> 24 & 8'hff) |
            (word_i << 8 & 24'hff0000) |
            (word_i >> 8 & 16'hff00) |
            (word_i << 24 & 32'hff000000);
 endfunction

  function bit [31:0] sm_zvksh_w(bit [31:0] M16, bit [31:0] M9, bit [31:0] M3,
                                 bit [31:0] M13, bit [31:0] M6);
    return (sm_p_1(M16 ^ M9 ^ sm_ROL32(M3, 15) ) ^ sm_ROL32(M13, 7) ^ M6);
  endfunction
  

endmodule
