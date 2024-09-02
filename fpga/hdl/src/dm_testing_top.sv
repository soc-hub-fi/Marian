//------------------------------------------------------------------------------
// Module   : dm_testing_top
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 27-apr-2024
//
// Description: Top level wrapper for testing debug module synthesis on FPGA
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

module dm_testing_top (
  input logic clk_p_i,
  input logic clk_n_i,
  input logic rst_i,
  // debug request irq
  output logic debug_req_irq_o,
  // jtag signals
  input  logic jtag_tck_i,
  input  logic jtag_tms_i,
  input  logic jtag_trst_i,
  input  logic jtag_tdi_i,
  output logic jtag_tdo_o
);

    // AXI-S interface to system -> debug module
    marian_fpga_pkg::debug_s_req_t  debug_axi_s_req;
    marian_fpga_pkg::debug_s_resp_t debug_axi_s_resp;
    // AXI-M interface to debug module -> system
    marian_fpga_pkg::debug_m_req_t  debug_axi_m_req;
    marian_fpga_pkg::debug_m_resp_t debug_axi_m_resp;

  logic clk_20MHz_s;
  logic locked_s;

  logic rstn_s;
  logic int_rstn_s;
  logic jtag_trstn_s;

  wire [0 : 0]  m_axi_awid;
  wire [63 : 0] m_axi_awaddr;
  wire [7 : 0]  m_axi_awlen;
  wire [2 : 0]  m_axi_awsize;
  wire [1 : 0]  m_axi_awburst;
  wire          m_axi_awlock;
  wire [3 : 0]  m_axi_awcache;
  wire [2 : 0]  m_axi_awprot;
  wire [3 : 0]  m_axi_awqos;
  wire          m_axi_awvalid;
  wire          m_axi_awready;
  wire [63 : 0] m_axi_wdata;
  wire [7 : 0]  m_axi_wstrb;
  wire          m_axi_wlast;
  wire          m_axi_wvalid;
  wire          m_axi_wready;
  wire [0 : 0]  m_axi_bid;
  wire [1 : 0]  m_axi_bresp;
  wire          m_axi_bvalid;
  wire          m_axi_bready;
  wire [0 : 0]  m_axi_arid;
  wire [63 : 0] m_axi_araddr;
  wire [7 : 0]  m_axi_arlen;
  wire [2 : 0]  m_axi_arsize;
  wire [1 : 0]  m_axi_arburst;
  wire          m_axi_arlock;
  wire [3 : 0]  m_axi_arcache;
  wire [2 : 0]  m_axi_arprot;
  wire [3 : 0]  m_axi_arqos;
  wire          m_axi_arvalid;
  wire          m_axi_arready;
  wire [0 : 0]  m_axi_rid;
  wire [63 : 0] m_axi_rdata;
  wire [1 : 0]  m_axi_rresp;
  wire          m_axi_rlast;
  wire          m_axi_rvalid;
  wire          m_axi_rready;

  wire [0 : 0]  s_axi_awid;
  wire [12 : 0] s_axi_awaddr;
  wire [7 : 0]  s_axi_awlen;
  wire [2 : 0]  s_axi_awsize;
  wire [1 : 0]  s_axi_awburst;
  wire          s_axi_awlock;
  wire [3 : 0]  s_axi_awcache;
  wire [2 : 0]  s_axi_awprot;
  wire          s_axi_awvalid;
  wire          s_axi_awready;
  wire [63 : 0] s_axi_wdata;
  wire [7 : 0]  s_axi_wstrb;
  wire          s_axi_wlast;
  wire          s_axi_wvalid;
  wire          s_axi_wready;
  wire [0 : 0]  s_axi_bid;
  wire [1 : 0]  s_axi_bresp;
  wire          s_axi_bvalid;
  wire          s_axi_bready;
  wire [0 : 0]  s_axi_arid;
  wire [12 : 0] s_axi_araddr;
  wire [7 : 0]  s_axi_arlen;
  wire [2 : 0]  s_axi_arsize;
  wire [1 : 0]  s_axi_arburst;
  wire          s_axi_arlock;
  wire [3 : 0]  s_axi_arcache;
  wire [2 : 0]  s_axi_arprot;
  wire          s_axi_arvalid;
  wire          s_axi_arready;
  wire [0 : 0]  s_axi_rid;
  wire [63 : 0] s_axi_rdata;
  wire [1 : 0]  s_axi_rresp;
  wire          s_axi_rlast;
  wire          s_axi_rvalid;
  wire          s_axi_rready;


  // combined internal reset
  assign rstn_s       = ~rst_i;
  assign int_rstn_s   = locked_s & rstn_s;
  assign jtag_trstn_s = ~jtag_trst_i;

  // connect JTAG AXI to DEBUG SYSTEM AXI
  // dm -> jtag axi
  assign m_axi_awready = debug_axi_s_resp.aw_ready;
  assign m_axi_wready  = debug_axi_s_resp.w_ready;
  assign m_axi_bid     = debug_axi_s_resp.b.id;
  assign m_axi_bresp   = debug_axi_s_resp.b.resp;
  assign m_axi_bvalid  = debug_axi_s_resp.b_valid;
  assign m_axi_arready = debug_axi_s_resp.ar_ready;
  assign m_axi_rid     = debug_axi_s_resp.r.id;
  assign m_axi_rdata   = debug_axi_s_resp.r.data;
  assign m_axi_rresp   = debug_axi_s_resp.r.resp;
  assign m_axi_rlast   = debug_axi_s_resp.r.last;
  assign m_axi_rvalid  = debug_axi_s_resp.r_valid;
  // axi jtag -> dm

  assign  debug_axi_s_req.aw.id     = m_axi_awid;
  assign  debug_axi_s_req.aw.addr   = m_axi_awaddr;
  assign  debug_axi_s_req.aw.len    = m_axi_awlen;
  assign  debug_axi_s_req.aw.size   = m_axi_awsize;
  assign  debug_axi_s_req.aw.burst  = m_axi_awburst;
  assign  debug_axi_s_req.aw.lock   = m_axi_awlock;
  assign  debug_axi_s_req.aw.cache  = m_axi_awcache;
  assign  debug_axi_s_req.aw.prot   = m_axi_awprot;
  assign  debug_axi_s_req.aw.qos    = m_axi_awqos;
  assign  debug_axi_s_req.aw_valid  = m_axi_awvalid;
  assign  debug_axi_s_req.w.data    = m_axi_wdata;
  assign  debug_axi_s_req.w.strb    = m_axi_wstrb;
  assign  debug_axi_s_req.w.last    = m_axi_wlast;
  assign  debug_axi_s_req.w_valid   = m_axi_wvalid;
  assign  debug_axi_s_req.b_ready   = m_axi_bready;
  assign  debug_axi_s_req.ar.id     = m_axi_arid;
  assign  debug_axi_s_req.ar.addr   = m_axi_araddr;
  assign  debug_axi_s_req.ar.len    = m_axi_arlen;
  assign  debug_axi_s_req.ar.size   = m_axi_arsize;
  assign  debug_axi_s_req.ar.burst  = m_axi_arburst;
  assign  debug_axi_s_req.ar.lock   = m_axi_arlock;
  assign  debug_axi_s_req.ar.cache  = m_axi_arcache;
  assign  debug_axi_s_req.ar.prot   = m_axi_arprot;
  assign  debug_axi_s_req.ar.qos    = m_axi_arqos;
  assign  debug_axi_s_req.ar_valid  = m_axi_arvalid;
  assign  debug_axi_s_req.r_ready   = m_axi_rready;

  assign debug_axi_s_req.aw.region = '0;
  assign debug_axi_s_req.aw.atop   = '0;
  assign debug_axi_s_req.aw.user   = '0;
  assign debug_axi_s_req.w.user    = '0;
  assign debug_axi_s_req.ar.region = '0;
  assign debug_axi_s_req.ar.user   = '0;


  // connect DEBUG SYSTEM AXI to AXI BRAM
  // dm -> bram
  assign s_axi_awid    = debug_axi_m_req.aw.id;
  assign s_axi_awaddr  = debug_axi_m_req.aw.addr;
  assign s_axi_awlen   = debug_axi_m_req.aw.len;
  assign s_axi_awsize  = debug_axi_m_req.aw.size;
  assign s_axi_awburst = debug_axi_m_req.aw.burst;
  assign s_axi_awlock  = debug_axi_m_req.aw.lock;
  assign s_axi_awcache = debug_axi_m_req.aw.cache;
  assign s_axi_awprot  = debug_axi_m_req.aw.prot;
  assign s_axi_awvalid = debug_axi_m_req.aw_valid;
  assign s_axi_wdata   = debug_axi_m_req.w.data;
  assign s_axi_wstrb   = debug_axi_m_req.w.strb;
  assign s_axi_wlast   = debug_axi_m_req.w.last;
  assign s_axi_wvalid  = debug_axi_m_req.w_valid;
  assign s_axi_bready  = debug_axi_m_req.b_ready;
  assign s_axi_arid    = debug_axi_m_req.ar.id;
  assign s_axi_araddr  = debug_axi_m_req.ar.addr;
  assign s_axi_arlen   = debug_axi_m_req.ar.len;
  assign s_axi_arsize  = debug_axi_m_req.ar.size;
  assign s_axi_arburst = debug_axi_m_req.ar.burst;
  assign s_axi_arlock  = debug_axi_m_req.ar.lock;
  assign s_axi_arcache = debug_axi_m_req.ar.cache;
  assign s_axi_arprot  = debug_axi_m_req.ar.prot;
  assign s_axi_arvalid = debug_axi_m_req.ar_valid;
  assign s_axi_rready  = debug_axi_m_req.r_ready;
  // bram -> dm
  assign debug_axi_m_resp.aw_ready = s_axi_awready;
  assign debug_axi_m_resp.w_ready  = s_axi_wready;
  assign debug_axi_m_resp.b.id     = s_axi_bid;
  assign debug_axi_m_resp.b.resp   = s_axi_bresp;
  assign debug_axi_m_resp.b_valid  = s_axi_bvalid;
  assign debug_axi_m_resp.ar_ready = s_axi_arready;
  assign debug_axi_m_resp.r.id     = s_axi_rid;
  assign debug_axi_m_resp.r.data   = s_axi_rdata;
  assign debug_axi_m_resp.r.resp   = s_axi_rresp;
  assign debug_axi_m_resp.r.last   = s_axi_rlast;
  assign debug_axi_m_resp.r_valid  = s_axi_rvalid;

  assign debug_axi_m_resp.b.user = '0;
  assign debug_axi_m_resp.r.user = '0;

/**** DEBUG SYSTEM ****/
  debug_system i_debug_system (
    .clk_i              ( clk_20MHz_s       ),
    .rstn_i             ( int_rstn_s        ),
    .debug_axi_s_req_i  ( debug_axi_s_req   ),
    .debug_axi_s_resp_o ( debug_axi_s_resp  ),
    .debug_axi_m_resp_i ( debug_axi_m_resp  ),
    .debug_axi_m_req_o  ( debug_axi_m_req   ),
    .debug_req_irq_o    ( debug_req_irq_o   ),
    .jtag_tck_i         ( jtag_tck_i        ),
    .jtag_tms_i         ( jtag_tms_i        ),
    .jtag_trstn_i       ( jtag_trstn_s      ),
    .jtag_tdi_i         ( jtag_tdi_i        ),
    .jtag_tdo_o         ( jtag_tdo_o        )
  );

/**** XILINX IPs ****/

// CLOCK GEN
  clk_gen i_clk_gen (
    .clk_out1  ( clk_20MHz_s ),
    .locked    ( locked_s    ),
    .clk_in1_p ( clk_p_i     ),
    .clk_in1_n ( clk_n_i     )
  );

// AXI JTAG IP
  jtag_axi i_jtag_axi (
    .aclk          ( clk_20MHz_s   ), // input wire aclk
    .aresetn       ( int_rstn_s    ), // input wire aresetn
    .m_axi_awid    ( m_axi_awid    ), // output wire [0 : 0] m_axi_awid
    .m_axi_awaddr  ( m_axi_awaddr  ), // output wire [63 : 0] m_axi_awaddr
    .m_axi_awlen   ( m_axi_awlen   ), // output wire [7 : 0] m_axi_awlen
    .m_axi_awsize  ( m_axi_awsize  ), // output wire [2 : 0] m_axi_awsize
    .m_axi_awburst ( m_axi_awburst ), // output wire [1 : 0] m_axi_awburst
    .m_axi_awlock  ( m_axi_awlock  ), // output wire m_axi_awlock
    .m_axi_awcache ( m_axi_awcache ), // output wire [3 : 0] m_axi_awcache
    .m_axi_awprot  ( m_axi_awprot  ), // output wire [2 : 0] m_axi_awprot
    .m_axi_awqos   ( m_axi_awqos   ), // output wire [3 : 0] m_axi_awqos
    .m_axi_awvalid ( m_axi_awvalid ), // output wire m_axi_awvalid
    .m_axi_awready ( m_axi_awready ), // input wire m_axi_awready
    .m_axi_wdata   ( m_axi_wdata   ), // output wire [63 : 0] m_axi_wdata
    .m_axi_wstrb   ( m_axi_wstrb   ), // output wire [7 : 0] m_axi_wstrb
    .m_axi_wlast   ( m_axi_wlast   ), // output wire m_axi_wlast
    .m_axi_wvalid  ( m_axi_wvalid  ), // output wire m_axi_wvalid
    .m_axi_wready  ( m_axi_wready  ), // input wire m_axi_wready
    .m_axi_bid     ( m_axi_bid     ), // input wire [0 : 0] m_axi_bid
    .m_axi_bresp   ( m_axi_bresp   ), // input wire [1 : 0] m_axi_bresp
    .m_axi_bvalid  ( m_axi_bvalid  ), // input wire m_axi_bvalid
    .m_axi_bready  ( m_axi_bready  ), // output wire m_axi_bready
    .m_axi_arid    ( m_axi_arid    ), // output wire [0 : 0] m_axi_arid
    .m_axi_araddr  ( m_axi_araddr  ), // output wire [63 : 0] m_axi_araddr
    .m_axi_arlen   ( m_axi_arlen   ), // output wire [7 : 0] m_axi_arlen
    .m_axi_arsize  ( m_axi_arsize  ), // output wire [2 : 0] m_axi_arsize
    .m_axi_arburst ( m_axi_arburst ), // output wire [1 : 0] m_axi_arburst
    .m_axi_arlock  ( m_axi_arlock  ), // output wire m_axi_arlock
    .m_axi_arcache ( m_axi_arcache ), // output wire [3 : 0] m_axi_arcache
    .m_axi_arprot  ( m_axi_arprot  ), // output wire [2 : 0] m_axi_arprot
    .m_axi_arqos   ( m_axi_arqos   ), // output wire [3 : 0] m_axi_arqos
    .m_axi_arvalid ( m_axi_arvalid ), // output wire m_axi_arvalid
    .m_axi_arready ( m_axi_arready ), // input wire m_axi_arready
    .m_axi_rid     ( m_axi_rid     ), // input wire [0 : 0] m_axi_rid
    .m_axi_rdata   ( m_axi_rdata   ), // input wire [63 : 0] m_axi_rdata
    .m_axi_rresp   ( m_axi_rresp   ), // input wire [1 : 0] m_axi_rresp
    .m_axi_rlast   ( m_axi_rlast   ), // input wire m_axi_rlast
    .m_axi_rvalid  ( m_axi_rvalid  ), // input wire m_axi_rvalid
    .m_axi_rready  ( m_axi_rready  )  // output wire m_axi_rready
  );

  // AXI BRAM
  axi_bram i_axi_bram (
    .s_axi_aclk    ( clk_20MHz_s   ), // input wire s_axi_aclk
    .s_axi_aresetn ( int_rstn_s    ), // input wire s_axi_aresetn
    .s_axi_awid    ( s_axi_awid    ), // input wire [0 : 0] s_axi_awid
    .s_axi_awaddr  ( s_axi_awaddr  ), // input wire [12 : 0] s_axi_awaddr
    .s_axi_awlen   ( s_axi_awlen   ), // input wire [7 : 0] s_axi_awlen
    .s_axi_awsize  ( s_axi_awsize  ), // input wire [2 : 0] s_axi_awsize
    .s_axi_awburst ( s_axi_awburst ), // input wire [1 : 0] s_axi_awburst
    .s_axi_awlock  ( s_axi_awlock  ), // input wire s_axi_awlock
    .s_axi_awcache ( s_axi_awcache ), // input wire [3 : 0] s_axi_awcache
    .s_axi_awprot  ( s_axi_awprot  ), // input wire [2 : 0] s_axi_awprot
    .s_axi_awvalid ( s_axi_awvalid ), // input wire s_axi_awvalid
    .s_axi_awready ( s_axi_awready ), // output wire s_axi_awready
    .s_axi_wdata   ( s_axi_wdata   ), // input wire [63 : 0] s_axi_wdata
    .s_axi_wstrb   ( s_axi_wstrb   ), // input wire [7 : 0] s_axi_wstrb
    .s_axi_wlast   ( s_axi_wlast   ), // input wire s_axi_wlast
    .s_axi_wvalid  ( s_axi_wvalid  ), // input wire s_axi_wvalid
    .s_axi_wready  ( s_axi_wready  ), // output wire s_axi_wready
    .s_axi_bid     ( s_axi_bid     ), // output wire [0 : 0] s_axi_bid
    .s_axi_bresp   ( s_axi_bresp   ), // output wire [1 : 0] s_axi_bresp
    .s_axi_bvalid  ( s_axi_bvalid  ), // output wire s_axi_bvalid
    .s_axi_bready  ( s_axi_bready  ), // input wire s_axi_bready
    .s_axi_arid    ( s_axi_arid    ), // input wire [0 : 0] s_axi_arid
    .s_axi_araddr  ( s_axi_araddr  ), // input wire [12 : 0] s_axi_araddr
    .s_axi_arlen   ( s_axi_arlen   ), // input wire [7 : 0] s_axi_arlen
    .s_axi_arsize  ( s_axi_arsize  ), // input wire [2 : 0] s_axi_arsize
    .s_axi_arburst ( s_axi_arburst ), // input wire [1 : 0] s_axi_arburst
    .s_axi_arlock  ( s_axi_arlock  ), // input wire s_axi_arlock
    .s_axi_arcache ( s_axi_arcache ), // input wire [3 : 0] s_axi_arcache
    .s_axi_arprot  ( s_axi_arprot  ), // input wire [2 : 0] s_axi_arprot
    .s_axi_arvalid ( s_axi_arvalid ), // input wire s_axi_arvalid
    .s_axi_arready ( s_axi_arready ), // output wire s_axi_arready
    .s_axi_rid     ( s_axi_rid     ), // output wire [0 : 0] s_axi_rid
    .s_axi_rdata   ( s_axi_rdata   ), // output wire [63 : 0] s_axi_rdata
    .s_axi_rresp   ( s_axi_rresp   ), // output wire [1 : 0] s_axi_rresp
    .s_axi_rlast   ( s_axi_rlast   ), // output wire s_axi_rlast
    .s_axi_rvalid  ( s_axi_rvalid  ), // output wire s_axi_rvalid
    .s_axi_rready  ( s_axi_rready  )  // input wire s_axi_rready
  );

endmodule
