//------------------------------------------------------------------------------
// Module   : xilinx_sp_bram
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 22-dec-2023
//
// Description: Single Port SRAM module which will infer the creation of BRAMs
// on Xilinx FPGAs. This module is a modified version of the BRAM inference
// template provided within Vivado 2022.2. Original template comments below:
//
//  Xilinx Single Port Write First RAM This code implements a parameterizable
//  single-port write-first memory where when data is written to the memory, the
//  output reflects the same data being written to the memory. If the output
//  data is not needed during writes or the last read value is desired to be it
//  is suggested to use a No Change as it is more power efficient. If a reset or
//  enable is not necessary, it may be tied off or removed from the code. Modify
//  the parameters for the desired RAM characteristics.
//
// Parameters:
//  - RAMWidthBytes: Specify number of columns (number of bytes)
//  - BYTE_WIDTH: Specify Byte width (typically 8 or 9)
//  - RAM_DEPTH: Specify RAM depth (number of entries)
//  - RAM_PERFORMANCE: Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
//  - INIT_FILE: Specify name/location of RAM initialization file if using one
//    (leave blank if not)
//
// Inputs:
//  - clk_i: Clock
//  - rst_ni: Active-low synchronous reset of output registers (does not affect
//    memory contents)
//  - regcea_i: Active-high register enable for output registers
//  - addr_i: Address line
//  - wdata_i: Write data
//  - we_i: Active-high write enable
//  - re_i: Active-high RAM enable
//
// Outputs:
//  - rdata_o: RAM output data
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

module xilinx_sp_bram #(
  parameter integer BYTE_WIDTH      =    8,
  parameter integer DATA_WIDTH      =    8,
  parameter integer RAM_DEPTH       = 1024,
  parameter         RAM_PERFORMANCE = "HIGH_PERFORMANCE",
  parameter         INIT_FILE       = "",

  localparam integer RAMWidthBytes = (DATA_WIDTH + (BYTE_WIDTH-1)) / BYTE_WIDTH
) (
  input  logic                           clk_i,
  input  logic                           rst_ni,
  input  logic                           regcea_i,
  input  logic [$clog2(RAM_DEPTH-1)-1:0] addr_i,
  input  logic [       (DATA_WIDTH)-1:0] wdata_i,
  input  logic                           we_i,
  input  logic                           re_i,

  output logic [       (DATA_WIDTH)-1:0] rdata_o
);

  reg [DATA_WIDTH-1:0] BRAM [RAM_DEPTH-1:0];
  reg [DATA_WIDTH-1:0] ram_data = {(DATA_WIDTH){1'b0}};

  // The following code either initializes the memory values to a specified file
  // or to all zeros to match hardware
  generate
    if (INIT_FILE != "") begin: gen_init_file
      initial
        $readmemh(INIT_FILE, BRAM, 0, RAM_DEPTH-1);
    end else begin: gen_init_zero
      integer ram_index;
      initial
        for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
          BRAM[ram_index] = {(DATA_WIDTH){1'b0}};
    end
  endgenerate

  always @(posedge clk_i)
    if (re_i)
      if (we_i) begin
        BRAM[addr_i] <= wdata_i;
        rdata_o <= wdata_i;
      end else
        rdata_o <= BRAM[addr_i];

  //  The following code generates HIGH_PERFORMANCE (use output register) or
  //  LOW_LATENCY (no output register)
  generate
    if (RAM_PERFORMANCE == "LOW_LATENCY") begin: gen_no_output_register

      // The following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing
       assign rdata_o = ram_data;

    end else begin: gen_output_register

      // The following is a 2 clock cycle read latency with improve clock-to-out timing

      reg [(DATA_WIDTH)-1:0] douta_reg = {(DATA_WIDTH){1'b0}};

      always @(posedge clk_i)
        if (rst_ni)
          douta_reg <= {(DATA_WIDTH){1'b0}};
        else if (regcea_i)
          douta_reg <= ram_data;

      assign rdata_o = douta_reg;

    end
  endgenerate

endmodule
