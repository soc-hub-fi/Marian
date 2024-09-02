//------------------------------------------------------------------------------
// Module   : bootrom_if
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Endrit Isufi <endrit.isufi@tuni.fi>
// Created  : 28-May-2024
//
// Description: ROM for booting Marian
//
// Parameters:
//  - AxiAddrWidth: AXI bus address width
//  - AxiDataWidth: AXI bus data width
//
// Inputs:
//  - clk_i :    Clock
//  - rst_ni:    Asynchronous active-low reset
//  - addr_i:    address of instruction
//
// Outputs:
//  - data_o:    Instruction fetched from ROM
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

module bootrom_if
#(
	parameter AxiAddrWidth = 32,
	parameter AxiDataWidth = 128
)
(
  input  logic                     clk_i,
  input  logic                     rst_ni,

  input  logic                       CSN, //unused
  input  logic [AxiAddrWidth-1:0]    addr_i,
  output logic [AxiDataWidth-1:0]    data_o
  );

/*

  Idea is that the bootROM will repeatedly check the value of the control register
  'bootRAM ready'. Once it is set with a non-zero value, the bootROM will load the
  value within the bootRAM_addr register and jump to it

the assembly looks like this:
   0:   00028013                mv      zero,t0
   4:   000022b7                lui     t0,0x2
   8:   0302829b                addiw   t0,t0,48 # 2030 <BOOTRAM_RDY>
   c:   0002b303                ld      t1,0(t0)
  10:   fe0308e3                beqz    t1,0 <jump_to_bootram>
  14:   00038013                mv      zero,t2
  18:   000023b7                lui     t2,0x2
  1c:   0283839b                addiw   t2,t2,40 # 2028 <BOOTRAM_ADDR>
  20:   0003b383                ld      t2,0(t2)
  24:   00038067                jr      t2
*/

  localparam integer unsigned MemRows = 3;
  localparam integer unsigned MemDepth = $clog2(MemRows);

  const logic [AxiDataWidth-1:0] mem [0:MemRows-1] = {
    128'h0002b303_0302829b_000022b7_00028013,
    128'h0283839b_000023b7_00038013_fe0308e3,
    128'h00000000_00000000_00038067_0003b383
  };

  logic [MemDepth-1:0] A_Q;

  always_ff @(posedge clk_i or negedge rst_ni)
  begin
    if (~rst_ni)
      A_Q <= '0;
    else
      A_Q <= addr_i[(4+MemDepth)-1:4];
  end

  assign data_o = mem[A_Q];

endmodule