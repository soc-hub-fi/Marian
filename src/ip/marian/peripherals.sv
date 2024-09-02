//------------------------------------------------------------------------------
// Module   : peripherals
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Endrit Isufi <endrit.isufi@tuni.fi>
// Created  : 14-June-2024
//
// Description: Wrapper for CLINT, PLIC and config register modules.
//------------------------------------------------------------------------------
//
//
// Inputs:
//  - clk_i:                  Clock in
//  - rst_ni:                 Asynchronous active-low reset
//  - periph_wide_axi_req_i:  AXI bus request channel
//  - irq_s:                  Global interrupt sources
// Outputs:
//  - periph_wide_axi_resp_o: AXI bus response channel
//  - exit_o:                 CTRL register EOC signal
//  - timer_irq:              CLINT timer interrupt
//  - ipi_o:                  CLINT software interrupt (== inter-process-interrupt)
//  - plic_irq_o:             PLIC IPI interrupts routed towards core
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

module peripherals
  import marian_pkg::*; (
    input  logic                           clk_i,
    input  logic                           rst_ni,
    input  soc_wide_req_t                  periph_wide_axi_req_i,
    output soc_wide_resp_t                 periph_wide_axi_resp_o,
    output logic [PeriphWideDataWidth-1:0] exit_o,
    output logic                           timer_irq,
    output logic                           ipi_o
  );

  `include "common_cells/registers.svh"
  periph_axi_wide_req_t   periph_axi_req;
  periph_axi_wide_resp_t  periph_axi_resp;

  periph_wide_lite_req_t  [NrPeriphWideMasters -1:0] periph_axi_lite_req;
  periph_wide_lite_resp_t [NrPeriphWideMasters -1:0] periph_axi_lite_resp;

  periph_wide_lite_req_t  axi_lite_req;
  periph_wide_lite_resp_t axi_lite_resp;


  logic [NrPeriphWideMasters-2:0] aw_select_d;
  logic [NrPeriphWideMasters-2:0] ar_select_d;
  logic [NrPeriphWideMasters-2:0] aw_select_q;
  logic [NrPeriphWideMasters-2:0] ar_select_q;


  //128b -> 64b
  axi_dw_converter #(
    .AxiSlvPortDataWidth ( AxiWideDataWidth         ),
    .AxiMstPortDataWidth ( PeriphWideDataWidth      ),
    .AxiAddrWidth        ( AxiAddrWidth             ),
    .AxiIdWidth          ( AxiSocIdWidth            ),
    .AxiMaxReads         ( 1                        ),
    .ar_chan_t           ( soc_wide_ar_chan_t       ),
    .mst_r_chan_t        ( periph_axi_wide_r_chan_t ),
    .slv_r_chan_t        ( soc_wide_r_chan_t        ),
    .aw_chan_t           ( periph_axi_wide_aw_chan_t),
    .b_chan_t            ( soc_wide_b_chan_t        ),
    .mst_w_chan_t        ( periph_axi_wide_w_chan_t ),
    .slv_w_chan_t        ( soc_wide_w_chan_t        ),
    .axi_mst_req_t       ( periph_axi_wide_req_t    ),
    .axi_mst_resp_t      ( periph_axi_wide_resp_t   ),
    .axi_slv_req_t       ( soc_wide_req_t           ),
    .axi_slv_resp_t      ( soc_wide_resp_t          )
  ) i_axi_slave_periph_dwc (
    .clk_i      ( clk_i                        ),
    .rst_ni     ( rst_ni                       ),
    .slv_req_i  ( periph_wide_axi_req_i        ),
    .slv_resp_o ( periph_wide_axi_resp_o       ),
    .mst_req_o  ( periph_axi_req               ),
    .mst_resp_i ( periph_axi_resp              )
  );

  //axi to axi lite
  axi_to_axi_lite #(
    .AxiAddrWidth    ( AxiAddrWidth            ),
    .AxiDataWidth    ( PeriphWideDataWidth     ),
    .AxiIdWidth      ( AxiSocIdWidth           ),
    .AxiUserWidth    ( AxiUserWidth            ),
    .AxiMaxWriteTxns ( 32'd1                   ),
    .AxiMaxReadTxns  ( 32'd1                   ),
    .FallThrough     ( 1'b1                    ),
    .full_req_t      ( periph_axi_wide_req_t   ),
    .full_resp_t     ( periph_axi_wide_resp_t  ),
    .lite_req_t      ( periph_wide_lite_req_t  ),
    .lite_resp_t     ( periph_wide_lite_resp_t )
  ) i_axi_to_axi_lite_periph (
    .clk_i      ( clk_i           ),
    .rst_ni     ( rst_ni          ),
    .test_i     ( 1'b0            ),
    .slv_req_i  ( periph_axi_req  ),
    .slv_resp_o ( periph_axi_resp ),
    .mst_req_o  ( axi_lite_req    ),
    .mst_resp_i ( axi_lite_resp   )
  );

  /*
    Set axi-lite demux selector signals according to AXI-LITE bus aw & ar addresses.
  */
  always_comb begin
    aw_select_d = '0;
    ar_select_d = '0;
    if(periph_axi_req.aw_valid) begin
      if ((periph_axi_req.aw.addr >= CTRLBase) & periph_axi_req.aw.addr <= (CTRLBase + CTRLLength)) begin
        aw_select_d = CFG_M;
      end
      else if ((periph_axi_req.aw.addr >= CLINTBase) & periph_axi_req.aw.addr <= (CLINTBase + CLINTLength))begin
        aw_select_d = CLINT_M;
      end
    end
    if(periph_axi_req.ar_valid) begin
      if ((periph_axi_req.ar.addr >= CTRLBase) & periph_axi_req.ar.addr <= (CTRLBase + CTRLLength)) begin
        ar_select_d = CFG_M;
      end
      else if ((periph_axi_req.ar.addr >= CLINTBase) & periph_axi_req.ar.addr <= (CLINTBase + CLINTLength))begin
        ar_select_d = CLINT_M;
      end
    end
  end
  // One-cycle latency
  `FF(aw_select_q, aw_select_d, 1'b0, clk_i , rst_ni );
  `FF(ar_select_q, ar_select_d, 1'b0, clk_i , rst_ni );



  axi_lite_demux #(
    .aw_chan_t      (periph_wide_lite_aw_chan_t), // AXI4-Lite AW channel
    .w_chan_t       (periph_wide_lite_w_chan_t ), // AXI4-Lite  W channel
    .b_chan_t       (periph_wide_lite_b_chan_t ), // AXI4-Lite  B channel
    .ar_chan_t      (periph_wide_lite_ar_chan_t), // AXI4-Lite AR channel
    .r_chan_t       (periph_wide_lite_r_chan_t ), // AXI4-Lite  R channel
    .axi_req_t      (periph_wide_lite_req_t    ), // AXI4-Lite request struct
    .axi_resp_t     (periph_wide_lite_resp_t   ), // AXI4-Lite response struct
    .NoMstPorts     (NrPeriphWideMasters       ), // Number of instantiated ports
    .MaxTrans       (10                        ), // Maximum number of open transactions per channel
    .FallThrough    (1'b1                      ),  // FIFOs are in fall through mode
    .SpillAw        (),  // insert one cycle latency on slave AW
    .SpillW         (),  // insert one cycle latency on slave  W
    .SpillB         (),  // insert one cycle latency on slave  B
    .SpillAr        (),  // insert one cycle latency on slave AR
    .SpillR         (),  // insert one cycle latency on slave  R
    // Dependent parameters, DO NOT OVERRIDE!
    .select_t       ()
  ) i_periph_lite_demux(
    .clk_i  (clk_i ),
    .rst_ni (rst_ni),
    .test_i ('0    ),
    // slave port (AXI4-Lite input), connect master module here
    .slv_req_i       (axi_lite_req ),
    .slv_aw_select_i (aw_select_q  ),
    .slv_ar_select_i (ar_select_q  ),
    .slv_resp_o      (axi_lite_resp),
    // master ports (AXI4-Lite outputs), connect slave modules here
    .mst_reqs_o     (periph_axi_lite_req ),
    .mst_resps_i    (periph_axi_lite_resp)
  );



 // ██████╗  ██████╗ ███╗   ██╗███████╗██╗ ██████╗ 
 // ██╔═══╝ ██╔═══██╗████╗  ██║██╔════╝██║██╔════╝ 
 // ██║     ██║   ██║██╔██╗ ██║█████╗  ██║██║  ███╗
 // ██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██║   ██║
 // ╚██████╗╚██████╔╝██║ ╚████║██║     ██║╚██████╔╝
 //  ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝ 
  
  ctrl_registers #(
    .DRAMBaseAddr    ( DRAMBase               ),
    .DRAMLength      ( DRAMLength             ),
    .DataWidth       ( PeriphWideDataWidth    ),
    .AddrWidth       ( PeriphAddrWidth        ),
    .axi_lite_req_t  ( periph_wide_lite_req_t ),
    .axi_lite_resp_t ( periph_wide_lite_resp_t)
  ) i_ctrl_registers (
    .clk_i                 ( clk_i                ),
    .rst_ni                ( rst_ni               ),
    .axi_lite_slave_req_i  ( periph_axi_lite_req[CFG_M] ),
    .axi_lite_slave_resp_o ( periph_axi_lite_resp[CFG_M]),
    .dram_base_addr_o      ( /* Unused*/                ),
    .dram_end_addr_o       ( /* Unused*/                ),
    .exit_o                ( exit_o                     ),
    .event_trigger_o       ( /* Unused  */              ),
    .hw_cnt_en_o           ( /* Unused  */              )
  );


/*
 ██████╗██╗     ██╗███╗   ██╗████████╗
██╔════╝██║     ██║████╗  ██║╚══██╔══╝
██║     ██║     ██║██╔██╗ ██║   ██║   
██║     ██║     ██║██║╚██╗██║   ██║   
╚██████╗███████╗██║██║ ╚████║   ██║   
 ╚═════╝╚══════╝╚═╝╚═╝  ╚═══╝   ╚═╝                                     
  */
 clint_wrapper #(
  .NR_CORES   (CLINTNRCORES)
)i_clint_wrapper (
  .clk_i          ( clk_i                        ),
  .rst_ni         ( rst_ni                       ),
  // clint timer outputs
  .timer_irq      ( timer_irq                    ),
  .ipi_o          ( ipi_o                        ),
  // axi-lite
  .clint_lite_req   (periph_axi_lite_req[CLINT_M]),
  .clint_lite_resp  (periph_axi_lite_resp[CLINT_M])
);


endmodule
