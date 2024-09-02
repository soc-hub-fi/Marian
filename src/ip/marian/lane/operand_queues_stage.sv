//------------------------------------------------------------------------------
// Module   : lane_sequencer
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Matheus Cavalcante <matheusd@iis.ee.ethz.ch>
//            Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 28-jan-2024
//
// Description: Ara operand queue modified for use within Marian. Original
// description preserved below:
//------------------------------------------------------------------------------
// Copyright 2021 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Author: Matheus Cavalcante <matheusd@iis.ee.ethz.ch>
// Description:
// This stage holds the operand queues, holding elements for the VRFs.
//------------------------------------------------------------------------------
//
// Parameters:
//  - NrLanes: Number of lanes
//  - FPUSupport: Support for floating-point data types
//
// Inputs:
//  - clk_i: Clock in
//  - rst_ni: Asynchronous active-low reset
//  - lane_id_i: Current lane ID
//  - operand_i: Operand from VRF
//  - operand_valid_i: Operand valid from VRF
//  - operand_issued_i: Operand issued from operand requester
//  - operand_queue_cmd_i: Operand queue command from operand requester
//  - operand_queue_cmd_valid_i: Handshaking for operand queue command
//  - alu_operand_ready_i: ALU operand handshaking
//  - mfpu_operand_ready_i: MFPU operand handshaking
//  - stu_operand_ready_i: Store Unit operand handshaking
//  - addrgen_operand_ready_i: Addr Gen operand handshaking
//  - sldu_operand_ready_i: Slide Unit operand handshaking
//  - mask_operand_ready_i: Mask Unit operand handshaking
//  - crypto_operand_ready_i: Crypto Unit operand handshaking
//
// Outputs:
//  - operand_queue_ready_o:
//  - alu_operand_o: ALU operand
//  - alu_operand_valid_o: ALU operand handshaking
//  - mfpu_operand_o: MFPU operand
//  - mfpu_operand_valid_o: MFPU operand handshaking
//  - stu_operand_o: Store Unit operand
//  - stu_operand_valid_o: Store Unit operand handshaking
//  - sldu_addrgen_operand_o: Addr Gen operand
//  - sldu_addrgen_operand_target_fu_o: Target select for Addr Gen operand
//  - sldu_addrgen_operand_valid_o: Addr Gen operand handshaking
//  - mask_operand_o: Mask Unit operand
//  - mask_operand_valid_o: Mask Unit operand handshaking
//  - crypto_operand_o: Crypto Unit operand
//  - crypto_operand_valid_o: Crypto Unit operand handshaking
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

module operand_queues_stage
  import ara_pkg::*;
  import rvv_pkg::*;
  import cf_math_pkg::idx_width; 
#(
  parameter int     unsigned NrLanes = 0,
  // Support for floating-point data types
  parameter fpu_support_e FPUSupport = FPUSupportHalfSingleDouble
) (
  input  logic                                     clk_i,
  input  logic                                     rst_ni,
  input  logic            [idx_width(NrLanes)-1:0] lane_id_i,
  // Interface with the Vector Register File
  input  elen_t              [NrOperandQueues-1:0] operand_i,
  input  logic               [NrOperandQueues-1:0] operand_valid_i,
  // Input with the Operand Requester
  input  logic               [NrOperandQueues-1:0] operand_issued_i,
  output logic               [NrOperandQueues-1:0] operand_queue_ready_o,
  input  operand_queue_cmd_t [NrOperandQueues-1:0] operand_queue_cmd_i,
  input  logic               [NrOperandQueues-1:0] operand_queue_cmd_valid_i,
  // Interface with the VFUs
  // ALU
  output elen_t              [1:0]                 alu_operand_o,
  output logic               [1:0]                 alu_operand_valid_o,
  input  logic               [1:0]                 alu_operand_ready_i,
  // Multiplier/FPU
  output elen_t              [2:0]                 mfpu_operand_o,
  output logic               [2:0]                 mfpu_operand_valid_o,
  input  logic               [2:0]                 mfpu_operand_ready_i,
  // Store unit
  output elen_t                                    stu_operand_o,
  output logic                                     stu_operand_valid_o,
  input  logic                                     stu_operand_ready_i,
  // Slide Unit/Address Generation unit
  output elen_t                                    sldu_addrgen_operand_o,
  output target_fu_e                               sldu_addrgen_operand_target_fu_o,
  output logic                                     sldu_addrgen_operand_valid_o,
  input  logic                                     addrgen_operand_ready_i,
  input  logic                                     sldu_operand_ready_i,
  // Mask unit
  output elen_t              [1:0]                 mask_operand_o,
  output logic               [1:0]                 mask_operand_valid_o,
  input  logic               [1:0]                 mask_operand_ready_i,
  // Crypto Unit
  output elen_t              [2:0]                 crypto_operand_o,
  output logic               [2:0]                 crypto_operand_valid_o,
  input  logic               [2:0]                 crypto_operand_ready_i
);

  ///////////
  //  ALU  //
  ///////////

  operand_queue #(
    .CmdBufDepth   (ValuInsnQueueDepth),
    .DataBufDepth  (5                 ),
    .FPUSupport    (FPUSupport        ),
    .NrLanes       (NrLanes           ),
    .SupportIntExt2(1'b1              ),
    .SupportIntExt4(1'b1              ),
    .SupportIntExt8(1'b1              ),
    .SupportReduct (1'b1              ),
    .SupportNtrVal (1'b0              )
  ) i_operand_queue_alu_a (
    .clk_i                    (clk_i                          ),
    .rst_ni                   (rst_ni                         ),
    .lane_id_i                (lane_id_i                      ),
    .operand_queue_cmd_i      (operand_queue_cmd_i[AluA]      ),
    .operand_queue_cmd_valid_i(operand_queue_cmd_valid_i[AluA]),
    .operand_i                (operand_i[AluA]                ),
    .operand_valid_i          (operand_valid_i[AluA]          ),
    .operand_issued_i         (operand_issued_i[AluA]         ),
    .operand_queue_ready_o    (operand_queue_ready_o[AluA]    ),
    .operand_o                (alu_operand_o[0]               ),
    .operand_target_fu_o      (/* Unused */                   ),
    .operand_valid_o          (alu_operand_valid_o[0]         ),
    .operand_ready_i          (alu_operand_ready_i[0]         )
  );

  operand_queue #(
    .CmdBufDepth   (ValuInsnQueueDepth),
    .DataBufDepth  (5                 ),
    .FPUSupport    (FPUSupport        ),
    .NrLanes       (NrLanes           ),
    .SupportIntExt2(1'b1              ),
    .SupportIntExt4(1'b1              ),
    .SupportIntExt8(1'b1              ),
    .SupportReduct (1'b1              ),
    .SupportNtrVal (1'b1              )
  ) i_operand_queue_alu_b (
    .clk_i                    (clk_i                          ),
    .rst_ni                   (rst_ni                         ),
    .lane_id_i                (lane_id_i                      ),
    .operand_queue_cmd_i      (operand_queue_cmd_i[AluB]      ),
    .operand_queue_cmd_valid_i(operand_queue_cmd_valid_i[AluB]),
    .operand_i                (operand_i[AluB]                ),
    .operand_valid_i          (operand_valid_i[AluB]          ),
    .operand_issued_i         (operand_issued_i[AluB]         ),
    .operand_queue_ready_o    (operand_queue_ready_o[AluB]    ),
    .operand_o                (alu_operand_o[1]               ),
    .operand_target_fu_o      (/* Unused */                   ),
    .operand_valid_o          (alu_operand_valid_o[1]         ),
    .operand_ready_i          (alu_operand_ready_i[1]         )
  );

  //////////////////////
  //  Multiplier/FPU  //
  //////////////////////

  operand_queue #(
    .CmdBufDepth   (MfpuInsnQueueDepth ),
    .DataBufDepth  (5                  ),
    .FPUSupport    (FPUSupport         ),
    .NrLanes       (NrLanes            ),
    .SupportIntExt2(1'b1               ),
    .SupportReduct (1'b1               ),
    .SupportNtrVal (1'b0               )
  ) i_operand_queue_mfpu_a (
    .clk_i                    (clk_i                             ),
    .rst_ni                   (rst_ni                            ),
    .lane_id_i                (lane_id_i                         ),
    .operand_queue_cmd_i      (operand_queue_cmd_i[MulFPUA]      ),
    .operand_queue_cmd_valid_i(operand_queue_cmd_valid_i[MulFPUA]),
    .operand_i                (operand_i[MulFPUA]                ),
    .operand_valid_i          (operand_valid_i[MulFPUA]          ),
    .operand_issued_i         (operand_issued_i[MulFPUA]         ),
    .operand_queue_ready_o    (operand_queue_ready_o[MulFPUA]    ),
    .operand_o                (mfpu_operand_o[0]                 ),
    .operand_target_fu_o      (/* Unused */                      ),
    .operand_valid_o          (mfpu_operand_valid_o[0]           ),
    .operand_ready_i          (mfpu_operand_ready_i[0]           )
  );

  operand_queue #(
    .CmdBufDepth   (MfpuInsnQueueDepth ),
    .DataBufDepth  (5                  ),
    .FPUSupport    (FPUSupport         ),
    .NrLanes       (NrLanes            ),
    .SupportIntExt2(1'b1               ),
    .SupportReduct (1'b1               ),
    .SupportNtrVal (1'b1               )
  ) i_operand_queue_mfpu_b (
    .clk_i                    (clk_i                             ),
    .rst_ni                   (rst_ni                            ),
    .lane_id_i                (lane_id_i                         ),
    .operand_queue_cmd_i      (operand_queue_cmd_i[MulFPUB]      ),
    .operand_queue_cmd_valid_i(operand_queue_cmd_valid_i[MulFPUB]),
    .operand_i                (operand_i[MulFPUB]                ),
    .operand_valid_i          (operand_valid_i[MulFPUB]          ),
    .operand_issued_i         (operand_issued_i[MulFPUB]         ),
    .operand_queue_ready_o    (operand_queue_ready_o[MulFPUB]    ),
    .operand_o                (mfpu_operand_o[1]                 ),
    .operand_target_fu_o      (/* Unused */                      ),
    .operand_valid_o          (mfpu_operand_valid_o[1]           ),
    .operand_ready_i          (mfpu_operand_ready_i[1]           )
  );

  operand_queue #(
    .CmdBufDepth   (MfpuInsnQueueDepth ),
    .DataBufDepth  (5                  ),
    .FPUSupport    (FPUSupport         ),
    .NrLanes       (NrLanes            ),
    .SupportIntExt2(1'b1               ),
    .SupportReduct (1'b1               ),
    .SupportNtrVal (1'b1               )
  ) i_operand_queue_mfpu_c (
    .clk_i                    (clk_i                             ),
    .rst_ni                   (rst_ni                            ),
    .lane_id_i                (lane_id_i                         ),
    .operand_queue_cmd_i      (operand_queue_cmd_i[MulFPUC]      ),
    .operand_queue_cmd_valid_i(operand_queue_cmd_valid_i[MulFPUC]),
    .operand_i                (operand_i[MulFPUC]                ),
    .operand_valid_i          (operand_valid_i[MulFPUC]          ),
    .operand_issued_i         (operand_issued_i[MulFPUC]         ),
    .operand_queue_ready_o    (operand_queue_ready_o[MulFPUC]    ),
    .operand_o                (mfpu_operand_o[2]                 ),
    .operand_target_fu_o      (/* Unused */                      ),
    .operand_valid_o          (mfpu_operand_valid_o[2]           ),
    .operand_ready_i          (mfpu_operand_ready_i[2]           )
  );

  ///////////////////////
  //  Load/Store Unit  //
  ///////////////////////

  operand_queue #(
    .CmdBufDepth   (VstuInsnQueueDepth + MaskuInsnQueueDepth),
    .DataBufDepth  (2                                       ),
    .FPUSupport    (FPUSupport                              ),
    .NrLanes       (NrLanes                                 )
  ) i_operand_queue_st_mask_a (
    .clk_i                    (clk_i                         ),
    .rst_ni                   (rst_ni                        ),
    .lane_id_i                (lane_id_i                     ),
    .operand_queue_cmd_i      (operand_queue_cmd_i[StA]      ),
    .operand_queue_cmd_valid_i(operand_queue_cmd_valid_i[StA]),
    .operand_i                (operand_i[StA]                ),
    .operand_valid_i          (operand_valid_i[StA]          ),
    .operand_issued_i         (operand_issued_i[StA]         ),
    .operand_queue_ready_o    (operand_queue_ready_o[StA]    ),
    .operand_o                (stu_operand_o                 ),
    .operand_target_fu_o      (/* Unused */                  ),
    .operand_valid_o          (stu_operand_valid_o           ),
    .operand_ready_i          (stu_operand_ready_i           )
  );

  /****************
   *  Slide Unit  *
   ****************/

  operand_queue #(
    .CmdBufDepth   (VlduInsnQueueDepth),
    .DataBufDepth  (2                 ),
    .FPUSupport    (FPUSupport        ),
    .NrLanes       (NrLanes           )
  ) i_operand_queue_slide_addrgen_a (
    .clk_i                    (clk_i                                         ),
    .rst_ni                   (rst_ni                                        ),
    .lane_id_i                (lane_id_i                                     ),
    .operand_queue_cmd_i      (operand_queue_cmd_i[SlideAddrGenA]            ),
    .operand_queue_cmd_valid_i(operand_queue_cmd_valid_i[SlideAddrGenA]      ),
    .operand_i                (operand_i[SlideAddrGenA]                      ),
    .operand_valid_i          (operand_valid_i[SlideAddrGenA]                ),
    .operand_issued_i         (operand_issued_i[SlideAddrGenA]               ),
    .operand_queue_ready_o    (operand_queue_ready_o[SlideAddrGenA]          ),
    .operand_o                (sldu_addrgen_operand_o                        ),
    .operand_target_fu_o      (sldu_addrgen_operand_target_fu_o              ),
    .operand_valid_o          (sldu_addrgen_operand_valid_o                  ),
    .operand_ready_i          (addrgen_operand_ready_i | sldu_operand_ready_i)
  );

  /////////////////
  //  Mask Unit  //
  /////////////////

  operand_queue #(
    .CmdBufDepth   (MaskuInsnQueueDepth),
    .DataBufDepth  (1                  ),
    .FPUSupport    (FPUSupport         ),
    .SupportIntExt2(1'b1               ),
    .SupportIntExt4(1'b1               ),
    .SupportIntExt8(1'b1               ),
    .NrLanes    (NrLanes   )
  ) i_operand_queue_mask_b (
    .clk_i                    (clk_i                           ),
    .rst_ni                   (rst_ni                          ),
    .lane_id_i                (lane_id_i                       ),
    .operand_queue_cmd_i      (operand_queue_cmd_i[MaskB]      ),
    .operand_queue_cmd_valid_i(operand_queue_cmd_valid_i[MaskB]),
    .operand_i                (operand_i[MaskB]                ),
    .operand_valid_i          (operand_valid_i[MaskB]          ),
    .operand_issued_i         (operand_issued_i[MaskB]         ),
    .operand_queue_ready_o    (operand_queue_ready_o[MaskB]    ),
    .operand_o                (mask_operand_o[1]               ),
    .operand_target_fu_o      (/* Unused */                    ),
    .operand_valid_o          (mask_operand_valid_o[1]         ),
    .operand_ready_i          (mask_operand_ready_i[1]         )
  );

  operand_queue #(
    .CmdBufDepth   (MaskuInsnQueueDepth),
    .DataBufDepth  (1                  ),
    .NrLanes       (NrLanes            )
  ) i_operand_queue_mask_m (
    .clk_i                    (clk_i                           ),
    .rst_ni                   (rst_ni                          ),
    .lane_id_i                (lane_id_i                       ),
    .operand_queue_cmd_i      (operand_queue_cmd_i[MaskM]      ),
    .operand_queue_cmd_valid_i(operand_queue_cmd_valid_i[MaskM]),
    .operand_i                (operand_i[MaskM]                ),
    .operand_valid_i          (operand_valid_i[MaskM]          ),
    .operand_issued_i         (operand_issued_i[MaskM]         ),
    .operand_queue_ready_o    (operand_queue_ready_o[MaskM]    ),
    .operand_o                (mask_operand_o[0]               ),
    .operand_target_fu_o      (/* Unused */                    ),
    .operand_valid_o          (mask_operand_valid_o[0]         ),
    .operand_ready_i          (mask_operand_ready_i[0]         )
  );

  /*****************
   *  Crypto Unit  *
   *****************/

  operand_queue #(
    .CmdBufDepth   ( CryptoInsnQueueDepth ),
    .DataBufDepth  ( 2                    ),
    .FPUSupport    ( FPUSupport           ),
    .NrLanes       ( NrLanes              )
  ) i_operand_queue_cryptoA (
    .clk_i                     ( clk_i                              ),
    .rst_ni                    ( rst_ni                             ),
    .lane_id_i                 ( lane_id_i                          ),
    .operand_queue_cmd_i       ( operand_queue_cmd_i[CryptoA]       ),
    .operand_queue_cmd_valid_i ( operand_queue_cmd_valid_i[CryptoA] ),
    .operand_i                 ( operand_i[CryptoA]                 ),
    .operand_valid_i           ( operand_valid_i[CryptoA]           ),
    .operand_issued_i          ( operand_issued_i[CryptoA]          ),
    .operand_queue_ready_o     ( operand_queue_ready_o[CryptoA]     ),
    .operand_o                 ( crypto_operand_o[0]                ),
    .operand_target_fu_o       ( /* Unused */                       ),
    .operand_valid_o           ( crypto_operand_valid_o[0]          ),
    .operand_ready_i           ( crypto_operand_ready_i[0]          )
  );

  operand_queue #(
    .CmdBufDepth   ( CryptoInsnQueueDepth ),
    .DataBufDepth  ( 2                    ),
    .FPUSupport    ( FPUSupport           ),
    .NrLanes       ( NrLanes              )
  ) i_operand_queue_cryptoB (
    .clk_i                     ( clk_i                              ),
    .rst_ni                    ( rst_ni                             ),
    .lane_id_i                 ( lane_id_i                          ),
    .operand_queue_cmd_i       ( operand_queue_cmd_i[CryptoB]       ),
    .operand_queue_cmd_valid_i ( operand_queue_cmd_valid_i[CryptoB] ),
    .operand_i                 ( operand_i[CryptoB]                 ),
    .operand_valid_i           ( operand_valid_i[CryptoB]           ),
    .operand_issued_i          ( operand_issued_i[CryptoB]          ),
    .operand_queue_ready_o     ( operand_queue_ready_o[CryptoB]     ),
    .operand_o                 ( crypto_operand_o[1]                ),
    .operand_target_fu_o       ( /* Unused */                       ),
    .operand_valid_o           ( crypto_operand_valid_o[1]          ),
    .operand_ready_i           ( crypto_operand_ready_i[1]          )
  );

  operand_queue #(
    .CmdBufDepth   ( CryptoInsnQueueDepth ),
    .DataBufDepth  ( 2                    ),
    .FPUSupport    ( FPUSupport           ),
    .NrLanes       ( NrLanes              )
  ) i_operand_queue_cryptoC (
    .clk_i                     ( clk_i                              ),
    .rst_ni                    ( rst_ni                             ),
    .lane_id_i                 ( lane_id_i                          ),
    .operand_queue_cmd_i       ( operand_queue_cmd_i[CryptoC]       ),
    .operand_queue_cmd_valid_i ( operand_queue_cmd_valid_i[CryptoC] ),
    .operand_i                 ( operand_i[CryptoC]                 ),
    .operand_valid_i           ( operand_valid_i[CryptoC]           ),
    .operand_issued_i          ( operand_issued_i[CryptoC]          ),
    .operand_queue_ready_o     ( operand_queue_ready_o[CryptoC]     ),
    .operand_o                 ( crypto_operand_o[2]                ),
    .operand_target_fu_o       ( /* Unused */                       ),
    .operand_valid_o           ( crypto_operand_valid_o[2]          ),
    .operand_ready_i           ( crypto_operand_ready_i[2]          )
  );

endmodule : operand_queues_stage
