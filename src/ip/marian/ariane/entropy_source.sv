//------------------------------------------------------------------------------
// Module   : entropy_source
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 11-jun-2024
//
// Description: Dummy entropy source which uses an LFSR to generate pseudo-
//              random numbers for use by the SEED CSR. LFSR is Galois LFSR with
//              taps at [4, 13, 14, 15] to ensure maximal length at 16b. FSM is
//              compatible with operation defined in Chapter 4 of RISC-V
//              Cryptography Extensions Volume I: Scalar & Entropy Source
//              instructions.
//
// Parameters:
//
// Inputs:
//  - clk_i: Input clock
//  - rst_ni: Input reset
//  - poll_i: Indicate that current value has been read and a new value should
//            be generated
//
// Outputs:
//  - opst_o: Operation state
//    BIST - 00
//    WAIT - 01
//    ES16 - 10
//    DEAD - 11
//  - entropy_o: 16b of entropy
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

module entropy_source (
  input logic clk_i,
  input logic rst_ni,

  input logic poll_i,

  output logic [ 1:0] opst_o,
  output logic [15:0] entropy_o
);

/*********
 * TYPES *
 *********/

  typedef enum logic [1:0] {
    BIST,
    WAIT,
    ES16,
    DEAD
  } op_state_e;


/***********
 * SIGNALS *
 ***********/

  op_state_e state_d, state_q;

  logic [15:0] lfsr_d, lfsr_q;


/*******
 * FSM *
 *******/

  always_comb begin

    // default assignments
    state_d = state_q;

    case (state_q)
      BIST: begin
        state_d = WAIT;
      end

      WAIT: begin
        state_d = ES16;
      end

      ES16: begin
        if (poll_i == 1'b1) begin
          state_d = WAIT;
        end
      end

      DEAD: begin
        // do nothing, currently no reason to ever reach here
      end

      default:
        state_d = BIST;

    endcase

  end

  always_ff @(posedge clk_i or negedge rst_ni) begin

    if (~rst_ni) begin
      state_q <= BIST;
    end else begin
      state_q <= state_d;
    end

  end

/********
 * LFSR *
 ********/

  // maximal implementation
  // polynomial x^16 + x^15 + x^13 + X^4 + 1

  always_comb begin

    // default assignment

    lfsr_d[0] = lfsr_q[15];

    for (int bit_idx = 1; bit_idx < 16; bit_idx++) begin
      lfsr_d[bit_idx] = lfsr_q[bit_idx-1];
    end

    lfsr_d[15] = lfsr_q[14] ^ lfsr_q[15];
    lfsr_d[13] = lfsr_q[12] ^ lfsr_q[15];
    lfsr_d[4]  = lfsr_q[3]  ^ lfsr_q[15];

  end

  always_ff @(posedge clk_i or negedge rst_ni) begin

    if (~rst_ni) begin
      lfsr_q <= 16'hCAFE; // seed LFSR, cannot be zero
    end else begin
      // only shift when polled
      if (poll_i) begin
        lfsr_q <= lfsr_d;
      end
    end

  end

/**********************
 * OUTPUT ASSIGNMENTS *
 **********************/

  assign opst_o    = state_q;
  // only display entropy value when in ES16
  assign entropy_o = (state_q == ES16) ? lfsr_q : '0;

/**************
 * ASSERTIONS *
 **************/

//pragma translate_off
`ifndef VERILATOR
  // Illegal LFSR value
  assert property(@(posedge clk_i) lfsr_q != '0);
`endif
//pragma translate_on

endmodule
