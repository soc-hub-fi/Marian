//------------------------------------------------------------------------------
// Module   : clint_wrapper
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
//            Endrit Isufi   <endrit.isufi@tuni.fi>
// Created  : 07-jun-2024
//
// Description: Wrapper to contain CLINT and required protocol conversion modules
//
// Parameters:
//  - NB_CORES   : Number of cores using CLINT
//
// Inputs:
//  - clk_i: Clock
//  - rst_ni:  Asynchronous active-low reset
//  - soc_axi_req_i: AXI from xbar
//
// Outputs:
//  - timer_irq     : Timer interrupts routed towards core
//  - ipi_o         : Software interrupt (== inter-process-interrupt)
//  - soc_axi_resp_o: AXI to xbar
//
// Revision History:
//  - Version 1.0: Initial release
//  - Version 1.1: Switch to AXI-Lite port definition
//
//------------------------------------------------------------------------------

`include "axi/assign.svh"


module clint_wrapper import marian_pkg::*; #(
  parameter int unsigned NR_CORES   = 1
)(
input  logic          clk_i,
input  logic          rst_ni,
// clint timer outputs
output logic [NR_CORES-1:0] timer_irq,
output logic [NR_CORES-1:0] ipi_o,
//AXI-lite  interface
input  periph_wide_lite_req_t  clint_lite_req,
output periph_wide_lite_resp_t clint_lite_resp
);

/***********
 * SIGNALS *
 ***********/
logic              rtc_clk;
ariane_axi::req_t  clint_ariane_req;
ariane_axi::resp_t clint_ariane_resp;



/***************
 * Assignments *
 ***************/
  // clint_lite_resp  <-- clint_ariane_resp

 assign  clint_lite_resp.aw_ready   = clint_ariane_resp.aw_ready;
 assign  clint_lite_resp.ar_ready   = clint_ariane_resp.ar_ready;
 assign  clint_lite_resp.w_ready    = clint_ariane_resp.w_ready ;
 assign  clint_lite_resp.b_valid    = clint_ariane_resp.b_valid ;
 assign  clint_lite_resp.b.resp     = clint_ariane_resp.b.resp  ;
 assign  clint_lite_resp.r_valid    = clint_ariane_resp.r_valid ;
 assign  clint_lite_resp.r.data     = clint_ariane_resp.r.data  ;
 assign  clint_lite_resp.r.resp     = clint_ariane_resp.r.resp  ;

 // clint_ariane_req  <-- clint_lite_req

 assign clint_ariane_req.aw.id     = '0;
 assign clint_ariane_req.aw.addr   = clint_lite_req.aw.addr;
 assign clint_ariane_req.aw.len    = '0;
 assign clint_ariane_req.aw.size   = '0;
 assign clint_ariane_req.aw.burst  = '0;
 assign clint_ariane_req.aw.lock   = '0;
 assign clint_ariane_req.aw.cache  = '0;
 assign clint_ariane_req.aw.prot   = clint_lite_req.aw.prot;
 assign clint_ariane_req.aw.qos    = '0;
 assign clint_ariane_req.aw.region = '0;
 assign clint_ariane_req.aw.atop   = '0;
 assign clint_ariane_req.aw.user   = '0;
 assign clint_ariane_req.aw_valid  = clint_lite_req.aw_valid;
 assign clint_ariane_req.w.data    = clint_lite_req.w.data;
 assign clint_ariane_req.w.strb    = clint_lite_req.w.strb;
 assign clint_ariane_req.w.last    = '0;
 assign clint_ariane_req.w.user    = '0;
 assign clint_ariane_req.w_valid   = clint_lite_req.w_valid;
 assign clint_ariane_req.b_ready   = clint_lite_req.b_ready;
 assign clint_ariane_req.ar.id     = '0;
 assign clint_ariane_req.ar.addr   = clint_lite_req.ar.addr;
 assign clint_ariane_req.ar.len    = '0;
 assign clint_ariane_req.ar.size   = '0;
 assign clint_ariane_req.ar.burst  = '0;
 assign clint_ariane_req.ar.lock   = '0;
 assign clint_ariane_req.ar.cache  = '0;
 assign clint_ariane_req.ar.prot   = clint_lite_req.ar.prot;
 assign clint_ariane_req.ar.qos    = '0;
 assign clint_ariane_req.ar.region = '0;
 assign clint_ariane_req.ar.user   = '0;
 assign clint_ariane_req.ar_valid  = clint_lite_req.ar_valid;
 assign clint_ariane_req.r_ready   = clint_lite_req.r_ready;

// RTC generator
rtc_generator i_rtc_generator
(
 .refclk    (clk_i   ),
 .refrstn   (rst_ni  ),
 .rtc_clk_o (rtc_clk )
 );

clint #(
 .AXI_ADDR_WIDTH ( AxiAddrWidth      ),
 .AXI_DATA_WIDTH ( CLINTDataWidth    ),
 .AXI_ID_WIDTH   ( CLINTIdWidth      ),
 .NR_CORES       ( NR_CORES          ) 
) i_clint (
 .clk_i       ( clk_i                        ),
 .rst_ni      ( rst_ni                       ),
 .testmode_i  ( '0                           ),
 .axi_req_i   ( clint_ariane_req             ),
 .axi_resp_o  ( clint_ariane_resp            ),
 .rtc_i       ( rtc_clk                      ),
 .timer_irq_o ( timer_irq                    ),
 .ipi_o       ( ipi_o                        ) 
);


endmodule
