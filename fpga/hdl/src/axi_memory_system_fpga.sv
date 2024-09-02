//------------------------------------------------------------------------------
// Module   : axi_memory_system_fpga
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 26-feb-2024
//
// Description: Contains AXI infrastructure and memory IPs used for prototyping
//              Marian.
//
// Parameters:
//  - None
//
// Inputs:
//  - clk_i: Clock
//  - rst_ni Asynchronous active-low reset
//  - memory_axi_req_i: 128b AXI request lines from xbar (M) to Memory (S)
//
// Outputs:
//  - memory_axi_resp_o: 128b AXI response lines from Memory (S) to xbar (M)
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

module axi_memory_system_fpga
  import marian_fpga_pkg::*;
(
  input  logic         clk_i,
  input  logic         rst_ni,
  input  system_req_t  memory_axi_req_i,

  output system_resp_t memory_axi_resp_o
);

  /*ToDo: The intention of this module is to create a single entity to house
          both the DDR and BRAM implementations of memory which can be used
          for the prototype of Marian.
          It is likely that this will be selected using macros.
  */

  axi_bram_2MiB_wrapper i_axi_bram_wrapper (
    .clk_i             ( clk_i             ),
    .rst_ni            ( rst_ni            ),
    .memory_axi_req_i  ( memory_axi_req_i  ),
    .memory_axi_resp_o ( memory_axi_resp_o )
  );


endmodule
