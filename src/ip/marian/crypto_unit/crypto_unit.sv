//------------------------------------------------------------------------------
// Module   : crypto_unit
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 28-jan-2024
//
// Description: Marian vector functional unit used to perform cryto operations.
// In order to maintain with Ara, ports + instruction queue mechanisms have
// been kept as close as possible to the existing functional units.
//
// Parameters:
//  - NrLanes: Number of vector lanes
//  - vaddr_t: Type used for vrf address
//  - MaxOperandCount: Max number of elements at SEW32
//  - DataWidth: Width of the lane datapath
//  - StrbWidth: Width of the strobe signal going to vrf
//  - strb_t: Type of the strobe signal going to vrf
//
// Inputs:
//  - clk_i: Clock
//  - rst_ni Asynchronous active-low reset
//  - pe_req_i: Processing element request from sequencer
//  - pe_req_valid_i: Handshaking for PE request from sequencer
//  - pe_vinsn_running_i: Vector instruction running array from sequencer
//  - crypto_operand_i: Source operand for crypto FU
//  - crypto_operand_valid_i: Handshaking for source operand
//  - crypto_result_gnt_i: Grant signal from VRF for element result
//  - crypto_result_final_gnt_i: Grant signal for final result element
//
// Outputs:
//  - pe_req_ready_o: Handshaking for PE request from sequencer
//  - pe_resp_o: Processing element response to sequencer
//  - crypto_operand_ready_o: Handshaking for source operands
//  - crypto_result_req_o: Request to write result to VRF
//  - crypto_result_id_o: ID of result being written to VRF
//  - crypto_result_addr_o: VRF address of result to be written
//  - crypto_result_wdata_o: Data of result to be written to VRF
//  - crypto_result_be_o: Byte enable (strobe) for writing result to VRF
//
// Revision History:
//  - Version 1.0: Initial release
//  - Version 1.1: Fixed bug in pe_req filtering logic [TZS 02-jul-2024]
//------------------------------------------------------------------------------

module crypto_unit
  import ara_pkg::*;
  import rvv_pkg::*;
  import cf_math_pkg::idx_width;
#(
  parameter int unsigned   NrLanes = 0,
  parameter  type          vaddr_t = logic,  // Type used to address vector register file elements
  // Dependant parameters. DO NOT CHANGE!
  localparam int  unsigned MaxOperandCount = (MAXVL >> 2),         // MAXVL @ SEW32
  localparam int  unsigned DataWidth       = $bits(elen_t),        // Width of the lane datapath
  localparam int  unsigned StrbWidth       = DataWidth/8,
  localparam type          strb_t          = logic [StrbWidth-1:0] // Byte-strobe type
) (
  input  logic                    clk_i,
  input  logic                    rst_ni,
  // interface with the sequencer
  input  pe_req_t                 pe_req_i,
  input  logic                    pe_req_valid_i,
  input  logic      [NrVInsn-1:0] pe_vinsn_running_i,
  output logic                    pe_req_ready_o,
  output pe_resp_t                pe_resp_o,
  // interface with the lanes
  // source operands {vs1, vd, vs2}
  input  elen_t     [NrLanes-1:0][2:0] crypto_operand_i,
  input  logic      [NrLanes-1:0][2:0] crypto_operand_valid_i,
  output logic      [NrLanes-1:0][2:0] crypto_operand_ready_o,
  // result operands
  output logic      [NrLanes-1:0]      crypto_result_req_o,
  output vid_t      [NrLanes-1:0]      crypto_result_id_o,
  output vaddr_t    [NrLanes-1:0]      crypto_result_addr_o,
  output elen_t     [NrLanes-1:0]      crypto_result_wdata_o,
  output strb_t     [NrLanes-1:0]      crypto_result_be_o,
  input  logic      [NrLanes-1:0]      crypto_result_gnt_i,
  input  logic      [NrLanes-1:0]      crypto_result_final_gnt_i
);

/**********
* SIGNALS *
***********/

  // operand data and controls
  elen_t [NrLanes-1:0][2:0] crypto_operand;
  logic  [NrLanes-1:0][2:0] crypto_operand_valid;
  logic  [NrLanes-1:0][2:0] crypto_operand_ready;

  // handshaking for PE FIFO
  logic pe_fifo_full_s, pe_fifo_empty_s, pe_fifo_push_s;
  logic pe_crypto_req_valid_s, pe_crypto_req_ack_s;

  // id used to determine if current request is new
  vid_t pe_id_d, pe_id_q;
  logic pe_req_valid_q;
  logic pe_req_valid_rise_s;

  // PE req registers for FIFO input, execution and WB
  pe_crypto_req_t pe_crypto_req_in_s,
                  pe_crypto_req_coll_s,
                  pe_crypto_req_exec_s,
                  pe_crypto_req_wb_q;

  // handshaking for execution units
  logic crypto_args_valid_s, crypto_args_ready_s;

  // handshaking for writeback
  logic wb_valid_s, wb_ready_s;

  // argument buffer for crypto operations
  operand_buff_t crypto_args_buff_s;

  // result of Crypto operation
  logic [EGW256-1:0] crypto_result_s;

  // wb complete
  logic wb_done_s;

/**********************************
 * REGISTERS FOR STORING OPERANDS *
 **********************************/

for (genvar lane = 0; lane < NrLanes; lane++) begin: gen_regs_vs2

  fall_through_register #(
    .T(elen_t)
  ) i_register_vs2 (
    .clk_i      ( clk_i                           ),
    .rst_ni     ( rst_ni                          ),
    .clr_i      ( 1'b0                            ),
    .testmode_i ( 1'b0                            ),
    .data_i     ( crypto_operand_i[lane][0]       ),
    .valid_i    ( crypto_operand_valid_i[lane][0] ),
    .ready_o    ( crypto_operand_ready_o[lane][0] ),
    .data_o     ( crypto_operand[lane][0]         ),
    .valid_o    ( crypto_operand_valid[lane][0]   ),
    .ready_i    ( crypto_operand_ready[lane][0]   )
  );

end: gen_regs_vs2

for (genvar lane = 0; lane < NrLanes; lane++) begin: gen_regs_vd

  fall_through_register #(
    .T(elen_t)
  ) i_register_vd (
    .clk_i      ( clk_i                           ),
    .rst_ni     ( rst_ni                          ),
    .clr_i      ( 1'b0                            ),
    .testmode_i ( 1'b0                            ),
    .data_i     ( crypto_operand_i[lane][1]       ),
    .valid_i    ( crypto_operand_valid_i[lane][1] ),
    .ready_o    ( crypto_operand_ready_o[lane][1] ),
    .data_o     ( crypto_operand[lane][1]         ),
    .valid_o    ( crypto_operand_valid[lane][1]   ),
    .ready_i    ( crypto_operand_ready[lane][1]   )
  );

end: gen_regs_vd

for (genvar lane = 0; lane < NrLanes; lane++) begin: gen_regs_vs1

  fall_through_register #(
    .T(elen_t)
  ) i_register_vs1 (
    .clk_i      ( clk_i                           ),
    .rst_ni     ( rst_ni                          ),
    .clr_i      ( 1'b0                            ),
    .testmode_i ( 1'b0                            ),
    .data_i     ( crypto_operand_i[lane][2]       ),
    .valid_i    ( crypto_operand_valid_i[lane][2] ),
    .ready_o    ( crypto_operand_ready_o[lane][2] ),
    .data_o     ( crypto_operand[lane][2]         ),
    .valid_o    ( crypto_operand_valid[lane][2]   ),
    .ready_i    ( crypto_operand_ready[lane][2]   )
  );

end: gen_regs_vs1

/***************************
 * FIFO FOR STORING PE REQ *
 ***************************/

  // convert incoming peq_req to pe_crypto req for storage in FIFO
  always_comb begin

    // default assignment
    pe_crypto_req_in_s = '0;

    // add to queue if valid/ready are set and VFU is crypto
    if (pe_req_i.vfu == VFU_CryptoUnit) begin
      // filter necessary fields
      pe_crypto_req_in_s = '{
        id        : pe_req_i.id,
        op        : pe_req_i.op,
        vs1       : pe_req_i.vs1,
        vs2       : pe_req_i.vs2,
        vd        : pe_req_i.vd,
        scalar_op : pe_req_i.scalar_op,
        vl        : pe_req_i.vl,
        vstart    : pe_req_i.vstart,
        eg_len    : '0,
        vtype     : pe_req_i.vtype
      };

      // length in "element groups"
      pe_crypto_req_in_s.eg_len =
        (pe_req_i.op inside {[VAESK1:VSM4R_VS]}) ? (pe_req_i.vl >> 2) : (pe_req_i.vl >> 3);

    end
  end

  assign pe_id_d = pe_req_i.id;

  // register pe_id to determine if request is new or not
  // there should not be 2 pe_req in consecutive cycles which have the same ID
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if(~rst_ni) begin
      pe_id_q        <= '0;
      pe_req_valid_q <= '0;
    end else begin
      pe_id_q        <= pe_id_d;
      pe_req_valid_q <= pe_req_valid_i;
    end
  end

  // if there has been a rising edge detected on valid
  assign pe_req_valid_rise_s = pe_req_valid_i & (~pe_req_valid_q);

  // only push request in pe FIFO if there is a rising edge on valid OR
  // valid has been high for consecutive cycles and the pe_id changes
  assign pe_fifo_push_s = (pe_req_i.vfu == VFU_CryptoUnit &&
    ((pe_req_valid_rise_s == 1'b1) ||
    ((pe_id_d != pe_id_q) && ((pe_req_valid_i & pe_req_valid_q) == 1'b1)))) ?
    pe_req_valid_i : '0;

  // pe ready driven by fifo NOT full
  assign pe_req_ready_o = ~pe_fifo_full_s;
  // pe crypto valid driven by fifo NOT empty
  assign pe_crypto_req_valid_s = ~pe_fifo_empty_s;

  fifo_v3 #(
    .FALL_THROUGH ( 1                    ),
    .DEPTH        ( CryptoInsnQueueDepth ), // as many instructions as can be run in parallel
    .dtype        ( pe_crypto_req_t      )
  ) i_pe_fifo (
    .clk_i        ( clk_i                ),
    .rst_ni       ( rst_ni               ),
    .flush_i      ( 1'b0                 ),
    .testmode_i   ( 1'b0                 ),
    .full_o       ( pe_fifo_full_s       ),
    .empty_o      ( pe_fifo_empty_s      ),
    .usage_o      ( /* UNCONNECTED */    ),
    .data_i       ( pe_crypto_req_in_s   ),
    .push_i       ( pe_fifo_push_s       ),
    .data_o       ( pe_crypto_req_coll_s ),
    .pop_i        ( pe_crypto_req_ack_s  )
  );

/*********************
 * OPERAND COLLECTOR *
 *********************/

  operand_collector #(
    .NrLanes ( NrLanes )
  ) i_operand_collector (
    .clk_i                  ( clk_i                 ),
    .rst_ni                 ( rst_ni                ),
    .pe_req_valid_i         ( pe_crypto_req_valid_s ),
    .pe_crypto_req_i        ( pe_crypto_req_coll_s  ),
    .pe_req_ack_o           ( pe_crypto_req_ack_s   ),
    .pe_crypto_req_o        ( pe_crypto_req_exec_s  ),
    .crypto_operand_i       ( crypto_operand        ),
    .crypto_operand_valid_i ( crypto_operand_valid  ),
    .crypto_operand_ready_o ( crypto_operand_ready  ),
    .crypto_args_buff_o     ( crypto_args_buff_s    ),
    .crypto_args_valid_o    ( crypto_args_valid_s   ),
    .crypto_args_ready_i    ( crypto_args_ready_s   )
  );

/*******************
 * EXECUTION UNITS *
 *******************/

  execution_units i_execution_units (
    .clk_i              ( clk_i                ),
    .rst_ni             ( rst_ni               ),
    .arg_valid_i        ( crypto_args_valid_s  ),
    .wb_ready_i         ( wb_ready_s           ),
    .crypto_args_buff_i ( crypto_args_buff_s   ),
    .pe_crypto_req_i    ( pe_crypto_req_exec_s ),
    .arg_ready_o        ( crypto_args_ready_s  ),
    .result_valid_o     ( wb_valid_s           ),
    .pe_crypto_req_o    ( pe_crypto_req_wb_q   ),
    .crypto_result_o    ( crypto_result_s      )
  );


/**************
 * WRITE BACK *
 **************/

  write_back #(
    .NrLanes ( NrLanes ),
    .vaddr_t ( vaddr_t )
  ) i_write_back (
    .clk_i                     ( clk_i                     ),
    .rst_ni                    ( rst_ni                    ),
    .result_valid_i            ( wb_valid_s                ),
    .pe_crypto_req_i           ( pe_crypto_req_wb_q        ),
    .crypto_result_i           ( crypto_result_s           ),
    .crypto_result_gnt_i       ( crypto_result_gnt_i       ),
    .crypto_result_final_gnt_i ( crypto_result_final_gnt_i ),
    .wb_ready_o                ( wb_ready_s                ),
    .crypto_result_req_o       ( crypto_result_req_o       ),
    .crypto_result_id_o        ( crypto_result_id_o        ),
    .crypto_result_addr_o      ( crypto_result_addr_o      ),
    .crypto_result_wdata_o     ( crypto_result_wdata_o     ),
    .crypto_result_be_o        ( crypto_result_be_o        ),
    .wb_done_o                 ( wb_done_s                 )
  );

  // temporary logic to control when to send the pe_resp
  always_ff @(posedge clk_i or negedge rst_ni) begin

    if (~rst_ni) begin

      pe_resp_o.vinsn_done <= '0;

    end else begin

      if (wb_done_s) begin
        pe_resp_o.vinsn_done[int'(pe_crypto_req_wb_q.id)] <= 1'b1;
      end else begin
        pe_resp_o.vinsn_done                              <= '0;
      end

    end
  end

endmodule
