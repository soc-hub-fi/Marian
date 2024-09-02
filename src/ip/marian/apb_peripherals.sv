//------------------------------------------------------------------------------
// Module   : apb_peripherals
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Endrit Isufi   <endrit.isufi@tuni.fi>
//            Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 25-June-2024
//
// Description: Marian Peripherals with 32-bit APB interface
//------------------------------------------------------------------------------
// Parameters:
//
// Inputs:
//  - clk_i: Clock in
//  - rst_ni: Asynchronous active-low reset
//  - periph_wide_axi_req_i: AXI bus request channel
//  - marian_uart_rx_i: UART receiver input
//  - marian_qspi_data_i:  Quad SPI data in
//  - marian_gpio_i: GPIO inputs
//  - ext_irq_i: external interrupts
// Outputs:
//  - periph_wide_axi_resp_o: AXI bus response channel
//  - marian_uart_tx_o: UART transmitter output
//  - marian_qspi_csn_o: Quad SPI chip-select
//  - marian_qspi_data_o: Quad SPI data out
//  - spi_mode_o: SPI mode to configure IO pads
//  - marian_gpio_o: GPIO outputs 
//  - marian_gpio_oe: GPIO Output enable
//  - plic_irq_o:  IRQs from PLIC
//
// Revision History:
//  - Version 1.0: Initial release
//  - Version 1.1: Adding AXI cut to ease timing and updated documentation
//                 [TZS:07-jul-2024]
//
//------------------------------------------------------------------------------


module apb_peripherals import marian_pkg::*; (
    input  logic              clk_i,
    input  logic              rst_ni,
    input  soc_wide_req_t     periph_wide_axi_req_i,
    output soc_wide_resp_t    periph_wide_axi_resp_o,
    //UART
    input  logic marian_uart_rx_i,
    output logic marian_uart_tx_o,
    //QSPI
    input  logic [3:0]  marian_qspi_data_i,
    output logic        marian_qspi_csn_o,
    output logic [3:0]  marian_qspi_data_o,
    output logic        marian_qspi_sclk_o,
    output logic [1:0]  spi_mode_o,
    // GPIO
    input  logic [1:0]  marian_gpio_i,
    output logic [1:0]  marian_gpio_o,
    output logic [1:0]  marian_gpio_oe,
    //PLIC
    input  logic                  ext_irq_i,
    output logic [2*NB_CORES-1:0] plic_irq_o
  );

  periph_axi_narrow_req_t   periph_axi_req, periph_axi_cut_req;
  periph_axi_narrow_resp_t  periph_axi_resp, periph_axi_cut_resp;
  periph_narrow_lite_req_t  periph_axi_lite_req;
  periph_narrow_lite_resp_t periph_axi_lite_resp;
  periph_apb_req_t          periph_apb_req;
  periph_apb_resp_t         periph_apb_resp;

  /*APB BUS*/
  logic [NrPeriphApbMasters-1:0] 			                      penable;
  logic [NrPeriphApbMasters-1:0] 			                      pwrite;
  logic [NrPeriphApbMasters-1:0][PeriphAddrWidth-1:0]       paddr;
  logic [NrPeriphApbMasters-1:0] 			                      psel;
  logic [NrPeriphApbMasters-1:0][PeriphNarrowDataWidth-1:0] pwdata;
  logic [NrPeriphApbMasters-1:0][PeriphNarrowDataWidth-1:0] prdata;
  logic [NrPeriphApbMasters-1:0] 			                      pready;
  logic [NrPeriphApbMasters-1:0] 			                      pslverr;

  // CONFIGURATION PORT
  logic [NrPeriphApbMasters-1:0][PeriphAddrWidth-1:0]  START_ADDR_i;
  logic [NrPeriphApbMasters-1:0][PeriphAddrWidth-1:0]  END_ADDR_i;

  logic [NumExternalIRQ-1:0] irq_s;
  logic [             2-1:0] spi_events_s;
  logic                      uart_events_s;
  logic                      gpio_events_s;
  logic [             2-1:0] timer_events_s;

  assign START_ADDR_i[UART_M] = UARTBase;
  assign START_ADDR_i[QSPI_M] = QSPIBase;
  assign START_ADDR_i[TIMR_M] = TIMRBase;
  assign START_ADDR_i[GPIO_M] = GPIOBase;
  assign START_ADDR_i[PLIC_M] = PLICBase;

  assign END_ADDR_i[UART_M] = UARTBase  +  UARTLength;
  assign END_ADDR_i[QSPI_M] = QSPIBase  +  QSPILength;
  assign END_ADDR_i[TIMR_M] = TIMRBase  +  TIMRLength;
  assign END_ADDR_i[GPIO_M] = GPIOBase  +  GPIOLength;
  assign END_ADDR_i[PLIC_M] = PLICBase  +  PLICLength;

  // combine all IRQ sources
  assign irq_s = {ext_irq_i, gpio_events_s, spi_events_s, uart_events_s, timer_events_s};

  typedef struct packed {
    int unsigned idx;
    axi_addr_t   start_addr;
    axi_addr_t   end_addr;
  } periph_apb_rule_t;

  periph_apb_rule_t periph_apb_map;
  assign periph_apb_map = '{idx: 0, start_addr: '0, end_addr: '1}; //all transactions to apb_node

  //128b -> 32b
  axi_dw_converter #(
    .AxiSlvPortDataWidth ( AxiWideDataWidth           ),
    .AxiMstPortDataWidth ( PeriphNarrowDataWidth      ),
    .AxiAddrWidth        ( AxiAddrWidth               ),
    .AxiIdWidth          ( AxiSocIdWidth              ),
    .AxiMaxReads         ( 10                          ),
    .ar_chan_t           ( soc_wide_ar_chan_t         ),
    .mst_r_chan_t        ( periph_axi_narrow_r_chan_t ),
    .slv_r_chan_t        ( soc_wide_r_chan_t          ),
    .aw_chan_t           ( periph_axi_narrow_aw_chan_t),
    .b_chan_t            ( soc_wide_b_chan_t          ),
    .mst_w_chan_t        ( periph_axi_narrow_w_chan_t ),
    .slv_w_chan_t        ( soc_wide_w_chan_t          ),
    .axi_mst_req_t       ( periph_axi_narrow_req_t    ),
    .axi_mst_resp_t      ( periph_axi_narrow_resp_t   ),
    .axi_slv_req_t       ( soc_wide_req_t             ),
    .axi_slv_resp_t      ( soc_wide_resp_t            )
  ) i_axi_slave_periph_dwc (
    .clk_i      ( clk_i                 ),
    .rst_ni     ( rst_ni                ),
    .slv_req_i  ( periph_wide_axi_req_i ),
    .slv_resp_o ( periph_wide_axi_resp_o),
    .mst_req_o  ( periph_axi_req        ),
    .mst_resp_i ( periph_axi_resp       )
  );

  axi_multicut #(
    .NoCuts     ( 1                           ),
    .aw_chan_t  ( periph_axi_narrow_aw_chan_t ),
    .w_chan_t   ( periph_axi_narrow_w_chan_t  ),
    .b_chan_t   ( periph_axi_narrow_b_chan_t  ),
    .ar_chan_t  ( periph_axi_narrow_ar_chan_t ),
    .r_chan_t   ( periph_axi_narrow_r_chan_t  ),
    .axi_req_t  ( periph_axi_narrow_req_t     ),
    .axi_resp_t ( periph_axi_narrow_resp_t    )
  ) i_axi_multicut (
    .clk_i      ( clk_i               ),
    .rst_ni     ( rst_ni              ),
    .slv_req_i  ( periph_axi_req      ),
    .slv_resp_o ( periph_axi_resp     ),
    .mst_req_o  ( periph_axi_cut_req  ),
    .mst_resp_i ( periph_axi_cut_resp )
  );

  //axi to axi lite
  axi_to_axi_lite #(
    .AxiAddrWidth    ( AxiAddrWidth              ),
    .AxiDataWidth    ( PeriphNarrowDataWidth     ),
    .AxiIdWidth      ( AxiSocIdWidth             ),
    .AxiUserWidth    ( AxiUserWidth              ),
    .AxiMaxWriteTxns ( 10                        ),
    .AxiMaxReadTxns  ( 10                        ),
    .FallThrough     ( 1'b0                      ),
    .full_req_t      ( periph_axi_narrow_req_t   ),
    .full_resp_t     ( periph_axi_narrow_resp_t  ),
    .lite_req_t      ( periph_narrow_lite_req_t  ),
    .lite_resp_t     ( periph_narrow_lite_resp_t )
  ) i_axi_to_axi_lite_periph (
    .clk_i      ( clk_i                ),
    .rst_ni     ( rst_ni               ),
    .test_i     ( 1'b0                 ),
    .slv_req_i  ( periph_axi_cut_req   ),
    .slv_resp_o ( periph_axi_cut_resp  ),
    .mst_req_o  ( periph_axi_lite_req  ),
    .mst_resp_i ( periph_axi_lite_resp )
  );
  //lite to apb
  axi_lite_to_apb #(
    .NoApbSlaves      ( 32'd1                    ),
    .NoRules          ( 32'd1                    ),
    .AddrWidth        ( PeriphAddrWidth          ),
    .DataWidth        ( PeriphNarrowDataWidth    ),
    .PipelineRequest  ( 1'b0                     ),
    .PipelineResponse ( 1'b0                     ),
    .axi_lite_req_t   ( periph_narrow_lite_req_t ),
    .axi_lite_resp_t  ( periph_narrow_lite_resp_t),
    .apb_req_t        ( periph_apb_req_t         ),
    .apb_resp_t       ( periph_apb_resp_t        ),
    .rule_t           ( periph_apb_rule_t        )
  ) i_axi_lite_to_apb_periph (
    .clk_i           ( clk_i                ),
    .rst_ni          ( rst_ni               ),
    .axi_lite_req_i  ( periph_axi_lite_req  ),
    .axi_lite_resp_o ( periph_axi_lite_resp ),
    .apb_req_o       ( periph_apb_req       ),
    .apb_resp_i      ( periph_apb_resp      ),
    .addr_map_i      ( periph_apb_map       )
  );
  //apb node
  apb_node #(
    .NB_MASTER      ( NrPeriphApbMasters    ),
    .APB_DATA_WIDTH ( PeriphNarrowDataWidth ),
    .APB_ADDR_WIDTH ( PeriphAddrWidth       )
  )i_apb_node(
    // SLAVE PORT
    .penable_i                  (periph_apb_req.penable ),
    .pwrite_i                   (periph_apb_req.pwrite  ),
    .paddr_i                    (periph_apb_req.paddr   ),
    .psel_i                     (periph_apb_req.psel    ),
    .pwdata_i                   (periph_apb_req.pwdata  ),
    .prdata_o                   (periph_apb_resp.prdata ),
    .pready_o                   (periph_apb_resp.pready ),
    .pslverr_o                  (periph_apb_resp.pslverr),

    // MASTER PORTS
    .penable_o                  (penable),
    .pwrite_o                   (pwrite ),
    .paddr_o                    (paddr  ),
    .psel_o                     (psel   ),
    .pwdata_o                   (pwdata ),
    .prdata_i                   (prdata ),
    .pready_i                   (pready ),
    .pslverr_i                  (pslverr),

    // CONFIGURATION PORT
    .START_ADDR_i               (START_ADDR_i),
    .END_ADDR_i                 (END_ADDR_i  )
);


  //  ██╗   ██╗ █████╗ ██████╗ ████████╗
  //  ██║   ██║██╔══██╗██╔══██╗╚══██╔══╝
  //  ██║   ██║███████║██████╔╝   ██║
  //  ██║   ██║██╔══██║██╔══██╗   ██║
  //  ╚██████╔╝██║  ██║██║  ██║   ██║
  //   ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝

  `ifndef SIM_UART
  apb_uart_sv #(
    .APB_ADDR_WIDTH ( 32 )
  ) i_apb_uart (
    .CLK     ( clk_i               ),
    .RSTN    ( rst_ni              ),
    .PADDR   ( paddr[UART_M][31:0] ),
    .PWDATA  ( pwdata[UART_M]      ),
    .PWRITE  ( pwrite[UART_M]      ),
    .PSEL    ( psel[UART_M]        ),
    .PENABLE ( penable[UART_M]     ),
    .PRDATA  ( prdata[UART_M]      ),
    .PREADY  ( pready[UART_M]      ),
    .PSLVERR ( pslverr[UART_M]     ),
    .rx_i    ( marian_uart_rx_i    ),
    .tx_o    ( marian_uart_tx_o    ),
    .event_o ( uart_events_s       )
  );
  `else
  mock_uart i_mock_apb_uart (
    .clk_i     ( clk_i              ),
    .rst_ni    ( rst_ni             ),
    .penable_i ( penable[UART_M]    ),
    .pwrite_i  ( pwrite[UART_M]     ),
    .paddr_i   ( paddr[UART_M][31:0]),
    .psel_i    ( psel[UART_M]       ),
    .pwdata_i  ( pwdata[UART_M]     ),
    .prdata_o  ( prdata[UART_M]     ),
    .pready_o  ( pready[UART_M]     ),
    .pslverr_o ( pslverr[UART_M]    )
  );

  assign marian_uart_tx_o = 1'b0;
  assign uart_events_s    = 1'b0;

  `endif

//  ██████╗ ███████╗██████╗ ██╗
// ██╔═══██╗██╔════╝██╔══██╗██║
// ██║   ██║███████╗██████╔╝██║
// ██║▄▄ ██║╚════██║██╔═══╝ ██║
// ╚██████╔╝███████║██║     ██║
//  ╚══▀▀═╝ ╚══════╝╚═╝     ╚═╝

  apb_spi_master #(
    .BUFFER_DEPTH   ( 16                    ),
    .APB_ADDR_WIDTH ( PeriphAddrWidth       )  //APB slaves are 4KB by default
  )i_apb_spi_master(
  .HCLK             ( clk_i                 ),
  .HRESETn          ( rst_ni                ),
  .PADDR            ( paddr[QSPI_M]         ),
  .PWDATA           ( pwdata[QSPI_M]        ),
  .PWRITE           ( pwrite[QSPI_M]        ),
  .PSEL             ( psel[QSPI_M]          ),
  .PENABLE          ( penable[QSPI_M]       ),
  .PRDATA           ( prdata[QSPI_M]        ),
  .PREADY           ( pready[QSPI_M]        ),
  .PSLVERR          ( pslverr[QSPI_M]       ),

  .events_o         ( spi_events_s          ),

  .spi_clk          ( marian_qspi_sclk_o    ),
  .spi_csn0         ( marian_qspi_csn_o     ),
  .spi_csn1         (  /* UNCONNECTED */    ),
  .spi_csn2         (  /* UNCONNECTED */    ),
  .spi_csn3         (  /* UNCONNECTED */    ),
  .spi_mode         ( spi_mode_o            ),
  .spi_sdo0         ( marian_qspi_data_o[0] ),
  .spi_sdo1         ( marian_qspi_data_o[1] ),
  .spi_sdo2         ( marian_qspi_data_o[2] ),
  .spi_sdo3         ( marian_qspi_data_o[3] ),
  .spi_sdi0         ( marian_qspi_data_i[0] ),
  .spi_sdi1         ( marian_qspi_data_i[1] ),
  .spi_sdi2         ( marian_qspi_data_i[2] ),
  .spi_sdi3         ( marian_qspi_data_i[3] )
);


// ████████╗██╗███╗   ███╗███████╗██████╗
// ╚══██╔══╝██║████╗ ████║██╔════╝██╔══██╗
//    ██║   ██║██╔████╔██║█████╗  ██████╔╝
//    ██║   ██║██║╚██╔╝██║██╔══╝  ██╔══██╗
//    ██║   ██║██║ ╚═╝ ██║███████╗██║  ██║
//    ╚═╝   ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝

  timer #(
    .APB_ADDR_WIDTH ( PeriphAddrWidth )
  ) i_apb_timer (
    .HCLK    ( clk_i           ),
    .HRESETn ( rst_ni          ),
    .PADDR   ( paddr[TIMR_M]   ),
    .PWDATA  ( pwdata[TIMR_M]  ),
    .PWRITE  ( pwrite[TIMR_M]  ),
    .PSEL    ( psel[TIMR_M]    ),
    .PENABLE ( penable[TIMR_M] ),
    .PRDATA  ( prdata[TIMR_M]  ),
    .PREADY  ( pready[TIMR_M]  ),
    .PSLVERR ( pslverr[TIMR_M] ),
    .irq_o   ( timer_events_s  )
  );

//   ██████╗ ██████╗ ██╗ ██████╗
//  ██╔════╝ ██╔══██╗██║██╔═══██╗
//  ██║  ███╗██████╔╝██║██║   ██║
//  ██║   ██║██╔═══╝ ██║██║   ██║
//  ╚██████╔╝██║     ██║╚██████╔╝
//   ╚═════╝ ╚═╝     ╚═╝ ╚═════╝

apb_gpio #(
  .APB_ADDR_WIDTH ( PeriphAddrWidth ),
  .PAD_NUM        ( 2               )
) i_apb_gpio (
  .HCLK            ( clk_i               ),
  .HRESETn         ( rst_ni              ),
  .dft_cg_enable_i (  '0                 ),
  .PADDR           ( paddr[GPIO_M]       ),
  .PWDATA          ( pwdata[GPIO_M]      ),
  .PWRITE          ( pwrite[GPIO_M]      ),
  .PSEL            ( psel[GPIO_M]        ),
  .PENABLE         ( penable[GPIO_M]     ),
  .PRDATA          ( prdata[GPIO_M]      ),
  .PREADY          ( pready[GPIO_M]      ),
  .PSLVERR         ( pslverr[GPIO_M]     ),
  .gpio_in         ( marian_gpio_i),
  .gpio_in_sync    ( /* UNCONNECTED */   ),
  .gpio_out        ( marian_gpio_o       ),
  .gpio_dir        ( marian_gpio_oe      ),
  .gpio_padcfg     ( /* UNCONNECTED */   ),
  .interrupt       ( gpio_events_s       )
);

/*
██████╗ ██╗     ██╗ ██████╗
██╔══██╗██║     ██║██╔════╝
██████╔╝██║     ██║██║
██╔═══╝ ██║     ██║██║
██║     ███████╗██║╚██████╗
╚═╝     ╚══════╝╚═╝ ╚═════╝
*/

plic_wrapper #(
  .NB_EXT_IRQ ( NumExternalIRQ ),
  .NB_CORES   ( NB_CORES       )
) i_plic_wrapper (
  .clk_i     ( clk_i           ),
  .rst_ni    ( rst_ni          ),
  .ext_irq_i ( irq_s           ),
  .irq_o     ( plic_irq_o      ),
  .penable_i ( penable[PLIC_M] ),
  .pwrite_i  ( pwrite[PLIC_M]  ),
  .paddr_i   ( paddr[PLIC_M]   ),
  .psel_i    ( psel[PLIC_M]    ),
  .pwdata_i  ( pwdata[PLIC_M]  ),
  .prdata_o  ( prdata[PLIC_M]  ),
  .pready_o  ( pready[PLIC_M]  ),
  .pslverr_o ( pslverr[PLIC_M] )
);


  endmodule
