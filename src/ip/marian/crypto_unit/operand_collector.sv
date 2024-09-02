//------------------------------------------------------------------------------
// Module   : operand_collector
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
//            Endrit Isufi <endrit.isufi@tuni.fi>
// Created  : 14-feb-2024
//
// Description: Module containing logic to collect, pre-process and feed operand
//              data which is to be used by the crypto execution unit.
//
// Parameters:
//  - NrLanes: Number of vector lanes
//  - OpQ32Elems: Number of SEW32 elements contained within a single operand
//    entry within the operand queue.
//  - OpQ64Elems: Number of SEW64 elements contained within a single operand
//    entry within the operand queue.
//
// Inputs:
//  - clk_i: Clock
//  - rst_ni: Asynchronous active-low reset
//  - pe_req_valid_i: Processing element request valid from main sequencer
//  - crypto_operand_valid_i: Handshaking valid for incoming operand data
//  - crypto_operand_i: Operand data from VRF
//  - crypto_args_ready_i: Handshaking for arguments from crypto execution unit
//
// Outputs:
//  - pe_req_ack_o: Handshaking to ack pe_req from crypto unit
//  - crypto_operand_ready_o: Handshaking read for incoming operand data
//  - crypto_args_buff_o: Arguments to be sent to crypto execution unit
//  - crypto_args_valid_o: Handshaking for arguments to crypto execution unit
//
// Revision History:
//  - Version 1.0: Initial release
//  - Version 1.1: Refactored to improve performance [TZS:19-May-2024]
//  - Version 1.2: Refactored to enable support for multiple lanes/vlen + tidy
//                 logic [TZS: 15-jul-2024]
//  - Version 1.3: Update scalar width for SM algos [TZS:26-Jul-2024]
//
//------------------------------------------------------------------------------

module operand_collector
  import ara_pkg::*;
#(
  parameter integer unsigned NrLanes = 0
) (
  input  logic                     clk_i,
  input  logic                     rst_ni,
  // processing element requests
  input  pe_crypto_req_t           pe_crypto_req_i,
  input  logic                     pe_req_valid_i,
  output logic                     pe_req_ack_o, // drives ready of pe FIFO
  output pe_crypto_req_t           pe_crypto_req_o, // request being forwarded to other units
  // incoming operand data {vs1, vd, vs2}
  input  elen_t [NrLanes-1:0][2:0] crypto_operand_i,
  input  logic  [NrLanes-1:0][2:0] crypto_operand_valid_i,
  output logic  [NrLanes-1:0][2:0] crypto_operand_ready_o,
  // operand buffer output + control signals
  output operand_buff_t            crypto_args_buff_o,
  output logic                     crypto_args_valid_o,
  input  logic                     crypto_args_ready_i
);

/***********************
 * CONSTANTS AND TYPES *
 ***********************/


/******************
 * GLOBAL SIGNALS *
 ******************/

  // translated operand signals
  elen_t [2:0][NrLanes-1:0] crypto_operand_trans_s;
  logic  [2:0][NrLanes-1:0] crypto_operand_valid_trans_s;
  logic  [2:0][NrLanes-1:0] crypto_operand_ready_trans_s;

  // registered request
  pe_crypto_req_t pe_req_q;
  // internal pe_req_ack signal
  logic pe_req_ack_s;
  // done signal for each operand, used to resolve pe_req_ack
  logic [NumOperands-1:0] pe_req_done_s, pe_req_ack_en_s;

  // Indicates which operand is currently required by the current pe_req
  logic [NumOperands-1:0] operand_active_s;
  // Indicates that the argument (output) for the corresponding operand is full
  logic [NumOperands-1:0] arg_full_d, arg_full_q;
  // control signal used to control when the valid of the crypto args can be set
  // should be set when the operand is either not active or the operand is active
  // and the corresponding argument is full
  logic [NumOperands-1:0] arg_valid_s;

  // enable signal used to control operand processing pipeline and prevent new
  // arg data being written to output before it is read
  logic operand_logic_en_s;
  // control signal used to indicate that all args are valid
  logic arg_buff_valid_d, arg_buff_valid_q;
  // register to hold crypto args and scalar val
  logic [NumOperands-1:0][CryptoArgWidthBytes-1:0][7:0] args_d, args_q;
  logic                                           [7:0] scalar_d, scalar_q;

  // idx for byte in operand buffer that maps to vstart
  operand_byte_count_t vstart_byte_s;
  // how many bytes should there be in each output arg
  arg_byte_count_t     arg_bytes_s;
  // total number of bytes to be read from each input operand in this request
  logic [$clog2(MAXVL)-1:0] operand_bytes_total_s;

  genvar operand, lane;

/***********************
 * OPERAND TRANSLATION *
 ***********************/

  // Logic to transform input operand control signals from Lane Major -> Operand major
  for (operand = 0; operand < NumOperands; operand++) begin : gen_trans_in_operand
    for (lane = 0; lane < NrLanes; lane++) begin : gen_trans_in_lane
     assign crypto_operand_trans_s[operand][lane]       = crypto_operand_i[lane][operand];
     assign crypto_operand_valid_trans_s[operand][lane] = crypto_operand_valid_i[lane][operand];
    end
  end

/************************
 * CONTROL SIGNAL LOGIC *
 ************************/

  // operand active controls
  always_comb begin

    // default assignment
    operand_active_s = 3'b000;
    scalar_d         = scalar_q;

    if (pe_req_valid_i) begin
      unique case (pe_crypto_req_i.op) inside
        VAESK1: begin
          operand_active_s = 3'b001; // vs2 active
          scalar_d         = pe_crypto_req_i.scalar_op[7:0]; // scalar val used
        end
        VAESK2: begin
          operand_active_s = 3'b011; // vs2 + vd active
          scalar_d         = pe_crypto_req_i.scalar_op[7:0]; // scalar val used
        end
        [VAESDF_VV:VGMUL]: begin
          operand_active_s = 3'b011; // vs2 + vd active
        end
        [VGHSH:VSHA2MS]: begin
          operand_active_s = 3'b111; // vs2 + vd + vs1 active
        end
        VSM4K: begin
          operand_active_s = 3'b001; // vs2 active
          scalar_d = pe_crypto_req_i.scalar_op[7:0];
        end
        [VSM4R_VV:VSM4R_VS] : begin
          operand_active_s = 3'b011; // vs2 + vd active
        end
        VSM3ME: begin
          operand_active_s = 3'b101; // vs2 + vs1 active
        end
        VSM3C: begin
          operand_active_s = 3'b011; // vs2 + vd active
          scalar_d = pe_crypto_req_i.scalar_op[7:0];
        end
        default: begin
          operand_active_s = 3'b000;
        end
      endcase
    end
  end

  // arg is only valid if there is a valid request, the argument associated with
  // the operand is full or is not active
  for (operand = 0; operand < NumOperands; operand++) begin : gen_arg_valid
    assign arg_valid_s[operand] = pe_req_valid_i &
                                  ((~operand_active_s[operand]) | arg_full_d[operand]);
  end


  // pe_req ack send if there is a valid request and all active operands in the 
  // request have been read
  for (operand = 0; operand < NumOperands; operand++) begin : gen_pe_req_ack
    assign pe_req_ack_en_s[operand] = pe_req_valid_i &
                                  ((~operand_active_s[operand]) | pe_req_done_s[operand]);
  end

  assign pe_req_ack_s = &pe_req_ack_en_s;


  // arg_buff valid set when all args are valid
  assign arg_buff_valid_d = &(arg_valid_s);

  // only process operands if there is a valid request either:
  //   there is a valid argument buffer being acknowledged within this cycle
  //   there is not a valid argument buffer
  assign operand_logic_en_s = pe_req_valid_i &
                              ((crypto_args_ready_i & arg_buff_valid_q) | (~arg_buff_valid_q));

  // block to contain counter limit calculation logic
  always_comb begin : comb_limit_calc

    // default assignment
    vstart_byte_s         = '0;
    arg_bytes_s           = '0;
    operand_bytes_total_s = '0;

    if (pe_req_valid_i) begin
      // intermediate helpers for byte position calcs.
      automatic integer unsigned vsew_s   = int'(pe_crypto_req_i.vtype.vsew);
      automatic integer unsigned vstart_s = int'(pe_crypto_req_i.vstart);
      // how many elements are contained within each operand
      automatic integer unsigned elems_per_operand_s = OperandBytes >> vsew_s;

      vstart_byte_s         = operand_byte_count_t'((vstart_s & (elems_per_operand_s-1)) << vsew_s);
      arg_bytes_s           =
        (pe_crypto_req_i.op inside {[VAESK1:VSM4R_VS]}) ?
        arg_byte_count_t'(CryptoEGS_4 * (1 << vsew_s)) :
        arg_byte_count_t'(CryptoEGS_8 * (1 << vsew_s));
      operand_bytes_total_s = arg_bytes_s * pe_crypto_req_i.eg_len;
    end
  end

//------------------------------------------------------------------------------

/**************************
 * LOGIC FOR EACH OPERAND *
 **************************/

for(operand = 0; operand < NumOperands; operand++) begin : gen_operand_logic

  // number of operand bytes (total) read from operand buffer
  logic [$clog2(MAXVL)-1:0] operand_bytes_read_d, operand_bytes_read_q;
  // idx of the byte in the current operand buffer which is to be read
  operand_byte_count_t curr_operand_byte_idx_s;
  // idx of the byte in the current arg buffer which is to be written
  arg_byte_count_t curr_arg_byte_idx_d, curr_arg_byte_idx_q;
  // indices used to determine range of arg buffer assignment
  arg_byte_count_t arg_idx_lo_s;
  arg_byte_count_t arg_idx_hi_s;
  // counter to track the number of unread bytes remaining in current operand buffer
  operand_byte_count_t operand_bytes_remaining_s;
  // intermediate storage of operand buffer
  operand_bytes_t unshuffled_operand_buff_s;
  // flag to indicate that this operand is a scalar in a vector-scalar op
  logic vector_scalar_op_s;

  // resolve vector_scalar_op value using the operand and pe_req
  assign vector_scalar_op_s =
    ((operand == VS2) &&
    (pe_crypto_req_i.op inside {[VAESDF_VS:VAESZ_VS]} ||
     pe_crypto_req_i.op == VSM4R_VS)) ? 1'b1 : 1'b0;

  always_comb begin

    // helper variable to store byte count written per iteration
    automatic integer unsigned arg_bytes_written = 0;

    // default assignments
    args_d[operand]           = args_q[operand];
    pe_req_done_s[operand]    = '0;
    unshuffled_operand_buff_s = '0;
    arg_idx_lo_s              = '0;
    arg_idx_hi_s              = '0;
    operand_bytes_remaining_s = '0;
    curr_operand_byte_idx_s   = '0;
    operand_bytes_read_d      = operand_bytes_read_q;
    curr_arg_byte_idx_d       = curr_arg_byte_idx_q;
    arg_full_d[operand]       = arg_full_q[operand];

    crypto_operand_ready_trans_s[operand] = '0;

    // is it safe to clear the arg full flag?
    // for vector scalar ops, arg should remain full after first time it is filled
    if (crypto_args_ready_i && ~vector_scalar_op_s) begin
      arg_full_d[operand] = 1'b0;
      curr_arg_byte_idx_d = '0;
    end


    if (vector_scalar_op_s) begin
      // for a vector-scalar op, only a single argument needs to be read from the operand buff
      if (operand_bytes_read_q == arg_bytes_s) begin
        // Operations relating to this operand are complete
        pe_req_done_s[operand] = 1'b1;
        // maintain arg output throughout request
        args_d[operand] = args_q[operand];
        // clear arg counters when pe_req is done for vector-scalar ops
        if (pe_req_ack_s) begin
          operand_bytes_read_d = 0;
          arg_full_d[operand]  = 1'b0; // arg remains full until pe_req is completed
          curr_arg_byte_idx_d  = '0;
        end
      end
    end else begin
      // have all arguments been read from the buffer?
      if (operand_bytes_read_q == operand_bytes_total_s) begin
        // Operations relating to this operand are complete
        pe_req_done_s[operand] = 1'b1;
        // Have all other operands finished?
        if (pe_req_ack_s) begin
          // reset bytes read counter
          operand_bytes_read_d = 0;
        end
      end
    end

    // do not start processing a new argument if current arg is full
    // used to stall requests by one cycle
    if (~arg_full_q[operand]) begin
      // disable logic while there is a registered request waiting
      if (operand_logic_en_s) begin

        if (~pe_req_done_s[operand] && operand_active_s[operand]) begin

          if (&crypto_operand_valid_trans_s[operand]) begin

            // get value of current operand byte
            curr_operand_byte_idx_s = get_operand_idx(vstart_byte_s, operand_bytes_read_q);

            // set low pointer for arg buffer
            arg_idx_lo_s = curr_arg_byte_idx_q;
            // number of bytes left within current operand buffer entry
            operand_bytes_remaining_s = OperandBytes - curr_operand_byte_idx_s;

            // SET ARGUMENT POINTERS //

            // if all remaining bytes within current operand buffer entry will fit into the arg
            if ((arg_idx_lo_s + operand_bytes_remaining_s) <= arg_bytes_s) begin
              // high byte of arg is lo bound + number of bytes in current operand buffer entry
              arg_idx_hi_s = arg_idx_lo_s + operand_bytes_remaining_s;
            end else begin
              // high byte is limited by the remaing argument
              arg_idx_hi_s = arg_bytes_s;
            end

            // ASSIGN INTO ARGUMENT BUFFER //

            // unshuffle operand into temporary value
            unshuffled_operand_buff_s = unshuffle_operand(
              pe_crypto_req_i.vtype.vsew, crypto_operand_trans_s[operand]);

            // iterate through bytes of argument and assign rangne between pointers
            for (int arg_byte_idx = 0; arg_byte_idx < CryptoArgWidthBytes; arg_byte_idx++) begin

              if ((arg_byte_idx >= arg_idx_lo_s) && (arg_byte_idx < arg_idx_hi_s)) begin
                args_d[operand][arg_byte_idx] =
                  unshuffled_operand_buff_s[curr_operand_byte_idx_s + (arg_byte_idx - arg_idx_lo_s)];
              end else begin
                // assign existing value if not in range
                args_d[operand][arg_byte_idx] = args_q[operand][arg_byte_idx];
              end

            end

            // populate helper
            arg_bytes_written = arg_idx_hi_s - arg_idx_lo_s;

            // MANAGE ARG COUNTERS

            // accumulate pointer range within arg byte counter
            curr_arg_byte_idx_d  = curr_arg_byte_idx_q + arg_bytes_written;
            // set arg_buffer to full if counter is at its max value
            if ((curr_arg_byte_idx_q + arg_bytes_written) == arg_bytes_s) begin
              arg_full_d[operand] = 1'b1;
            end

            // MANAGE OPERAND COUNTERS

            operand_bytes_read_d = operand_bytes_read_q + arg_bytes_written;
            // determine wether to send a ready to the operand buffer
            //   a) All bytes from current buffer entry have been read,
            //   b) All bytes from current request have been read (note that
            //      the total number of bytes varies when processing a vector-scalar).
            if (((curr_operand_byte_idx_s + arg_bytes_written) == OperandBytes) ||
                (operand_bytes_read_d == operand_bytes_total_s) ||
                (vector_scalar_op_s && (operand_bytes_read_d == arg_bytes_s))) begin
              // finished with current operand buffer entry
              crypto_operand_ready_trans_s[operand] = '1;
            end

          end // if (&crypto_operand_valid_trans_s[operand])

        end // if (~pe_req_done_s[operand])

      end // if (operand_logic_en_s)

    end // ~arg_full_d[operand]

  end // always_comb


  /***************************
   * OPERAND-LEVEL REGISTERS *
   ***************************/

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      operand_bytes_read_q    <= '0;
      curr_arg_byte_idx_q     <= '0;
    end else begin
      operand_bytes_read_q    <= operand_bytes_read_d;
      curr_arg_byte_idx_q     <= curr_arg_byte_idx_d;
    end
  end

end : gen_operand_logic

//------------------------------------------------------------------------------

/**************************
 * GLOBAL-LEVEL REGISTERS *
 **************************/

  always_ff @(posedge clk_i or negedge rst_ni) begin

    if (~rst_ni) begin
      arg_buff_valid_q <= '0;
      args_q           <= '0;
      scalar_q         <= '0;
      pe_req_q         <= '0;
      arg_full_q       <= '0;
    end else begin
      arg_buff_valid_q <= arg_buff_valid_d;
      args_q           <= args_d;
      scalar_q         <= scalar_d;
      pe_req_q         <= pe_crypto_req_i;
      arg_full_q       <= arg_full_d;
    end

  end

/**********************
 * OUTPUT ASSIGNMENTS *
 **********************/

  assign pe_req_ack_o              = pe_req_ack_s;
  assign pe_crypto_req_o           = pe_req_q;
  assign crypto_args_valid_o       = arg_buff_valid_q;

  for (operand = 0; operand < NumOperands; operand++) begin : gen_trans_out_operand
    for (lane = 0; lane < NrLanes; lane++) begin : gen_trans_out_lane
     assign crypto_operand_ready_o[lane][operand] = crypto_operand_ready_trans_s[operand][lane];
    end
  end

  assign crypto_args_buff_o.vs2    = args_q[0];
  assign crypto_args_buff_o.vd     = args_q[1];
  assign crypto_args_buff_o.vs1    = args_q[2];
  assign crypto_args_buff_o.scalar = scalar_q;

/************************
 * FUNCTION DEFINITIONS *
 ************************/

  // converts operands into array of ordered bytes
  function automatic operand_bytes_t unshuffle_operand (
    rvv_pkg::vew_e       sew,
    elen_t [NrLanes-1:0] operand_arr
  );

    automatic vlen_t shuffled_idx;
    automatic vlen_t shuffled_offset;
    automatic vlen_t lane_idx;

    automatic operand_bytes_t op_bytes = '0;

    for (int byte_idx = 0; byte_idx < OperandBytes; byte_idx++) begin

      shuffled_idx    = shuffle_index(byte_idx, NrLanes, sew);
      shuffled_offset = shuffled_idx & 'b111;
      lane_idx        = (int'(shuffled_idx) >> 3);

      op_bytes[byte_idx] = operand_arr[lane_idx][(8*shuffled_offset) +: 8];

    end

    return op_bytes;

  endfunction

  // get the byte index for the current byte to be read out of the operand buffer
  function automatic integer unsigned get_operand_idx(
    integer unsigned vstart_byte,
    integer unsigned operand_bytes_read_total
  );

  automatic integer unsigned byte_idx;

  byte_idx = (vstart_byte + operand_bytes_read_total) & (OperandBytes - 1);

  return byte_idx;

  endfunction

/**************
 * ASSERTIONS *
 **************/

// pragma translate_off
`ifndef VERILATOR

  ap_arg_vld_hold: assert property (
    @(posedge clk_i) disable iff (!rst_ni)
      arg_buff_valid_q |-> ##1 $stable(arg_buff_valid_q) until $rose(crypto_args_ready_i)) else
      $fatal(1, "Operand Collector: arg_vld changed before arg_rdy set");

  ap_arg_stable: assert property (
    @(posedge clk_i) disable iff (!rst_ni)
      arg_buff_valid_q |-> ##1 $stable(args_q) until $rose(crypto_args_ready_i)) else
      $fatal(1, "Operand Collector: operands args changed before arg_rdy set");

  ap_scalar_stable: assert property (
    @(posedge clk_i) disable iff (!rst_ni)
      arg_buff_valid_q |-> ##1 $stable(scalar_q) until $rose(crypto_args_ready_i)) else
      $fatal(1, "Operand Collector: scalar args changed before arg_rdy set");

`endif
// pragma translate_on

endmodule
