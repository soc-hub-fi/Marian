//------------------------------------------------------------------------------
// Module   : marian_fpga_system
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 20-jan-2024
//
// Description: FPGA implementation of "Ara System", containing Ariane and Ara.
//
// Parameters:
//  - None
//
// Inputs:
//  - debug_req_i: Debug request IRQ line from debug module
//
// Outputs:
//  -
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

module marian_fpga_system
  import marian_fpga_pkg::*;
  import ara_pkg::*;
#(
    // Ariane configuration
    parameter ariane_pkg::ariane_cfg_t ArianeCfg = ariane_pkg::ArianeDefaultConfig

  ) (
    input  logic                    clk_i,
    input  logic                    rst_ni,
    input  logic             [63:0] boot_addr_i,
    input  logic              [2:0] hart_id_i,
    // debug req irq line
    input  logic                    debug_req_i,
    // AXI Interface
    output marian_fpga_pkg::system_req_t  axi_req_o,
    input  marian_fpga_pkg::system_resp_t axi_resp_i
);

  ///////////
  //  AXI  //
  ///////////

  marian_fpga_pkg::ariane_axi_req_t  ariane_narrow_axi_req;
  marian_fpga_pkg::ariane_axi_resp_t ariane_narrow_axi_resp;
  marian_fpga_pkg::ara_axi_req_t     ariane_axi_req, ara_axi_req_inval, ara_axi_req;
  marian_fpga_pkg::ara_axi_resp_t    ariane_axi_resp, ara_axi_resp_inval, ara_axi_resp;

  //////////////////////
  //  Ara and Ariane  //
  //////////////////////

  import ariane_pkg::accelerator_req_t;
  import ariane_pkg::accelerator_resp_t;

  // Accelerator ports
  accelerator_req_t                     acc_req;
  logic                                 acc_req_valid;
  logic                                 acc_req_ready;
  accelerator_resp_t                    acc_resp;
  logic                                 acc_resp_valid;
  logic                                 acc_resp_ready;
  logic                                 acc_cons_en;
  logic              [AxiAddrWidth-1:0] inval_addr;
  logic                                 inval_valid;
  logic                                 inval_ready;

  // Support max 8 cores, for now
  logic [63:0] hart_id;
  assign hart_id = {'0, hart_id_i};

  ariane #(
    .ArianeCfg( ArianeCfg )
  ) i_ariane (
    .clk_i            ( clk_i                  ),
    .rst_ni           ( rst_ni                 ),
    .boot_addr_i      ( boot_addr_i            ),
    .hart_id_i        ( hart_id                ),
    .irq_i            ( '0                     ),
    .ipi_i            ( '0                     ),
    .time_irq_i       ( '0                     ),
    .debug_req_i      ( debug_req_i            ),
    .axi_req_o        ( ariane_narrow_axi_req  ),
    .axi_resp_i       ( ariane_narrow_axi_resp ),
    // Accelerator ports
    .acc_req_o        ( acc_req                ),
    .acc_req_valid_o  ( acc_req_valid          ),
    .acc_req_ready_i  ( acc_req_ready          ),
    .acc_resp_i       ( acc_resp               ),
    .acc_resp_valid_i ( acc_resp_valid         ),
    .acc_resp_ready_o ( acc_resp_ready         ),
    .acc_cons_en_o    ( acc_cons_en            ),
    .inval_addr_i     ( inval_addr             ),
    .inval_valid_i    ( inval_valid            ),
    .inval_ready_o    ( inval_ready            )
  );

  axi_dw_conv_up_sys_wrapper i_axi_dw_conv_up_sys_wrapper (
    .clk_i                    ( clk_i                  ),
    .rstn_i                   ( rst_ni                 ),
    .ariane_axi_resp_i        ( ariane_axi_resp        ),
    .ariane_narrow_axi_req_i  ( ariane_narrow_axi_req  ),
    .ariane_axi_req_o         ( ariane_axi_req         ),
    .ariane_narrow_axi_resp_o ( ariane_narrow_axi_resp )
  );

  axi_inval_filter #(
    .MaxTxns    (4                              ),
    .AddrWidth  (AxiAddrWidth                   ),
    .L1LineWidth(ariane_pkg::DCACHE_LINE_WIDTH/8)
  ) i_axi_inval_filter (
    .clk_i                ( clk_i              ),
    .rst_ni               ( rst_ni             ),
    .en_i                 ( acc_cons_en        ),
    .ara_axi_req_i        ( ara_axi_req        ),
    .ara_axi_resp_o       ( ara_axi_resp       ),
    .ara_axi_req_inval_o  ( ara_axi_req_inval  ),
    .ara_axi_resp_inval_i ( ara_axi_resp_inval ),
    .inval_addr_o         ( inval_addr         ),
    .inval_valid_o        ( inval_valid        ),
    .inval_ready_i        ( inval_ready        )
  );

// When debugging Ariane without Ara, use ARIANE_DEBUG define to remove Ara
// instantiation and improve synth + simulation times
`ifndef ARIANE_DEBUG
  ara #(
    .NrLanes     ( marian_fpga_pkg::NrLanes           ),
    .FPUSupport  ( marian_fpga_pkg::FPUSupport        ),
    .FPExtSupport( marian_fpga_pkg::FPExtSupport      ),
    .FixPtSupport( marian_fpga_pkg::FixPtSupport      ),
    .AxiDataWidth( marian_fpga_pkg::AxiWideDataWidth  ),
    .AxiAddrWidth( marian_fpga_pkg::AxiAddrWidth      ),
    .axi_ar_t    ( marian_fpga_pkg::ara_axi_ar_chan_t ),
    .axi_r_t     ( marian_fpga_pkg::ara_axi_r_chan_t  ),
    .axi_aw_t    ( marian_fpga_pkg::ara_axi_aw_chan_t ),
    .axi_w_t     ( marian_fpga_pkg::ara_axi_w_chan_t  ),
    .axi_b_t     ( marian_fpga_pkg::ara_axi_b_chan_t  ),
    .axi_req_t   ( marian_fpga_pkg::ara_axi_req_t     ),
    .axi_resp_t  ( marian_fpga_pkg::ara_axi_resp_t    )
  ) i_ara (
    .clk_i           (clk_i         ),
    .rst_ni          (rst_ni        ),
    .acc_req_i       (acc_req       ),
    .acc_req_valid_i (acc_req_valid ),
    .acc_req_ready_o (acc_req_ready ),
    .acc_resp_o      (acc_resp      ),
    .acc_resp_valid_o(acc_resp_valid),
    .acc_resp_ready_i(acc_resp_ready),
    .axi_req_o       (ara_axi_req   ),
    .axi_resp_i      (ara_axi_resp  )
  );
`else
  assign acc_req_ready  = '0;
  assign acc_resp       = '0;
  assign acc_resp_valid = '0;
  assign ara_axi_req    = '0;
`endif

  axi_mux #(
    .SlvAxiIDWidth ( marian_fpga_pkg::AxiCoreIdWidth       ),
    .slv_ar_chan_t ( marian_fpga_pkg::ara_axi_ar_chan_t    ),
    .slv_aw_chan_t ( marian_fpga_pkg::ara_axi_aw_chan_t    ),
    .slv_b_chan_t  ( marian_fpga_pkg::ara_axi_b_chan_t     ),
    .slv_r_chan_t  ( marian_fpga_pkg::ara_axi_r_chan_t     ),
    .slv_req_t     ( marian_fpga_pkg::ara_axi_req_t        ),
    .slv_resp_t    ( marian_fpga_pkg::ara_axi_resp_t       ),
    .mst_ar_chan_t ( marian_fpga_pkg::system_ar_chan_t     ),
    .mst_aw_chan_t ( marian_fpga_pkg::system_aw_chan_t     ),
    .w_chan_t      ( marian_fpga_pkg::system_w_chan_t      ),
    .mst_b_chan_t  ( marian_fpga_pkg::system_b_chan_t      ),
    .mst_r_chan_t  ( marian_fpga_pkg::system_r_chan_t      ),
    .mst_req_t     ( marian_fpga_pkg::system_req_t         ),
    .mst_resp_t    ( marian_fpga_pkg::system_resp_t        ),
    .NoSlvPorts    ( 2                                     ),
    .SpillAr       ( 1'b1                                  ),
    .SpillR        ( 1'b1                                  ),
    .SpillAw       ( 1'b1                                  ),
    .SpillW        ( 1'b1                                  ),
    .SpillB        ( 1'b1                                  )
  ) i_system_mux (
    .clk_i       ( clk_i                                 ),
    .rst_ni      ( rst_ni                                ),
    .test_i      ( 1'b0                                  ),
    .slv_reqs_i  ( {ara_axi_req_inval, ariane_axi_req}   ),
    .slv_resps_o ( {ara_axi_resp_inval, ariane_axi_resp} ),
    .mst_req_o   ( axi_req_o                             ),
    .mst_resp_i  ( axi_resp_i                            )
  );

endmodule

