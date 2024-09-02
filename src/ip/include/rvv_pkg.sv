//------------------------------------------------------------------------------
// Module   : rvv_pkg
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Matheus Cavalcante <matheusd@iis.ee.ethz.ch>
//            Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 16-jan-2024
//
// Description: Modified version of the rvv package which was originally
// contained within Ara. Extended to include vector-crypto definitions.
// Originally description maintained below:
//------------------------------------------------------------------------------
// Copyright 2021 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//------------------------------------------------------------------------------
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

package rvv_pkg;

  // This package depends on CVA6's riscv package
  import riscv::*;

  //////////////////////////////
  //  Common RVV definitions  //
  //////////////////////////////

  // Element width
  typedef enum logic [2:0] {
    EW8    = 3'b000,
    EW16   = 3'b001,
    EW32   = 3'b010,
    EW64   = 3'b011,
    EW128  = 3'b100,
    EW256  = 3'b101,
    EW512  = 3'b110,
    EW1024 = 3'b111
  } vew_e;

  // Length multiplier
  typedef enum logic [2:0] {
    LMUL_1    = 3'b000,
    LMUL_2    = 3'b001,
    LMUL_4    = 3'b010,
    LMUL_8    = 3'b011,
    LMUL_RSVD = 3'b100,
    LMUL_1_8  = 3'b101,
    LMUL_1_4  = 3'b110,
    LMUL_1_2  = 3'b111
  } vlmul_e;

  // Vector type register
  typedef struct packed {
    logic vill;
    logic vma;
    logic vta;
    vew_e vsew;
    vlmul_e vlmul;
  } vtype_t;

  // vector-vector, vector-scalar encoding flag
  typedef enum logic {
    VV = 0,
    VS = 1
  } vec_scal_enc_e;

  // Func3 values for vector arithmetics instructions under OpcodeV
  typedef enum logic [2:0] {
    OPIVV = 3'b000,
    OPFVV = 3'b001,
    OPMVV = 3'b010,
    OPIVI = 3'b011,
    OPIVX = 3'b100,
    OPFVF = 3'b101,
    OPMVX = 3'b110,
    OPCFG = 3'b111
  } opcodev_func3_e;

  // Func6 values for vector crypto instructions under OpcodeCryptoVec
  typedef enum logic [5:0] {
    F6_VSM3ME   = 6'b100000,
    F6_VSM4K    = 6'b100001,
    F6_VAESFK1  = 6'b100010,
    F6_VAES_VV  = 6'b101000,
    F6_VAES_VS  = 6'b101001,
    F6_VAESFK2  = 6'b101010,
    F6_VSM3C    = 6'b101011,
    F6_VGHSH    = 6'b101100,
    F6_VSHA2MS  = 6'b101101,
    F6_VSHA2CH  = 6'b101110,
    F6_VSHA2CL  = 6'b101111
  } opcodevcrypto_func6_e;

  // vs1 values for vector crypto instructions under OpcodeCryptoVec
  typedef enum logic [4:0] {
    VAESDM_VS1 = 5'b00000,
    VAESDF_VS1 = 5'b00001,
    VAESEM_VS1 = 5'b00010,
    VAESEF_VS1 = 5'b00011,
    VAESZ_VS1  = 5'b00111,
    VSM4R_VS1  = 5'b10000,
    VGMUL_VS1  = 5'b10001
  } opcodevcrypto_vs1_e;

  ///////////////////
  //  Vector CSRs  //
  ///////////////////

  function automatic logic is_vector_csr (riscv::csr_reg_t csr);
    case (csr)
      riscv::CSR_VSTART,
      riscv::CSR_VXSAT,
      riscv::CSR_VXRM,
      riscv::CSR_VCSR,
      riscv::CSR_VL,
      riscv::CSR_VTYPE,
      riscv::CSR_VLENB: begin
        return 1'b1;
      end
      default: return 1'b0;
    endcase
  endfunction : is_vector_csr

  ////////////////////////////////
  //  Vector instruction types  //
  ////////////////////////////////

  typedef struct packed {
    logic [31:29] nf;
    logic mew;
    logic [27:26] mop;
    logic vm;
    logic [24:20] rs2;
    logic [19:15] rs1;
    logic [14:12] width;
    logic [11:7] rd;
    logic [6:0] opcode;
  } vmem_type_t;

  typedef struct packed {
    logic [31:27] amoop;
    logic wd;
    logic vm;
    logic [24:20] rs2;
    logic [19:15] rs1;
    logic [14:12] width;
    logic [11:7] rd;
    logic [6:0] opcode;
  } vamo_type_t;

  typedef struct packed {
    logic [31:26] func6;
    logic vm;
    logic [24:20] rs2;
    logic [19:15] rs1;
    opcodev_func3_e func3;
    logic [11:7] rd;
    logic [6:0] opcode;
  } varith_type_t;

  typedef struct packed {
    logic func1;
    logic [30:20] zimm11;
    logic [19:15] rs1;
    opcodev_func3_e func3;
    logic [11:7] rd;
    logic [6:0] opcode;
  } vsetvli_type_t;

  typedef struct packed {
    logic [31:30] func2;
    logic [29:20] zimm10;
    logic [19:15] uimm5;
    opcodev_func3_e func3;
    logic [11:7] rd;
    logic [6:0] opcode;
  } vsetivli_type_t;

  typedef struct packed {
    logic [31:25] func7;
    logic [24:20] rs2;
    logic [19:15] rs1;
    opcodev_func3_e func3;
    logic [11:7] rd;
    logic [6:0] opcode;
  } vsetvl_type_t;

  // note that this is currently the same as varith, but to protect against
  // future updates, a separate type has been defined
  typedef struct packed {
    logic [31:26] func6;
    logic vm;
    logic [24:20] rs2;
    logic [19:15] rs1;
    opcodev_func3_e func3;
    logic [11:7] rd;
    logic [6:0] opcode;
  } vcrypto_type_t;

  typedef union packed {
    logic [31:0] instr ;
    riscv::itype_t i_type; // For CSR instructions
    vmem_type_t vmem_type;
    vamo_type_t vamo_type;
    varith_type_t varith_type;
    vsetvli_type_t vsetvli_type;
    vsetivli_type_t vsetivli_type;
    vsetvl_type_t vsetvl_type;
    vcrypto_type_t vcrypto_type;
  } rvv_instruction_t;

  ////////////////////////////
  //  Vector mask register  //
  ////////////////////////////

  // The mask register is always vreg[0]
  localparam VMASK = 5'b00000;

endpackage : rvv_pkg
