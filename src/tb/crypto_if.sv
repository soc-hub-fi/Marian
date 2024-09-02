//------------------------------------------------------------------------------
// Module   : crypto_if.sv
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 30-apr-2024
//
// Description: Interface to be used when testing the crypto_unit
//
// Parameters:
//  - None
//
// Inputs:
//  - None
//
// Outputs:
//  - None
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

interface crypto_if (
  input logic clk_i,
  input logic rstn_i
);
  import ara_pkg::*;
  import crypto_unit_tb_pkg::*;

  // interface with the sequencer
  pe_req_t                 pe_req_i;
  logic                    pe_req_valid_i;
  logic      [NrVInsn-1:0] pe_vinsn_running_i;
  logic                    pe_req_ready_o;
  pe_resp_t                pe_resp_o;
  // interface with the lanes
  // source operands {vs1, vd, vs2}
  elen_t     [NrLanes-1:0][2:0] crypto_operand_i;
  logic      [NrLanes-1:0][2:0] crypto_operand_valid_i;
  logic      [NrLanes-1:0][2:0] crypto_operand_ready_o;
  // result operands
  logic      [NrLanes-1:0]      crypto_result_req_o;
  vid_t      [NrLanes-1:0]      crypto_result_id_o;
  vaddr_t    [NrLanes-1:0]      crypto_result_addr_o;
  elen_t     [NrLanes-1:0]      crypto_result_wdata_o;
  strb_t     [NrLanes-1:0]      crypto_result_be_o;
  logic      [NrLanes-1:0]      crypto_result_gnt_i;
  logic      [NrLanes-1:0]      crypto_result_final_gnt_i;

endinterface 