

module vc_ss_tech_mem #(
  parameter int unsigned DATA_WIDTH   =   64,
  parameter int unsigned NUM_WORDS    = 1024,

  localparam integer DataWidthBytes = (DATA_WIDTH+(8-1))/8
)(
  input  logic                         clk_i,
  input  logic                         req_i,
  input  logic                         we_i,
  input  logic [$clog2(NUM_WORDS)-1:0] addr_i,
  input  logic [       DATA_WIDTH-1:0] wdata_i,
  input  logic [   DataWidthBytes-1:0] be_i,
  output logic [       DATA_WIDTH-1:0] rdata_o
);

  assign rdata_o = '0;

endmodule

