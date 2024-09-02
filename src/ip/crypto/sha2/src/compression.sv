//------------------------------------------------------------------------------
// Module   : msg_schedule
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 22-may-2024
//
// Description: SHA-2 Operation module, containing logic to perform two rounds 
//              of compression.
//              This module supports both SHA-256 and SHA-512 operations. In the
//              former case, only the first half of each word is used.
//              Taken from Sail code listed within:
//              RISC-V Cryptography Extensions Volume II : Vector Instructions
//              Version v1.0.0, 22 August 2023 RC3,
//              Chapter 3.21 vsha2c[hl].vv
//
// Parameters:
//  - None
//
// Inputs:
//  - c_state_0_i    : current state {c, d, g, h} (vd)
//  - c_state_1_i    : current state {a, b, e, f} (vs2)
//  - msg_sched_pc_i : message schedule + constant (vs1)
//  - sha_op_i       :
//    0 = HIGH PART SEW32 (SHA256)
//    1 = HIGH PART SEW64 (SHA512)
//    2 = LOW PART SEW32 (SHA256)
//    3 = LOW PART SEW64 (SHA512)
//
// Outputs:
//  - n_state_o : next state {a, b, e, f}
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

module compression
import ara_pkg::*;
(
  input  logic [EGW256-1:0] c_state_0_i,
  input  logic [EGW256-1:0] c_state_1_i,
  input  logic [EGW256-1:0] msg_sched_pc_i,
  input  logic [  1:0] sha_op_i,

  output logic [EGW256-1:0] n_state_o
);

/*********
 * TYPES *
 *********/

  typedef enum logic {
    SHA2_COMP_HIGH = 1'b0,
    SHA2_COMP_LOW  = 1'b1
  } sha_2_comp_e;

/***********
 * SIGNALS *
 ***********/

  logic [31:0] a_32, b_32, c_32, d_32, e_32, f_32, g_32, h_32;
  logic [63:0] a_64, b_64, c_64, d_64, e_64, f_64, g_64, h_64;

  logic [3:0][31:0] msg_sched_pc_32_s;
  logic [3:0][63:0] msg_sched_pc_64_s;

  logic [31:0] W0_32, W1_32;
  logic [63:0] W0_64, W1_64;

  logic [31:0] T1_32, T2_32;
  logic [63:0] T1_64, T2_64;

  logic [255:0] n_state_s;


/*********************
 * MESSAGE SHEDULING *
 *********************/

  always_comb begin

    // default assignments
    a_32 = '0;               a_64 = '0;
    b_32 = '0;               b_64 = '0;
    c_32 = '0;               c_64 = '0;
    d_32 = '0;               d_64 = '0;
    e_32 = '0;               e_64 = '0;
    f_32 = '0;               f_64 = '0;
    g_32 = '0;               g_64 = '0;
    h_32 = '0;               h_64 = '0;

    msg_sched_pc_32_s = '0;  msg_sched_pc_64_s = '0;

    W0_32 = '0;              W0_64 = '0;
    W1_32 = '0;              W1_64 = '0;

    T1_32 = '0;              T1_64 = '0;
    T2_32 = '0;              T2_64 = '0;

    n_state_s = '0;


    if (sha_op_i[0] == 1'b1) begin // SHA-512 (SEW64)

      // initial assignments
      {a_64, b_64, e_64, f_64} = c_state_1_i;
      {c_64, d_64, g_64, h_64} = c_state_0_i;

      msg_sched_pc_64_s = msg_sched_pc_i;

      {W1_64, W0_64} = (sha_op_i[1] == SHA2_COMP_LOW) ? msg_sched_pc_64_s [1:0] :
                                                        msg_sched_pc_64_s [3:2];

      T1_64 = h_64 + sum1_64(e_64) + ch_64(e_64, f_64, g_64) + W0_64;
      T2_64 = sum0_64(a_64) + maj_64(a_64, b_64, c_64);

      h_64 = g_64;
      g_64 = f_64;
      f_64 = e_64;
      e_64 = d_64 + T1_64;
      d_64 = c_64;
      c_64 = b_64;
      b_64 = a_64;
      a_64 = T1_64 + T2_64;

      T1_64 = h_64 + sum1_64(e_64) + ch_64(e_64, f_64, g_64) + W1_64;
      T2_64 = sum0_64(a_64) + maj_64(a_64, b_64, c_64);

      h_64 = g_64;
      g_64 = f_64;
      f_64 = e_64;
      e_64 = d_64 + T1_64;
      d_64 = c_64;
      c_64 = b_64;
      b_64 = a_64;
      a_64 = T1_64 + T2_64;

      n_state_s = {a_64, b_64, e_64, f_64};

    end else begin // SHA-256 (SEW32)

      // initial assignments (only extract lower half of buffer when SEW32)
      {a_32, b_32, e_32, f_32} = c_state_1_i[127:0];
      {c_32, d_32, g_32, h_32} = c_state_0_i[127:0];

      msg_sched_pc_32_s = msg_sched_pc_i[127:0];

      {W1_32, W0_32} = (sha_op_i[1] == SHA2_COMP_LOW) ? msg_sched_pc_32_s [1:0] :
                                                        msg_sched_pc_32_s [3:2];

      T1_32 = h_32 + sum1_32(e_32) + ch_32(e_32, f_32, g_32) + W0_32;
      T2_32 = sum0_32(a_32) + maj_32(a_32, b_32, c_32);

      h_32 = g_32;
      g_32 = f_32;
      f_32 = e_32;
      e_32 = d_32 + T1_32;
      d_32 = c_32;
      c_32 = b_32;
      b_32 = a_32;
      a_32 = T1_32 + T2_32;

      T1_32 = h_32 + sum1_32(e_32) + ch_32(e_32, f_32, g_32) + W1_32;
      T2_32 = sum0_32(a_32) + maj_32(a_32, b_32, c_32);

      h_32 = g_32;
      g_32 = f_32;
      f_32 = e_32;
      e_32 = d_32 + T1_32;
      d_32 = c_32;
      c_32 = b_32;
      b_32 = a_32;
      a_32 = T1_32 + T2_32;

      // only fill lower half of output buffer when SEW32
      n_state_s[127:0] = {a_32, b_32, e_32, f_32};

    end

  end

/*********************
 * OUTPUT ASSIGNMENT *
 *********************/

  assign n_state_o = n_state_s;

/************************
 * FUNCTION DEFINITIONS *
 ************************/

  // Circular rotate right for SEW64
  function automatic logic [63:0] ROTR_64( logic [63:0] x, int n);

   return ((x >> n) | (x << (64 - n)));

  endfunction

  // Circular rotate right for SEW32
  function automatic logic [31:0] ROTR_32( logic [31:0] x, int n);

   return ((x >> n) | (x << (32 - n)));

  endfunction

  // sum0 for SEW64
  function automatic logic [63:0] sum0_64(logic [63:0] x);

    return (ROTR_64(x, 28) ^ ROTR_64(x, 34) ^ ROTR_64(x, 39));

  endfunction;

  // sum0 for SEW32
  function automatic logic [31:0] sum0_32(logic [31:0] x);

    return (ROTR_32(x, 2) ^ ROTR_32(x, 13) ^ ROTR_32(x, 22));

  endfunction;

  // sum1 for SEW64
  function automatic logic [63:0] sum1_64(logic [63:0] x);

    return (ROTR_64(x, 14) ^ ROTR_64(x, 18) ^ ROTR_64(x, 41));

  endfunction;

  // sum1 for SEW32
  function automatic logic [31:0] sum1_32(logic [31:0] x);

    return (ROTR_32(x, 6) ^ ROTR_32(x, 11) ^ ROTR_32(x, 25));

  endfunction;

  // ch function for SEW64
  function automatic logic [63:0] ch_64(logic [63:0] x, logic [63:0] y, logic [63:0] z);

    return ((x & y) ^ ((~x) & z));

  endfunction

  // ch function for SEW32
  function automatic logic [31:0] ch_32(logic [31:0] x, logic [31:0] y, logic [31:0] z);

    return ((x & y) ^ ((~x) & z));

  endfunction

  // maj function for SEW64
  function automatic logic [63:0] maj_64( logic [63:0] x, logic [63:0] y, logic [63:0] z);

    return ((x & y) ^ (x & z) ^ (y & z));

  endfunction

  // maj function for SEW32
  function automatic logic [31:0] maj_32( logic [31:0] x, logic [31:0] y, logic [31:0] z);

    return ((x & y) ^ (x & z) ^ (y & z));

  endfunction

endmodule
