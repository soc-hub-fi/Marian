//------------------------------------------------------------------------------
// Module   : tico_generic_fpga
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 11-jun-2024
//
// Description: File containing collection of FPGA-friendly tico cells 
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

module tico_ctsync (
  input  logic clk, rst_n, data_in,
  output logic data_out
);

(* ASYNC_REG = "TRUE" *) reg sync1;
(* ASYNC_REG = "TRUE" *) reg sync2;

   always_ff @(posedge clk, negedge rst_n)
     begin : syncreg
  if (rst_n == 1'b0) begin
           sync1 <= 1'b0;
     sync2 <= 1'b0;
  end else begin
     sync1 <= data_in;
     sync2 <= sync1;
  end
     end

   assign data_out = sync2;
endmodule // tico_ctsync