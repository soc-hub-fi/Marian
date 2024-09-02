//------------------------------------------------------------------------------
// Module   : sm3_compression
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Endrit Isufi <endrit.isufi@tuni.fi>
// Created  : 10-July-2024
//
// Description: SM3 Operation module, containing logic to perform two rounds 
//              of compression.
//              Taken from Sail code listed within:
//              RISC-V Cryptography Extensions Volume II : Vector Instructions
//              Version v1.0.0, 5 October RC3,
//              Chapter 3.21 vsha2c[hl].vv
//
// Parameters:
//  - None
//
// Inputs:
//  - crnt_state_i : Current state {H, G, F, E, D, C, B, A}
//  - msg_words_i  : Message words {-,-,w[5],w[4],-,-,w[1],w[0]}
//  - rnds_i       : round number (rnds)
//
// Outputs:
//  - next_state_o : Next state {H,G.F,E,D,C,B,A}
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

module sm3_compression
import ara_pkg::*;
(
  input  logic [EGW256-1:0] crnt_state_i,
  input  logic [EGW256-1:0] msg_words_i,
  input  logic [  4:0]      rnds_i,

  output logic [EGW256-1:0] next_state_o
);

/***********
 * SIGNALS *
 ***********/
  logic [EGW256-1:0] crnt_state_s;
  logic [EGW256-1:0] msg_words_s;
  logic [  4:0]      rnds_s;

  logic [31:0] Hi;
  logic [31:0] Gi;
  logic [31:0] Fi;
  logic [31:0] Ei;
  logic [31:0] Di;
  logic [31:0] Ci;
  logic [31:0] Bi;
  logic [31:0] Ai;

  logic [31:0] u_w7;
  logic [31:0] u_w6;
  logic [31:0] w5i;
  logic [31:0] w4i;
  logic [31:0] u_w3;
  logic [31:0] u_w2;
  logic [31:0] w1i;
  logic [31:0] w0i;

  logic [31:0] j;
  logic [31:0] H;
  logic [31:0] G;
  logic [31:0] F;
  logic [31:0] E;
  logic [31:0] D;
  logic [31:0] C;
  logic [31:0] B;
  logic [31:0] A;

  logic [31:0] w5;
  logic [31:0] w4;
  logic [31:0] w1;
  logic [31:0] w0;

  logic [31:0] x0;
  logic [31:0] x1;

  logic [31:0] ss1;
  logic [31:0] ss2;
  logic [31:0] tt1;
  logic [31:0] tt2;

  logic [31:0] A1;
  logic [31:0] C1;
  logic [31:0] E1;
  logic [31:0] G1;

  logic [31:0] A2;
  logic [31:0] C2;
  logic [31:0] E2;
  logic [31:0] G2;

  logic [4:0] rnd_s;
  logic [255:0] result;

/***************
 * COMPRESSION *
 ***************/

  always_comb begin

    //initial assignments
    crnt_state_s = 32'h0;
    msg_words_s  = 32'h0;
    rnds_s       = 5'h0;
    Hi = 32'h0;
    Gi = 32'h0;
    Fi = 32'h0;
    Ei = 32'h0;
    Di = 32'h0;
    Ci = 32'h0;
    Bi = 32'h0;
    Ai = 32'h0;
  
    u_w7 = 32'h0;
    u_w6 = 32'h0;
    w5i  = 32'h0;
    w4i  = 32'h0;
    u_w3 = 32'h0;
    u_w2 = 32'h0;
    w1i  = 32'h0;
    w0i  = 32'h0;
  
    j = '0;
    H = 32'h0;
    G = 32'h0;
    F = 32'h0;
    E = 32'h0;
    D = 32'h0;
    C = 32'h0;
    B = 32'h0;
    A = 32'h0;
  
    w4 = 32'h0;
    w5 = 32'h0;
    w1 = 32'h0;
    w0 = 32'h0;
  
    x0 = 32'h0;
    x1 = 32'h0;
  
    ss1 = 32'h0;
    ss2 = 32'h0;
    tt1 = 32'h0;
    tt2 = 32'h0;
  
    A1 = 32'h0;
    C1 = 32'h0;
    E1 = 32'h0;
    G1 = 32'h0;
  
    A2 = 32'h0;
    C2 = 32'h0;
    E2 = 32'h0;
    G2 = 32'h0;
  
    result = 256'h0;    

    // SM3 compression logic
    crnt_state_s = crnt_state_i;
    msg_words_s  = msg_words_i;
    rnd_s = rnds_i;
  
    {Hi, Gi, Fi, Ei, Di, Ci, Bi, Ai} = crnt_state_s;
    {u_w7, u_w6, w5i, w4i, u_w3, u_w2, w1i, w0i} = msg_words_s;

    H = sm_rev8(Hi);
    G = sm_rev8(Gi);
    F = sm_rev8(Fi);
    E = sm_rev8(Ei);
    D = sm_rev8(Di);
    C = sm_rev8(Ci);
    B = sm_rev8(Bi);
    A = sm_rev8(Ai); 
    
    w5 = sm_rev8(w5i);
    w4 = sm_rev8(w4i);
    w1 = sm_rev8(w1i);
    w0 = sm_rev8(w0i);

    x0 = w0 ^ w4;
    x1 = w1 ^ w5;

    j = 2 * rnd_s;
    ss1 = sm_ROL32(sm_ROL32(A, 12) + E + sm_ROL32(sm_t_j(j), j % 32), 7);
    ss2 = ss1 ^ sm_ROL32(A, 12);
    tt1 = sm_ff_j(A, B, C, j) + D + ss2 + x0;
    tt2 = sm_gg_j(E, F, G, j) + H + ss1 + w0;
    D = C;
    C1 = sm_ROL32(B, 9);
    B = A;
    A1 = tt1;
    H = G;
    G1 = sm_ROL32(F, 19);
    F = E;
    E1 = sm_p_0(tt2);

    j = 2 * rnd_s + 1;
    ss1 = sm_ROL32(sm_ROL32(A1, 12) + E1 + sm_ROL32(sm_t_j(j), j % 32), 7);
    ss2 = ss1 ^ sm_ROL32(A1, 12);
    tt1 = sm_ff_j(A1, B, C1, j) + D + ss2 + x1;
    tt2 = sm_gg_j(E1, F, G1, j) + H + ss1 + w1;
    D = C1;
    C2 = sm_ROL32(B, 9);
    B = A1;
    A2 = tt1;
    H = G1;
    G2 = sm_ROL32(F, 19);
    F = E1;
    E2 = sm_p_0(tt2);

    result = {sm_rev8(G1), sm_rev8(G2), sm_rev8(E1), sm_rev8(E2),
              sm_rev8(C1), sm_rev8(C2), sm_rev8(A1), sm_rev8(A2)};
   
  end

/*********************
 * OUTPUT ASSIGNMENT *
 *********************/
assign next_state_o = result; 

/************************
 * FUNCTION DEFINITIONS *
 ************************/
  //rotate X by a factor of S
 function bit [31:0] sm_ROL32(bit [31:0] X, int S);
  return ((X << S) | (X >> (32 - S)));
 endfunction

 /*byte-reverse */
 function bit [31:0] sm_rev8(bit [31:0] word_i);
    return  (word_i >> 24 & 8'hff) |
            (word_i << 8 & 24'hff0000) |
            (word_i >> 8 & 16'hff00) |
            (word_i << 24 & 32'hff000000);
 endfunction


 function bit [31:0] sm_ff1(bit [31:0] X, bit [31:0] Y, bit [31:0] Z);
 return (X ^ Y ^ Z);
 endfunction

function bit [31:0] sm_ff2(bit [31:0] X, bit [31:0] Y, bit [31:0] Z);
 return ( (X & Y) | (X & Z) | (Y & Z) );
 endfunction

 function bit [31:0] sm_ff_j(bit [31:0] X, bit [31:0] Y, bit [31:0] Z, int unsigned J);
 return ( (J <= 15) ? sm_ff1(X, Y, Z) : sm_ff2(X, Y, Z) );
 endfunction

function bit [31:0] sm_gg1(bit [31:0] X, bit [31:0] Y, bit [31:0] Z);
 return (X ^ Y ^ Z);
endfunction

function bit [31:0] sm_gg2(bit [31:0] X, bit [31:0] Y, bit [31:0] Z);
 return (X & Y) | ((~X) & Z);
endfunction

function bit [31:0] sm_gg_j(bit [31:0] X, bit [31:0] Y, bit [31:0] Z, int J);
 return J <= 15 ? sm_gg1(X, Y, Z) : sm_gg2(X, Y, Z);
endfunction


function bit [31:0] sm_t_j(int unsigned J);
 return J <= 15 ? 32'h79CC4519 : 32'h7A879D8A;
endfunction

function bit [31:0] sm_p_0(bit [31:0] X);
 return (X ^ sm_ROL32(X, 9) ^ sm_ROL32(X, 17));
endfunction

endmodule
