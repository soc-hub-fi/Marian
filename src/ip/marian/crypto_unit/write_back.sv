//------------------------------------------------------------------------------
// Module   : write_back
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 25-may-2024
//
// Description: Module to hold logic for the crypto unit write-back. Note that
//              the current implementation does no support lane numbers other
//              than 4.
//
// Parameters:
//  - NrLanes: Number of vector lanes
//  - vaddr_t: Type used for vrf address
//  - DataWidth: Width of the lane datapath
//  - StrbWidth: Width of the strobe signal going to vrf
//  - strb_t: Type of the strobe signal going to vrf
//
// Inputs:
//  - clk_i: Clock
//  - rst_ni Asynchronous active-low reset
//  - result_valid_i: Handshaking from execution unit
//  - pe_crypto_req_i: PE crypto request forwarded from execution unit
//  - crypto_result_i: Result from execution unit
//  - crypto_result_gnt_i: Grant signal from VRF for element result
//  - crypto_result_final_gnt_i: Grant signal for final result element
//
// Outputs:
//  - wb_ready_o: Handshaking to execution unit
//  - crypto_result_req_o: Request to write result to VRF
//  - crypto_result_id_o: ID of result being written to VRF
//  - crypto_result_addr_o: VRF address of result to be written
//  - crypto_result_wdata_o: Data of result to be written to VRF
//  - crypto_result_be_o: Byte enable (strobe) for writing result to VRF
//  - wb_done_o: Flag to determine that write back complete for request
//
// Revision History:
//  - Version 1.0: Initial release
//  - Version 1.1: Refactored to support Lane configs other than 4 and results
//    with an SEW other than EW32 [TZS:19-May-2024]
//  - Fixed bug in vrf address calculation [TZS:24-Jun-2024]
//  - Replaced integers with bit-width specific types [TZS:15-Jul-2024]
//
//------------------------------------------------------------------------------

module write_back
  import ara_pkg::*;
  import rvv_pkg::*;
#(
  parameter int unsigned NrLanes = 0,
  parameter type         vaddr_t = logic,
  // Dependant parameters. DO NOT CHANGE!
  localparam int unsigned DataWidth      = $bits(elen_t), // Width of the lane datapath
  localparam int unsigned StrbWidth      = DataWidth/8,
  localparam type         strb_t         = logic [StrbWidth-1:0] // Byte-strobe type
)(
  input  logic                         clk_i,
  input  logic                         rst_ni,
  input  logic                         result_valid_i,
  input  pe_crypto_req_t               pe_crypto_req_i,
  input  logic           [ EGW256-1:0] crypto_result_i,
  input  logic           [NrLanes-1:0] crypto_result_gnt_i,
  input  logic           [NrLanes-1:0] crypto_result_final_gnt_i,

  output logic                         wb_ready_o,
  output logic           [NrLanes-1:0] crypto_result_req_o,
  output vid_t           [NrLanes-1:0] crypto_result_id_o,
  output vaddr_t         [NrLanes-1:0] crypto_result_addr_o,
  output elen_t          [NrLanes-1:0] crypto_result_wdata_o,
  output strb_t          [NrLanes-1:0] crypto_result_be_o,
  output logic                         wb_done_o
);

/***********
 * SIGNALS *
 ***********/

  // enable used to gate control logic
  logic wb_en_s;

  // done signal to indicate that current pe_req is complete
  logic wb_done_d, wb_done_q;

  // handshaking to exec units
  logic wb_ready_s;

  // flag to indicate when write buffer is "fresh" to aid in be assignment
  logic dirty_wr_buff_d, dirty_wr_buff_q;

  // valid/ready signal for handshaking to VRF
  logic               vrf_vld_d, vrf_vld_q;
  logic               vrf_rdy_s;
  logic [NrLanes-1:0] vrf_req_s;

  // packed array to contain result bytes
  result_bytes_t crypto_result_s;

  // unshuffled byte enable signals for write buffer
  logic  [OperandBytes-1:0] unshuffled_be_d, unshuffled_be_q;
  // shuffled byte enable signals for write buffer
  strb_t [     NrLanes-1:0] shuffled_be_d, shuffled_be_q;

  // id for vrf request;
  vid_t vrf_id_d, vrf_id_q;

  // vrf address
  vaddr_t vrf_addr_d,vrf_addr_q;

  // unshuffled write buffer
  operand_bytes_t               unshuffled_write_buff_d, unshuffled_write_buff_q;
  // shuffled write buffer
  elen_t          [NrLanes-1:0] shuffled_write_buff_d, shuffled_write_buff_q;

  // number of elements that can fit into a single write-buffer
  operand_byte_count_t elems_per_wr_buff_s;
  // number of valid bytes in the current result
  arg_byte_count_t     result_bytes_s;

  // counter to track the result bytes remaining in current result
  arg_byte_count_t result_bytes_remaining_s;
  // number of valid bytes in all results of current request
  logic [$clog2(MAXVL)-1:0] result_bytes_total_s;

  // byte ID of vstart in write buffer
  operand_byte_count_t vstart_byte_s;

  // number of result bytes (total) written to buffer
  logic [$clog2(MAXVL)-1:0] result_bytes_written_d, result_bytes_written_q;
  // idx of the byte in the current result which is to be written
  arg_byte_count_t curr_result_byte_idx_d, curr_result_byte_idx_q;

  // indices used to determine range of write buffer assignment
  operand_byte_count_t write_idx_lo_s;
  operand_byte_count_t write_idx_hi_s;

/*********************************
 * WRITE BUFFER ASSIGNMENT LOGIC *
 *********************************/

  // move results into byte format for easy reading
  assign crypto_result_s = crypto_result_i;

  assign vrf_req_s = '{NrLanes{vrf_vld_q}};

  // reduce grant signals to for a ready
  assign vrf_rdy_s = &(crypto_result_gnt_i);

  // only process result if there is a valid result and it is possible to write
  // into the write buffer in the following cycle
  assign wb_en_s = ((result_valid_i == 1'b1) &&
                    (vrf_rdy_s == 1'b1 || vrf_vld_q == 1'b0)) ? 1'b1 : 1'b0;

  always_comb begin

    // default assignments
    elems_per_wr_buff_s  = '0;
    result_bytes_s       = '0;
    result_bytes_total_s = '0;
    vstart_byte_s        = '0;
    write_idx_lo_s       = '0;
    write_idx_hi_s       = '0;
    wb_ready_s           = '0;
    wb_done_d            = '0;

    result_bytes_remaining_s = '0;

    vrf_addr_d = vrf_addr_q;
    vrf_vld_d  = vrf_vld_q;
    vrf_id_d   = vrf_id_q;

    dirty_wr_buff_d          = dirty_wr_buff_q;

    unshuffled_write_buff_d = unshuffled_write_buff_q;
    shuffled_write_buff_d   = shuffled_write_buff_q;

    unshuffled_be_d        = unshuffled_be_q;
    shuffled_be_d          = shuffled_be_q;

    result_bytes_written_d = result_bytes_written_q;
    curr_result_byte_idx_d = curr_result_byte_idx_q;

    // clear valid when handshake is detected
    if (vrf_vld_q == 1'b1 && vrf_rdy_s == 1'b1) begin
      vrf_vld_d = 1'b0;
    end

    if (result_valid_i == 1'b1) begin
      // intermediate helpers for byte position calcs.
      automatic integer unsigned vsew_s      = int'(pe_crypto_req_i.vtype.vsew);
      automatic integer unsigned vstart_s    = int'(pe_crypto_req_i.vstart);

      elems_per_wr_buff_s  = OperandBytes >> vsew_s;
      result_bytes_s       =
        (pe_crypto_req_i.op inside {[VAESK1:VSM4R_VS]}) ?
        CryptoEGS_4 * (1 << vsew_s) : CryptoEGS_8 * (1 << vsew_s);
      result_bytes_total_s = result_bytes_s * pe_crypto_req_i.eg_len;
      vstart_byte_s        = (vstart_s & (elems_per_wr_buff_s-1)) << vsew_s;
    end

    if (wb_en_s == 1'b1) begin

      if (result_bytes_written_q != result_bytes_total_s) begin

        automatic integer unsigned assigned_byte_count    = 0;

        // make sure that _q is set in next cycle
        dirty_wr_buff_d = 1'b1;

        // determine where to start writing results into buffer
        write_idx_lo_s = get_byte_idx(vstart_byte_s,
                                      result_bytes_written_q, curr_result_byte_idx_q);
        // number of bytes left within current result entry
        result_bytes_remaining_s = result_bytes_s - curr_result_byte_idx_q;

        // if all remaining bytes from current result will fit into the current write buffer
        if ((result_bytes_remaining_s + write_idx_lo_s) <= OperandBytes) begin
          // hi of range is low plus remaining bytes
          write_idx_hi_s = write_idx_lo_s + result_bytes_remaining_s;
        end else begin
          // hi is the end of the write buffer
          write_idx_hi_s = OperandBytes;
        end

        // assign current result bytes into unshuffled array using range
        for (int wr_byte_idx = 0; wr_byte_idx < OperandBytes; wr_byte_idx++) begin

          if ((wr_byte_idx >= write_idx_lo_s) && (wr_byte_idx < write_idx_hi_s)) begin

            // if in valid range, assign valid bytes from result
            unshuffled_write_buff_d[wr_byte_idx] =
              crypto_result_s[wr_byte_idx - write_idx_lo_s + curr_result_byte_idx_q];
            // mark byte enable if valid value has been written
            unshuffled_be_d[wr_byte_idx] = 1'b1;

          end else begin

            // outside of range, assign existing values
            unshuffled_write_buff_d[wr_byte_idx] = unshuffled_write_buff_q[wr_byte_idx];
            // If this is a fresh write buffer, do not preserve old vals
            unshuffled_be_d[wr_byte_idx] =
              (dirty_wr_buff_q == 1'b0) ? 1'b0 : unshuffled_be_q[wr_byte_idx];

          end
        end

        // shuffle bytes and assign to shuffled array
        for (int wr_byte_idx = 0; wr_byte_idx < OperandBytes; wr_byte_idx++) begin
          automatic integer unsigned shuffled_idx;
          automatic integer unsigned shuffled_lane;
          automatic integer unsigned shuffled_offset;

          shuffled_idx  = shuffle_index(wr_byte_idx, NrLanes, pe_crypto_req_i.vtype.vsew);
          shuffled_lane = shuffled_idx >> 3;
          shuffled_offset = shuffled_idx & 'h7;

          // shuffle write buffer data
          shuffled_write_buff_d[shuffled_lane][(shuffled_offset*8) +: 8] =
            unshuffled_write_buff_d[wr_byte_idx];

          // shuffle byte enables
          shuffled_be_d[shuffled_lane][shuffled_offset] = unshuffled_be_d[wr_byte_idx];

        end

        assigned_byte_count = write_idx_hi_s - write_idx_lo_s;

        result_bytes_written_d += assigned_byte_count;
        curr_result_byte_idx_d += assigned_byte_count;

        // if all bytes of current result have been read
        if ((curr_result_byte_idx_q + assigned_byte_count) == result_bytes_s) begin
          // get new result by acking current result
          wb_ready_s = 1'b1;
          curr_result_byte_idx_d = 0;
        end

        // if the end of the current write buffer has been reached
        if ((write_idx_hi_s == OperandBytes)) begin
          vrf_vld_d = 1'b1;
          vrf_id_d  = pe_crypto_req_i.id;
          vrf_addr_d = get_vrf_address(NrLanes, result_bytes_written_q, pe_crypto_req_i);
          // write buffer will be clean next iteration
          dirty_wr_buff_d = 1'b0;
        end

        // all result bytes have been read
        if ((result_bytes_written_q + assigned_byte_count) == result_bytes_total_s) begin
          vrf_vld_d = 1'b1;
          vrf_id_d  = pe_crypto_req_i.id;
          vrf_addr_d = get_vrf_address(NrLanes, result_bytes_written_q, pe_crypto_req_i);
          // reset byte counter at end of request
          result_bytes_written_d = 0;
          // write buffer will be clean next iteration
          dirty_wr_buff_d = 1'b0;
          // indicate that this is the final write of the current pe req
          wb_done_d = 1'b1;
        end

      end
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      result_bytes_written_q  <=  0;
      curr_result_byte_idx_q  <=  0;
      unshuffled_write_buff_q <= '0;
      shuffled_write_buff_q   <= '0;
      unshuffled_be_q         <= '0;
      shuffled_be_q           <= '0;
      vrf_vld_q               <= '0;
      vrf_id_q                <= '0;
      vrf_addr_q              <= '0;
      wb_done_q               <= '0;
      dirty_wr_buff_q         <= '0;
    end else begin
      result_bytes_written_q  <= result_bytes_written_d;
      curr_result_byte_idx_q  <= curr_result_byte_idx_d;
      unshuffled_write_buff_q <= unshuffled_write_buff_d;
      shuffled_write_buff_q   <= shuffled_write_buff_d;
      unshuffled_be_q         <= unshuffled_be_d;
      shuffled_be_q           <= shuffled_be_d;
      vrf_vld_q               <= vrf_vld_d;
      vrf_id_q                <= vrf_id_d;
      vrf_addr_q              <= vrf_addr_d;
      wb_done_q               <= wb_done_d;
      dirty_wr_buff_q         <= dirty_wr_buff_d;
    end
  end

/**********************
 * OUTPUT ASSIGNMENTS *
 **********************/

  assign wb_ready_o            = wb_ready_s;
  assign wb_done_o             = wb_done_q;

  assign crypto_result_req_o   = vrf_req_s;
  assign crypto_result_wdata_o = shuffled_write_buff_q;
  assign crypto_result_be_o    = shuffled_be_q;
  assign crypto_result_id_o    = '{NrLanes{vrf_id_q}};
  assign crypto_result_addr_o  = '{NrLanes{vrf_addr_q}};

/************************
 * FUNCTION DEFINITIONS *
 ************************/

  // uses data of current request to determine the index of the byte to be written within the
  // write buffer
  function automatic integer unsigned get_byte_idx(
    integer unsigned vstart_byte,
    integer unsigned result_bytes_written,
    integer unsigned curr_result_byte_idx
  );

    automatic integer unsigned byte_idx;
    // module total bytes written with OperandBytes
    byte_idx = (vstart_byte + result_bytes_written + curr_result_byte_idx) & (OperandBytes - 1);

    return byte_idx;

  endfunction

  // calculate the vrf address to send with the current wb data buffer
  function automatic vaddr_t get_vrf_address(
    integer unsigned Nr_Lanes,
    integer unsigned result_bytes_written,
    pe_crypto_req_t  pe_req
  );

    automatic vaddr_t vrf_addr;
    automatic integer unsigned elements_written = result_bytes_written >> int'(pe_req.vtype.vsew);

    vrf_addr = vaddr(pe_req.vd, Nr_Lanes) +
      (((pe_req.vstart + elements_written) / NrLanes) >>
       (int'(EW64) - int'(pe_req.vtype.vsew)));

    return vrf_addr;

  endfunction


endmodule

