//------------------------------------------------------------------------------
// Module   : debug_system
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 20-jan-2024
//
// Description: Top module Marian debug module components.
//
// Parameters:
//  - None
//
// Inputs:
//  - clk_i: Clock
//  - rst_ni Asynchronous active-low reset
//  - debug_axi_s_req_i: 64b AXI request lines from xbar (M) to dbg module (S)
//  - debug_axi_m_resp_i: 64b AXI response from xbar (S) to dbg module (S)
//  - debug_req_irq_o: IRQ request for debug
//  - jtag_tck_i: JTAG test clock
//  - jtag_tms_i: JTAG test mode select signal
//  - jtag_trstn_i: JTAG test reset (async, actve-low)
//  - jtag_tdi_i: JTAG test data in
//
// Outputs:
//  - debug_axi_s_resp_o: 64b AXI response from dbg module (S) to xbar (M)
//  - debug_axi_m_req_o: 64b AXI request lines from dbg module (M) to xbar (S)
//  - jtag_tdo_o: JTAG test data out
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

`include "axi/assign.svh"

module debug_system
  import marian_pkg::*;
(
  input  logic clk_i,
  input  logic rstn_i,
  // axi signals from xbar
  input  marian_pkg::debug_s_req_t  debug_axi_s_req_i,
  output marian_pkg::debug_s_resp_t debug_axi_s_resp_o,
  // axi signals from xbar
  input  marian_pkg::debug_m_resp_t debug_axi_m_resp_i,
  output marian_pkg::debug_m_req_t  debug_axi_m_req_o,
  // debug request IRQ
  output logic debug_req_irq_o,
  // jtag signals
  input  logic jtag_tck_i,
  input  logic jtag_tms_i,
  input  logic jtag_trstn_i,
  input  logic jtag_tdi_i,
  output logic jtag_tdo_o
);

/**************
 * Parameters *
 **************/

  localparam int unsigned NrHarts =  1;

  localparam int unsigned DbgAxiDataWidth = marian_pkg::AxiNarrowDataWidth;
  localparam int unsigned DbgAxiAddrWidth = marian_pkg::AxiAddrWidth;
  localparam int unsigned DbgAxiUserWidth = marian_pkg::AxiUserWidth;

`ifndef FPGA
  localparam int unsigned DbgAxiIdWidth   = marian_pkg::AxiSocIdWidth;
`else
  localparam int unsigned DbgAxiIdWidth   = marian_pkg::AxiIdWidth;
`endif

/***********
 * Signals *
 ***********/

  // static debug hartinfo
  localparam dm::hartinfo_t DebugHartInfo = '{
    zero1:                 '0,
    nscratch:               2,
    zero0:                 '0,
    dataaccess:          1'b1,
    datasize:               dm::DataCount,
    dataaddr:               dm::DataAddr
  };

  // DTM/DMI <-> DM signals
  dm::dmi_req_t                   dmi_req_s;
  dm::dmi_resp_t                  dmi_resp_s;
  logic                           dmi_req_valid_s;
  logic                           dmi_req_ready_s;
  logic                           dmi_resp_valid_s;
  logic                           dmi_resp_ready_s;
  // dbg_s 
  logic                           dbg_s_req_s;
  logic                           dbg_s_we_s;
  logic [    DbgAxiAddrWidth-1:0] dbg_s_addr_s;
  logic [    DbgAxiDataWidth-1:0] dbg_s_wdata_s;
  logic [(DbgAxiDataWidth/8)-1:0] dbg_s_be_s;
  logic [    DbgAxiDataWidth-1:0] dbg_s_rdata_s;
  // dbg_m
  logic                           dbg_m_req_s;
  logic [    DbgAxiAddrWidth-1:0] dbg_m_add_s;
  logic                           dbg_m_we_s;
  logic [    DbgAxiDataWidth-1:0] dbg_m_wdata_s;
  logic [(DbgAxiDataWidth/8)-1:0] dbg_m_be_s;
  logic                           dbg_m_gnt_s;
  logic                           dbg_m_valid_s;
  logic [    DbgAxiDataWidth-1:0] dbg_m_rdata_s;

  ariane_axi::req_t  dbg_m_axi_req_s;
  ariane_axi::resp_t dbg_m_axi_resp_s;

  // axi bus interface
  AXI_BUS #(
    .AXI_ADDR_WIDTH ( DbgAxiAddrWidth ),
    .AXI_DATA_WIDTH ( DbgAxiDataWidth ),
    .AXI_ID_WIDTH   ( DbgAxiIdWidth   ),
    .AXI_USER_WIDTH ( DbgAxiUserWidth )
  ) axi_dbg_if ();

/***************
 * Assignments *
 ***************/

  /* Explicit assignments used as ariane_axi::resp_t and ariane_axi::req_t may
     change once CVA6 is changed. Casting may mask bugs if this update occurs */

  // dbg_m_axi_resp_s <- debug_axi_m_resp_i

  assign dbg_m_axi_resp_s.aw_ready = debug_axi_m_resp_i.aw_ready;
  assign dbg_m_axi_resp_s.ar_ready = debug_axi_m_resp_i.ar_ready;
  assign dbg_m_axi_resp_s.w_ready  = debug_axi_m_resp_i.w_ready;
  assign dbg_m_axi_resp_s.b_valid  = debug_axi_m_resp_i.b_valid;
  assign dbg_m_axi_resp_s.b.id     = debug_axi_m_resp_i.b.id[3:0];
  assign dbg_m_axi_resp_s.b.resp   = debug_axi_m_resp_i.b.resp;
  assign dbg_m_axi_resp_s.b.user   = debug_axi_m_resp_i.b.user;
  assign dbg_m_axi_resp_s.r_valid  = debug_axi_m_resp_i.r_valid;
  assign dbg_m_axi_resp_s.r.id     = debug_axi_m_resp_i.r.id[3:0];
  assign dbg_m_axi_resp_s.r.data   = debug_axi_m_resp_i.r.data;
  assign dbg_m_axi_resp_s.r.resp   = debug_axi_m_resp_i.r.resp;
  assign dbg_m_axi_resp_s.r.last   = debug_axi_m_resp_i.r.last;
  assign dbg_m_axi_resp_s.r.user   = debug_axi_m_resp_i.r.user;


  // debug_axi_m_req_o <- dbg_m_axi_req_s

  assign debug_axi_m_req_o.aw.id     = {'0, dbg_m_axi_req_s.aw.id};
  assign debug_axi_m_req_o.aw.addr   = dbg_m_axi_req_s.aw.addr;
  assign debug_axi_m_req_o.aw.len    = dbg_m_axi_req_s.aw.len;
  assign debug_axi_m_req_o.aw.size   = dbg_m_axi_req_s.aw.size;
  assign debug_axi_m_req_o.aw.burst  = dbg_m_axi_req_s.aw.burst;
  assign debug_axi_m_req_o.aw.lock   = dbg_m_axi_req_s.aw.lock;
  assign debug_axi_m_req_o.aw.cache  = dbg_m_axi_req_s.aw.cache;
  assign debug_axi_m_req_o.aw.prot   = dbg_m_axi_req_s.aw.prot;
  assign debug_axi_m_req_o.aw.qos    = dbg_m_axi_req_s.aw.qos;
  assign debug_axi_m_req_o.aw.region = dbg_m_axi_req_s.aw.region;
  assign debug_axi_m_req_o.aw.atop   = dbg_m_axi_req_s.aw.atop;
  assign debug_axi_m_req_o.aw.user   = dbg_m_axi_req_s.aw.user;
  assign debug_axi_m_req_o.aw_valid  = dbg_m_axi_req_s.aw_valid;
  assign debug_axi_m_req_o.w.data    = dbg_m_axi_req_s.w.data;
  assign debug_axi_m_req_o.w.strb    = dbg_m_axi_req_s.w.strb;
  assign debug_axi_m_req_o.w.last    = dbg_m_axi_req_s.w.last;
  assign debug_axi_m_req_o.w.user    = dbg_m_axi_req_s.w.user;
  assign debug_axi_m_req_o.w_valid   = dbg_m_axi_req_s.w_valid;
  assign debug_axi_m_req_o.b_ready   = dbg_m_axi_req_s.b_ready;
  assign debug_axi_m_req_o.ar.id     = {'0, dbg_m_axi_req_s.ar.id};
  assign debug_axi_m_req_o.ar.addr   = dbg_m_axi_req_s.ar.addr;
  assign debug_axi_m_req_o.ar.len    = dbg_m_axi_req_s.ar.len;
  assign debug_axi_m_req_o.ar.size   = dbg_m_axi_req_s.ar.size;
  assign debug_axi_m_req_o.ar.burst  = dbg_m_axi_req_s.ar.burst;
  assign debug_axi_m_req_o.ar.lock   = dbg_m_axi_req_s.ar.lock;
  assign debug_axi_m_req_o.ar.cache  = dbg_m_axi_req_s.ar.cache;
  assign debug_axi_m_req_o.ar.prot   = dbg_m_axi_req_s.ar.prot;
  assign debug_axi_m_req_o.ar.qos    = dbg_m_axi_req_s.ar.qos;
  assign debug_axi_m_req_o.ar.region = dbg_m_axi_req_s.ar.region;
  assign debug_axi_m_req_o.ar.user   = dbg_m_axi_req_s.ar.user;
  assign debug_axi_m_req_o.ar_valid  = dbg_m_axi_req_s.ar_valid;
  assign debug_axi_m_req_o.r_ready   = dbg_m_axi_req_s.r_ready;

  // convert axi struct to interface for axi2mem module
  `AXI_ASSIGN_FROM_REQ(axi_dbg_if, debug_axi_s_req_i)
  `AXI_ASSIGN_TO_RESP(debug_axi_s_resp_o, axi_dbg_if)

/**************
 * Components *
 **************/

 dmi_jtag #(
    .IdcodeValue ( 32'hF007BA11 )
  ) i_dmi_jtag (
    .clk_i                ( clk_i            ),
    .rst_ni               ( rstn_i           ),
    .testmode_i           ( '0               ),
    .dmi_rst_no           ( /*nc*/           ),
    .dmi_req_valid_o      ( dmi_req_valid_s  ),
    .dmi_req_ready_i      ( dmi_req_ready_s  ),
    .dmi_req_o            ( dmi_req_s        ),
    .dmi_resp_valid_i     ( dmi_resp_valid_s ),
    .dmi_resp_ready_o     ( dmi_resp_ready_s ),
    .dmi_resp_i           ( dmi_resp_s       ),
    .tck_i                ( jtag_tck_i       ),
    .tms_i                ( jtag_tms_i       ),
    .trst_ni              ( jtag_trstn_i     ),
    .td_i                 ( jtag_tdi_i       ),
    .td_o                 ( jtag_tdo_o       ),
    .tdo_oe_o             ( /*nc*/           )
  );

  dm_top #(
    .NrHarts         ( NrHarts         ),
    .BusWidth        ( DbgAxiDataWidth ),
    .DmBaseAddress   ( DBGBase         ),
    .SelectableHarts ( {NrHarts{1'b1}} )
  ) i_dm_top (
    .clk_i                ( clk_i               ),
    .rst_ni               ( rstn_i              ),
    .testmode_i           ( '0                  ),
    .ndmreset_o           ( /*nc*/              ),
    .dmactive_o           ( /*nc*/              ),
    .debug_req_o          ( debug_req_irq_o     ),
    .unavailable_i        ( '0                  ),
    .hartinfo_i           ( DebugHartInfo       ),
    .slave_req_i          ( dbg_s_req_s         ),
    .slave_we_i           ( dbg_s_we_s          ),
    .slave_addr_i         ( dbg_s_addr_s        ),
    .slave_be_i           ( dbg_s_be_s          ),
    .slave_wdata_i        ( dbg_s_wdata_s       ),
    .slave_rdata_o        ( dbg_s_rdata_s       ),
    .master_req_o         ( dbg_m_req_s         ),
    .master_add_o         ( dbg_m_add_s         ),
    .master_we_o          ( dbg_m_we_s          ),
    .master_wdata_o       ( dbg_m_wdata_s       ),
    .master_be_o          ( dbg_m_be_s          ),
    .master_gnt_i         ( dbg_m_gnt_s         ),
    .master_r_valid_i     ( dbg_m_valid_s       ),
    .master_r_rdata_i     ( dbg_m_rdata_s       ),
    .dmi_rst_ni           ( rstn_i              ),
    .dmi_req_valid_i      ( dmi_req_valid_s     ),
    .dmi_req_ready_o      ( dmi_req_ready_s     ),
    .dmi_req_i            ( dmi_req_s           ),
    .dmi_resp_valid_o     ( dmi_resp_valid_s    ),
    .dmi_resp_ready_i     ( dmi_resp_ready_s    ),
    .dmi_resp_o           ( dmi_resp_s          )
  );

  // converts dbg M -> AXI
  axi_adapter #(
    .DATA_WIDTH            ( DbgAxiDataWidth        )
  ) i_dm_to_axi_master (
    .clk_i                 ( clk_i                  ),
    .rst_ni                ( rstn_i                 ),
    .req_i                 ( dbg_m_req_s            ),
    .type_i                ( ariane_axi::SINGLE_REQ ),
    .gnt_o                 ( dbg_m_gnt_s            ),
    .gnt_id_o              ( /* UNUSED */           ),
    .addr_i                ( dbg_m_add_s            ),
    .we_i                  ( dbg_m_we_s             ),
    .wdata_i               ( dbg_m_wdata_s          ),
    .be_i                  ( dbg_m_be_s             ),
    .size_i                ( 2'b11                  ), // 2^3 = 8 Bytes
    .id_i                  ( '0                     ),
    .valid_o               ( dbg_m_valid_s          ),
    .rdata_o               ( dbg_m_rdata_s          ),
    .id_o                  ( /* UNUSED */           ),
    .critical_word_o       ( /* UNUSED */           ),
    .critical_word_valid_o ( /* UNUSED */           ),
    .axi_req_o             ( dbg_m_axi_req_s        ),
    .axi_resp_i            ( dbg_m_axi_resp_s       )
  );

  // converts AXI -> dbg S
  axi2mem #(
    .AXI_ID_WIDTH   ( DbgAxiIdWidth   ),
    .AXI_ADDR_WIDTH ( DbgAxiAddrWidth ),
    .AXI_DATA_WIDTH ( DbgAxiDataWidth ),
    .AXI_USER_WIDTH ( DbgAxiUserWidth )
  ) i_axi_slave_to_dm (
    .clk_i  ( clk_i               ),
    .rst_ni ( rstn_i              ),
    .slave  ( axi_dbg_if          ),
    .req_o  ( dbg_s_req_s         ),
    .we_o   ( dbg_s_we_s          ),
    .addr_o ( dbg_s_addr_s        ),
    .be_o   ( dbg_s_be_s          ),
    .user_o ( /* NOT CONNECTED */ ),
    .data_o ( dbg_s_wdata_s       ),
    .data_i ( dbg_s_rdata_s       ),
    .user_i ( '0                  )
  );

endmodule
