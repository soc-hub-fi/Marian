//------------------------------------------------------------------------------
// Module   : execution_units
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
//            Endrit Isufi   <endrit.isufi@tuni.fi>
// Created  : 21-feb-2024
//
// Description: Structural module to hold execution units for individual crypto
//              operations.
//
// Parameters:
//
// Inputs:
//  - clk_i: Clock
//  - rst_ni: Asynchronous active-low reset
//  - arg_valid_i: Handshaking for input args
//  - wb_ready_i: Handshaking for result
//  - crypto_args_buff_i: Input arguments for crypto ops
//  - pe_crypto_req_i: crypto request
//
// Outputs:
//  - arg_ready_o: Handshaking for argument
//  - result_valid_o:  Handshaking for result
//  - pe_crypto_req_o: Registered pe_crypto_req
//  - crypto_result_o: Crypto operation result
//
// Revision History:
//  - Version 1.0: Initial release
//  - Version 1.1: Added SHA-2 module [TZS 23-may-2024]
//  - Version 1.2: Added SM4 module [EIS 11-July-2024]
//  - Version 1.3: Added SM3 module [EIS 17-July-2024]
//
//------------------------------------------------------------------------------

module execution_units
import ara_pkg::*;
(
  input  logic                         clk_i,
  input  logic                         rst_ni,
  input  logic                         arg_valid_i,
  input  logic                         wb_ready_i,
  input  operand_buff_t                crypto_args_buff_i,
  input  pe_crypto_req_t               pe_crypto_req_i,

  output logic                         arg_ready_o,
  output logic                         result_valid_o,
  output pe_crypto_req_t               pe_crypto_req_o,
  output logic           [EGW256-1:0]  crypto_result_o
);

/*********
 * TYPES *
 *********/

  typedef enum logic {
    IDLE,
    EXEC
  } states_t;

/***********
 * SIGNALS *
 ***********/

  logic [EGW256-1:0] crypto_result_d, crypto_result_q;
  logic [EGW128-1:0] aesfk_result_s;
  logic [EGW128-1:0] encdec_result_s;
  logic [EGW128-1:0] gcm_result_s;
  logic [EGW256-1:0] msg_sched_result_s;
  logic [EGW256-1:0] compr_result_s;
  logic [EGW128-1:0] smfk_result_s;
  logic [EGW128-1:0] sm_encdec_result_s;
  logic [EGW256-1:0] sm3_msg_expn_words_o;
  logic [EGW256-1:0] sm3_compression_o;


  pe_crypto_req_t    pe_crypto_req_d, pe_crypto_req_q;

  states_t state_d, state_q;

  logic arg_ready_s;

  logic result_valid_d, result_valid_q;

  logic gcm_result_valid_s;

/*******
 * FSM *
 *******/

  always_comb begin

    // default assignments
    state_d         = state_q;
    arg_ready_s     = 1'b0;
    result_valid_d  = result_valid_q;
    // latch result and request for WB stage to access
    pe_crypto_req_d = pe_crypto_req_q;
    crypto_result_d = crypto_result_q;

    case (state_q)

      IDLE: begin

        // results available
        if (arg_valid_i) begin

          // register result
          pe_crypto_req_d = pe_crypto_req_i;

          // mux result based on current request
          if (pe_crypto_req_d.op inside{[VAESK1:VAESK2]}) begin

            crypto_result_d[EGW128-1:0] = aesfk_result_s;
            // ack current argument
            arg_ready_s    = 1'b1;
            // indicate result is available next cycle
            result_valid_d = 1'b1;

          end else if (pe_crypto_req_d.op inside {[VSM4R_VV:VSM4R_VS]}) begin 
            crypto_result_d[EGW128-1:0] = sm_encdec_result_s;
            // ack surrent argument
            arg_ready_s = 1'b1;
            // indicate result is available next cycle
            result_valid_d = 1'b1;
          end else if (pe_crypto_req_d.op == VSM4K) begin
            crypto_result_d[EGW128-1:0] = smfk_result_s;
            // ack current argument
            arg_ready_s    = 1'b1;
            // indicate result is available next cycle
            result_valid_d = 1'b1;
          end else if (pe_crypto_req_d.op == VSM3ME ) begin 
            crypto_result_d = sm3_msg_expn_words_o;
            // ack surrent argument
            arg_ready_s = 1'b1;
            // indicate result is available next cycle
            result_valid_d = 1'b1;
          end else if (pe_crypto_req_d.op == VSM3C) begin
            crypto_result_d = sm3_compression_o;
            // ack current argument
            arg_ready_s    = 1'b1;
            // indicate result is available next cycle
            result_valid_d = 1'b1;
          end else if (pe_crypto_req_d.op inside{[VAESDF_VV:VAESZ_VS]}) begin

            crypto_result_d[EGW128-1:0] = encdec_result_s;
            // ack current argument
            arg_ready_s    = 1'b1;
            // indicate result is available next cycle
            result_valid_d = 1'b1;

          end else if (pe_crypto_req_d.op inside {[VSHA2CH:VSHA2CL]}) begin

            crypto_result_d = compr_result_s;
            // ack current argument
            arg_ready_s    = 1'b1;
            // indicate result is available next cycle
            result_valid_d = 1'b1;

          end else if (pe_crypto_req_d.op == VSHA2MS) begin

            // ack current argument
            arg_ready_s = 1'b1;
            // indicate result is available next cycle
            result_valid_d  = 1'b1;
            crypto_result_d = msg_sched_result_s;

          end else if (pe_crypto_req_d.op inside {[VGMUL:VGHSH]}) begin

            // take valid/ready from result valid as this might be a multi-cycle op
            arg_ready_s    = gcm_result_valid_s;
            result_valid_d = gcm_result_valid_s;

            // assign result if it is ready
            if (gcm_result_valid_s == 1'b1) begin
              crypto_result_d[EGW128-1:0] = gcm_result_s;
            end

          end

          // Move to EXEC to wait for handshaking
          state_d = EXEC;

        end

      end

      EXEC: begin

        // don't accept new args until result is accepted
        arg_ready_s = 1'b0;

        // if current result is ready
        if (result_valid_q == 1'b1) begin

          // Result has been accepted
          if (wb_ready_i) begin

            // if there is a new argument
            if (arg_valid_i) begin

              // register request
              pe_crypto_req_d = pe_crypto_req_i;

              // mux result based on current request
              if (pe_crypto_req_d.op inside{[VAESK1:VAESK2]}) begin

                crypto_result_d[EGW128-1:0] = aesfk_result_s;
                // ack current argument
                arg_ready_s = 1'b1;
                // indicate result is available next cycle
                result_valid_d = 1'b1;

              end else if (pe_crypto_req_d.op inside {[VSM4R_VV:VSM4R_VS]}) begin 
                crypto_result_d[EGW128-1:0] = sm_encdec_result_s;
                // ack surrent argument
                arg_ready_s = 1'b1;
                // indicate result is available next cycle
                result_valid_d = 1'b1;

              end else if (pe_crypto_req_d.op == VSM4K) begin
                crypto_result_d[EGW128-1:0] = smfk_result_s;
                // ack current argument
                arg_ready_s    = 1'b1;
                // indicate result is available next cycle
                result_valid_d = 1'b1;

              end else if (pe_crypto_req_d.op == VSM3ME ) begin 
                crypto_result_d = sm3_msg_expn_words_o;
                // ack surrent argument
                arg_ready_s = 1'b1;
                // indicate result is available next cycle
                result_valid_d = 1'b1;
              end else if (pe_crypto_req_d.op == VSM3C) begin
                crypto_result_d = sm3_compression_o;
                // ack current argument
                arg_ready_s    = 1'b1;
                // indicate result is available next cycle
                result_valid_d = 1'b1;
              end else if (pe_crypto_req_d.op inside{[VAESDF_VV:VAESZ_VS]}) begin

                crypto_result_d[EGW128-1:0] = encdec_result_s;
                // ack current argument
                arg_ready_s = 1'b1;
                // indicate result is available next cycle
                result_valid_d = 1'b1;

              end else if (pe_crypto_req_d.op inside {[VSHA2CH:VSHA2CL]}) begin

                crypto_result_d = compr_result_s;
                // ack current argument
                arg_ready_s = 1'b1;
                // indicate result is available next cycle
                result_valid_d = 1'b1;

              end else if (pe_crypto_req_d.op == VSHA2MS) begin

                crypto_result_d = msg_sched_result_s;
                // ack current argument
                arg_ready_s = 1'b1;
                // indicate result is available next cycle
                result_valid_d = 1'b1;

              end else if (pe_crypto_req_d.op inside {[VGMUL:VGHSH]}) begin

                // take valid/ready from result valid as this might be a multi-cycle op
                arg_ready_s    = gcm_result_valid_s;
                result_valid_d = gcm_result_valid_s;

                // assign result if it is ready
                if (gcm_result_valid_s == 1'b1) begin
                  crypto_result_d[EGW128-1:0] = gcm_result_s;
                end

              end

            // if there isn't a new arg, clear valid and return to idle
            end else begin

              result_valid_d = 1'b0;

              state_d = IDLE;

            end

          end

        end else begin // if current result is not ready yet

          // MULTICYCLE INSTRUCTIONS
          if (pe_crypto_req_q.op inside {[VGMUL:VGHSH]}) begin

            result_valid_d = gcm_result_valid_s;
            arg_ready_s    = gcm_result_valid_s;

            if (gcm_result_valid_s == 1'b1) begin
              crypto_result_d[EGW128-1:0] = gcm_result_s;
            end

          end else begin

            // do nothing

          end
        end
      end

      default: begin
        // do nothing
      end

    endcase

  end

  always_ff @(posedge clk_i or negedge rst_ni) begin

    if (~rst_ni) begin
      state_q         <= IDLE;
      pe_crypto_req_q <= '0;
      crypto_result_q <= '0;
      result_valid_q  <= 1'b0;
    end else begin
      state_q         <= state_d;
      pe_crypto_req_q <= pe_crypto_req_d;
      crypto_result_q <= crypto_result_d;
      result_valid_q  <= result_valid_d;
    end

  end

/*********************
 * OUTPUT ASSIGNMENT *
 *********************/

  assign pe_crypto_req_o = pe_crypto_req_q;
  assign crypto_result_o = crypto_result_q;
  assign result_valid_o  = result_valid_q;
  assign arg_ready_o     = arg_ready_s;

/*******
* AES *
*******/

  aes i_aes(
    .crypto_args_buff_i ( crypto_args_buff_i ),
    .pe_crypto_req_i    ( pe_crypto_req_i    ),
    .aesfk_result_o     ( aesfk_result_s     ),
    .encdec_result_o    ( encdec_result_s    )
  );

/*******
* SHA *
*******/

  sha i_sha (
    .crypto_args_buff_i ( crypto_args_buff_i ),
    .pe_crypto_req_i    ( pe_crypto_req_i    ),
    .msg_sched_result_o ( msg_sched_result_s ),
    .compr_result_o     ( compr_result_s     )
  );

/*******
* GCM *
*******/

  gcm i_gcm (
    .clk_i              ( clk_i               ),
    .rst_ni             ( rst_ni              ),
    .arg_valid_i        ( arg_valid_i         ),
    .crypto_args_buff_i ( crypto_args_buff_i  ),
    .pe_crypto_req_i    ( pe_crypto_req_i     ),
    .gcm_valid_o        ( gcm_result_valid_s  ),
    .gcm_result_o       ( gcm_result_s        )
  );

/*******
*  SM4 *
*******/

  sm4 i_sm4 (
    .crypto_args_buff_i (crypto_args_buff_i),
    .smfk_result_o      (smfk_result_s     ),
    .encdec_result_o    (sm_encdec_result_s)
  );

/*******
*  SM3 *
*******/
sm3 i_sm3 (
  .crypto_args_buff_i (crypto_args_buff_i),
  //compresison
  .next_state_o (sm3_compression_o),
  //msg expansion
  .msg_exp_words_o(sm3_msg_expn_words_o)
);

/**************
 * ASSERTIONS *
 **************/

// pragma translate_off
 `ifndef VERILATOR

  ap_res_vld_hold: assert property (
    @(posedge clk_i) disable iff (!rst_ni)
    result_valid_q |-> ##1 $stable(result_valid_q) until $rose(wb_ready_i)) else
      $fatal(1, "Execution Unit: result_valid changed before wb_ready set");

  ap_res_stable: assert property (
    @(posedge clk_i) disable iff (!rst_ni)
      result_valid_q |-> ##1 $stable(crypto_result_q) until $rose(wb_ready_i)) else
      $fatal(1, "Execution Unit: Crypto Result changed before wb_ready set");

  ap_req_stable: assert property (
    @(posedge clk_i) disable iff (!rst_ni)
      result_valid_q |-> ##1 $stable(pe_crypto_req_q) until $rose(wb_ready_i)) else
      $fatal(1, "Execution Unit: pe_crypto_req changed before wb_ready set");

`endif
// pragma translate_on

endmodule
