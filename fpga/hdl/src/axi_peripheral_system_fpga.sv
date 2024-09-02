//------------------------------------------------------------------------------
// Module   : axi_peripheral_system_fpga
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 19-jan-2024
//
// Description: Contains AXI conversion and Marian peripheral components.
// Used for Marian FPGA prototyping.
//
// Parameters:
//  - None
//
// Inputs:
//  - clk_i: Clock
//  - rst_ni Asynchronous active-low reset
//  - uart_s_axi_req_i: 128b AXI request lines from xbar (M) to UART (S)
//  - qspi_s_axi_req_i: 128b AXI request lines from xbar (M) to QSPI (S)
//  - gpio_s_axi_req_i: 128b AXI request lines from xbar (M) to GPIO (S)
//  - timer_s_axi_req_i: 128b AXI request lines from xbar (M) to HW Timer (S)
//  - uart_rx_i: UART Rx
//
// Outputs:
//  - uart_s_axi_resp_o: 128b AXI response from UART (S) to xbar (M)
//  - qspi_s_axi_resp_o: 128b AXI response from QSPI (S) to xbar (M)
//  - gpio_s_axi_resp_o: 128b AXI response from GPIO (S) to xbar (M)
//  - timer_s_axi_resp_o: 128b AXI response from HW Timer (S) to xbar (M)
//  - uart_tx_o: UART Tx
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

import marian_fpga_pkg::*;

module axi_peripheral_system_fpga (
  input logic clk_i,
  input logic rstn_i,
  // axi signals from xbar
  // uart
  input  system_req_t  system_uart_s_axi_req_i,
  output system_resp_t system_uart_s_axi_resp_o,
  // qspi
  input  system_req_t  system_qspi_s_axi_req_i,
  output system_resp_t system_qspi_s_axi_resp_o,
  // gpio
  input  system_req_t  system_gpio_s_axi_req_i,
  output system_resp_t system_gpio_s_axi_resp_o,
  // timer
  input  system_req_t  system_timer_s_axi_req_i,
  output system_resp_t system_timer_s_axi_resp_o,
  // functional signals from peripherals
  // UART
  input  logic uart_rx_i,
  output logic uart_tx_o
);

  /***********
   * Signals *
   ***********/

  // uart axi
  periph_resp_t      uart_axi_resp;
  periph_req_t       uart_axi_req;
  periph_lite_resp_t uart_lite_resp;
  periph_lite_req_t  uart_lite_req;

  // qspi axi
  periph_resp_t      qspi_axi_resp;
  periph_req_t       qspi_axi_req;

  // gpio axi
  periph_resp_t      gpio_axi_resp;
  periph_req_t       gpio_axi_req;
  periph_lite_resp_t gpio_lite_resp;
  periph_lite_req_t  gpio_lite_req;


  // timer axi
  periph_resp_t      timer_axi_resp;
  periph_req_t       timer_axi_req;
  periph_lite_resp_t timer_lite_resp;
  periph_lite_req_t  timer_lite_req;


  /********
   * UART *
   ********/

  axi_dw_conv_down_periph_wrapper i_uart_axi_downsizer (
    .clk_i         ( clk_i                    ),
    .rstn_i        ( rstn_i                   ),
    .system_req_i  ( system_uart_s_axi_req_i  ),
    .system_resp_o ( system_uart_s_axi_resp_o ),
    .periph_resp_i ( uart_axi_resp            ),
    .periph_req_o  ( uart_axi_req             )
  );

  axi_to_axi_lite_periph_wrapper i_uart_axi_to_axi_lite (
    .clk_i              ( clk_i          ),
    .rstn_i             ( rstn_i         ),
    .periph_req_i       ( uart_axi_req   ),
    .periph_resp_o      ( uart_axi_resp  ),
    .periph_lite_resp_i ( uart_lite_resp ),
    .periph_lite_req_o  ( uart_lite_req  )
  );

`ifndef XSIM

  axi_uart_wrapper i_axi_uart (
    .clk_i              ( clk_i          ),
    .rstn_i             ( rstn_i         ),
    .periph_lite_req_i  ( uart_lite_req  ),
    .periph_lite_resp_o ( uart_lite_resp ),
    .uart_rx_i          ( uart_rx_i      ),
    .uart_tx_o          ( uart_tx_o      )
  );

`else

  uart_apb_req_t   uart_apb_req;
  uart_apb_resp_t  uart_apb_resp;

  typedef struct packed {
    int unsigned idx;
    axi_addr_t   start_addr;
    axi_addr_t   end_addr;
  } uart_apb_rule_t;

  uart_apb_rule_t uart_apb_map;

  assign uart_apb_map = '{idx: 0, start_addr: '0, end_addr: '1};

  axi_lite_to_apb #(
    .NoApbSlaves      ( 32'd1              ),
    .NoRules          ( 32'd1              ),
    .AddrWidth        ( AxiAddrWidth       ),
    .DataWidth        ( 32'd32             ),
    .PipelineRequest  ( 1'b0               ),
    .PipelineResponse ( 1'b0               ),
    .axi_lite_req_t   ( periph_lite_req_t  ),
    .axi_lite_resp_t  ( periph_lite_resp_t ),
    .apb_req_t        ( uart_apb_req_t     ),
    .apb_resp_t       ( uart_apb_resp_t    ),
    .rule_t           ( uart_apb_rule_t    )
  ) i_axi_lite_to_apb_uart (
    .clk_i           ( clk_i          ),
    .rst_ni          ( rstn_i         ),
    .axi_lite_req_i  ( uart_lite_req  ),
    .axi_lite_resp_o ( uart_lite_resp ),
    .apb_req_o       ( uart_apb_req   ),
    .apb_resp_i      ( uart_apb_resp  ),
    .addr_map_i      ( uart_apb_map   )
  );

  mock_uart i_mock_apb_uart (
    .clk_i     ( clk_i                    ),
    .rst_ni    ( rstn_i                   ),
    .penable_i ( uart_apb_req.penable     ),
    .pwrite_i  ( uart_apb_req.pwrite      ),
    .paddr_i   ( uart_apb_req.paddr[31:0] ),
    .psel_i    ( uart_apb_req.psel        ),
    .pwdata_i  ( uart_apb_req.pwdata      ),
    .prdata_o  ( uart_apb_resp.prdata     ),
    .pready_o  ( uart_apb_resp.pready     ),
    .pslverr_o ( uart_apb_resp.pslverr    )
  );

  assign uart_tx_o = 1'b0;

`endif


  /********
   * QSPI *
   ********/

   assign system_qspi_s_axi_resp_o = '0;

  /********
   * GPIO *
   ********/

   assign system_gpio_s_axi_resp_o = '0;

  /*********
   * TIMER *
   *********/

   assign system_timer_s_axi_resp_o = '0;

endmodule
