//------------------------------------------------------------------------------
// Module   : sram
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 22-dec-2023
//
// Description: Single Port SRAM model which can be used in both RTL simulation
// and for FPGA synthesis. Ports designed to maintain compatibility with sram
// modules used within CVA6.
//
// Parameters:
//  - INIT_FILE: Path to a .mem file which is passed to the $readmemh function
//    during initialisation. If left blank, the parameter is ignored and the
//    content of the memory is initialised to zero.
//  - DATA_WIDTH: Bit width of each word in memory.
//  - NUM_WORDS: Number of words stored in memory.
//  - REGISTERED_OUTPUT: Configures whether an additional register is placed
//    immediately before the rdata_o port.
//
// Inputs:
//  - clk_i: Clock input
//  - rst_ni: Asynchronous active-low reset
//  - req_i: Active-high request line (SRAM enable)
//  - we_i: Active-high write enable
//  - addr_i: Word address line
//  - wdata_i: Write data
//  - be_i: Active-high byte enable for write
//
// Outputs:
//  - rdata_o: Read data
//
// Revision History:
//  - Version 1.0: Initial release
//  - Version 1.1 [23-may-2024, TZS]: Added synth memory models 
//
//------------------------------------------------------------------------------

module sram #(
  parameter int unsigned BYTE_WIDTH        = 8,
  parameter              INIT_FILE         = "",
  parameter int unsigned DATA_WIDTH        = 64,
  parameter int unsigned NUM_WORDS         = 1024,
  parameter bit          REGISTERED_OUTPUT = 0,

  localparam integer DataWidthBytes = (DATA_WIDTH+(BYTE_WIDTH-1))/BYTE_WIDTH
)(
  input  logic                         clk_i,
  input  logic                         rst_ni,
  input  logic                         req_i,
  input  logic                         we_i,
  input  logic [$clog2(NUM_WORDS)-1:0] addr_i,
  input  logic [       DATA_WIDTH-1:0] wdata_i,
  input  logic [   DataWidthBytes-1:0] be_i,

  output logic [       DATA_WIDTH-1:0] rdata_o
);

`ifndef FPGA /************************* ASIC MODEL ****************************/

  // declare ram whether it is used or not to prevent TB errors
  logic [DATA_WIDTH-1:0] ram [NUM_WORDS-1:0];

  `ifndef SYNTH_MEM /************* SIMULATION *********************************/

    localparam integer AddrWidth = $clog2(NUM_WORDS);

    logic [DATA_WIDTH-1:0] rdata_s, rdata_q;
    logic [AddrWidth-1 :0] raddr_q;

    genvar gen_idx;

    generate

      initial begin : gen_init_ram
        // initialise all memory locations to zero
        for (int ram_index = 0; ram_index < NUM_WORDS; ram_index = ram_index + 1)
          ram[ram_index] = {DATA_WIDTH{1'b0}};
        // Overwrite zeroed memory with initialisation file (if defined)
        if (INIT_FILE != "") begin: use_init_file
          $readmemh(INIT_FILE, ram);
        end
      end

    endgenerate

    // use generate loop to maintain Verilator compatibility
    for (gen_idx = 0; gen_idx < DATA_WIDTH; gen_idx++) begin : gen_write_data

      always @(posedge clk_i or negedge rst_ni) begin

        if (~rst_ni) begin
          raddr_q <= '0;
        end else begin
          if (req_i) begin
            if (!we_i) begin
              raddr_q <= addr_i;
            end else begin
              if (be_i[gen_idx/BYTE_WIDTH]) ram[addr_i][gen_idx] <= wdata_i[gen_idx];
            end
          end
        end

      end
    end

    // if REGISTERED_OUTPUT is set, add a register slice after the RAM output
    assign rdata_s = ram[raddr_q];

    if (REGISTERED_OUTPUT) begin : gen_output_reg

      always_ff @(posedge clk_i, negedge rst_ni) begin
        if (~rst_ni) begin
          rdata_q <= '0;
        end else begin
          rdata_q <= rdata_s;
        end
      end

      assign rdata_o = rdata_q;

    end else begin  : gen_no_output_reg

      assign rdata_o = rdata_s;

    end

  `else /********************** SYNTH_MEM *************************************/

    vc_ss_tech_mem #(
      .DATA_WIDTH (DATA_WIDTH),
      .NUM_WORDS  (NUM_WORDS)
    ) i_vc_ss_tech_mem_sram (
      .clk_i   ( clk_i   ),
      .req_i   ( req_i   ),
      .we_i    ( we_i    ),
      .addr_i  ( addr_i  ),
      .wdata_i ( wdata_i ),
      .be_i    ( be_i    ),
      .rdata_o ( rdata_o )
    );

  `endif
`else /****************************** FPGA MODEL ******************************/

  localparam RAMPerformance = (REGISTERED_OUTPUT) ? "HIGH_PERFORMANCE" : "LOW_LATENCY";
  localparam int unsigned BRAMDataWidth = DataWidthBytes * BYTE_WIDTH;

  initial begin
    assert (BRAMDataWidth >= DATA_WIDTH)
      else $fatal(1, "BRAM Data Width cannot be smaller than data width");
    assert (BYTE_WIDTH == 8)
      else $fatal(1, "BRAM Byte width must be 8");
  end

  logic [DataWidthBytes-1:0] bram_we_s;
  logic [ BRAMDataWidth-1:0] bram_rdata_s, bram_wdata_s;

  // pad write data && trim read data if required
  if (BRAMDataWidth < DATA_WIDTH) begin : gen_bram_narrow_data
    assign bram_wdata_s = {'0, wdata_i};
    assign rdata_o      = bram_rdata_s[DATA_WIDTH-1:0];
  end else begin : gen_bram_data
    assign bram_wdata_s = wdata_i;
    assign rdata_o      = bram_rdata_s;
  end

  assign bram_we_s = (we_i == 1'b1) ? be_i : '0;

  xilinx_sp_bram_byte_en #(
    .BYTE_WIDTH      ( BYTE_WIDTH      ),
    .DATA_WIDTH      ( BRAMDataWidth   ),
    .RAM_DEPTH       ( NUM_WORDS       ),
    .RAM_PERFORMANCE ( RAMPerformance  ),
    .INIT_FILE       ( INIT_FILE       )
  ) i_xilinx_sp_bram (
    .clk_i           ( clk_i           ),
    .rst_ni          ( rst_ni          ),
    .regcea_i        ( 1'b1            ),
    .addr_i          ( addr_i          ),
    .wdata_i         ( bram_wdata_s    ),
    .we_i            ( bram_we_s       ),
    .re_i            ( req_i           ),
    .rdata_o         ( bram_rdata_s    )
  );

`endif /***********************************************************************/

endmodule
