//------------------------------------------------------------------------------
// Module   : crypto_unit_tb_pkg.sv
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
//            Endrit Isufi   <endrit.isufi@tuni.fi>
// Created  : 29-apr-2024
//
// Description: Package to hold constants, types and routines to be used within
//              the crypto_unit_tb
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

package crypto_unit_tb_pkg;

  import ara_pkg::*;
  import rvv_pkg::*;

  // DUT configuration params
  localparam int  unsigned NrLanes    = `NR_LANES;
  localparam int  unsigned DataWidth  = $bits(elen_t); // Width of the lane datapath
  localparam int  unsigned StrbWidth  = DataWidth/8;
  localparam type          strb_t     = logic [StrbWidth-1:0]; // Byte-strobe type
  localparam type          vaddr_t    = logic;
  localparam int  unsigned OperandNum = 3;


  // table-based sbox implementation to be used for SM algorithms
  localparam logic [7:0] SMSboxFwd [256] = '{
    8'hD6, 8'h90, 8'hE9, 8'hFE, 8'hCC, 8'hE1, 8'h3D, 8'hB7,
    8'h16, 8'hB6, 8'h14, 8'hC2, 8'h28, 8'hFB, 8'h2C, 8'h05,

    8'h2B, 8'h67, 8'h9A, 8'h76, 8'h2A, 8'hBE, 8'h04, 8'hC3,
    8'hAA, 8'h44, 8'h13, 8'h26, 8'h49, 8'h86, 8'h06, 8'h99,

    8'h9C, 8'h42, 8'h50, 8'hF4, 8'h91, 8'hEF, 8'h98, 8'h7A,
    8'h33, 8'h54, 8'h0B, 8'h43, 8'hED, 8'hCF, 8'hAC, 8'h62,

    8'hE4, 8'hB3, 8'h1C, 8'hA9, 8'hC9, 8'h08, 8'hE8, 8'h95,
    8'h80, 8'hDF, 8'h94, 8'hFA, 8'h75, 8'h8F, 8'h3F, 8'hA6,

    8'h47, 8'h07, 8'hA7, 8'hFC, 8'hF3, 8'h73, 8'h17, 8'hBA,
    8'h83, 8'h59, 8'h3C, 8'h19, 8'hE6, 8'h85, 8'h4F, 8'hA8,

    8'h68, 8'h6B, 8'h81, 8'hB2, 8'h71, 8'h64, 8'hDA, 8'h8B,
    8'hF8, 8'hEB, 8'h0F, 8'h4B, 8'h70, 8'h56, 8'h9D, 8'h35,

    8'h1E, 8'h24, 8'h0E, 8'h5E, 8'h63, 8'h58, 8'hD1, 8'hA2,
    8'h25, 8'h22, 8'h7C, 8'h3B, 8'h01, 8'h21, 8'h78, 8'h87,

    8'hD4, 8'h00, 8'h46, 8'h57, 8'h9F, 8'hD3, 8'h27, 8'h52,
    8'h4C, 8'h36, 8'h02, 8'hE7, 8'hA0, 8'hC4, 8'hC8, 8'h9E,

    8'hEA, 8'hBF, 8'h8A, 8'hD2, 8'h40, 8'hC7, 8'h38, 8'hB5,
    8'hA3, 8'hF7, 8'hF2, 8'hCE, 8'hF9, 8'h61, 8'h15, 8'hA1,

    8'hE0, 8'hAE, 8'h5D, 8'hA4, 8'h9B, 8'h34, 8'h1A, 8'h55,
    8'hAD, 8'h93, 8'h32, 8'h30, 8'hF5, 8'h8C, 8'hB1, 8'hE3,

    8'h1D, 8'hF6, 8'hE2, 8'h2E, 8'h82, 8'h66, 8'hCA, 8'h60,
    8'hC0, 8'h29, 8'h23, 8'hAB, 8'h0D, 8'h53, 8'h4E, 8'h6F,

    8'hD5, 8'hDB, 8'h37, 8'h45, 8'hDE, 8'hFD, 8'h8E, 8'h2F,
    8'h03, 8'hFF, 8'h6A, 8'h72, 8'h6D, 8'h6C, 8'h5B, 8'h51,

    8'h8D, 8'h1B, 8'hAF, 8'h92, 8'hBB, 8'hDD, 8'hBC, 8'h7F,
    8'h11, 8'hD9, 8'h5C, 8'h41, 8'h1F, 8'h10, 8'h5A, 8'hD8,

    8'h0A, 8'hC1, 8'h31, 8'h88, 8'hA5, 8'hCD, 8'h7B, 8'hBD,
    8'h2D, 8'h74, 8'hD0, 8'h12, 8'hB8, 8'hE5, 8'hB4, 8'hB0,

    8'h89, 8'h69, 8'h97, 8'h4A, 8'h0C, 8'h96, 8'h77, 8'h7E,
    8'h65, 8'hB9, 8'hF1, 8'h09, 8'hC5, 8'h6E, 8'hC6, 8'h84,

    8'h18, 8'hF0, 8'h7D, 8'hEC, 8'h3A, 8'hDC, 8'h4D, 8'h20,
    8'h79, 8'hEE, 8'h5F, 8'h3E, 8'hD7, 8'hCB, 8'h39, 8'h48
  };

  // table-based forward/inverse sbox implementations for use in models
  localparam logic [7:0] SboxFwd [256] = '{
    8'h63, 8'h7C, 8'h77, 8'h7B, 8'hF2, 8'h6B, 8'h6F, 8'hC5,
    8'h30, 8'h01, 8'h67, 8'h2B, 8'hFE, 8'hD7, 8'hAB, 8'h76,

    8'hCA, 8'h82, 8'hC9, 8'h7D, 8'hFA, 8'h59, 8'h47, 8'hF0,
    8'hAD, 8'hD4, 8'hA2, 8'hAF, 8'h9C, 8'hA4, 8'h72, 8'hC0,

    8'hB7, 8'hFD, 8'h93, 8'h26, 8'h36, 8'h3F, 8'hF7, 8'hCC,
    8'h34, 8'hA5, 8'hE5, 8'hF1, 8'h71, 8'hD8, 8'h31, 8'h15,

    8'h04, 8'hC7, 8'h23, 8'hC3, 8'h18, 8'h96, 8'h05, 8'h9A,
    8'h07, 8'h12, 8'h80, 8'hE2, 8'hEB, 8'h27, 8'hB2, 8'h75,

    8'h09, 8'h83, 8'h2C, 8'h1A, 8'h1B, 8'h6E, 8'h5A, 8'hA0,
    8'h52, 8'h3B, 8'hD6, 8'hB3, 8'h29, 8'hE3, 8'h2F, 8'h84,

    8'h53, 8'hD1, 8'h00, 8'hED, 8'h20, 8'hFC, 8'hB1, 8'h5B,
    8'h6A, 8'hCB, 8'hBE, 8'h39, 8'h4A, 8'h4C, 8'h58, 8'hCF,

    8'hD0, 8'hEF, 8'hAA, 8'hFB, 8'h43, 8'h4D, 8'h33, 8'h85,
    8'h45, 8'hF9, 8'h02, 8'h7F, 8'h50, 8'h3C, 8'h9F, 8'hA8,

    8'h51, 8'hA3, 8'h40, 8'h8F, 8'h92, 8'h9D, 8'h38, 8'hF5,
    8'hBC, 8'hB6, 8'hDA, 8'h21, 8'h10, 8'hFF, 8'hF3, 8'hD2,

    8'hCD, 8'h0C, 8'h13, 8'hEC, 8'h5F, 8'h97, 8'h44, 8'h17,
    8'hC4, 8'hA7, 8'h7E, 8'h3D, 8'h64, 8'h5D, 8'h19, 8'h73,

    8'h60, 8'h81, 8'h4F, 8'hDC, 8'h22, 8'h2A, 8'h90, 8'h88,
    8'h46, 8'hEE, 8'hB8, 8'h14, 8'hDE, 8'h5E, 8'h0B, 8'hDB,

    8'hE0, 8'h32, 8'h3A, 8'h0A, 8'h49, 8'h06, 8'h24, 8'h5C,
    8'hC2, 8'hD3, 8'hAC, 8'h62, 8'h91, 8'h95, 8'hE4, 8'h79,

    8'hE7, 8'hC8, 8'h37, 8'h6D, 8'h8D, 8'hD5, 8'h4E, 8'hA9,
    8'h6C, 8'h56, 8'hF4, 8'hEA, 8'h65, 8'h7A, 8'hAE, 8'h08,

    8'hBA, 8'h78, 8'h25, 8'h2E, 8'h1C, 8'hA6, 8'hB4, 8'hC6,
    8'hE8, 8'hDD, 8'h74, 8'h1F, 8'h4B, 8'hBD, 8'h8B, 8'h8A,

    8'h70, 8'h3E, 8'hB5, 8'h66, 8'h48, 8'h03, 8'hF6, 8'h0E,
    8'h61, 8'h35, 8'h57, 8'hB9, 8'h86, 8'hC1, 8'h1D, 8'h9E,

    8'hE1, 8'hF8, 8'h98, 8'h11, 8'h69, 8'hD9, 8'h8E, 8'h94,
    8'h9B, 8'h1E, 8'h87, 8'hE9, 8'hCE, 8'h55, 8'h28, 8'hDF,

    8'h8C, 8'hA1, 8'h89, 8'h0D, 8'hBF, 8'hE6, 8'h42, 8'h68,
    8'h41, 8'h99, 8'h2D, 8'h0F, 8'hB0, 8'h54, 8'hBB, 8'h16
  };

  localparam logic [7:0] SboxInv [256] = '{
    8'h52, 8'h09, 8'h6a, 8'hd5, 8'h30, 8'h36, 8'ha5, 8'h38,
    8'hbf, 8'h40, 8'ha3, 8'h9e, 8'h81, 8'hf3, 8'hd7, 8'hfb,

    8'h7c, 8'he3, 8'h39, 8'h82, 8'h9b, 8'h2f, 8'hff, 8'h87,
    8'h34, 8'h8e, 8'h43, 8'h44, 8'hc4, 8'hde, 8'he9, 8'hcb,

    8'h54, 8'h7b, 8'h94, 8'h32, 8'ha6, 8'hc2, 8'h23, 8'h3d,
    8'hee, 8'h4c, 8'h95, 8'h0b, 8'h42, 8'hfa, 8'hc3, 8'h4e,

    8'h08, 8'h2e, 8'ha1, 8'h66, 8'h28, 8'hd9, 8'h24, 8'hb2,
    8'h76, 8'h5b, 8'ha2, 8'h49, 8'h6d, 8'h8b, 8'hd1, 8'h25,

    8'h72, 8'hf8, 8'hf6, 8'h64, 8'h86, 8'h68, 8'h98, 8'h16,
    8'hd4, 8'ha4, 8'h5c, 8'hcc, 8'h5d, 8'h65, 8'hb6, 8'h92,

    8'h6c, 8'h70, 8'h48, 8'h50, 8'hfd, 8'hed, 8'hb9, 8'hda,
    8'h5e, 8'h15, 8'h46, 8'h57, 8'ha7, 8'h8d, 8'h9d, 8'h84,

    8'h90, 8'hd8, 8'hab, 8'h00, 8'h8c, 8'hbc, 8'hd3, 8'h0a,
    8'hf7, 8'he4, 8'h58, 8'h05, 8'hb8, 8'hb3, 8'h45, 8'h06,

    8'hd0, 8'h2c, 8'h1e, 8'h8f, 8'hca, 8'h3f, 8'h0f, 8'h02,
    8'hc1, 8'haf, 8'hbd, 8'h03, 8'h01, 8'h13, 8'h8a, 8'h6b,

    8'h3a, 8'h91, 8'h11, 8'h41, 8'h4f, 8'h67, 8'hdc, 8'hea,
    8'h97, 8'hf2, 8'hcf, 8'hce, 8'hf0, 8'hb4, 8'he6, 8'h73,

    8'h96, 8'hac, 8'h74, 8'h22, 8'he7, 8'had, 8'h35, 8'h85,
    8'he2, 8'hf9, 8'h37, 8'he8, 8'h1c, 8'h75, 8'hdf, 8'h6e,

    8'h47, 8'hf1, 8'h1a, 8'h71, 8'h1d, 8'h29, 8'hc5, 8'h89,
    8'h6f, 8'hb7, 8'h62, 8'h0e, 8'haa, 8'h18, 8'hbe, 8'h1b,

    8'hfc, 8'h56, 8'h3e, 8'h4b, 8'hc6, 8'hd2, 8'h79, 8'h20,
    8'h9a, 8'hdb, 8'hc0, 8'hfe, 8'h78, 8'hcd, 8'h5a, 8'hf4,

    8'h1f, 8'hdd, 8'ha8, 8'h33, 8'h88, 8'h07, 8'hc7, 8'h31,
    8'hb1, 8'h12, 8'h10, 8'h59, 8'h27, 8'h80, 8'hec, 8'h5f,

    8'h60, 8'h51, 8'h7f, 8'ha9, 8'h19, 8'hb5, 8'h4a, 8'h0d,
    8'h2d, 8'he5, 8'h7a, 8'h9f, 8'h93, 8'hc9, 8'h9c, 8'hef,

    8'ha0, 8'he0, 8'h3b, 8'h4d, 8'hae, 8'h2a, 8'hf5, 8'hb0,
    8'hc8, 8'heb, 8'hbb, 8'h3c, 8'h83, 8'h53, 8'h99, 8'h61,

    8'h17, 8'h2b, 8'h04, 8'h7e, 8'hba, 8'h77, 8'hd6, 8'h26,
    8'he1, 8'h69, 8'h14, 8'h63, 8'h55, 8'h21, 8'h0c, 8'h7d
  };

  // Types
  typedef elen_t [2:0][NrLanes-1:0] operand_grp_t;
  typedef elen_t      [NrLanes-1:0] operand_t;

  // used for easy operand indexing
  typedef enum int {
    VS2 = 0,
    VD  = 1,
    VS1 = 2
  } operands_e;

  // encoding/decoding selection
  typedef enum bit {
    DEC = 1'b0,
    ENC = 1'b1
  } enc_sel_e;

  // vector-vector/vector-scalar encoding
  typedef enum bit {
    VS = 0,
    VV = 1
  } vec_scal_enc_e;

  // SHA-2 Compression High/Low encoding
  typedef enum bit {
    SHA2_COMP_HIGH = 0,
    SHA2_COMP_LOW  = 1
  } sha_2_comp_e;

  // dynamic object to store operation + data
  class CryptoRequest;

    vid_t               id;        // ID of the vector instruction
    ara_op_e            op;        // Operation
    logic         [4:0] vs1;       // 1st vector register operand
    logic         [4:0] vs2;       // 2nd vector register operand
    logic         [4:0] vd;        // Destination vector register
    elen_t              scalar_op; // Scalar operand
    vlen_t              vl;        // vector length (elements)
    vlen_t              vstart;    // starting element ID in the vector
    eg_len_t            eg_len;    // length in "element groups"
    vtype_t             vtype;     // populated by seq

    logic               use_vs1       = 1'b0;
    logic               use_vs2       = 1'b0;
    logic               use_vd        = 1'b0;
    logic               read_vd       = 1'b0;
    logic               use_scalar_op = 1'b0;
    vec_scal_enc_e      vec_scal      = VV;

    string             object_id = "CryptoRequest";

    function new (
      int unsigned        id,
      ara_op_e            op,
      int unsigned        vs1,
      int unsigned        vs2,
      int unsigned        vd,
      int unsigned        scalar_op,
      int unsigned        vl,
      int unsigned        vstart
    );
      this.id        = id;
      this.op        = op;
      this.vs1       = vs1;
      this.vs2       = vs2;
      this.vd        = vd;
      this.use_vd    = 1'b1;
      this.scalar_op = scalar_op;
      this.vl        = vl;
      this.vstart    = vstart;
      this.eg_len    = vl >> 2;
      this.vec_scal  = (this.op inside {[VAESDF_VS:VAESZ_VS]} ||
                        this.op == VSM4R_VS) ? VS : VV;

      case(this.op) inside
        [VGHSH:VSHA2MS]: begin
          this.use_vs1       = 1'b1;
          this.use_vs2       = 1'b1;
          this.read_vd       = 1'b1;
          this.use_scalar_op = 1'b0;
        end
        VAESK1: begin
          this.use_vs1       = 1'b0;
          this.use_vs2       = 1'b1;
          this.read_vd       = 1'b0;
          this.use_scalar_op = 1'b1;
        end
        VAESK2: begin
          this.use_vs1       = 1'b0;
          this.use_vs2       = 1'b1;
          this.read_vd       = 1'b1;
          this.use_scalar_op = 1'b1;
        end
        [VAESDF_VV:VGMUL]: begin
          this.use_vs1       = 1'b0;
          this.use_vs2       = 1'b1;
          this.read_vd       = 1'b1;
          this.use_scalar_op = 1'b0;
        end
        VSM4K: begin
          this.use_vs1       = 1'b0;
          this.use_vs2       = 1'b1;
          this.read_vd       = 1'b1;
          this.use_scalar_op = 1'b1;
        end
        VSM4R_VV: begin
          this.use_vs1       = 1'b0;
          this.use_vs2       = 1'b1;
          this.read_vd       = 1'b1;
          this.use_scalar_op = 1'b0;
        end
        VSM4R_VS: begin
          this.use_vs1       = 1'b0;
          this.use_vs2       = 1'b1;
          this.read_vd       = 1'b1;
          this.use_scalar_op = 1'b1;
        end
        VSM3ME: begin
          this.use_vs1       = 1'b1;
          this.use_vs2       = 1'b1;
          this.read_vd       = 1'b0;
          this.use_scalar_op = 1'b0;
        end
        VSM3C: begin
          this.use_vs1       = 1'b0;
          this.use_vs2       = 1'b1;
          this.read_vd       = 1'b1;
          this.use_scalar_op = 1'b0;
        end
        default:
          $fatal(1, "[%s:%0d @ %0t] Unrecognised op!", `__FILE__, `__LINE__, $realtime);
      endcase

      // Error checking
      assert ((id <= NrVInsn) && (id >= 1)) else
        $fatal(1, "[%s:%0d @ %0t] ID cannot be greater than NrVInsn or less than 1!", `__FILE__,
          `__LINE__, $realtime);

      assert ((vs1 < 32) && (vs2 < 32) && (vd < 32)) else
        $fatal(1, "[%s:%0d @ %0t] Register address cannot be larger then size of VRF!", `__FILE__,
          `__LINE__, $realtime);

      assert ((vl % 4) == 0) else
        $fatal(1, "[%s:%0d @ %0t] vl must be a multiple of 4!", `__FILE__, `__LINE__, $realtime);

    endfunction


    // print out the op being performed
    function void print_op;
      $display("\n[%s @ %0t] Op Cfg Values:", this.object_id, $realtime);
      $display("\tid:        %4d", id);
      $display("\top:        %s",  op);
      $display("\tvs1:       %4d", vs1);
      $display("\tvs2:       %4d", vs2);
      $display("\tvd:        %4d", vd);
      $display("\tscalar_op: %4d", scalar_op);
      $display("\tvl:        %4d", vl);
      $display("\tvstart:    %4d", vstart);
      $display("\teg_len:    %4d", eg_len);
    endfunction

  endclass

  // Simple sequencer just to act as a buffer for now
  class Sequencer;

    CryptoRequest request_queue [$];
    vtype_t       curr_vtype = '0; // vtype set by sequencer as it is a system configuration

    string        object_id = "Sequencer";

    function new;
      this.curr_vtype.vta   = 1;
      this.curr_vtype.vsew  = EW32;
      this.curr_vtype.vlmul = LMUL_1;
    endfunction

    function void add_request(CryptoRequest cr_req);
      // perform shallow copy
      CryptoRequest req = new cr_req;
      // add vtype to Crypto req
      req.vtype = curr_vtype;
      request_queue.push_back(req);
    endfunction

    function CryptoRequest get_request;
      return request_queue.pop_front();
    endfunction

    function bit is_empty;
      if (request_queue.size())
        return 0;
      else
        return 1;
    endfunction

    function void set_vtype(
      logic vill,
      logic vma,
      logic vta,
      vew_e vsew,
      vlmul_e vlmul
    );
      this.curr_vtype.vill  = vill;
      this.curr_vtype.vma   = vma;
      this.curr_vtype.vta   = vta;
      this.curr_vtype.vsew  = vsew;
      this.curr_vtype.vlmul = vlmul;
    endfunction

  endclass

  // Test data object to pass to scoreboard for checking
  class TestDataItem;

    operand_grp_t operands [];
    operand_t     results  [];
    CryptoRequest crypto_req;

    string        object_id = "TestDataItem";

    function new();
    endfunction

    function void print();

      $display("\n[%s @ %0t] Test Data Values:", this.object_id, $realtime);

      $display("\n\tOp Cfg Values:");
      $display("\t\tid:        %4d", crypto_req.id);
      $display("\t\top:        %s",  crypto_req.op);
      $display("\t\tvs1:       %4d", crypto_req.vs1);
      $display("\t\tvs2:       %4d", crypto_req.vs2);
      $display("\t\tvd:        %4d", crypto_req.vd);
      $display("\t\tscalar_op: %4d", crypto_req.scalar_op);
      $display("\t\tvl:        %4d", crypto_req.vl);
      $display("\t\tvstart:    %4d", crypto_req.vstart);
      $display("\t\teg_len:    %4d", crypto_req.eg_len);

      $display("\n\tOperands:");
      foreach (this.operands[entry]) begin
        for(int lane = 0; lane < NrLanes; lane++) begin
           $display("\t\tEntry: %0d, Lane: %0d", entry, lane);
           $display("\t\t\tvs2 value = %16H", this.operands[entry][VS2][lane]);
           $display("\t\t\tvd  value = %16H", this.operands[entry][VD][lane]);
           $display("\t\t\tvs1 value = %16H", this.operands[entry][VS1][lane]);
        end
      end

      $display("\n\tResults:");
      foreach (this.results[entry]) begin
        $display("\t\tEntry: %0d", entry);
        for(int lane = 0; lane < NrLanes; lane++) begin
           $display("\t\t\tLane %0d, Result = %16H", lane, this.results[entry][lane]);
        end
      end

    endfunction

  endclass

  // Driver to interface with DUT and control handshaking
  class Driver;

    Sequencer     seq = null;
    mailbox       scoreboard_mbx;

    // vif to dut
    virtual crypto_if dut_vif;

    // queue to store requests
    // dynamic array to hold variable number operands, depending on request
    operand_grp_t       operands [];
    operand_t           results  [];

    string              object_id = "Driver";

    // register sequencer
    function new(virtual crypto_if vif, mailbox mbx);
      this.seq     = new();
      this.dut_vif = vif;
      // initialise interface inputs to 0
      this.dut_vif.pe_req_i                  = '0;
      this.dut_vif.pe_req_valid_i            = '0;
      this.dut_vif.pe_vinsn_running_i        = '0;
      this.dut_vif.crypto_operand_i          = '0;
      this.dut_vif.crypto_operand_valid_i    = '0;
      this.dut_vif.crypto_result_gnt_i       = '0;
      this.dut_vif.crypto_result_final_gnt_i = '0;
      this.scoreboard_mbx                    = mbx;
    endfunction

     // Initialise the operands using random data
    function void create_operands(vlen_t vl, vew_e sew);

      // calculate how many elements are in the dynamic operands array
      // each array element is referred to as an "operand group"
      automatic int velems_per_group = (((ELEN/8)*NrLanes) >> int'(sew));
      automatic int operand_grp_cnt  = ((int'(vl)-1) / velems_per_group) + 1;

      // create new operand array
      this.operands = new[operand_grp_cnt];

      foreach (this.operands[operand_grp]) begin
        for (int operand = 0; operand < OperandNum; operand++) begin
          for (int lane = 0; lane < NrLanes; lane++) begin

            automatic elen_t tmp_rnd_val = '0;
            std::randomize(tmp_rnd_val); // Note: Implementation dependent randomization function

            this.operands[operand_grp][operand][lane] = tmp_rnd_val;

          end
        end
      end

    endfunction

    // print out elements within the operand array
    function void print_operands;
      $display("\n[%s @ %0t] Operand Values:", this.object_id, $realtime);
      foreach (this.operands[entry]) begin
        for(int lane = 0; lane < NrLanes; lane++) begin
           $display("\tEntry: %0d, Lane: %0d", entry, lane);
           $display("\t\tvs2 value = %16H", this.operands[entry][0][lane]);
           $display("\t\tvd  value = %16H", this.operands[entry][1][lane]);
           $display("\t\tvs1 value = %16H", this.operands[entry][2][lane]);
        end
      end
    endfunction

    task run_all_req();

      // check if there is a req to send
      if (seq.is_empty()) begin
        $error("[%s:%0d @ %0t] Attempted to read empty sequencer buffer!", `__FILE__,
          `__LINE__, $realtime);
        return;
      end

      while (this.seq.is_empty() == 0) begin
        this.run_single_req();
      end

    endtask

    task run_single_req();

      automatic CryptoRequest tmp_crypto_req = null;
      automatic pe_req_t      tmp_pe_req     = '0;
      automatic integer operand_grp_count    = 0;
      automatic int elements_per_group       = 0;
      // used to track how many results are left
      automatic int elem_remaining_res         = 0;
      automatic int operand_group_count_scalar = 0;
      automatic int result_group               = 0;
      // object to send to scoreboard
      TestDataItem test_data_item = new();

      // check if there is a req to send
      if (this.seq.is_empty()) begin
        $error("[%s:%0d @ %0t] Attempted to read empty sequencer buffer!", `__FILE__,
          `__LINE__, $realtime);
        return;
      end

      // get request and use it to populate pe_req
      tmp_crypto_req = seq.get_request();

      // populate useful fields of pe_req
      tmp_pe_req.id            = tmp_crypto_req.id;
      tmp_pe_req.op            = tmp_crypto_req.op;
      tmp_pe_req.use_vs1       = tmp_crypto_req.use_vs1;
      tmp_pe_req.vs1           = tmp_crypto_req.vs1;
      tmp_pe_req.use_vs2       = tmp_crypto_req.use_vs2;
      tmp_pe_req.vs2           = tmp_crypto_req.vs2;
      tmp_pe_req.use_vd        = tmp_crypto_req.use_vd;
      tmp_pe_req.vd            = tmp_crypto_req.vd;
      tmp_pe_req.scalar_op     = tmp_crypto_req.scalar_op;
      tmp_pe_req.use_scalar_op = tmp_crypto_req.use_scalar_op;
      tmp_pe_req.vl            = tmp_crypto_req.vl;
      tmp_pe_req.vstart        = tmp_crypto_req.vstart;
      tmp_pe_req.vtype         = seq.curr_vtype;
      tmp_pe_req.vfu           = VFU_CryptoUnit;

      // ((ELEN*NrLanes) >> (3 + tmp_pe_req.vtype.vsew)) provides the number of elements
      // which each operand group can provide with the current sew configuration
      elements_per_group = (((ELEN/8)*NrLanes) >> int'(tmp_pe_req.vtype.vsew));
      operand_grp_count  = ((tmp_pe_req.vl-1) / elements_per_group) + 1;
      // if there is a vector-scalar operation being performed, the scalar operand should only
      // contain a single vector element group. An element group is 4 elements.
      operand_group_count_scalar = (3 / elements_per_group) + 1;

      // generate operands for this request
      this.create_operands(tmp_pe_req.vl, tmp_pe_req.vtype.vsew);

      // send pe_req to IF
      @(negedge dut_vif.clk_i);
      while (dut_vif.pe_req_ready_o == 1'b0) begin
        @(negedge dut_vif.clk_i);
      end

      dut_vif.pe_req_valid_i = 1'b1;
      dut_vif.pe_req_i       = tmp_pe_req;

      @(negedge dut_vif.clk_i);
      dut_vif.pe_req_valid_i = 1'b0;

      @(negedge dut_vif.clk_i);

      // deliver operands to crypto unit + extract results concurrently

      // create results array
      // the operand_grp_count should match the number of operand results sent back to VRF
      results         = new[operand_grp_count];
      elem_remaining_res  = tmp_pe_req.vl;

      fork

        begin // Vs2 operand queue

          automatic int vs2_operand_count = (tmp_crypto_req.vec_scal == VV) ?
              operand_grp_count : operand_group_count_scalar;

          // skip if operand not in use
          if (tmp_crypto_req.use_vs2 == 1'b1) begin

            //$display("vs2_operand_count = %0d", vs2_operand_count);

            // iterate through operand groups and write data into buffer
            for (int group = 0; group < vs2_operand_count; group++) begin

              automatic operand_t curr_operand = operands[group][VS2];

              // wait for all lane buffers to be ready
              while(&dut_vif.crypto_operand_ready_o[VS2] != 1'b1) begin
                @(negedge dut_vif.clk_i);
              end

              // value + valid should be set at rising edge
              @(posedge dut_vif.clk_i);

              for (int lane = 0; lane < NrLanes; lane++) begin
                dut_vif.crypto_operand_valid_i[lane][VS2] = 1'b1;
                dut_vif.crypto_operand_i[lane][VS2]       = curr_operand[lane];
              end

              @(posedge dut_vif.clk_i);

              for (int lane = 0; lane < NrLanes; lane++) begin
                dut_vif.crypto_operand_valid_i[lane][VS2] = 1'b0;
                dut_vif.crypto_operand_i[lane][VS2]       = '0;
              end

              @(negedge dut_vif.clk_i);

            end
          end
        end

        begin // Vd operand queue

          // skip if operand not in use
          if (tmp_crypto_req.read_vd == 1'b1) begin

            // iterate through operand groups
            for (int group = 0; group < operand_grp_count; group++) begin

              automatic operand_t curr_operand = operands[group][VD];

              // wait for all lane buffers to be ready
              while(&dut_vif.crypto_operand_ready_o[VD] != 1'b1) begin
                @(negedge dut_vif.clk_i);
              end

              // value + valid should be set at rising edge
              @(posedge dut_vif.clk_i);

              for (int lane = 0; lane < NrLanes; lane++) begin
                dut_vif.crypto_operand_valid_i[lane][VD] = 1'b1;
                dut_vif.crypto_operand_i[lane][VD]       = curr_operand[lane];
              end

              @(posedge dut_vif.clk_i);

              for (int lane = 0; lane < NrLanes; lane++) begin
                dut_vif.crypto_operand_valid_i[lane][VD] = 1'b0;
                dut_vif.crypto_operand_i[lane][VD]       = '0;
              end

              @(negedge dut_vif.clk_i);

            end
          end
        end

        begin // VS1 operand queue

          // skip if operand not in use
          if (tmp_crypto_req.use_vs1 == 1'b1) begin

            // iterate through operand groups
            for (int group = 0; group < operand_grp_count; group++) begin

              automatic operand_t curr_operand = operands[group][VS1];

              // wait for all lane buffers to be ready
              while(&dut_vif.crypto_operand_ready_o[VS1] != 1'b1) begin
                @(negedge dut_vif.clk_i);
              end

              // value + valid should be set at rising edge
              @(posedge dut_vif.clk_i);

              for (int lane = 0; lane < NrLanes; lane++) begin
                dut_vif.crypto_operand_valid_i[lane][VS1] = 1'b1;
                dut_vif.crypto_operand_i[lane][VS1]       = curr_operand[lane];
              end

              @(posedge dut_vif.clk_i);

              for (int lane = 0; lane < NrLanes; lane++) begin
                dut_vif.crypto_operand_valid_i[lane][VS1] = 1'b0;
                dut_vif.crypto_operand_i[lane][VS1]       = '0;
              end

              @(negedge dut_vif.clk_i);

            end
          end
        end

        begin // Extract results

          @(negedge dut_vif.clk_i);

          // once all operands of current operation has been sent, collect the result
          dut_vif.crypto_result_gnt_i = '1;

          // collect all results into array
          while(elem_remaining_res != 0) begin

            // wait for result
            while(&dut_vif.crypto_result_req_o == 1'b0) begin
              @(negedge dut_vif.clk_i);
            end

            // log result and increment group index
            // filter bytes using the value of byte enable
            for (int lane = 0; lane < NrLanes; lane++) begin
              for (int lane_byte = 0; lane_byte < StrbWidth; lane_byte++) begin
                if (dut_vif.crypto_result_be_o[lane][lane_byte] == 1'b1) begin
                  results[result_group][lane][(lane_byte*8) +: 8] =
                    dut_vif.crypto_result_wdata_o[lane][(lane_byte*8) +: 8];
                end else begin
                  results[result_group][lane][(lane_byte*8) +: 8] = '0;
                end
              end
            end

            result_group++;

            // if size of elements remaining is smaller than number of elements in each request,
            // set elem remaining to zero
            if (elem_remaining_res < elements_per_group) begin
              elem_remaining_res = 0;
            end else begin
              elem_remaining_res -= elements_per_group;
            end

            @(negedge dut_vif.clk_i);

          end
        end
      join

      // write data to scoreboard
      test_data_item.operands   = new[this.operands.size()](this.operands);
      test_data_item.results    = new[this.results.size()](this.results);
      test_data_item.crypto_req = tmp_crypto_req;

      this.scoreboard_mbx.put(test_data_item);

    endtask

  endclass;

  // reads inputs/outputs and performs correctness checks using a golden model
  class Scoreboard;

    mailbox       scoreboard_mbx;
    TestDataItem  curr_test_data = null;

    // unpacked data for comparison
    bit [MAXVLEN-1:0] op_data_vs2;
    bit [MAXVLEN-1:0] op_data_vd;
    bit [MAXVLEN-1:0] op_data_vs1;
    bit [MAXVLEN-1:0] op_data_res;
    // golden results to contain output from model
    bit [MAXVLEN-1:0] golden_res;

    string        object_id = "Scoreboard";

    function new(mailbox mbx);
      this.scoreboard_mbx = mbx;
    endfunction

    task run;

      forever begin
        scoreboard_mbx.get(curr_test_data);
        //curr_test_data.print();
        this.unpack_test_data();
        this.run_model();
        this.check_result();
      end

    endtask

    // unpack data from current test data into "registers"
    function void unpack_test_data();

      // shallow copy members to make referencing easier
      automatic CryptoRequest curr_req          = curr_test_data.crypto_req;
      automatic operand_grp_t  curr_operands [] = curr_test_data.operands;
      automatic operand_t      curr_results  [] = curr_test_data.results;

      automatic int curr_grp_count  = 0;
      automatic int max_byte_count  = (2 << int'(curr_req.vtype.vsew)) * curr_req.vl;
      automatic int bytes_per_group = ((ELEN*NrLanes) / 8);

      //initialise registers to 0
      this.op_data_vs2 = '0;
      this.op_data_vd  = '0;
      this.op_data_vs1 = '0;
      this.op_data_res = '0;

      // unpack operands
      for (int operand = 0; operand < OperandNum; operand++) begin
        for (int byte_idx = 0; byte_idx < max_byte_count; byte_idx++) begin

          automatic vlen_t operand_byte_idx = shuffle_index(byte_idx, NrLanes, curr_req.vtype.vsew);
          automatic int byte_offset = int'(operand_byte_idx[2:0]);
          automatic int lane_idx    = int'(operand_byte_idx >> 3);

          if (operand == VS2) begin
            this.op_data_vs2[(byte_idx*8) +: 8] =
              curr_operands[curr_grp_count][operand][lane_idx][(byte_offset*8) +: 8];
          end else if (operand == VD) begin
            this.op_data_vd[(byte_idx*8) +: 8] =
              curr_operands[curr_grp_count][operand][lane_idx][(byte_offset*8) +: 8];
          end else begin
            this.op_data_vs1[(byte_idx*8) +: 8] =
              curr_operands[curr_grp_count][operand][lane_idx][(byte_offset*8) +: 8];
          end

          // increment group count when byte counter is one below next group
          if ((byte_idx + 1) % bytes_per_group == 0) begin
            curr_grp_count++;
          end

        end

        curr_grp_count = 0;

      end

      // unpack results
      for (int byte_idx = 0; byte_idx < max_byte_count; byte_idx++) begin

        automatic vlen_t res_byte_idx = shuffle_index(byte_idx, NrLanes, curr_req.vtype.vsew);
        automatic int    byte_offset = int'(res_byte_idx[2:0]);
        automatic int    lane_idx    = int'(res_byte_idx >> 3);

        this.op_data_res[(byte_idx*8) +: 8] =
          curr_results[curr_grp_count][lane_idx][(byte_offset*8) +: 8];

        // increment group count when byte counter is one below next group
        if ((byte_idx + 1) % bytes_per_group == 0) begin
          curr_grp_count++;
        end
      end

    endfunction

    // use crypto request data to select and call correct golden model
    function void run_model();

      automatic ara_op_e op = this.curr_test_data.crypto_req.op;

      // clear golden results before running model
      this.golden_res = '0;

      case(op)
        VAESK1    : this.golden_aes_key_expansion_128();
        VAESK2    : this.golden_aes_key_expansion_256();
        VAESZ_VS  : this.golden_aes_zero_round();
        VAESEM_VV : this.golden_aes_enc_mid(VV);
        VAESEF_VV : this.golden_aes_enc_fin(VV);
        VAESDM_VV : this.golden_aes_dec_mid(VV);
        VAESDF_VV : this.golden_aes_dec_fin(VV);
        VAESEM_VS : this.golden_aes_enc_mid(VS);
        VAESEF_VS : this.golden_aes_enc_fin(VS);
        VAESDM_VS : this.golden_aes_dec_mid(VS);
        VAESDF_VS : this.golden_aes_dec_fin(VS);
        VSHA2CH   : this.golden_sha2_compr(SHA2_COMP_HIGH);
        VSHA2CL   : this.golden_sha2_compr(SHA2_COMP_LOW);
        VSHA2MS   : this.golden_sha2_msg_sched();
        VGMUL     : this.golden_vector_mult_ghash();
        VGHSH     : this.golden_vector_add_mult_ghash();
        VSM4K     : this.golden_sm4_key_expansion();
        VSM4R_VV  : this.golden_sm4_enc_round(VV);
        VSM4R_VS  : this.golden_sm4_enc_round(VS);
        VSM3ME    : this.golden_sm3_msg_expansion();
        VSM3C     : this.golden_sm3_compr();

        default: begin
          $fatal(1, "[%s:%0d @ %0t] Unrecognised/Unimplemented op!",
                      `__FILE__, `__LINE__, $realtime);
        end
      endcase

    endfunction

    function void check_result();
      // print unpacked data
      $display("\n[%s @ %0t] Unpacked Operand/Result Values for %s:", this.object_id, $realtime,
        this.curr_test_data.crypto_req.op);
      $display("\top_data_vs2 = 0x%0H", this.op_data_vs2);
      $display("\top_data_vd  = 0x%0H", this.op_data_vd);
      $display("\top_data_vs1 = 0x%0H", this.op_data_vs1);
      $display("\t---------------------------------------");
      $display("\top_data_res = 0x%0H", this.op_data_res);
      $display("\tgolden_res  = 0x%0H\n", this.golden_res);

      assert (this.op_data_res == this.golden_res)
        else $error("[%s:%0d @ %0t] Data mismatch in checker!",
                      `__FILE__, `__LINE__, $realtime);

    endfunction

  /**************************************************************************
   * SM4-128 KEY EXPANSION                                                  *
   **************************************************************************/
    function void golden_sm4_key_expansion();
      automatic vlen_t   vl  = this.curr_test_data.crypto_req.vl;
      automatic int EGS      = 4;
      automatic int eg_len   = vl/EGS;
      automatic int eg_start = this.curr_test_data.crypto_req.vstart/EGS;
      automatic bit [MAXVLEN-1:0] vs2 = this.op_data_vs2;

      automatic bit [31:0] B;
      automatic bit [31:0] S;
      automatic bit [31:0] rk0;
      automatic bit [31:0] rk1;
      automatic bit [31:0] rk2;
      automatic bit [31:0] rk3;
      automatic bit [31:0] rk4;
      automatic bit [31:0] rk5;
      automatic bit [31:0] rk6;
      automatic bit [31:0] rk7;
      automatic bit [ 2:0] rnd = this.curr_test_data.crypto_req.scalar_op[2:0];

      for (int i = eg_start; i < eg_len; i++) begin
        
        {rk3,rk2,rk1,rk0} = vs2[(i*EGW128) +: EGW128];
        
        B = rk1 ^ rk2 ^ rk3 ^ sm_constant_key(4*rnd);
        S = sm_subword_fwd(B); 
        rk4 = sm_round_key(rk0, S);
        
        B = rk2 ^ rk3 ^ rk4 ^ sm_constant_key((4 * rnd) + 1);
        S = sm_subword_fwd(B);
        rk5 = sm_round_key(rk1, S);
        
        B = rk3 ^ rk4 ^ rk5 ^ sm_constant_key((4 * rnd) + 2);
        S = sm_subword_fwd(B);
        rk6 = sm_round_key(rk2, S);
        
        B = rk4 ^ rk5 ^ rk6 ^ sm_constant_key((4 * rnd) + 3);
        S = sm_subword_fwd(B);
        rk7 = sm_round_key(rk3, S);
        
        this.golden_res[(i*EGW128) +: EGW128] = {rk7,rk6,rk5,rk4};

      end
    endfunction

  /**************************************************************************
   * SM4-128 Block Cipher Encode Rounds                                     *
   **************************************************************************/
  function void golden_sm4_enc_round(vec_scal_enc_e enc);
    automatic vlen_t   vl  = this.curr_test_data.crypto_req.vl;
    automatic int EGS      = 4;
    automatic int eg_len   = vl/EGS;
    automatic int eg_start = this.curr_test_data.crypto_req.vstart/EGS;
    automatic bit [MAXVLEN-1:0] vs2 = this.op_data_vs2;
    automatic bit [MAXVLEN-1:0] vd  = this.op_data_vd;
  
    automatic bit [31:0] B;
    automatic bit [31:0] S;
    automatic bit [31:0] rk0;
    automatic bit [31:0] rk1;
    automatic bit [31:0] rk2;
    automatic bit [31:0] rk3;
    automatic bit [31:0] x0;
    automatic bit [31:0] x1;
    automatic bit [31:0] x2;
    automatic bit [31:0] x3;
    automatic bit [31:0] x4;
    automatic bit [31:0] x5;
    automatic bit [31:0] x6;
    automatic bit [31:0] x7;
  
    for (int i = eg_start; i < eg_len; i++) begin
      automatic int key_elem = (enc == VV) ? i : 0;

      {rk3,rk2,rk1,rk0} = vs2[(key_elem*128) +: 128];
      {x3,x2,x1,x0} = vd[(i*128) +: 128];
  
      B = x1 ^ x2 ^ x3 ^ rk0;
      S = sm_subword_fwd(B); 
      x4 = sm_round(x0, S);
  
      B = x2 ^ x3 ^ x4 ^ rk1;
      S = sm_subword_fwd(B);
      x5 = sm_round(x1, S);
  
      B = x3 ^ x4 ^ x5 ^ rk2;
      S = sm_subword_fwd(B);
      x6 = sm_round(x2, S);
  
      B = x4 ^ x5 ^ x6 ^ rk3;
      S = sm_subword_fwd(B);
      x7 = sm_round(x3, S);
  
      this.golden_res[(i*128) +: 128] = {x7,x6,x5,x4};
    end
  endfunction
    
  /**************************************************************************
   * SM3-256 Vector Message Expansion                                       *
   **************************************************************************/
    // golden model for Vector SM3 Message expansion
    // Taken from Sail code listed within:
    // RISC-V Cryptography Extensions Volume II : Vector Instructions
    // Version v1.0.0, 22 August 2023 RC3,
    // Chapter 3.24 vsm3me.vv
  function void golden_sm3_msg_expansion();
    automatic vlen_t   vl  = this.curr_test_data.crypto_req.vl;
    automatic int EGS      = 8;
    automatic int eg_len   = vl/EGS;
    automatic int eg_start = this.curr_test_data.crypto_req.vstart/EGS;
    automatic bit [MAXVLEN-1:0] vs2 = this.op_data_vs2;
    automatic bit [MAXVLEN-1:0] vs1 = this.op_data_vs1;

    automatic bit [23:0][31:0] w;

    automatic bit [31:0] w0;
    automatic bit [31:0] w1;
    automatic bit [31:0] w2;
    automatic bit [31:0] w3;
    automatic bit [31:0] w4;
    automatic bit [31:0] w5;
    automatic bit [31:0] w6;
    automatic bit [31:0] w7;
    automatic bit [31:0] w8;
    automatic bit [31:0] w9;
    automatic bit [31:0] w10;
    automatic bit [31:0] w11;
    automatic bit [31:0] w12;
    automatic bit [31:0] w13;
    automatic bit [31:0] w14;
    automatic bit [31:0] w15;

    automatic bit [31:0] w16;
    automatic bit [31:0] w17;
    automatic bit [31:0] w18;
    automatic bit [31:0] w19;
    automatic bit [31:0] w20;
    automatic bit [31:0] w21;
    automatic bit [31:0] w22;
    automatic bit [31:0] w23;

    for (int i = eg_start; i < eg_len; i++) begin
      w[7:0] = vs1[i*256 +: 256];
      w[15:8] = vs2[i*256 +: 256];
      
      w15 = sm_rev8(w[15]);
      w14 = sm_rev8(w[14]);
      w13 = sm_rev8(w[13]);
      w12 = sm_rev8(w[12]);
      w11 = sm_rev8(w[11]);
      w10 = sm_rev8(w[10]);
      w9 = sm_rev8(w[9]);
      w8 = sm_rev8(w[8]);
      w7 = sm_rev8(w[7]);
      w6 = sm_rev8(w[6]);
      w5 = sm_rev8(w[5]);
      w4 = sm_rev8(w[4]);
      w3 = sm_rev8(w[3]);
      w2 = sm_rev8(w[2]);
      w1 = sm_rev8(w[1]);
      w0 = sm_rev8(w[0]);
      
      w[16] = sm_zvksh_w(w0, w7, w13, w3, w10);
      w[17] = sm_zvksh_w(w1, w8, w14, w4, w11);
      w[18] = sm_zvksh_w(w2, w9, w15, w5, w12);
      w[19] = sm_zvksh_w(w3, w10, w[16], w6, w13);
      w[20] = sm_zvksh_w(w4, w11, w[17], w7, w14);
      w[21] = sm_zvksh_w(w5, w12, w[18], w8, w15);
      w[22] = sm_zvksh_w(w6, w13, w[19], w9, w[16]);
      w[23] = sm_zvksh_w(w7, w14, w[20], w10, w[17]);
      
      w16 = sm_rev8(w[16]);
      w17 = sm_rev8(w[17]);
      w18 = sm_rev8(w[18]);
      w19 = sm_rev8(w[19]);
      w20 = sm_rev8(w[20]);
      w21 = sm_rev8(w[21]);
      w22 = sm_rev8(w[22]);
      w23 = sm_rev8(w[23]);
      
      this.golden_res[(i*256) +: 256] = {w23, w22, w21, w20, w19, w18, w17, w16};
      
    end

  endfunction

  /**************************************************************************
   * SM3-256 Vector Compression                                              *
   **************************************************************************/
    // golden model for Vector SM3 Compression
    // Taken from Sail code listed within:
    // RISC-V Cryptography Extensions Volume II : Vector Instructions
    // Version v1.0.0, 22 August 2023 RC3,
    // Chapter 3.23 vsm3c.vi
  function void golden_sm3_compr();
    automatic vlen_t   vl  = this.curr_test_data.crypto_req.vl;
    automatic int EGS      = 8;
    automatic int eg_len   = vl/EGS;
    automatic int eg_start = this.curr_test_data.crypto_req.vstart/EGS;
    automatic bit [MAXVLEN-1:0] vs2 = this.op_data_vs2;
    automatic bit [MAXVLEN-1:0] vd = this.op_data_vd;
    automatic bit [5:0]         rnd = this.curr_test_data.crypto_req.scalar_op[5:0];

    automatic bit [31:0] Hi;
    automatic bit [31:0] Gi;
    automatic bit [31:0] Fi;
    automatic bit [31:0] Ei;
    automatic bit [31:0] Di;
    automatic bit [31:0] Ci;
    automatic bit [31:0] Bi;
    automatic bit [31:0] Ai;

    automatic bit [31:0] u_w7;
    automatic bit [31:0] u_w6;
    automatic bit [31:0] w5i;
    automatic bit [31:0] w4i;
    automatic bit [31:0] u_w3;
    automatic bit [31:0] u_w2;
    automatic bit [31:0] w1i;
    automatic bit [31:0] w0i;

    automatic int j;
    automatic bit [31:0] H;
    automatic bit [31:0] G;
    automatic bit [31:0] F;
    automatic bit [31:0] E;
    automatic bit [31:0] D;
    automatic bit [31:0] C;
    automatic bit [31:0] B;
    automatic bit [31:0] A;

    automatic bit [31:0] w5;
    automatic bit [31:0] w4;
    automatic bit [31:0] w1;
    automatic bit [31:0] w0;

    automatic bit [31:0] x0;
    automatic bit [31:0] x1;

    automatic bit [31:0] ss1;
    automatic bit [31:0] ss2;
    automatic bit [31:0] tt1;
    automatic bit [31:0] tt2;

    automatic bit [31:0] A1;
    automatic bit [31:0] C1;
    automatic bit [31:0] E1;
    automatic bit [31:0] G1;

    automatic bit [31:0] A2;
    automatic bit [31:0] C2;
    automatic bit [31:0] E2;
    automatic bit [31:0] G2;

    automatic bit [255:0] result;

    for (int i = eg_start; i < eg_len; i++) begin
      {Hi, Gi, Fi, Ei, Di, Ci, Bi, Ai} = vd[(i*256) +: 256];
      {u_w7, u_w6, w5i, w4i, u_w3, u_w2, w1i, w0i} = vs2[(i*256) +: 256];
      H = sm_rev8(Hi);
      G = sm_rev8(Gi);
      F = sm_rev8(Fi);
      E = sm_rev8(Ei);
      D = sm_rev8(Di);
      C = sm_rev8(Ci);
      B = sm_rev8(Bi);
      A = sm_rev8(Ai); 
      
      w5 = sm_rev8(w5i);
      w4 = sm_rev8(w4i);
      w1 = sm_rev8(w1i);
      w0 = sm_rev8(w0i);
  
      x0 = w0 ^ w4;
      x1 = w1 ^ w5;
  
      j = 2 * rnd;
      ss1 = sm_ROL32(sm_ROL32(A, 12) + E + sm_ROL32(sm_t_j(j), j % 32), 7);
      ss2 = ss1 ^ sm_ROL32(A, 12);
      tt1 = sm_ff_j(A, B, C, j) + D + ss2 + x0;
      tt2 = sm_gg_j(E, F, G, j) + H + ss1 + w0;
      D = C;
      C1 = sm_ROL32(B, 9);
      B = A;
      A1 = tt1;
      H = G;
      G1 = sm_ROL32(F, 19);
      F = E;
      E1 = sm_p_0(tt2);
  
      j = 2 * rnd + 1;
      ss1 = sm_ROL32(sm_ROL32(A1, 12) + E1 + sm_ROL32(sm_t_j(j), j % 32), 7);
      ss2 = ss1 ^ sm_ROL32(A1, 12);
      tt1 = sm_ff_j(A1, B, C1, j) + D + ss2 + x1;
      tt2 = sm_gg_j(E1, F, G1, j) + H + ss1 + w1;
      D = C1;
      C2 = sm_ROL32(B, 9);
      B = A1;
      A2 = tt1;
      H = G1;
      G2 = sm_ROL32(F, 19);
      F = E1;
      E2 = sm_p_0(tt2);
  
      result = {sm_rev8(G1), sm_rev8(G2), sm_rev8(E1), sm_rev8(E2),
                sm_rev8(C1), sm_rev8(C2), sm_rev8(A1), sm_rev8(A2)};
      
  
      this.golden_res[(i*256) +: 256] = result;
    end
  endfunction

  /**************************************************************************
   * AES-128 KEY EXPANSION                                                  *
   **************************************************************************/

    // golden model for AES128 key expansion
    // Taken from Sail code listed within:
    // RISC-V Cryptography Extensions Volume II : Vector Instructions
    // Version v1.0.0, 22 August 2023 RC3,
    // Chapter 3.5 vaeskf1.vi
    function void golden_aes_key_expansion_128();

      automatic vlen_t   vl  = this.curr_test_data.crypto_req.vl;
      automatic int EGS      = 4;
      automatic int eg_len   = vl/EGS;
      automatic int eg_start = this.curr_test_data.crypto_req.vstart/EGS;

      automatic bit [MAXVLEN-1:0] vs2 = this.op_data_vs2;
      automatic bit      [ 3:0]   rnd = this.curr_test_data.crypto_req.scalar_op[3:0];

      automatic bit      [ 3:0] r;
      automatic bit [3:0][31:0] current_round_key;
      automatic bit      [31:0] w0;
      automatic bit      [31:0] w1;
      automatic bit      [31:0] w2;
      automatic bit      [31:0] w3;

      if ((rnd > 10) || (rnd == 0)) begin
        rnd[3] = ~rnd[3];
      end

      r = rnd-1;

      for (int i = eg_start; i < eg_len; i++) begin

        current_round_key = vs2[(i*128) +: 128];
        w0 = aes_subword_fwd(aes_rotword(current_round_key[3])) ^
             aes_decode_rcon(r) ^ current_round_key[0];
        w1 = w0 ^ current_round_key[1];
        w2 = w1 ^ current_round_key[2];
        w3 = w2 ^ current_round_key[3];

        //$display("\nVAESKF1 GOLDEN RESULTS:");
        //$display("\tElement Group: %0d", i);
        //$display("\t\tcurrent_round_key = 0x%032H", current_round_key);
        //$display("\t\trnd               = 0x%032H", rnd);
        //$display("\t\tword              = 0x%032H", {w3, w2, w1, w0});

        this.golden_res[(i*128) +: 128] = {w3,w2,w1,w0};

      end

    endfunction

  /**************************************************************************
   * AES-256 KEY EXPANSION                                                  *
   **************************************************************************/

    // golden model for AES256 key expansion
    // Taken from Sail code listed within:
    // RISC-V Cryptography Extensions Volume II : Vector Instructions
    // Version v1.0.0, 22 August 2023 RC3,
    // Chapter 3.6 vaeskf2.vi
    function void golden_aes_key_expansion_256();

      automatic vlen_t vl       = this.curr_test_data.crypto_req.vl;
      automatic int    EGS      = 4;
      automatic int    eg_len   = vl/EGS;
      automatic int    eg_start = this.curr_test_data.crypto_req.vstart/EGS;

      automatic bit [MAXVLEN-1:0] vs2 = this.op_data_vs2;
      automatic bit [MAXVLEN-1:0] vd  = this.op_data_vd;
      automatic bit      [ 3:0]   rnd = this.curr_test_data.crypto_req.scalar_op[3:0];

      automatic bit [3:0][31:0] current_round_key;
      automatic bit [3:0][31:0] round_key_B;
      automatic bit      [31:0] w0;
      automatic bit      [31:0] w1;
      automatic bit      [31:0] w2;
      automatic bit      [31:0] w3;

      if ((rnd < 2) || (rnd > 14)) begin
        rnd[3] = ~rnd[3];
      end

      for (int i = eg_start; i < eg_len; i++) begin

        current_round_key = vs2[(i*128) +: 128];
        round_key_B       = vd[(i*128) +: 128]; // previous round

        if (rnd[0] == 1'b1) begin
          w0 = aes_subword_fwd(current_round_key[3]) ^ round_key_B[0];
        end else begin
          w0 = aes_subword_fwd(aes_rotword(current_round_key[3])) ^
               aes_decode_rcon((rnd >> 1)) ^ round_key_B[0];
        end

        w1 = w0 ^ round_key_B[1];
        w2 = w1 ^ round_key_B[2];
        w3 = w2 ^ round_key_B[3];

        //$display("\nVAESKF2 GOLDEN RESULTS:");
        //$display("\tElement Group: %0d", i);
        //$display("\t\tcurrent_round_key = 0x%032H", current_round_key);
        //$display("\t\tround_key_B       = 0x%032H", round_key_B);
        //$display("\t\trnd               = 0x%032H", rnd);
        //$display("\t\tword              = 0x%032H", {w3, w2, w1, w0});

        this.golden_res[(i*128) +: 128] = {w3, w2, w1, w0};

      end

    endfunction

  /**************************************************************************
   * AES ROUND ZERO ENC/DEC                                                 *
   **************************************************************************/

    // golden model for AES round zero encryption/decryption
    // Taken from Sail code listed within:
    // RISC-V Cryptography Extensions Volume II : Vector Instructions
    // Version v1.0.0, 22 August 2023 RC3,
    // Chapter 3.7 vaesz.vs
    function void golden_aes_zero_round();

      automatic vlen_t vl       = this.curr_test_data.crypto_req.vl;
      automatic int    EGS      = 4;
      automatic int    eg_len   = vl/EGS;
      automatic int    eg_start = this.curr_test_data.crypto_req.vstart/EGS;

      automatic bit [MAXVLEN-1:0] vs2 = this.op_data_vs2;
      automatic bit [MAXVLEN-1:0] vd  = this.op_data_vd;

      automatic bit [3:0][31:0] state;
      automatic bit [3:0][31:0] rkey;
      automatic bit [3:0][31:0] ark;

      for (int i = eg_start; i < eg_len; i++) begin

        state = vd[(i*128) +: 128];
        rkey  = vs2[127:0];
        ark   = state ^ rkey;

        //$display("\nVAESZ GOLDEN RESULTS:");
        //$display("\tElement Group: %0d", i);
        //$display("\t\tstate = 0x%032H", state);
        //$display("\t\trkey  = 0x%032H", rkey);
        //$display("\t\tark   = 0x%032H", ark);

        this.golden_res[(i*128) +: 128] = ark;

      end

    endfunction

  /**************************************************************************
   * AES ROUND ENC MID                                                      *
   **************************************************************************/

    // golden model for AES middle round encryption
    // Taken from Sail code listed within:
    // RISC-V Cryptography Extensions Volume II : Vector Instructions
    // Version v1.0.0, 22 August 2023 RC3,
    // Chapter 3.4 vaesem.[vv, vs]
    function void golden_aes_enc_mid(vec_scal_enc_e enc);

      automatic vlen_t vl       = this.curr_test_data.crypto_req.vl;
      automatic int    EGS      = 4;
      automatic int    eg_len   = vl/EGS;
      automatic int    eg_start = this.curr_test_data.crypto_req.vstart/EGS;

      automatic bit [MAXVLEN-1:0] vs2 = this.op_data_vs2;
      automatic bit [MAXVLEN-1:0] vd  = this.op_data_vd;

      automatic bit [3:0][31:0] state;
      automatic bit [3:0][31:0] rkey;
      automatic bit [3:0][31:0] sb;
      automatic bit [3:0][31:0] sr;
      automatic bit [3:0][31:0] mix;
      automatic bit [3:0][31:0] ark;

      for (int i = eg_start; i < eg_len; i++) begin

        automatic int key_elem = (enc == VV) ? i : 0;

        state = vd[(i*128) +: 128];
        rkey  = vs2[(key_elem*128) +: 128];
        sb    = aes_subword_fwd(state);
        sr    = aes_shift_rows(sb, ENC);
        mix   = aes_mix_columns(sr, ENC);
        ark   = mix ^ rkey;

        //$display("\nVAESEM.%s GOLDEN RESULTS:", enc);
        //$display("\tElement Group: %0d", i);
        //$display("\t\tstate = 0x%032H", state);
        //$display("\t\trkey  = 0x%032H", rkey);
        //$display("\t\tsb    = 0x%032H", sb);
        //$display("\t\tsr    = 0x%032H", sr);
        //$display("\t\tmix   = 0x%032H", mix);
        //$display("\t\tark   = 0x%032H", ark);

        this.golden_res[(i*128) +: 128] = ark;

      end

    endfunction

  /**************************************************************************
   * AES ROUND ENC FIN                                                      *
   **************************************************************************/

    // golden model for AES final round encryption
    // Taken from Sail code listed within:
    // RISC-V Cryptography Extensions Volume II : Vector Instructions
    // Version v1.0.0, 22 August 2023 RC3,
    // Chapter 3.3 vaesef.[vv, vs]
    function void golden_aes_enc_fin(vec_scal_enc_e enc);

      automatic vlen_t vl       = this.curr_test_data.crypto_req.vl;
      automatic int    EGS      = 4;
      automatic int    eg_len   = vl/EGS;
      automatic int    eg_start = this.curr_test_data.crypto_req.vstart/EGS;

      automatic bit [MAXVLEN-1:0] vs2 = this.op_data_vs2;
      automatic bit [MAXVLEN-1:0] vd  = this.op_data_vd;

      automatic bit [3:0][31:0] state;
      automatic bit [3:0][31:0] rkey;
      automatic bit [3:0][31:0] sb;
      automatic bit [3:0][31:0] sr;
      automatic bit [3:0][31:0] ark;

      for (int i = eg_start; i < eg_len; i++) begin

        automatic int key_elem = (enc == VV) ? i : 0;

        state = vd[(i*128) +: 128];
        rkey  = vs2[(key_elem*128) +: 128];
        sb    = aes_subword_fwd(state);
        sr    = aes_shift_rows(sb, ENC);
        ark   = sr ^ rkey;

        //$display("\nVAESEF.%s GOLDEN RESULTS:", enc);
        //$display("\tElement Group: %0d", i);
        //$display("\t\tstate = 0x%032H", state);
        //$display("\t\trkey  = 0x%032H", rkey);
        //$display("\t\tsb    = 0x%032H", sb);
        //$display("\t\tsr    = 0x%032H", sr);
        //$display("\t\tark   = 0x%032H", ark);

        this.golden_res[(i*128) +: 128] = ark;

      end

    endfunction

  /**************************************************************************
   * AES ROUND DEC MID                                                      *
   **************************************************************************/

    // golden model for AES middle round decryption
    // Taken from Sail code listed within:
    // RISC-V Cryptography Extensions Volume II : Vector Instructions
    // Version v1.0.0, 22 August 2023 RC3,
    // Chapter 3.2 vaesdm.[vv, vs]
    function void golden_aes_dec_mid(vec_scal_enc_e enc);

      automatic vlen_t vl       = this.curr_test_data.crypto_req.vl;
      automatic int    EGS      = 4;
      automatic int    eg_len   = vl/EGS;
      automatic int    eg_start = this.curr_test_data.crypto_req.vstart/EGS;

      automatic bit [MAXVLEN-1:0] vs2 = this.op_data_vs2;
      automatic bit [MAXVLEN-1:0] vd  = this.op_data_vd;

      automatic bit [3:0][31:0] state;
      automatic bit [3:0][31:0] rkey;
      automatic bit [3:0][31:0] sb;
      automatic bit [3:0][31:0] sr;
      automatic bit [3:0][31:0] mix;
      automatic bit [3:0][31:0] ark;

      for (int i = eg_start; i < eg_len; i++) begin

        automatic int key_elem = (enc == VV) ? i : 0;

        state = vd[(i*128) +: 128];
        rkey  = vs2[(key_elem*128) +: 128];
        sr    = aes_shift_rows(state, DEC);
        sb    = aes_subword_inv(sr);
        ark   = sb ^ rkey;
        mix   = aes_mix_columns(ark, DEC);

        //$display("\nVAESDM.%s GOLDEN RESULTS:", enc);
        //$display("\tElement Group: %0d", i);
        //$display("\t\tstate = 0x%032H", state);
        //$display("\t\trkey  = 0x%032H", rkey);
        //$display("\t\tsb    = 0x%032H", sb);
        //$display("\t\tsr    = 0x%032H", sr);
        //$display("\t\tmix   = 0x%032H", mix);

        this.golden_res[(i*128) +: 128] = mix;

      end

    endfunction

  /**************************************************************************
   * AES ROUND DEC FIN                                                      *
   **************************************************************************/

    // golden model for AES final round decryption
    // Taken from Sail code listed within:
    // RISC-V Cryptography Extensions Volume II : Vector Instructions
    // Version v1.0.0, 22 August 2023 RC3,
    // Chapter 3.1 vaesdf.[vv, vs]
    function void golden_aes_dec_fin(vec_scal_enc_e enc);

      automatic vlen_t vl       = this.curr_test_data.crypto_req.vl;
      automatic int    EGS      = 4;
      automatic int    eg_len   = vl/EGS;
      automatic int    eg_start = this.curr_test_data.crypto_req.vstart/EGS;

      automatic bit [MAXVLEN-1:0] vs2 = this.op_data_vs2;
      automatic bit [MAXVLEN-1:0] vd  = this.op_data_vd;

      automatic bit [3:0][31:0] state;
      automatic bit [3:0][31:0] rkey;
      automatic bit [3:0][31:0] sb;
      automatic bit [3:0][31:0] sr;
      automatic bit [3:0][31:0] ark;

      for (int i = eg_start; i < eg_len; i++) begin

        automatic int key_elem = (enc == VV) ? i : 0;

        state = vd[(i*128) +: 128];
        rkey  = vs2[(key_elem*128) +: 128];
        sr    = aes_shift_rows(state, DEC);
        sb    = aes_subword_inv(sr);
        ark   = sb ^ rkey;

        //$display("\nVAESFM.%s GOLDEN RESULTS:", enc);
        //$display("\tElement Group: %0d", i);
        //$display("\t\tstate = 0x%032H", state);
        //$display("\t\trkey  = 0x%032H", rkey);
        //$display("\t\tsb    = 0x%032H", sb);
        //$display("\t\tsr    = 0x%032H", sr);
        //$display("\t\tark   = 0x%032H", ark);

        this.golden_res[(i*128) +: 128] = ark;

      end

    endfunction

  /**************************************************************************
   * ADD-MULT OVER GHASH GALOIS FIELD                                       *
   **************************************************************************/

    // golden model for vector add-multiply over GHASH Galois field
    // Taken from Sail code listed within:
    // RISC-V Cryptography Extensions Volume II : Vector Instructions
    // Version v1.0.0, 22 August 2023 RC3,
    // Chapter 3.16 vghsh.vv

    function void golden_vector_add_mult_ghash();

      automatic vlen_t vl       = this.curr_test_data.crypto_req.vl;
      automatic int    EGS      = 4;
      automatic int    eg_len   = vl/EGS;
      automatic int    eg_start = this.curr_test_data.crypto_req.vstart/EGS;

      automatic bit [MAXVLEN-1:0] vs1 = this.op_data_vs1;
      automatic bit [MAXVLEN-1:0] vs2 = this.op_data_vs2;
      automatic bit [MAXVLEN-1:0] vd  = this.op_data_vd;

      automatic bit [3:0][31:0] Y;
      automatic bit [3:0][31:0] X;
      automatic bit [3:0][31:0] H;

      automatic bit [EGW128-1:0] Z;
      automatic bit [EGW128-1:0] S;

      automatic bit [EGW128-1:0] result;

      automatic bit reduce = 0;

      for (int i = eg_start; i < eg_len; i++) begin

        Y = vd[(i*EGW128) +: EGW128]; // current partial-hash
        X = vs1[(i*EGW128) +: EGW128]; // block cipher output
        H = brev8_128(vs2[(i*EGW128) +: EGW128]); // Hash subkey

        Z = '0;
        S = brev8_128((Y ^ X));

        for (int bit_idx = 0; bit_idx < EGW128; bit_idx++) begin

          if (S[bit_idx] == 1'b1) begin
            Z ^= H;
          end

          reduce = H[3][31]; // H[127]


          H = H << 1;

          if (reduce == 1'b1) begin
            H ^= 128'h87; // Reduce using x^7 + x^2 + x^1 + 1 polynomial
          end

        end

        result = brev8_128(Z); // bit reverse bytes to get back to GCM standard ordering
        this.golden_res[(i*EGW128) +: EGW128] = result;

      end

    endfunction

  /**************************************************************************
   * MULTIPLY OVER GHASH GALOIS FIELD                                       *
   **************************************************************************/

    // golden model for vector multiply over GHASH Galois field
    // Taken from Sail code listed within:
    // RISC-V Cryptography Extensions Volume II : Vector Instructions
    // Version v1.0.0, 22 August 2023 RC3,
    // Chapter 3.17 vgmul.vv

    function void golden_vector_mult_ghash();

      automatic vlen_t vl       = this.curr_test_data.crypto_req.vl;
      automatic int    EGS      = 4;
      automatic int    eg_len   = vl/EGS;
      automatic int    eg_start = this.curr_test_data.crypto_req.vstart/EGS;

      automatic bit [MAXVLEN-1:0] vs2 = this.op_data_vs2;
      automatic bit [MAXVLEN-1:0] vd  = this.op_data_vd;

      automatic bit [3:0][31:0] H;

      automatic bit [EGW128-1:0] Y;
      automatic bit [EGW128-1:0] Z;

      automatic bit [EGW128-1:0] result;

      automatic bit reduce = 0;

      for (int i = eg_start; i < eg_len; i++) begin

        Y = brev8_128(vd[(i*EGW128) +: EGW128]); // Multiplier
        H = brev8_128(vs2[(i*EGW128) +: EGW128]); // Multiplicand

        Z = '0;

        for (int bit_idx = 0; bit_idx < EGW128; bit_idx++) begin

          if (Y[bit_idx] == 1'b1) begin
            Z ^= H;
          end

          reduce = H[3][31]; // H[127]
          H = H << 1;

          if (reduce == 1'b1) begin
            H ^= 128'h87; // Reduce using x^7 + x^2 + x^1 + 1 polynomial
          end

        end

        result = brev8_128(Z);
        this.golden_res[(i*EGW128) +: EGW128] = result;

      end

    endfunction

  /**************************************************************************
   * SHA-2 COMPRESSION                                                *
   **************************************************************************/

    // golden model for SHA-2 two rounds of compression
    // Taken from Sail code listed within:
    // RISC-V Cryptography Extensions Volume II : Vector Instructions
    // Version v1.0.0, 22 August 2023 RC3,
    // Chapter 3.21 vsha2c[hl].vv
    function void golden_sha2_compr(sha_2_comp_e sh2_comp_hi_lo);

      automatic int sew = 8 << int'(this.curr_test_data.crypto_req.vtype.vsew);

      if (sew == 32) begin
        golden_sha2_compr_SEW32(sh2_comp_hi_lo);
      end else begin
        golden_sha2_compr_SEW64(sh2_comp_hi_lo);
      end


    endfunction

    // SEW32 variation of sha-2 compression
    function void golden_sha2_compr_SEW32(sha_2_comp_e sh2_comp_hi_lo);

      localparam integer unsigned SEW = 32;
      localparam integer unsigned EGW = SEW * 4;

      automatic vlen_t vl       = this.curr_test_data.crypto_req.vl;
      automatic int    EGS      = 4;
      automatic int    eg_len   = vl/EGS;
      automatic int    eg_width = EGS * SEW;
      automatic int    eg_start = this.curr_test_data.crypto_req.vstart/EGS;

      automatic bit [MAXVLEN-1:0] vs2 = this.op_data_vs2;
      automatic bit [MAXVLEN-1:0] vd  = this.op_data_vd;
      automatic bit [MAXVLEN-1:0] vs1 = this.op_data_vs1;

      automatic bit      [SEW-1:0] a, b, c, d, e, f, g, h;
      automatic bit [3:0][SEW-1:0] MessageSchedPlusC;

      automatic bit [SEW-1:0] W0, W1;

      automatic bit [SEW-1:0] T1, T2;

      for (int i = eg_start; i < eg_len; i++) begin

        {a, b, e, f} = vs2[(i*eg_width) +: EGW];
        {c, d, g, h} = vd[(i*eg_width) +: EGW];
        MessageSchedPlusC = vs1[(i*eg_width) +: EGW];
        {W1, W0} = (sh2_comp_hi_lo == SHA2_COMP_LOW) ? MessageSchedPlusC[1:0] :
                                                       MessageSchedPlusC[3:2];

        // pad MSB with 0's in SEW32 variant as functions are written to 64b
        T1 = h + sum1({'0,e}, SEW)[SEW-1:0] + ch({'0,e}, {'0,f}, {'0,g})[31:0] + W0;
        T2 = sum0({'0,a}, SEW)[SEW-1:0] + maj({'0,a}, {'0,b}, {'0,c})[31:0];

        h = g;
        g = f;
        f = e;
        e = d + T1;
        d = c;
        c = b;
        b = a;
        a = T1 + T2;

        T1 = h + sum1({'0,e}, SEW)[SEW-1:0] + ch({'0,e}, {'0,f}, {'0,g})[31:0] + W1;
        T2 = sum0({'0,a}, SEW)[SEW-1:0] + maj({'0,a}, {'0,b}, {'0,c})[31:0];

        h = g;
        g = f;
        f = e;
        e = d + T1;
        d = c;
        c = b;
        b = a;
        a = T1 + T2;

        this.golden_res[(i*eg_width) +: EGW] = {a, b, e, f};

      end

    endfunction

    // SEW64 variation of sha-2 compression
    function void golden_sha2_compr_SEW64(sha_2_comp_e sh2_comp_hi_lo);

      localparam integer unsigned SEW = 64;
      localparam integer unsigned EGW = SEW * 4;

      automatic vlen_t vl       = this.curr_test_data.crypto_req.vl;
      automatic int    EGS      = 4;
      automatic int    eg_len   = vl/EGS;
      automatic int    eg_width = EGS * SEW;
      automatic int    eg_start = this.curr_test_data.crypto_req.vstart/EGS;

      automatic bit [MAXVLEN-1:0] vs2 = this.op_data_vs2;
      automatic bit [MAXVLEN-1:0] vd  = this.op_data_vd;
      automatic bit [MAXVLEN-1:0] vs1 = this.op_data_vs1;

      automatic bit      [SEW-1:0] a, b, c, d, e, f, g, h;
      automatic bit [3:0][SEW-1:0] MessageSchedPlusC;

      automatic bit [SEW-1:0] W0, W1;

      automatic bit [SEW-1:0] T1, T2;

      for (int i = eg_start; i < eg_len; i++) begin

        {a, b, e, f} = vs2[(i*eg_width) +: EGW];
        {c, d, g, h} = vd[(i*eg_width) +: EGW];
        MessageSchedPlusC = vs1[(i*eg_width) +: EGW];
        {W1, W0} = (sh2_comp_hi_lo == SHA2_COMP_LOW) ? MessageSchedPlusC[1:0] :
                                                     MessageSchedPlusC[3:2];

        T1 = h + sum1(e, SEW) + ch(e, f, g) + W0;
        T2 = sum0(a, SEW) + maj(a, b, c);

        h = g;
        g = f;
        f = e;
        e = d + T1;
        d = c;
        c = b;
        b = a;
        a = T1 + T2;

        T1 = h + sum1(e, SEW) + ch(e, f, g) + W1;
        T2 = sum0(a, SEW) + maj(a, b, c);

        h = g;
        g = f;
        f = e;
        e = d + T1;
        d = c;
        c = b;
        b = a;
        a = T1 + T2;

        this.golden_res[(i*eg_width) +: EGW] = {a, b, e, f};

      end

    endfunction

  /**************************************************************************
   * SHA-2 MESSAGE SCHEDULE                                                 *
   **************************************************************************/

    // golden model for SHA-2 message schedule instruction
    // Taken from Sail code listed within:
    // RISC-V Cryptography Extensions Volume II : Vector Instructions
    // Version v1.0.0, 22 August 2023 RC3,
    // Chapter 3.22 vsha2ms.vv
    function void golden_sha2_msg_sched();

      automatic int sew = 8 << int'(this.curr_test_data.crypto_req.vtype.vsew);

      if (sew == 32) begin
        golden_sha2_msg_sched_SEW32();
      end else begin
        golden_sha2_msg_sched_SEW64();
      end

    endfunction

    function void golden_sha2_msg_sched_SEW32();

      localparam integer unsigned SEW = 32;
      localparam integer unsigned EGW = SEW * 4;

      automatic vlen_t vl       = this.curr_test_data.crypto_req.vl;
      automatic int    EGS      = 4;
      automatic int    eg_len   = vl/EGS;
      automatic int    eg_width = EGS * SEW;
      automatic int    eg_start = this.curr_test_data.crypto_req.vstart/EGS;

      automatic bit [MAXVLEN-1:0] vs2 = this.op_data_vs2;
      automatic bit [MAXVLEN-1:0] vd  = this.op_data_vd;
      automatic bit [MAXVLEN-1:0] vs1 = this.op_data_vs1;

      automatic bit [19:0][SEW-1:0] W;

      for (int i = eg_start; i < eg_len; i++) begin

        {W[ 3], W[ 2], W[ 1], W[ 0]} = vd[(i*eg_width) +: EGW];
        {W[11], W[10], W[ 9], W[ 4]} = vs2[(i*eg_width) +: EGW];
        {W[15], W[14], W[13], W[12]} = vs1[(i*eg_width) +: EGW];

        W[16] = sig1({'0, W[14]}, SEW)[SEW-1:0] + W[ 9] + sig0({'0, W[1]}, SEW)[SEW-1:0] + W[0];
        W[17] = sig1({'0, W[15]}, SEW)[SEW-1:0] + W[10] + sig0({'0, W[2]}, SEW)[SEW-1:0] + W[1];
        W[18] = sig1({'0, W[16]}, SEW)[SEW-1:0] + W[11] + sig0({'0, W[3]}, SEW)[SEW-1:0] + W[2];
        W[19] = sig1({'0, W[17]}, SEW)[SEW-1:0] + W[12] + sig0({'0, W[4]}, SEW)[SEW-1:0] + W[3];

        this.golden_res[(i*eg_width) +: EGW] = {W[19], W[18], W[17], W[16]};

      end

    endfunction

    function void golden_sha2_msg_sched_SEW64();

      localparam integer unsigned SEW = 64;
      localparam integer unsigned EGW = SEW * 4;

      automatic vlen_t vl       = this.curr_test_data.crypto_req.vl;
      automatic int    EGS      = 4;
      automatic int    eg_len   = vl/EGS;
      automatic int    eg_width = EGS * SEW;
      automatic int    eg_start = this.curr_test_data.crypto_req.vstart/EGS;

      automatic bit [MAXVLEN-1:0] vs2 = this.op_data_vs2;
      automatic bit [MAXVLEN-1:0] vd  = this.op_data_vd;
      automatic bit [MAXVLEN-1:0] vs1 = this.op_data_vs1;

      automatic bit [19:0][SEW-1:0] W;

      for (int i = eg_start; i < eg_len; i++) begin

        {W[ 3], W[ 2], W[ 1], W[ 0]} = vd[(i*eg_width) +: EGW];
        {W[11], W[10], W[ 9], W[ 4]} = vs2[(i*eg_width) +: EGW];
        {W[15], W[14], W[13], W[12]} = vs1[(i*eg_width) +: EGW];

        W[16] = sig1(W[14], SEW) + W[ 9] + sig0(W[1], SEW) + W[0];
        W[17] = sig1(W[15], SEW) + W[10] + sig0(W[2], SEW) + W[1];
        W[18] = sig1(W[16], SEW) + W[11] + sig0(W[3], SEW) + W[2];
        W[19] = sig1(W[17], SEW) + W[12] + sig0(W[4], SEW) + W[3];

        this.golden_res[(i*eg_width) +: EGW] = {W[19], W[18], W[17], W[16]};

      end

    endfunction

  /**************************************************************************
   * SM HELPER FUNCTIONS                                                    *
   **************************************************************************/

    // SM4 lookup Constant Key (CK)
    function bit [31:0] sm_constant_key(bit [4:0] r);
      case(r)
        5'h00: return 32'h00070E15;
        5'h01: return 32'h1C232A31;
        5'h02: return 32'h383F464D;
        5'h03: return 32'h545B6269;
        5'h04: return 32'h70777E85;
        5'h05: return 32'h8C939AA1;
        5'h06: return 32'hA8AFB6BD;
        5'h07: return 32'hC4CBD2D9;
        5'h08: return 32'hE0E7EEF5;
        5'h09: return 32'hFC030A11;
        5'h0A: return 32'h181F262D;
        5'h0B: return 32'h343B4249;
        5'h0C: return 32'h50575E65;
        5'h0D: return 32'h6C737A81;
        5'h0E: return 32'h888F969D;
        5'h0F: return 32'hA4ABB2B9;
        5'h10: return 32'hC0C7CED5;
        5'h11: return 32'hDCE3EAF1;
        5'h12: return 32'hF8FF060D;
        5'h13: return 32'h141B2229;
        5'h14: return 32'h30373E45;
        5'h15: return 32'h4C535A61;
        5'h16: return 32'h686F767D;
        5'h17: return 32'h848B9299;
        5'h18: return 32'hA0A7AEB5;
        5'h19: return 32'hBCC3CAD1;
        5'h1A: return 32'hD8DFE6ED;
        5'h1B: return 32'hF4FB0209;
        5'h1C: return 32'h10171E25;
        5'h1D: return 32'h2C333A41;
        5'h1E: return 32'h484F565D;
        5'h1F: return 32'h646B7279;
        default: return 32'h0;
      endcase
    endfunction

    // SM4 SubWord function used in the key expansion
    // Applies the forward sbox to each byte in the input word
    function bit [31:0] sm_subword_fwd (bit [31:0] word_i);

      automatic bit [31:0] sb = '0;
      sb = {SMSboxFwd[int'(word_i[31:24])],
            SMSboxFwd[int'(word_i[23:16])],
            SMSboxFwd[int'(word_i[15:8])],
            SMSboxFwd[int'(word_i[7:0])]};
      return sb;

    endfunction

    function bit [31:0] sm_round_key(bit [31:0] X,  bit [31:0] S);
      return (X ^ (S ^ sm_ROL32(S, 13) ^ sm_ROL32(S, 23)));
    endfunction

    //rotate X by a factor of S
    function bit [31:0] sm_ROL32(bit [31:0] X, int unsigned S);
      return ((X << S) | (X >> (32 - S)));
    endfunction

    function bit [31:0] sm_round(bit [31:0] X, bit [31:0] S);
      return X ^ (S ^ sm_ROL32(S, 2) ^ sm_ROL32(S, 10) ^ sm_ROL32(S, 18) ^ sm_ROL32(S, 24));
    endfunction

    /*endian byte swap */
    function bit [31:0] sm_rev8(bit [31:0] word_i);
      return  (word_i >> 24 & 8'hff) |
              (word_i << 8 & 24'hff0000) |
              (word_i >> 8 & 16'hff00) |
              (word_i << 24 & 32'hff000000);
    endfunction

    function bit [31:0] sm_p_1(bit [31:0] X);
      return (X ^ sm_ROL32(X, 15) ^ sm_ROL32(X, 23));
    endfunction

    function bit [31:0] sm_zvksh_w(bit [31:0] M16, bit [31:0] M9, bit [31:0] M3,
                                   bit [31:0] M13, bit [31:0] M6);

      return (sm_p_1(M16 ^ M9 ^ sm_ROL32(M3, 15) ) ^ sm_ROL32(M13, 7) ^ M6);
    endfunction

    function bit [31:0] sm_ff1(bit [31:0] X, bit [31:0] Y, bit [31:0] Z);
      return (X ^ Y ^ Z);
    endfunction

    function bit [31:0] sm_ff2(bit [31:0] X, bit [31:0] Y, bit [31:0] Z);
      return (X & Y) | (X & Z) | (Y & Z);
    endfunction

    function bit [31:0] sm_ff_j(bit [31:0] X, bit [31:0] Y, bit [31:0] Z, int unsigned J);
      return J <= 15 ? sm_ff1(X, Y, Z) : sm_ff2(X, Y, Z);
    endfunction

    function bit [31:0] sm_gg1(bit [31:0] X, bit [31:0] Y, bit [31:0] Z);
      return (X ^ Y ^ Z);
    endfunction

    function bit [31:0] sm_gg2(bit [31:0] X, bit [31:0] Y, bit [31:0] Z);
      return (X & Y) | ((~X) & Z);
    endfunction

    function bit [31:0] sm_gg_j(bit [31:0] X, bit [31:0] Y, bit [31:0] Z, int J);
      return J <= 15 ? sm_gg1(X, Y, Z) : sm_gg2(X, Y, Z);
    endfunction


    function bit [31:0] sm_t_j(int unsigned J);
      return J <= 15 ? 32'h79CC4519 : 32'h7A879D8A;
    endfunction

    function bit [31:0] sm_p_0(bit [31:0] X);
      return (X ^ sm_ROL32(X, 9) ^ sm_ROL32(X, 17));
    endfunction

  /**************************************************************************
   * AES HELPER FUNCTIONS                                                   *
   **************************************************************************/

    // AES SubWord function used in the key expansion
    // Applies the forward sbox to each byte in the input word
    function bit [3:0][31:0] aes_subword_fwd (bit [3:0][31:0] word_i);

      automatic bit [3:0][31:0] sb = '0;

      for (int word = 0; word < 4; word++) begin

        sb[word] = {SboxFwd[int'(word_i[word][31:24])],
                    SboxFwd[int'(word_i[word][23:16])],
                    SboxFwd[int'(word_i[word][15:8])],
                    SboxFwd[int'(word_i[word][7:0])]};
      end

      return sb;

    endfunction

    // AES SubWord function used in the key expansion
    // Applies the inverse sbox to each byte in the input word
    function bit [3:0][31:0] aes_subword_inv (bit [3:0][31:0] word_i);

      automatic bit [3:0][31:0] sb = '0;

      for (int word = 0; word < 4; word++) begin

        sb[word] = {SboxInv[int'(word_i[word][31:24])],
                    SboxInv[int'(word_i[word][23:16])],
                    SboxInv[int'(word_i[word][15:8])],
                    SboxInv[int'(word_i[word][7:0])]};
      end

      return sb;

    endfunction

    // word rotation for AES key schedule
    function bit [31:0] aes_rotword(bit [31:0] word_i);
      return {word_i[7:0],word_i[31:8]};
    endfunction

    // AES lookup round constant
    function bit [31:0] aes_decode_rcon(bit [3:0] r);
      case(r)
        4'h0: return 32'h00000001;
        4'h1: return 32'h00000002;
        4'h2: return 32'h00000004;
        4'h3: return 32'h00000008;
        4'h4: return 32'h00000010;
        4'h5: return 32'h00000020;
        4'h6: return 32'h00000040;
        4'h7: return 32'h00000080;
        4'h8: return 32'h0000001B;
        4'h9: return 32'h00000036;
        4'hA: return 32'h00000000;
        4'hB: return 32'h00000000;
        4'hC: return 32'h00000000;
        4'hD: return 32'h00000000;
        4'hE: return 32'h00000000;
        4'hF: return 32'h00000000;
        default: return 32'h0;
      endcase
    endfunction

    // perform mix rows (fed/inv)
    function bit [3:0][31:0] aes_shift_rows (
      bit       [3:0][31:0] curr_state,
      enc_sel_e             enc_dec_sel
    );

      automatic bit [3:0][ 3:0][7:0] c_state_bytes;
      automatic bit [3:0][31:0]      shifted_state;

      // transform word array into byte array for easy reference
      for (int word_idx = 0; word_idx < 4; word_idx++) begin
        for (int byte_idx = 0; byte_idx < 4; byte_idx++) begin
          c_state_bytes[word_idx][byte_idx] = curr_state[word_idx][(byte_idx*8) +: 8];
        end
      end

      if (enc_dec_sel == ENC) begin // encrypt

        shifted_state[0] = {c_state_bytes[3][3], c_state_bytes[2][2],
                            c_state_bytes[1][1], c_state_bytes[0][0]};
        shifted_state[1] = {c_state_bytes[0][3], c_state_bytes[3][2],
                            c_state_bytes[2][1], c_state_bytes[1][0]};
        shifted_state[2] = {c_state_bytes[1][3], c_state_bytes[0][2],
                            c_state_bytes[3][1], c_state_bytes[2][0]};
        shifted_state[3] = {c_state_bytes[2][3], c_state_bytes[1][2],
                            c_state_bytes[0][1], c_state_bytes[3][0]};

      end else begin // decrypt

        shifted_state[0] = {c_state_bytes[1][3], c_state_bytes[2][2],
                            c_state_bytes[3][1], c_state_bytes[0][0]};
        shifted_state[1] = {c_state_bytes[2][3], c_state_bytes[3][2],
                            c_state_bytes[0][1], c_state_bytes[1][0]};
        shifted_state[2] = {c_state_bytes[3][3], c_state_bytes[0][2],
                            c_state_bytes[1][1], c_state_bytes[2][0]};
        shifted_state[3] = {c_state_bytes[0][3], c_state_bytes[1][2],
                            c_state_bytes[2][1], c_state_bytes[3][0]};

      end

      return shifted_state;

    endfunction

    // perform mix columns (fwd/inv)
    function bit [3:0][31:0] aes_mix_columns (
      bit       [3:0][31:0] curr_state,
      enc_sel_e             enc_dec_sel
    );
      automatic bit [3:0][ 3:0][7:0] c_state_bytes;
      automatic bit [3:0][31:0]      mixed_state;

      // transform word array into byte array for easy reference
      for (int word_idx = 0; word_idx < 4; word_idx++) begin
        for (int byte_idx = 0; byte_idx < 4; byte_idx++) begin
          c_state_bytes[word_idx][byte_idx] = curr_state[word_idx][(byte_idx*8) +: 8];
        end
      end

      for (int word = 0; word < 4; word++) begin

        if (enc_dec_sel == ENC) begin // encrypt

          mixed_state[word][  7:0] = xt2(c_state_bytes[word][0]) ^
                                     xt3(c_state_bytes[word][1]) ^
                                     c_state_bytes[word][2]      ^
                                     c_state_bytes[word][3];
          mixed_state[word][ 15:8] = c_state_bytes[word][0]      ^
                                     xt2(c_state_bytes[word][1]) ^
                                     xt3(c_state_bytes[word][2]) ^
                                     c_state_bytes[word][3];
          mixed_state[word][23:16] = c_state_bytes[word][0]      ^
                                     c_state_bytes[word][1]      ^
                                     xt2(c_state_bytes[word][2]) ^
                                     xt3(c_state_bytes[word][3]);
          mixed_state[word][31:24] = xt3(c_state_bytes[word][0]) ^
                                     c_state_bytes[word][1]      ^
                                     c_state_bytes[word][2]      ^
                                     xt2(c_state_bytes[word][3]);

        end else begin // decrypt

          mixed_state[word][  7:0] = gfmul(c_state_bytes[word][0], 4'hE) ^
                                     gfmul(c_state_bytes[word][1], 4'hB) ^
                                     gfmul(c_state_bytes[word][2], 4'hD) ^
                                     gfmul(c_state_bytes[word][3], 4'h9);
          mixed_state[word][ 15:8] = gfmul(c_state_bytes[word][0], 4'h9) ^
                                     gfmul(c_state_bytes[word][1], 4'hE) ^
                                     gfmul(c_state_bytes[word][2], 4'hB) ^
                                     gfmul(c_state_bytes[word][3], 4'hD);
          mixed_state[word][23:16] = gfmul(c_state_bytes[word][0], 4'hD) ^
                                     gfmul(c_state_bytes[word][1], 4'h9) ^
                                     gfmul(c_state_bytes[word][2], 4'hE) ^
                                     gfmul(c_state_bytes[word][3], 4'hB);
          mixed_state[word][31:24] = gfmul(c_state_bytes[word][0], 4'hB) ^
                                     gfmul(c_state_bytes[word][1], 4'hD) ^
                                     gfmul(c_state_bytes[word][2], 4'h9) ^
                                     gfmul(c_state_bytes[word][3], 4'hE);

        end
      end

      return mixed_state;

    endfunction

    // Auxiliary function for performing GF multiplication
    function bit [7:0] xt2 (
      bit [7:0] x
    );
      xt2 = (x[7]) ? (x << 1) ^ 8'h1B : (x << 1) ^ 8'h00;
    endfunction

    // Auxiliary function for performing GF multiplication
    function bit [7:0] xt3 (
      bit [7:0] x
    );
      xt3 = x ^ xt2(x);
    endfunction

    // Multiply 8-bit field element by 4-bit value for AES MixCols step
    function bit [7:0] gfmul (
      bit [7:0] x,
      bit [3:0] y
    );
      automatic bit [7:0] x0, x1, x2, x3;

      x0 = (y[0]) ? x : 8'h00;
      x1 = (y[1]) ? xt2(x) : 8'h00;
      x2 = (y[2]) ? xt2(xt2(x)) : 8'h00;
      x3 = (y[3]) ? xt2(xt2(xt2(x))) : 8'h00;

      gfmul = x0 ^ x1 ^ x2 ^ x3;

    endfunction

    // reverse bits of bytes (128b word)
    function bit [127:0] brev8_128( bit [127:0] word_i);

      const int ByteCount = 16;

      automatic bit [127:0] word_o = '0;

      for (int byte_idx = 0; byte_idx < ByteCount; byte_idx++) begin
        for (int bit_idx = 0; bit_idx < 8; bit_idx++) begin
          word_o[(byte_idx*8) + (7-bit_idx)] = word_i[(byte_idx*8) + bit_idx];
        end
      end

      return word_o;

    endfunction

  /****************************************************************************
   * SHA-2 HELPER FUNCTIONS                                                   *
   ****************************************************************************/    

    // note that SEW32 input needs to be padded with 0 in MSBs
    function bit [63:0] ch(bit [63:0] x, bit [63:0] y, bit [63:0] z);

      return ((x & y) ^ ((~x) & z));

    endfunction

    // note that SEW32 input needs to be padded with 0 in MSBs
    function bit [63:0] maj( bit [63:0] x, bit [63:0] y, bit [63:0] z);

      return ((x & y) ^ (x & z) ^ y & z);

    endfunction

    // note that SEW32 input needs to be padded with 0 in MSBs
    function bit [63:0] ROTR( bit [63:0] x, int n, int sew);

      return ((x >> n) | (x << (sew - n)));

    endfunction

    // note that SEW32 input needs to be padded with 0 in MSBs
    function bit [63:0] SHR( bit [63:0] x, int n);

      return (x >> n);

    endfunction

    // note that SEW32 input needs to be padded with 0 in MSBs
    function bit [63:0] sum0(bit [63:0] x, int sew);

      if (sew == 32) begin
        return (ROTR(x, 2, 32) ^ ROTR(x, 13, 32) ^ ROTR(x, 22, 32));
      end else begin
        return (ROTR(x, 28, 64) ^ ROTR(x, 34, 64) ^ ROTR(x, 39, 64));
      end

    endfunction;

    // note that SEW32 input needs to be padded with 0 in MSBs
    function bit [63:0] sum1(bit [63:0] x, int sew);

      if (sew == 32) begin
        return (ROTR(x, 6, 32) ^ ROTR(x, 11, 32) ^ ROTR(x, 25, 32));
      end else begin
        return (ROTR(x, 14, 64) ^ ROTR(x, 18, 64) ^ ROTR(x, 41, 64));
      end

    endfunction;

    // note that SEW32 input needs to be padded with 0 in MSBs
    function bit [63:0] sig0(bit [63:0] x, int sew);

      if (sew == 32) begin
        return (ROTR(x, 7, 32) ^ ROTR(x, 18, 32) ^ SHR(x, 3));
      end else begin
        return (ROTR(x, 1, 64) ^ ROTR(x, 8, 64) ^ SHR(x, 7));
      end

    endfunction

    // note that SEW32 input needs to be padded with 0 in MSBs
    function bit [63:0] sig1(bit [63:0] x, int sew);

      if (sew == 32) begin
        return (ROTR(x, 17, 32) ^ ROTR(x, 19, 32) ^ SHR(x, 10));
      end else begin
        return (ROTR(x, 19, 64) ^ ROTR(x, 61, 64) ^ SHR(x, 6));
      end

    endfunction

  endclass


endpackage
