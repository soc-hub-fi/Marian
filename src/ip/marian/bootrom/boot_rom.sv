//------------------------------------------------------------------------------
// Module   : boot_rom
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Endrit Isufi <endrit.isufi@tuni.fi>
// Created  : 28-May-2024
//
// Description: ROM for booting Marian with an AXI interface
//
// Parameters:
//  - AxiAddrWidth: AXI bus address width
//  - AxiDataWidth: AXI bus data width
//
// Inputs:
//  - clk_i :    Clock
//  - rst_ni:    Asynchronous active-low reset
//  - axi_req_i: AXI bus request channel
//
// Outputs:
//  - axi_resp_o: AXI bus response channel 
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

`include "common_cells/registers.svh"
module boot_rom
import marian_pkg::*; 
#(
  parameter int unsigned AxiAddrWidth       = 64,
  parameter int unsigned AxiDataWidth       = 128
)(
  input  logic                      clk_i,
  input  logic                      rst_ni,
  input  soc_wide_req_t             axi_req_i, 
  output soc_wide_resp_t            axi_resp_o
);

logic CSN;
/**************
 * axi_to_mem *
 **************/
logic                      rom_req;
logic                      rom_we;
logic [AxiAddrWidth-1:0]   rom_addr;
logic [AxiDataWidth/8-1:0] rom_strb;
logic [AxiDataWidth-1:0]   rom_wdata;
logic [AxiDataWidth-1:0]   rom_rdata;
logic                      rom_rvalid;

axi_to_mem #(
  .AddrWidth  ( AxiAddrWidth    ),
  .DataWidth  ( AxiDataWidth    ),
  .IdWidth    ( AxiSocIdWidth   ),
  .NumBanks   ( 1               ),
  .axi_req_t  ( soc_wide_req_t  ),
  .axi_resp_t ( soc_wide_resp_t )
) i_axi_to_mem_rom (
  .clk_i        ( clk_i                           ),
  .rst_ni       ( rst_ni                          ),
  .axi_req_i    ( axi_req_i                       ), 
  .axi_resp_o   ( axi_resp_o                      ), 
  .mem_req_o    ( rom_req                         ), 
  .mem_gnt_i    ( rom_req                         ), 
  .mem_we_o     ( rom_we                          ), 
  .mem_addr_o   ( rom_addr                        ), 
  .mem_strb_o   ( rom_strb                        ), 
  .mem_wdata_o  ( rom_wdata                       ), 
  .mem_rdata_i  ( rom_rdata                       ), 
  .mem_rvalid_i ( rom_rvalid                      ), 
  .mem_atop_o   ( /* Unused */                    ),
  .busy_o       ( /* Unused */                    ) 
);

/***************
 * Assignments *
 ***************/
assign CSN       = '0;
`FF(rom_rvalid, rom_req, 1'b0, clk_i , rst_ni ); 

/*********************
 * BootRom Interface *
 *********************/
bootrom_if #(
  .AxiAddrWidth(AxiAddrWidth),
  .AxiDataWidth(AxiDataWidth)
) i_bootrom_if (
  .clk_i  (clk_i      ),
  .rst_ni (rst_ni     ),
  .CSN    (CSN        ), //unused
  .addr_i (rom_addr   ),
  .data_o (rom_rdata  )
);

/**************
 * Assertions *
 **************/
`ifndef VERILATOR
assert property(@(posedge clk_i) rom_we == 1'b0) else   $warning("write enabled but ROM cannot be written.");

assert property(@(posedge clk_i) rom_wdata == '0) else  $warning("Trying to write to ROM.");
`endif

endmodule
