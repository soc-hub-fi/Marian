//------------------------------------------------------------------------------
// Module   : plic_wrapper
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
//            Endrit Isufi   <endrit.isufi@tuni.fi>
// Created  : 07-jun-2024
// Updated  : 26-jun-2024
//
// Description: Wrapper to contain PLIC and required protocol conversion modules
//
// Parameters:
//  - NB_EXT_IRQ : Number of external interrupts
//  - NB_CORES   : Number of cores using PLIC
//
// Inputs:
//  - clk_i: Clock
//  - rst_ni:  Asynchronous active-low reset
//  - ext_irq_i: External interrupts routed to PLIC
//  - soc_axi_req_i: AXI from xbar
//
// Outputs:
//  - irq_o: IPI interrupts routed towards core
//  - soc_axi_resp_o: AXI to xbar
//
// Revision History:
//  - Version 1.0: Initial release
//  - Version 1.1: Updated port list to match Kactus2 generated wrapper signals
//                 [tzs:24-apr-2024]
//
//------------------------------------------------------------------------------

`include "register_interface/typedef.svh"
module plic_wrapper
  import marian_pkg::*;
#(
  parameter int unsigned NB_EXT_IRQ = 1,
  parameter int unsigned NB_CORES   = 1
)(
  input  logic                  clk_i,
  input  logic                  rst_ni,
  // irqs
  input  logic [NB_EXT_IRQ-1:0] ext_irq_i,
  output logic [2*NB_CORES-1:0] irq_o,

  input  logic [PeriphAddrWidth-1:0] paddr_i,
  input  logic               [31:0] pwdata_i,
  input  logic                      pwrite_i,
  input  logic                      psel_i,
  input  logic                      penable_i,
  output logic               [31:0] prdata_o,
  output logic                      pready_o,
  output logic                      pslverr_o
);

  /*************
   * CONSTANTS *
   *************/

  // bit width of PLIC register interface
  localparam integer unsigned PLICRegDataWidth = 64;

  /***********
   * SIGNALS *
   ***********/
   plic_reg_req_t plic_req;
   plic_reg_rsp_t plic_resp;

  /**************************
   * Conversion to reg type *
   **************************/

   REG_BUS #(
    .ADDR_WIDTH ( 64 ),
    .DATA_WIDTH ( 32 )
   ) reg_bus (clk_i);

   apb_to_reg i_apb_to_reg (
    .clk_i        (clk_i    ),
    .rst_ni       (rst_ni   ),
  
    .penable_i    (penable_i    ),
    .pwrite_i     (pwrite_i     ),
    .paddr_i      (paddr_i[31:0]), //defined as only 32-bits
    .psel_i       (psel_i       ),
    .pwdata_i     (pwdata_i     ),
    .prdata_o     (prdata_o     ),
    .pready_o     (pready_o     ),
    .pslverr_o    (pslverr_o    ),
  
    .reg_o        (reg_bus)
  );

  assign plic_req.addr  = reg_bus.addr;
  assign plic_req.write = reg_bus.write;
  assign plic_req.wdata = reg_bus.wdata;
  assign plic_req.wstrb = reg_bus.wstrb;
  assign plic_req.valid = reg_bus.valid;

  assign reg_bus.rdata = plic_resp.rdata;
  assign reg_bus.error = plic_resp.error;
  assign reg_bus.ready = plic_resp.ready;

  plic_top #(
    .N_SOURCE  ( NB_EXT_IRQ              ),
    .N_TARGET  ( 2                       ), /* M-Mode Hart, S-Mode Hart */
    .MAX_PRIO  (7                        ),
    .reg_req_t (plic_reg_req_t           ),
    .reg_rsp_t (plic_reg_rsp_t           )
  ) i_plic_top (
    .clk_i         ( clk_i           ),
    .rst_ni        ( rst_ni          ),
    .req_i         ( plic_req        ),
    .resp_o        ( plic_resp       ),
    .le_i          ( '0              ), /* 0 - level sensitive, 1 - edge sensitive */
    .irq_sources_i ( ext_irq_i       ),
    .eip_targets_o ( irq_o           )
  );

endmodule
