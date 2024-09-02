//------------------------------------------------------------------------------
// Module   : marian_jtag_pkg.sv
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Francesco Conti <fconti@iis.ee.ethz.ch>
//            Antonio Pullini <pullinia@iis.ee.ethz.ch>
//            Aleksei Gimbitskii <aleksei.gimbitskii@tuni.fi>
//            Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 21-jan-2024
//
// Description: Package containing routines to test JTAG/Debug Module in
// RTL simulation.
//
// Parameters:
//  - JTAG_TCK_PERIOD:
//  - NUM_TAPS:
//  - JTAG_IR_WIDTH:
//  - JTAG_IDCODE:
//  - JTAG_DTMCSR:
//  - JTAG_DMIACCESS:
//  - JTAG_AXIREG:
//  - JTAG_BBMUXREG:
//  - JTAG_CONFREG:
//  - JTAG_TESTMODEREG:
//  - JTAG_BISTREG:
//  - JTAG_BYPASS:
//  - JTAG_IDCODE_WIDTH:
//  - TAP_ID_CODE:
//  - DMI_SIZE:
//
// Inputs:
//  - None
//
// Outputs:
//  - None
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------
// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

/*
 * marian_jtag_pkg.sv
 * Francesco Conti <fconti@iis.ee.ethz.ch>
 * Antonio Pullini <pullinia@iis.ee.ethz.ch>
 * Aleksei Gimbitskii <aleksei.gimbitskii@tuni.fi>
 * Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
 * Antti Nurmi <antti.nurmi@tuni.fi>
 */


package marian_jtag_pkg;

   parameter time                               JTAG_TCK_PERIOD   = 125ns;
   parameter int unsigned                       NUM_TAPS          = 1;
   parameter int unsigned                       JTAG_IR_WIDTH     = 5;
   parameter logic        [  JTAG_IR_WIDTH-1:0] JTAG_IDCODE       = 5'b00001;
   parameter logic        [  JTAG_IR_WIDTH-1:0] JTAG_DTMCSR       = 5'b10000;
   parameter logic        [  JTAG_IR_WIDTH-1:0] JTAG_DMIACCESS    = 5'b10001;
   parameter logic        [  JTAG_IR_WIDTH-1:0] JTAG_AXIREG       = 5'b11111;
   parameter logic        [  JTAG_IR_WIDTH-1:0] JTAG_BBMUXREG     = 5'b00101;
   parameter logic        [  JTAG_IR_WIDTH-1:0] JTAG_CONFREG      = 5'b00110;
   parameter logic        [  JTAG_IR_WIDTH-1:0] JTAG_TESTMODEREG  = 5'b01000;
   parameter logic        [  JTAG_IR_WIDTH-1:0] JTAG_BISTREG      = 5'b01001;
   parameter logic        [  JTAG_IR_WIDTH-1:0] JTAG_BYPASS       = 5'b11111;
   parameter int unsigned                       JTAG_IDCODE_WIDTH = 32;
   parameter logic        [JTAG_IDCODE_WIDTH:0] TAP_ID_CODE       = 32'hf007ba11;

   parameter integer                            DMI_SIZE          = 32+7+2; 

   task automatic jtag_wait_halfperiod(input int cycles);
      #((JTAG_TCK_PERIOD/2)*cycles); // ~ 8MHz
   endtask

   task automatic jtag_clock(
      input int cycles,
      ref logic s_tck
   );
      for(int i=0; i<cycles; i=i+1) begin
         s_tck = 1'b0;
         jtag_wait_halfperiod(1);
         s_tck = 1'b1;
         jtag_wait_halfperiod(1);
         s_tck = 1'b0;
      end
   endtask

   task automatic jtag_reset(
      ref logic s_tck,
      ref logic s_tms,
      ref logic s_trstn,
      ref logic s_tdi
   );
      s_tms   = 1'b0;
      s_tck   = 1'b0;
      s_trstn = 1'b0;
      s_tdi   = 1'b0;
      jtag_wait_halfperiod(2);
      s_trstn = 1'b1;
   endtask

   task automatic jtag_softreset(
      ref logic s_tck,
      ref logic s_tms,
      ref logic s_trstn,
      ref logic s_tdi
   );
      s_tms   = 1'b1;
      s_trstn = 1'b1;
      s_tdi   = 1'b0;
      jtag_clock(5, s_tck); //enter RST
      s_tms   = 1'b0;
      jtag_clock(1, s_tck); // back to IDLE
      $display("[JTAG] SoftReset Done(%0t)",$realtime);

   endtask

   class JTAG_reg #(int unsigned size = 32, logic [(JTAG_IR_WIDTH)-1:0] instr = 'h0);

      task idle(
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi
      );
         s_trstn = 1'b1;
         // from SHIFT_DR to RUN_TEST : tms sequence 10
         s_tms   = 1'b1;
         s_tdi   = 1'b0;
         jtag_clock(1, s_tck);
         s_tms   = 1'b0;
         jtag_clock(1, s_tck);
      endtask

      task update_and_goto_shift(
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi
      );
         s_trstn = 1'b1;
         // from SHIFT_DR to RUN_TEST : tms sequence 110
         s_tms   = 1'b1;
         s_tdi   = 1'b0;
         jtag_clock(1, s_tck);
         s_tms   = 1'b1;
         jtag_clock(1, s_tck);
         s_tms   = 1'b0;
         jtag_clock(1, s_tck);
         jtag_clock(1, s_tck);
      endtask

      task jtag_goto_SHIFT_IR(
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi
      );
         s_trstn = 1'b1;
         s_tdi   = 1'b0;
         // from IDLE to SHIFT_IR : tms sequence 1100
         s_tms   = 1'b1;
         jtag_clock(2, s_tck);
         s_tms   = 1'b0;
         jtag_clock(2, s_tck);
      endtask

      task jtag_goto_SHIFT_DR(
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi
      );
         s_trstn = 1'b1;
         s_tdi   = 1'b0;
         // from IDLE to SHIFT_IR : tms sequence 100
         s_tms   = 1'b1;
         jtag_clock(1, s_tck);
         s_tms   = 1'b0;
         jtag_clock(2, s_tck);
      endtask

      task jtag_goto_UPDATE_DR_FROM_SHIFT_DR(
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi
      );
         //$display("I am at jtag_goto_UPDATE_DR_FROM_SHIFT_DR (%t)",$realtime);
         s_trstn = 1'b1;
         s_tdi   = 1'b1;
         // from SHIFT DR to UPDATE DR : tms sequence 11
         s_tms   = 1'b1;
         jtag_clock(1, s_tck);
         // back to Idle : tms sequence 0
         s_tms   = 1'b0;
         //wait a bit
         jtag_clock(50, s_tck);
      endtask

      task jtag_goto_CAPTURE_DR_FROM_UPDATE_DR_GETDATA(
         output logic [DMI_SIZE-1:0] dataout,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         //$display("I am at jtag_goto_CAPTURE_DR_FROM_UPDATE_DR_GETDATA (%t)",$realtime);
         s_trstn = 1'b1;
         s_tdi   = 1'b1;
         // from UPDATE DR to CAPTURE DR : tms sequence 10
         s_tms   = 1'b1;
         jtag_clock(1, s_tck);
         s_tms   = 1'b0;
         jtag_clock(1, s_tck);
         //back to Idle: tms sequence 110
         s_tms   = 1'b1;
         jtag_clock(2, s_tck);
         s_tms   = 1'b0;
         jtag_clock(1, s_tck);
         // go to SHIFT DR: tms sequence 100
         s_tms   = 1'b1;
         jtag_clock(1, s_tck);
         s_tms   = 1'b0;
         jtag_clock(2, s_tck);
         s_tms   = 1'b0;
         for(int i=0; i<DMI_SIZE; i=i+1) begin
            if (i == (DMI_SIZE-1))
               s_tms = 1'b1;
            s_tdi = 1'b0;
            jtag_clock(1, s_tck);
            dataout[i] = s_tdo;
         end

      endtask

      task jtag_goto_CAPTURE_DR_FROM_SHIFT_DR_GETDATA(
         output logic [DMI_SIZE-1:0] dataout,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         //$display("I am at jtag_goto_CAPTURE_DR_FROM_SHIFT_DR_GETDATA (%t)",$realtime);
         s_trstn = 1'b1;
         s_tdi   = 1'b1;
         // from UPDATE DR to CAPTURE DR : tms sequence 110
         s_tms   = 1'b1;
         jtag_clock(2, s_tck);
         s_tms   = 1'b0;
         jtag_clock(1, s_tck);
         // go to SHIFT DR
         s_tms   = 1'b0;
         jtag_clock(1, s_tck);
         s_tms   = 1'b0;
         for(int i=0; i<DMI_SIZE; i=i+1) begin
            if (i == (DMI_SIZE-1))
               s_tms = 1'b1;
            s_tdi = 1'b0;
            jtag_clock(1, s_tck);
            dataout[i] = s_tdo;
         end

      endtask

      task jtag_shift_SHIFT_IR(
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi
      );
         s_trstn = 1'b1;
         s_tms   = 1'b0;
         for(int i=0; i<JTAG_IR_WIDTH; i=i+1) begin
            if (i==(JTAG_IR_WIDTH-1))
                 s_tms = 1'b1;
            s_tdi = instr[i];
            jtag_clock(1, s_tck);
         end
      endtask

      task jtag_shift_NBITS_SHIFT_DR (
         input int unsigned     numbits,
         input logic[size-1:0]  datain,
         output logic[size-1:0] dataout,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         s_trstn = 1'b1;
         s_tms   = 1'b0;
         for(int i=0; i<numbits; i=i+1) begin
            if (i == (numbits-1))
               s_tms = 1'b1;
            s_tdi = datain[i];
            jtag_clock(1, s_tck);
            dataout[i] = s_tdo;
         end
      endtask

      task shift_nbits_noex(
         input int unsigned     numbits,
         input logic[size-1:0]  datain,
         output logic[size-1:0] dataout,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         s_trstn = 1'b1;
         s_tms   = 1'b0;
         for(int i=0; i<numbits; i=i+1) begin
            s_tdi = datain[i];
            jtag_clock(1, s_tck);
            dataout[i] = s_tdo;
         end
      endtask

      task start_shift(
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi
      );
         this.jtag_goto_SHIFT_DR(s_tck, s_tms, s_trstn, s_tdi);
      endtask

      task shift_nbits(
         input int unsigned     numbits,
         input logic[size-1:0]  datain,
         output logic[size-1:0] dataout,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
           this.jtag_shift_NBITS_SHIFT_DR(numbits, datain, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
      endtask

      task setIR(
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi
      );
         this.jtag_goto_SHIFT_IR(s_tck, s_tms, s_trstn, s_tdi);
         this.jtag_shift_SHIFT_IR(s_tck, s_tms, s_trstn, s_tdi);
         this.idle(s_tck, s_tms, s_trstn, s_tdi);
      endtask

      task shift(
         input logic[size-1:0]  datain,
         output logic[size-1:0] dataout,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         this.jtag_goto_SHIFT_DR(s_tck, s_tms, s_trstn, s_tdi);
         this.jtag_shift_NBITS_SHIFT_DR(size, datain, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         this.idle(s_tck, s_tms, s_trstn, s_tdi);
      endtask

   endclass

   task automatic jtag_get_idcode(
      ref logic s_tck,
      ref logic s_tms,
      ref logic s_trstn,
      ref logic s_tdi,
      ref logic s_tdo
   );
      automatic JTAG_reg #(.size(JTAG_IDCODE_WIDTH+NUM_TAPS-1), .instr(JTAG_IDCODE)) jtag_idcode = new;
      //more bits for the bypass
      logic [31+NUM_TAPS-1:0] s_idcode;
      jtag_idcode.setIR(s_tck, s_tms, s_trstn, s_tdi);
      jtag_idcode.shift('0, s_idcode, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
      $display("[JTAG] Got TAP ID: %h (%0t)",s_idcode[31:0], $realtime);
      if(s_idcode[JTAG_IDCODE_WIDTH-1:0] !== TAP_ID_CODE) begin
         $display("[JTAG] Tap ID Test [FAILED] (%0tns)", $realtime);
      end else begin
         $display("[JTAG] Tap ID Test [PASSED] (%0tns)", $realtime);
      end
   endtask

   task automatic jtag_bypass_test(
      ref logic s_tck,
      ref logic s_tms,
      ref logic s_trstn,
      ref logic s_tdi,
      ref logic s_tdo
   );
      automatic JTAG_reg #(.size(256), .instr(JTAG_BYPASS)) jtag_bypass = new;
                logic [255:0] result_data;
      automatic logic [255:0] test_data = {     32'hDEADBEEF, 32'h0BADF00D, 32'h01234567, 32'h89ABCDEF,
                                                32'hAAAABBBB, 32'hCCCCDDDD, 32'hEEEEFFFF, 32'h00001111};
      jtag_bypass.setIR(s_tck, s_tms, s_trstn, s_tdi);
      jtag_bypass.shift(test_data, result_data, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
      if (test_data[255-NUM_TAPS:0] === result_data[255:NUM_TAPS])
         $display("[JTAG] Bypass Test Passed (%0t)", $realtime);
      else
      begin
         $display("[JTAG] Bypass Test Failed");
         $display("[JTAG] LSB WORD TEST = %b (%0t)",test_data[255-NUM_TAPS:0], $realtime);
         $display("[JTAG] LSB WORD RES  = %b (%0t)",result_data[255:NUM_TAPS], $realtime);
      end
   endtask

   class test_mode_if_t;

      task init(
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi
      );
         JTAG_reg #(.size(256), .instr(JTAG_CONFREG)) JTAG_dbg = new;
         JTAG_dbg.setIR(s_tck, s_tms, s_trstn, s_tdi);
         $display("[rt_test_mode_if] %t - Init", $realtime);
      endtask

      task set_confreg(
         input  logic [8:0] confreg,
         output logic [8:0] dataout,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         logic [8+1:0] confreg_int, dataout_int; //extra bit for bypass
         JTAG_reg #(.size(10), .instr(JTAG_CONFREG)) JTAG_dbg = new;

         confreg_int = {1'b0, confreg};

         JTAG_dbg.start_shift(s_tck, s_tms, s_trstn, s_tdi);
         JTAG_dbg.shift_nbits(9+1, confreg_int, dataout_int, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         JTAG_dbg.idle(s_tck, s_tms, s_trstn, s_tdi);
         dataout = dataout_int[8:0];
         $display("[rt_test_mode_if] %0tns - Setting confreg to value %X.", $realtime, confreg);
      endtask

      task get_confreg(
         input logic [8:0] confreg,
         output bit  [8:0] rec,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         logic [8+NUM_TAPS-1:0] dataout; //extra bit for bypass
         JTAG_reg #(.size(9), .instr(JTAG_CONFREG)) JTAG_dbg = new;
         JTAG_dbg.start_shift(s_tck, s_tms, s_trstn, s_tdi);
         JTAG_dbg.shift_nbits(9+1, confreg, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         JTAG_dbg.idle(s_tck, s_tms, s_trstn, s_tdi);
         rec = dataout [8:0];
      endtask

   endclass

   class debug_mode_if_t #(
    parameter integer PROG_LEN = 150,
    parameter integer NR_LANES = 150
   );

     localparam integer L2Width = 64 * NR_LANES / 2;

      task init_dmi_access(
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi
      );
         JTAG_reg #(.size(32+NUM_TAPS-1), .instr(JTAG_DMIACCESS)) JTAG_dbg = new;
         JTAG_dbg.setIR(s_tck, s_tms, s_trstn, s_tdi);

      endtask

      task init_dtmcs(
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi
      );

         JTAG_reg #(.size(32+NUM_TAPS-1), .instr(JTAG_DTMCSR)) JTAG_dbg = new;
         JTAG_dbg.setIR(s_tck, s_tms, s_trstn, s_tdi);

      endtask

      task dump_dm_info(
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );

          typedef struct packed {
              logic [31:18] zero1;
              logic         dmihardreset;
              logic         dmireset;
              logic         zero0;
              logic [14:12] idle;
              logic [11:10] dmistat;
              logic [9:4]   abits;
              logic [3:0]   version;
          } dtmcs_t;

         dm::dmstatus_t  dmstatus;
         dtmcs_t dtmcs;

         $display("[JTAG] %t - Init", $realtime);
         this.init_dtmcs(s_tck, s_tms, s_trstn, s_tdi);

         this.read_dtmcs(dtmcs, s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         $display("[JTAG] %t - Debug Module dtmcs %x: \n\
                             dmihardreset %x \n\
                             dmireset     %x \n\
                             idle         %x \n\
                             dmistat      %x \n\
                             abits        %x \n\
                             version      %x \n",
                  $realtime, dtmcs, dtmcs.dmihardreset, dtmcs.dmireset, dtmcs.idle,
             dtmcs.dmistat, dtmcs.abits, dtmcs.version);

         this.init_dmi_access(s_tck, s_tms, s_trstn, s_tdi);

         this.read_debug_reg(dm::DMStatus, dmstatus,
             s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         $display("[JTAG] %t - Debug Module Debug Version: \n\
                 impebreak    %x\n\
                 allhavereset %x\n\
                 anyhavereset %x\n\
                 allrunning   %x\n\
                 anyrunning   %x\n\
                 allhalted    %x\n\
                 anyhalted    %x\n\
                 version      %x\n\
              ", $realtime, dmstatus.impebreak, dmstatus.allhavereset, dmstatus.anyhavereset,
             dmstatus.allrunning, dmstatus.anyrunning, dmstatus.allhalted, dmstatus.anyhalted,
             dmstatus.version);

      endtask


      task set_haltreq(
         input logic haltreq,
         ref logic   s_tck,
         ref logic   s_tms,
         ref logic   s_trstn,
         ref logic   s_tdi,
         ref logic   s_tdo
      );

          logic [1:0]     dm_op;
          logic [6:0]     dm_addr;
          logic [31:0]    dm_data;
          dm::dmcontrol_t dmcontrol;

         // TODO: we probably don't need to rescan IR
         this.init_dmi_access(s_tck, s_tms, s_trstn, s_tdi);
         this.read_debug_reg(dm::DMControl, dmcontrol,
                             s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         dmcontrol.haltreq = haltreq;

         this.write_debug_reg(dm::DMControl, dmcontrol,
                              s_tck, s_tms, s_trstn, s_tdi, s_tdo);


         //wait the core to be stalled
         dm_data = '0;
         while(dm_data[8] == 1'b0) begin //anyhalted
            this.set_dmi(
                  2'b01, //read
                  7'h11, //dmstatus
                  32'h0, //whatever
                  {dm_addr, dm_data, dm_op},
                  s_tck,
                  s_tms,
                  s_trstn,
                  s_tdi,
                  s_tdo
               );
         end

      endtask

      task set_resumereq(
         input logic resumereq,
         ref logic   s_tck,
         ref logic   s_tms,
         ref logic   s_trstn,
         ref logic   s_tdi,
         ref logic   s_tdo
      );

          logic [1:0]     dm_op;
          logic [6:0]     dm_addr;
          logic [31:0]    dm_data;
          dm::dmcontrol_t dmcontrol;

         // TODO: we probably don't need to rescan IR
         this.init_dmi_access(s_tck, s_tms, s_trstn, s_tdi);
         this.read_debug_reg(dm::DMControl, dmcontrol,
                             s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         dmcontrol.resumereq = resumereq;

         this.write_debug_reg(dm::DMControl, dmcontrol,
                              s_tck, s_tms, s_trstn, s_tdi, s_tdo);

      endtask


      task halt_harts(
         ref logic   s_tck,
         ref logic   s_tms,
         ref logic   s_trstn,
         ref logic   s_tdi,
         ref logic   s_tdo
      );

         dm::dmcontrol_t dmcontrol;
         dm::dmstatus_t  dmstatus;

         // stop the hart by setting haltreq
         this.read_debug_reg(dm::DMControl, dmcontrol,
                             s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         dmcontrol.haltreq = 1'b1;

         this.write_debug_reg(dm::DMControl, dmcontrol,
                              s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         // wait until hart is halted
         do begin
            this.read_debug_reg(dm::DMStatus, dmstatus,
                                s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         end while(dmstatus.allhalted != 1'b1);

         // clear haltreq
         dmcontrol.haltreq = 1'b0;
         this.write_debug_reg(dm::DMControl, dmcontrol,
                              s_tck, s_tms, s_trstn, s_tdi, s_tdo);

      endtask


      task resume_harts(
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );

         dm::dmcontrol_t dmcontrol;
         dm::dmstatus_t  dmstatus;

         // resume the hart by setting resumereq
         this.read_debug_reg(dm::DMControl, dmcontrol,
                             s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         dmcontrol.resumereq = 1'b1;

         this.write_debug_reg(dm::DMControl, dmcontrol,
                              s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         // wait until hart resumed
         do begin
            this.read_debug_reg(dm::DMStatus, dmstatus,
                                s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         end while(dmstatus.allresumeack != 1'b1);

         // clear resumereq
         dmcontrol.resumereq = 1'b0;
         this.write_debug_reg(dm::DMControl, dmcontrol,
                              s_tck, s_tms, s_trstn, s_tdi, s_tdo);

      endtask

      task block_until_any_halt(
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );

         dm::dmstatus_t dmstatus;

         do begin
            this.read_debug_reg(dm::DMStatus, dmstatus,
                                s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         end while(dmstatus.anyhalted == 1'b0);

      endtask

      task writeArg (
         input logic arg,
         input logic [31:0] val,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );


          logic [1:0]  dm_op;
          logic [6:0]  dm_addr;
          logic [31:0] dm_data;

         dm_addr = arg ? 7'd8 : 7'd4;

         this.set_dmi(
               2'b10,    //write
               dm_addr, //data0 or data1
               val,     //whatever
               {dm_addr, dm_data, dm_op},
               s_tck,
               s_tms,
               s_trstn,
               s_tdi,
               s_tdo
            );
      endtask

      task writePrgramBuff (
         input logic [2:0]  arg,
         input logic [31:0] val,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );


          logic [1:0]  dm_op;
          logic [6:0]  dm_addr;
          logic [31:0] dm_data;

         dm_addr = 7'h20 + arg;

         this.set_dmi(
               2'b10,    //write
               dm_addr, //progbuffer_i
               val,     //whatever
               {dm_addr, dm_data, dm_op},
               s_tck,
               s_tms,
               s_trstn,
               s_tdi,
               s_tdo
            );

      endtask

      // wait for abstract command to finish, no error checking
      task wait_command (
         input logic [31:0] command,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );

         dm::abstractcs_t abstractcs;

         // wait until we get a result
         do begin
            this.read_debug_reg(dm::AbstractCS, abstractcs,
                                s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         end while(abstractcs.busy == 1'b1);

         assert(abstractcs.cmderr == dm::CmdErrNone)
             else $error("Access to register %x failed with error %x",
                         command[15:0],
                         abstractcs.cmderr);

         // if we got an error we need to clear it for the following accesses
         if (abstractcs.cmderr != dm::CmdErrNone) begin
            abstractcs = '{default:0, cmderr:abstractcs.cmderr};
            this.write_debug_reg(dm::AbstractCS, abstractcs,
                                 s_tck, s_tms, s_trstn, s_tdi, s_tdo);


            this.read_debug_reg(dm::AbstractCS, abstractcs,
                             s_tck, s_tms, s_trstn, s_tdi, s_tdo);

            assert(abstractcs.cmderr == dm::CmdErrNone)
                else begin
                   $error("cmderr bit didn't get cleared");
                end
         end

      endtask


      task set_command (
         input logic [31:0] command,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );


          logic [1:0]  dm_op;
          logic [6:0]  dm_addr;
          logic [31:0] dm_data;

         this.set_dmi(
               2'b10,   //write
               7'h17,   //command
               command, //whatever
               {dm_addr, dm_data, dm_op},
               s_tck,
               s_tms,
               s_trstn,
               s_tdi,
               s_tdo
            );

         this.wait_command(
               command,
               s_tck,
               s_tms,
               s_trstn,
               s_tdi,
               s_tdo
            );

      endtask

      task read_dtmcs(
         output logic [31:0] dtmcs,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         logic [31+NUM_TAPS-1:0] dataout;
         JTAG_reg #(.size(32+NUM_TAPS-1), .instr(JTAG_DTMCSR)) JTAG_dbg = new;
         JTAG_dbg.start_shift(s_tck, s_tms, s_trstn, s_tdi);
         JTAG_dbg.shift_nbits(32+NUM_TAPS-1, '0, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         JTAG_dbg.idle(s_tck, s_tms, s_trstn, s_tdi);
         dtmcs = dataout[31:0];
      endtask

      task write_dtmcs(
         input logic [31:0] dtmcs,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         logic [31+NUM_TAPS-1:0] dataout;
         logic [NUM_TAPS-1:0] zeros = '0;
         JTAG_reg #(.size(32+NUM_TAPS-1), .instr(JTAG_DTMCSR)) JTAG_dbg = new;
         JTAG_dbg.start_shift(s_tck, s_tms, s_trstn, s_tdi);
         JTAG_dbg.shift_nbits(32+NUM_TAPS-1, {zeros, dtmcs}, dataout, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         JTAG_dbg.idle(s_tck, s_tms, s_trstn, s_tdi);

      endtask

      task test_read_sbcs(
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );

         dm::sbcs_t sbcs;

         this.read_debug_reg(dm::SBCS, sbcs,
                             s_tck, s_tms, s_trstn, s_tdi, s_tdo);


         $display("[JTAG] %t - Debug Module System Bus Access Control and Status: \n\
                 sbbusy          %x\n\
                 sbreadonaddr    %x\n\
                 sbaccess        %x\n\
                 sbautoincrement %x\n\
                 sbreadondata    %x\n\
                 sberror         %x\n\
                 sbasize         %x\n\
                 sbaccess128     %x\n\
                 sbaccess64      %x\n\
                 sbaccess32      %x\n\
                 sbaccess16      %x\n\
                 sbaccess8       %x\
              ", $realtime, sbcs.sbbusy, sbcs.sbreadonaddr, sbcs.sbaccess, sbcs.sbautoincrement,
                             sbcs.sbreadondata, sbcs.sberror, sbcs.sbasize, sbcs.sbaccess128,
                             sbcs.sbaccess64, sbcs.sbaccess32, sbcs.sbaccess16, sbcs.sbaccess8);

         assert(sbcs.sbbusy == 1'b0)
             else $error("sb is busy even though we are idling");
         assert(sbcs.sberror == 2'b0)
             else $error("sb is in some error state");
         assert(sbcs.sbasize == 7'd64)
             else $error("sbasize is not XLEN=64"); //change to 64 bit ariane
         assert(sbcs.sbaccess64 == 1'b1)
             else $error("sbaccess64 is should be supported");
         assert(sbcs.sbaccess32 == 1'b0)
             else $error("sbaccess32 is signaled as supported");
         assert(sbcs.sbaccess16 == 1'b0)
             else $error("sbaccess16 is signaled as supported");
         assert(sbcs.sbaccess8 == 1'b0)
             else $error("sbaccess8 is signaled as supported");

      endtask

      task test_read_abstractcs(
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );

         dm::abstractcs_t abstractcs;

         read_debug_reg(dm::AbstractCS, abstractcs, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         $display("[JTAG] %t - Abstractcs is %x (progbufsize %x, busy %x, cmderr %x, datacount %x)",
                   $realtime, abstractcs, abstractcs.progbufsize, abstractcs.busy,
                   abstractcs.cmderr, abstractcs.datacount);

         assert(abstractcs.progbufsize == 5'h8)
             else $error("progbufsize is not 8 (might be ok)");
         assert(abstractcs.datacount == 4'h2)
             else $error("datacount is not 2 (might be ok)");

      endtask

      task set_dmi(
         input  logic [1:0]  op_i,
         input  logic [6:0]  address_i,
         input  logic [31:0] data_i,
         output logic [DMI_SIZE-1:0]  data_o,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         logic [DMI_SIZE-1+(NUM_TAPS-1):0] buffer;
         logic [DMI_SIZE-1:0]   buffer_riscv;
         logic [NUM_TAPS-1:0] zeros = '0;
         JTAG_reg #(.size(DMI_SIZE+(NUM_TAPS-1)), .instr(JTAG_DMIACCESS)) JTAG_dbg = new;
         JTAG_dbg.start_shift(s_tck, s_tms, s_trstn, s_tdi);
         JTAG_dbg.shift_nbits(DMI_SIZE+(NUM_TAPS-1), {zeros, address_i, data_i, op_i}, buffer, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         JTAG_dbg.jtag_goto_UPDATE_DR_FROM_SHIFT_DR(s_tck, s_tms, s_trstn, s_tdi);
         JTAG_dbg.jtag_goto_CAPTURE_DR_FROM_UPDATE_DR_GETDATA(buffer, s_tck, s_tms, s_trstn, s_tdi,s_tdo);
         buffer_riscv = buffer[DMI_SIZE-1:0]; // dla is only TAP in the JTAG chain
         //while(buffer_riscv[1:0] == 2'b11) begin
         //   //$display("buffer is set_dmi is %x (OP %x address %x datain %x) (%t)",buffer, buffer[1:0], buffer[8:2], buffer[DMI_SIZE-1:9], $realtime);
         //   JTAG_dbg.jtag_goto_CAPTURE_DR_FROM_SHIFT_DR_GETDATA(buffer, s_tck, s_tms, s_trstn, s_tdi,s_tdo);
         //   buffer_riscv = buffer[DMI_SIZE:1];
         //end
         //$display("dataout is set_dmi is %x (OP %x address %x datain %x) (%t)",buffer, buffer[1:0], buffer[40:34],  buffer[33:2], $realtime);
         data_o[1:0]   = buffer_riscv[1:0];
         data_o[40:34] = buffer_riscv[40:34];
         data_o[33:2]  = buffer_riscv[33:2];
         JTAG_dbg.idle(s_tck, s_tms, s_trstn, s_tdi);

      endtask      

      task dmi_reset(
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         logic [31:0] buffer;
         init_dtmcs(s_tck, s_tms, s_trstn, s_tdi);

         this.read_dtmcs(
               buffer,
               s_tck,
               s_tms,
               s_trstn,
               s_tdi,
               s_tdo
            );
         buffer[16] = 1'b1;
         this.write_dtmcs(
               buffer,
               s_tck,
               s_tms,
               s_trstn,
               s_tdi,
               s_tdo
            );
         buffer[16] = 1'b0;
         this.write_dtmcs(
               buffer,
               s_tck,
               s_tms,
               s_trstn,
               s_tdi,
               s_tdo
            );
      endtask

      task set_dmactive(
         input logic dmactive,
         ref   logic s_tck,
         ref   logic s_tms,
         ref   logic s_trstn,
         ref   logic s_tdi,
         ref   logic s_tdo
      );

         logic [1:0]         dm_op;
         logic [31:0]        dm_data;
         logic [6:0]         dm_addr;

         this.set_dmi(
               2'b10, //Write
               7'h10, //DMControl
               {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 10'b0, 10'b0, 2'b0, 1'b0, 1'b0, 1'b0, dmactive},
               {dm_addr, dm_data, dm_op},
               s_tck,
               s_tms,
               s_trstn,
               s_tdi,
               s_tdo
            );

      endtask

      task set_hartsel(
         input logic [19:0] hartsel,
         ref   logic s_tck,
         ref   logic s_tms,
         ref   logic s_trstn,
         ref   logic s_tdi,
         ref   logic s_tdo
      );

         dm::dmcontrol_t dmcontrol;

         this.read_debug_reg(dm::DMControl, dmcontrol,
                             s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         dmcontrol.hartsello = hartsel[9:0];
         dmcontrol.hartselhi = hartsel[19:10];

         this.write_debug_reg(dm::DMControl, dmcontrol,
                              s_tck, s_tms, s_trstn, s_tdi, s_tdo);

      endtask


      task set_sbreadonaddr(
         input logic sbreadonaddr,
         ref   logic s_tck,
         ref   logic s_tms,
         ref   logic s_trstn,
         ref   logic s_tdi,
         ref   logic s_tdo
      );

         dm::sbcs_t sbcs;

         this.read_debug_reg(dm::SBCS, sbcs,
                             s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         sbcs.sbreadonaddr = sbreadonaddr;

         this.write_debug_reg(dm::SBCS, sbcs,
                              s_tck, s_tms, s_trstn, s_tdi, s_tdo);

      endtask

      task set_sbautoincrement(
         input logic sbautoincrement,
         ref   logic s_tck,
         ref   logic s_tms,
         ref   logic s_trstn,
         ref   logic s_tdi,
         ref   logic s_tdo
      );

         dm::sbcs_t sbcs;

         this.read_debug_reg(dm::SBCS, sbcs,
                             s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         sbcs.sbautoincrement = sbautoincrement;


         this.write_debug_reg(dm::SBCS, sbcs,
                              s_tck, s_tms, s_trstn, s_tdi, s_tdo);

      endtask

      // access (read) debug module register according to riscv-debug p. 71
      task read_debug_reg(
         input logic [6:0]   dmi_addr_i,
         output logic [31:0] data_o,
         ref logic           s_tck,
         ref logic           s_tms,
         ref logic           s_trstn,
         ref logic           s_tdi,
         ref logic           s_tdo
      );

         logic [1:0]         dmi_op;
         logic [31:0]        dmi_data;
         logic [6:0]         dmi_addr;

         // TODO: widen wait between Capture-DR and Update-DR when failing
         do begin
             this.set_dmi(
                   2'b01, //read
                   dmi_addr_i,
                   32'h0, // don't care
                   {dmi_addr, dmi_data, dmi_op},
                   s_tck,
                   s_tms,
                   s_trstn,
                   s_tdi,
                   s_tdo
             );
             if (dmi_op == 2'h2) begin
                 $display("[JTAG] %t dmi previous operation failed, not handled", $realtime);
                 dmi_op = 2'h0; // TODO: for now we just force completion
             end

             if (dmi_op == 2'h3) begin
                 $display("[JTAG] %t retrying debug reg access", $realtime);
                 this.dmi_reset(s_tck,s_tms,s_trstn,s_tdi,s_tdo);
                 this.init_dmi_access(s_tck,s_tms,s_trstn,s_tdi);
             end

         end while (dmi_op != 2'h0);

         data_o = dmi_data;
      endtask

      // access (write) debug module register according to riscv-debug p. 71
      task write_debug_reg(
         input logic [6:0]   dmi_addr_i,
         input logic [31:0]  dmi_data_i,
         ref logic           s_tck,
         ref logic           s_tms,
         ref logic           s_trstn,
         ref logic           s_tdi,
         ref logic           s_tdo
      );

         logic [1:0]     dmi_op;
         logic [31:0]    dmi_data;
         logic [6:0]     dmi_addr;
         dm::dmcontrol_t dmcontrol;
         int             dmsane;

         // According to riscv-debug p. 22 we are only allowed to write at most
         // one bit to resumereq, hartreset, ackhavereset,setresethaltreq and
         // clrresethaltreq. Others must be 0. This assert is for programming
         // errors.
         if(dmi_addr_i == dm::DMControl) begin
            dmcontrol = dmi_data_i;
            dmsane    = dmcontrol.resumereq + dmcontrol.hartreset +
                        dmcontrol.ackhavereset + dmcontrol.setresethaltreq +
                        dmcontrol.clrresethaltreq;

            assert (dmsane <= 1)
                else
                    $error("bad write to dmcontrol: only one of the following may be set to 1: resumereq %b,",
                           dmcontrol.resumereq,
                           "hartreset %b,", dmcontrol.hartreset,
                           "ackhavereset %b,", dmcontrol.ackhavereset,
                           "setresethaltreq %b,", dmcontrol.setresethaltreq,
                           "clrresethaltreq %b", dmcontrol.clrresethaltreq);
         end


         // TODO: widen wait between Capture-DR and Update-DR when failing
         do begin
             this.set_dmi(
                   2'b10, //write
                   dmi_addr_i,
                   dmi_data_i,
                   {dmi_addr, dmi_data, dmi_op},
                   s_tck,
                   s_tms,
                   s_trstn,
                   s_tdi,
                   s_tdo
             );
             if (dmi_op == 2'h2) begin
                 $display("[JTAG] %t dmi previous operation failed, not handled", $realtime);
                 dmi_op = 2'h0; // TODO: for now we just force completion
             end

             if (dmi_op == 2'h3) begin
                 $display("[JTAG] %t retrying debug reg access", $realtime);
                 this.dmi_reset(s_tck,s_tms,s_trstn,s_tdi,s_tdo);
                 this.init_dmi_access(s_tck,s_tms,s_trstn,s_tdi);
             end

         end while (dmi_op != 2'h0);

      endtask


      // access (read) csr, gpr by means of abstract command
      task read_reg_abstract_cmd(
         input logic [15:0]  regno_i,
         output logic [31:0] data_o,
         ref logic           s_tck,
         ref logic           s_tms,
         ref logic           s_trstn,
         ref logic           s_tdi,
         ref logic           s_tdo
      );

         logic [1:0]         dmi_op;
         logic [63:0]        dmi_data;
         logic [31:0]        dmi_command;
         logic [6:0]         dmi_addr;

         // load regno into data0
         dmi_command = {8'h0, 1'b0, 3'd3, 1'b0, 1'b0, 1'b1, 1'b0, regno_i};
         this.set_command(
            dmi_command,
            s_tck,
            s_tms,
            s_trstn,
            s_tdi,
            s_tdo
         );

         this.read_debug_reg(
            dm::Data0,
            dmi_data[31:0],
            s_tck,
            s_tms,
            s_trstn,
            s_tdi,
            s_tdo
         );

         this.read_debug_reg(
            dm::Data1,
            dmi_data[63:32],
            s_tck,
            s_tms,
            s_trstn,
            s_tdi,
            s_tdo
         );

         data_o = dmi_data;
      endtask


      // access (write) csr, gpr by means of abstract command
      task write_reg_abstract_cmd(
         input logic [15:0] regno_i,
         input logic [63:0] data_i,
         ref logic          s_tck,
         ref logic          s_tms,
         ref logic          s_trstn,
         ref logic          s_tdi,
         ref logic          s_tdo
      );

         logic [1:0]         dmi_op;
         logic [31:0]        dmi_data;
         logic [31:0]        dmi_command;
         logic [6:0]         dmi_addr;

         // write 64b data_i into data0 and data1
         this.write_debug_reg(
             dm::Data0,
             data_i[31:0],
             s_tck,
             s_tms,
             s_trstn,
             s_tdi,
             s_tdo
         );

         this.write_debug_reg(
             dm::Data1,
             data_i[63:32],
             s_tck,
             s_tms,
             s_trstn,
             s_tdi,
             s_tdo
         );

         // write data0 to regno_i
         dmi_command = {8'h0, 1'b0, 3'd3, 1'b0, 1'b0, 1'b1, 1'b1, regno_i};
         this.set_command(
            dmi_command,
            s_tck,
            s_tms,
            s_trstn,
            s_tdi,
            s_tdo
         );


      endtask

      // Before starting an abstract command, haltreq=resumereq=ackhavereset=0
      // must be ensured, which is what this task asserts (see debug spec p.11).
      // We use this to catch programming mistakes, not to test functionality
      task assert_rdy_for_abstract_cmd(
         ref logic           s_tck,
         ref logic           s_tms,
         ref logic           s_trstn,
         ref logic           s_tdi,
         ref logic           s_tdo
      );

         dm::dmcontrol_t dmcontrol;
         this.read_debug_reg(dm::DMControl, dmcontrol,
                             s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         assert(dmcontrol.haltreq == 1'b0)
             else $error("haltreq is not zero");
         assert(dmcontrol.resumereq == 1'b0)
             else $error("resumereq is not zero");
         assert(dmcontrol.ackhavereset == 1'b0)
             else $error("ackhavereset is not zero");

      endtask

      // access csr, gpr by means of program buffer
      task read_reg_prog_buff(
         input logic [15:0]  regno_i,
         output logic [31:0] data_o,
         ref logic           s_tck,
         ref logic           s_tms,
         ref logic           s_trstn,
         ref logic           s_tdi,
         ref logic           s_tdo
      );

         logic [1:0]         dmi_op;
         logic [31:0]        dmi_data;
         logic [31:0]        dmi_command;
         logic [6:0]         dmi_addr;

         // load regno into data0
         dmi_command = {8'h0, 1'b0, 3'd2, 1'b0, 1'b0, 1'b1, 1'b0, regno_i};
         this.set_command(
            dmi_command,
            s_tck,
            s_tms,
            s_trstn,
            s_tdi,
            s_tdo
         );

         this.read_debug_reg(
            dm::Data0,
            dmi_data,
            s_tck,
            s_tms,
            s_trstn,
            s_tdi,
            s_tdo
         );

         data_o = dmi_data;
      endtask


      task readMem(
         input  logic [63:0] addr_i,
         output logic [63:0] data_o,
         ref    logic s_tck,
         ref    logic s_tms,
         ref    logic s_trstn,
         ref    logic s_tdi,
         ref    logic s_tdo
      );

         logic [1:0]         dm_op;
         logic [31:0]        dm_data;
         logic [6:0]         dm_addr;

         //NOTE sbreadonaddr must be 1

         dm_op = '1; //error

         while(dm_op == '1) begin
            //Write the Address
            this.set_dmi(
               2'b10,        //write
               7'h39,        //sbaddress0,
               addr_i,       //address
               {dm_addr, dm_data, dm_op},
               s_tck,
               s_tms,
               s_trstn,
               s_tdi,
               s_tdo
            );
            // $display("(sbaddress0) dm_addr %x dm_data %x dm_op %x at time %t", dm_addr, dm_data, dm_op, $realtime,);
            if(dm_op == '1) begin
               $display("dmi_reset at time %t",$realtime);
               this.dmi_reset(s_tck,s_tms,s_trstn,s_tdi,s_tdo);
               this.init_dmi_access(s_tck,s_tms,s_trstn,s_tdi);
            end

         end

         dm_op = '1; //error

         while(dm_op == '1) begin

            this.set_dmi(
               2'b01,     //read
               7'h3D,     //sbdata1,
               32'h0,     //whatever
               {dm_addr, dm_data, dm_op},
               s_tck,
               s_tms,
               s_trstn,
               s_tdi,
               s_tdo
            );
            data_o[63:32] = dm_data;
            this.set_dmi(
               2'b01,     //read
               7'h3C,     //sbdata0,
               32'h0,     //whatever
               {dm_addr, dm_data, dm_op},
               s_tck,
               s_tms,
               s_trstn,
               s_tdi,
               s_tdo
            );
            data_o[31:0] = dm_data;
            // $display("(sbdata0) dm_addr %x dm_data %x dm_op %x at time %t", dm_addr, dm_data, dm_op, $realtime);
               if(dm_op == '1) begin
                  $display("dmi_reset at time %t",$realtime);
                  this.dmi_reset(s_tck,s_tms,s_trstn,s_tdi,s_tdo);
                  this.init_dmi_access(s_tck,s_tms,s_trstn,s_tdi);
               end

         end
         //data_o = dm_data;


      endtask

      /*
      task writeMem(
         input  logic [31:0] addr_i,
         input  logic [31:0] data_i,
         ref    logic s_tck,
         ref    logic s_tms,
         ref    logic s_trstn,
         ref    logic s_tdi,
         ref    logic s_tdo
      );

         logic [1:0]         dm_op;
         logic [31:0]        dm_data;
         logic [6:0]         dm_addr;

         //NOTE sbreadonaddr must be 1

         //Write the Address
         this.set_dmi(
            2'b10,        //write
            7'h39,        //sbaddress0,
            addr_i,       //address
            {dm_addr, dm_data, dm_op},
            s_tck,
            s_tms,
            s_trstn,
            s_tdi,
            s_tdo
         );

         this.set_dmi(
            2'b10,        //write
            7'h3C,        //sbdata0,
            data_i,      //data_i
            {dm_addr, dm_data, dm_op},
            s_tck,
            s_tms,
            s_trstn,
            s_tdi,
            s_tdo
         );

      endtask*/

      task writeMem(
         input  logic [63:0] addr_i,
         input  logic [63:0] data_i,
         ref    logic s_tck,
         ref    logic s_tms,
         ref    logic s_trstn,
         ref    logic s_tdi,
         ref    logic s_tdo
      );

         logic [1:0]         dm_op;
         logic [31:0]        dm_data;
         logic [6:0]         dm_addr;

         //NOTE sbreadonaddr must be 1

         //Write the Address
         this.set_dmi(
            2'b10,        //write
            7'h3A,        //sbaddress1,
            addr_i[63:32],       //address
            {dm_addr, dm_data, dm_op},
            s_tck,
            s_tms,
            s_trstn,
            s_tdi,
            s_tdo
         );

         this.set_dmi(
            2'b10,        //write
            7'h39,        //sbaddress0,
            addr_i,       //address
            {dm_addr, dm_data, dm_op},
            s_tck,
            s_tms,
            s_trstn,
            s_tdi,
            s_tdo
         );

         this.set_dmi(
            2'b10,         //write
            7'h3D,         //sbdata1,
            data_i[63:32], //data_i
            {dm_addr, dm_data, dm_op},
            s_tck,
            s_tms,
            s_trstn,
            s_tdi,
            s_tdo
         );

         this.set_dmi(
            2'b10,        //write
            7'h3C,        //sbdata0,
            data_i,       //data_i
            {dm_addr, dm_data, dm_op},
            s_tck,
            s_tms,
            s_trstn,
            s_tdi,
            s_tdo
         );

      endtask


      task load_L2(
         input logic [       63:0] base_addr,
         input logic [L2Width-1:0] stimuli [PROG_LEN],
         ref   logic s_tck,
         ref   logic s_tms,
         ref   logic s_trstn,
         ref   logic s_tdi,
         ref   logic s_tdo
      );

         logic [63:0] jtag_data;
         logic [63:0] jtag_addr = base_addr;
         logic        more_stim = 1;
         logic [ 1:0] dm_op;
         logic [31:0] dm_data;
         logic [ 6:0] dm_addr;

         int num_stim = 0;

         this.set_sbreadonaddr(1'b0, s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         this.set_sbautoincrement(1'b0, s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         $display("[JTAG] Loading L2 with debug module jtag interface");

         while (more_stim) begin // loop until we have no more stimuli

            jtag_data = stimuli[num_stim][63:0];  // assign LOW data

            // only print every 256 Bytes
            if(jtag_addr[7:0] == 8'h00)
              $display( "[JTAG] Writing data:", $sformatf("%x to addr:%x", jtag_data, jtag_addr));

            this.writeMem(jtag_addr, jtag_data, s_tck, s_tms, s_trstn, s_tdi, s_tdo);

            jtag_addr += 8; // increment address by word size in Bytes

            jtag_data = stimuli[num_stim][127:64];  // assign LOW data

            this.writeMem(jtag_addr, jtag_data, s_tck, s_tms, s_trstn, s_tdi, s_tdo);

            num_stim = num_stim + 1;

            // Make sure we have more valid stimuli. If not, set variable to 0,
            // this will prevent additional stimuli to be applied.
            if (num_stim > (PROG_LEN-1) || $isunknown(stimuli[num_stim]) ) begin
               more_stim = 0;
               break;
            end

            jtag_addr += 8; // increment address by word size in Bytes

         end
         this.set_sbreadonaddr(1'b1, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         this.set_sbautoincrement(1'b0, s_tck, s_tms, s_trstn, s_tdi, s_tdo);

      endtask

      // discover harts by writting all ones to hartsel and reading it back
      task test_discover_harts(
         output logic        error,
         ref logic           s_tck,
         ref logic           s_tms,
         ref logic           s_trstn,
         ref logic           s_tdi,
         ref logic           s_tdo
      );

         dm::dmcontrol_t dmcontrol;
         dm::dmstatus_t  dmstatus;
         logic [9:0]     hartsello;

         int hartcount = 0;

         error = 1'b0;

         this.read_debug_reg(dm::DMControl, dmcontrol,
                             s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         dmcontrol.hartsello = 10'h3ff;
         dmcontrol.hartselhi = 10'h3ff;

         this.write_debug_reg(dm::DMControl, dmcontrol,
                              s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         this.read_debug_reg(dm::DMControl, dmcontrol,
                             s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         $display("[JTAG] %t hartsel bits usuable %x",
                  $realtime, {dmcontrol.hartselhi, dmcontrol.hartsello});

         // some simulators don't like direct indexing
         hartsello = dmcontrol.hartsello;
         assert(hartsello[0] === 1'b1)
             else $info("test assumes atleast one usuable bit in hartsel");

         for (int i = 0; i < {dmcontrol.hartselhi, dmcontrol.hartsello}; i++) begin
            set_hartsel(i, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
            this.read_debug_reg(dm::DMStatus, dmstatus,
                             s_tck, s_tms, s_trstn, s_tdi, s_tdo);

            if(dmstatus.anynonexistent === 1'b1) // no more harts
                break;

            if(dmstatus.anyunavail !== 1'b1) // selected hart not here
                hartcount++;

         end

         assert (hartcount === 1)
             else begin
                $error("bad number of available harts in system detected: expected %x, received %x",
                         1, hartcount);
                error = 1'b1;
             end

      endtask


     // access csr, gpr by means of abstract command
      task test_gpr_read_write_abstract(
         output logic        error,
         ref logic           s_tck,
         ref logic           s_tms,
         ref logic           s_trstn,
         ref logic           s_tdi,
         ref logic           s_tdo
      );

         logic [1:0]         dmi_op;
         logic [31:0]        dmi_data;
         logic [31:0]        dmi_command;
         logic [6:0]         dmi_addr;

         error = 1'b0;

         //write beefdead into data0
         this.writeArg(
            0,
            32'hbeefdead,
            s_tck,
            s_tms,
            s_trstn,
            s_tdi,
            s_tdo
         );

         //Copy data0 to each register from x2 to x31 (abstract command)
         for (logic [15:0] regno = 16'h1002; regno < 16'h1020; regno=regno+1) begin
            dmi_data = {8'h0, 1'b0, 3'd2, 1'b0, 1'b0, 1'b1, 1'b1, regno};
               this.set_command(
                  dmi_data,
                  s_tck,
                  s_tms,
                  s_trstn,
                  s_tdi,
                  s_tdo
               );
         end

         // write ffff_ffff in data0 (some random value so that we can determine
         // whether we really load something form the gprs into data0 or if its
         // just the value from before)
         this.writeArg(
            0,
            32'hffff_ffff,
            s_tck,
            s_tms,
            s_trstn,
            s_tdi,
            s_tdo
         );

         for (logic [15:0] regno = 16'h1002; regno < 16'h1020; regno=regno+1) begin
            dmi_data = {8'h0, 1'b0, 3'd2, 1'b0, 1'b0, 1'b1, 1'b1, regno};
            this.set_command(
               dmi_data,
               s_tck,
               s_tms,
               s_trstn,
               s_tdi,
               s_tdo
            );
               // load regno into data0
            dmi_command = {8'h0, 1'b0, 3'd2, 1'b0, 1'b0, 1'b1, 1'b0, regno};
            this.set_command(
               dmi_command,
               s_tck,
               s_tms,
               s_trstn,
               s_tdi,
               s_tdo
            );


            // this command was tested separately to work
            // get out data0
            this.set_dmi(
               2'b01, //read
               7'h04, //data0
               32'h0, //whatever
               {dmi_addr, dmi_data, dmi_op},
               s_tck,
               s_tms,
               s_trstn,
               s_tdi,
               s_tdo
            );

            assert(dmi_data === 'hbeefdead)
                else begin
                   $error("expected %x, received %x in gpr %x",
                          'hbeefdead, dmi_data, regno);
                   error = 1'b1;
                end
         end

      endtask

      // access csr, gpr by means of abstract command in this version we employ
      // our precise read and write commands which closely follow what is
      // recommended in the debug spec
      task test_gpr_read_write_abstract_high_level(
         output logic        error,
         ref logic           s_tck,
         ref logic           s_tms,
         ref logic           s_trstn,
         ref logic           s_tdi,
         ref logic           s_tdo
      );

         logic [1:0]         dmi_op;
         logic [31:0]        dmi_data;
         logic [31:0]        dmi_command;
         logic [6:0]         dmi_addr;

         error = 1'b0;

         assert_rdy_for_abstract_cmd(s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         //Copy data0 to each register from x2 to x31 (abstract command)
         for (logic [15:0] regno = 16'h1002; regno < 16'h1020; regno=regno+1) begin
             this.write_reg_abstract_cmd(
                 regno,
                 32'hbeefdead, // TODO: want different values for regs
                 s_tck,
                 s_tms,
                 s_trstn,
                 s_tdi,
                 s_tdo
             );

         end

         // write ffff_ffff in data0 (some random value so that we can determine
         // whether we really load something form the gprs into data0 or if its
         // just the value from before)
         this.write_debug_reg(
             dm::Data0,
             32'hffff_ffff,
             s_tck,
             s_tms,
             s_trstn,
             s_tdi,
             s_tdo
         );

         for (logic [15:0] regno = 16'h1002; regno < 16'h1020; regno=regno+1) begin
            read_reg_abstract_cmd(
               regno,
               dmi_data,
               s_tck,
               s_tms,
               s_trstn,
               s_tdi,
               s_tdo
            );
            assert(dmi_data === 'hbeefdead)
                else begin
                   $error("expected %x, received %x in gpr %x",
                          'hbeefdead, dmi_data, regno);
                   error = 1'b1;
                end
         end

      endtask


      task test_wfi_in_program_buffer(
         output logic error,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );

         logic [31:0]        dm_data;
         this.write_debug_reg(
            dm::ProgBuf0,
            dm::wfi(), //wfi
            s_tck,
            s_tms,
            s_trstn,
            s_tdi,
            s_tdo
         );

         this.write_debug_reg(
            dm::ProgBuf0 + 1, //progrbuff1
            riscv::ebreak(), //ebreak
            s_tck,
            s_tms,
            s_trstn,
            s_tdi,
            s_tdo
         );
         //execute the program buffer
         dm_data = {8'h0, 1'b0, 3'd2, 1'b0, 1'b1, 1'b0, 1'b0, 16'h0};

         this.set_command(
              dm_data,
              s_tck,
              s_tms,
              s_trstn,
              s_tdi,
              s_tdo
              );
         error = 1'b0;
      endtask


      task test_abstract_cmds_prog_buf(
         output logic error,
         input logic [31:0] address_i,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );

         logic [1:0]         dm_op;
         logic [31:0]        dm_data;
         logic [6:0]         dm_addr;
         logic [31:0]        key_word = 32'hda41de;

         logic [63:0]        read_data;

         //write key_word in data0
         this.write_debug_reg(
            dm::Data0,
            key_word,
            s_tck,
            s_tms,
            s_trstn,
            s_tdi,
            s_tdo
         );

         assert_rdy_for_abstract_cmd(s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         //Copy data0 to each register from x2 to x31 by means of Access Register abstract commands
         for (logic [15:0] regno = 16'h1002; regno < 16'h1020; regno=regno+1) begin
            dm_data = {8'h0, 1'b0, 3'd2, 1'b0, 1'b0, 1'b1, 1'b1, regno};

               this.set_command(
                  dm_data,
                  s_tck,
                  s_tms,
                  s_trstn,
                  s_tdi,
                  s_tdo
               );
            //$display("[TB] %t Access Register at regno %d",$realtime(), regno[4:0]);

         end

         //Put address_i is x1 by writing it to data0 and then Access Register
         this.write_debug_reg(
            dm::Data0,
            address_i,
            s_tck,
            s_tms,
            s_trstn,
            s_tdi,
            s_tdo
         );

         dm_data = {8'h0, 1'b0, 3'd3, 1'b0, 1'b0, 1'b1, 1'b1, 16'h1001};
         this.set_command(
            dm_data,
            s_tck,
            s_tms,
            s_trstn,
            s_tdi,
            s_tdo
         );

         //increase every registers x2-x31 by 2-31  store them to *(x1++)
         for (logic [15:0] regno = 16'h1002; regno < 16'h1020; regno=regno+1) begin
               this.write_debug_reg(
                  dm::ProgBuf0,
                  { 7'h0, regno[4:0], regno[4:0], 3'b000, regno[4:0], 7'h13 }, // addi xi, xi, i
                  s_tck,
                  s_tms,
                  s_trstn,
                  s_tdi,
                  s_tdo
               );

               this.write_debug_reg(
                  dm::ProgBuf0 + 1,
                  riscv::store(3'b010, regno[4:0], 5'h1, 12'h0), // sw xi, 0(x1)
                  //{ 7'h0, regno[4:0], 5'h1, 1'b0, 2'b10, 5'h0, 7'h23 },
                  s_tck,
                  s_tms,
                  s_trstn,
                  s_tdi,
                  s_tdo
               );

               this.write_debug_reg(
                  dm::ProgBuf0 + 2,
                  { 12'h4, 5'h1, 3'b000, 5'h1, 7'h13 }, // addi x1, x1, 4
                  s_tck,
                  s_tms,
                  s_trstn,
                  s_tdi,
                  s_tdo
               );

               this.write_debug_reg(
                  dm::ProgBuf0 + 3,
                  riscv::ebreak(), //ebreak
                  s_tck,
                  s_tms,
                  s_trstn,
                  s_tdi,
                  s_tdo
               );
               //execute the program buffer
               dm_data = {8'h0, 1'b0, 3'd2, 1'b0, 1'b1, 1'b0, 1'b0, 16'h0};

               this.set_command(
                  dm_data,
                  s_tck,
                  s_tms,
                  s_trstn,
                  s_tdi,
                  s_tdo
               );
               //$display("[TB] %t Store of the value in reg %d",$realtime(), regno[4:0]);
         end

         //Now read them from memory the previous store values

         error = 1'b0;        
         for (int incAddr = 2; incAddr < 16; incAddr=incAddr+2) begin
            this.readMem(address_i + (incAddr-2)*4, read_data, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
            $display("[TB] %t Read %x from %x",$realtime(), read_data, address_i + (incAddr-2)*4);
            assert(read_data[31:0] === key_word + incAddr)
            else begin
               $error("read %x from %x instead of %x",
                      read_data[31:0], address_i + (incAddr-2)*4, key_word + incAddr);
               error = 1'b1;
            end

            assert(read_data[63:32] === key_word + incAddr +1)
            else begin
               $error("read %x from %x instead of %x",
                      read_data[63:32], address_i + (incAddr-2)*4 + 1, key_word + incAddr + 1);
               error = 1'b1;
            end
         end


      endtask


      task test_read_write_dpc(
         output logic error,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );

         logic [1:0]         dm_op;
         logic [31:0]        dm_data;
         logic [31:0]        saved;
         logic [6:0]         dm_addr;
         logic [31:0]        key_word;

         key_word = 32'hbeefdead & ~32'h1; // dpc lower bit always zero
         error = 1'b0;

         assert_rdy_for_abstract_cmd(s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         this.read_reg_abstract_cmd(
             riscv::CSR_DPC,
             saved,
             s_tck,
             s_tms,
             s_trstn,
             s_tdi,
             s_tdo
         );

         this.write_reg_abstract_cmd(
             riscv::CSR_DPC,
             key_word,
             s_tck,
             s_tms,
             s_trstn,
             s_tdi,
             s_tdo
         );

         this.read_reg_abstract_cmd(
             riscv::CSR_DPC,
             dm_data,
             s_tck,
             s_tms,
             s_trstn,
             s_tdi,
             s_tdo
         );

         assert(key_word === dm_data)
             else begin
                $error("read %x instead of %x", dm_data, key_word);
                error = 1'b1;
             end;

         this.write_reg_abstract_cmd(
             riscv::CSR_DPC,
             saved,
             s_tck,
             s_tms,
             s_trstn,
             s_tdi,
             s_tdo
         );

      endtask

      task test_wfi_wakeup(
         output logic error,
         input logic [31:0] addr_i,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );

         logic [31:0]        dm_dpc;
         riscv::dcsr_t       dcsr;
         dm::dmstatus_t      dmstatus;

         error = 1'b0;

        // check if our hart is halted
         this.read_debug_reg(dm::DMStatus, dmstatus,
                             s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         assert(dmstatus.allhalted == 1'b1)
             else begin
                $error("allhalted flag is not set when entering test");
                error = 1'b1;
             end

         // write short program to single step through
         //this.writeMem(addr_i, dm::wfi(),  // wfi
         //              s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         //$stop;
         //this.writeMem(addr_i + 4, { 7'h0, 5'b1, 5'b1, 3'b000, 5'b1, 7'h13 },  // addi xi, xi, i
         //              s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         //$stop;              
         //this.writeMem(addr_i + 8, { 7'h0, 5'b1, 5'b1, 3'b000, 5'b1, 7'h13 }, // addi xi, xi, i
         //              s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         //$stop;
         //this.writeMem(addr_i + 12, { 7'h0, 5'b1, 5'b1, 3'b000, 5'b1, 7'h13 }, // addi xi, xi, i
         //              s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         //$stop;
         //this.writeMem(addr_i + 16, {20'b0, 5'b0, 7'b1101111}, // J zero offset
         //              s_tck, s_tms, s_trstn, s_tdi, s_tdo);   
         //$stop;      


         this.writeMem(addr_i, {7'h0, 5'b1, 5'b1, 3'b000, 5'b1, 7'h13, dm::wfi()},  // wfi
                       s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         //$stop;
         this.writeMem(addr_i + 8, {7'h0, 5'b1, 5'b1, 3'b000, 5'b1, 7'h13, 7'h0, 5'b1, 5'b1, 3'b000, 5'b1, 7'h13}, // addi xi, xi, i
                       s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         //$stop;
         this.writeMem(addr_i + 16, {20'b0, 5'b0, 7'b1101111}, // J zero offset
                       s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         assert_rdy_for_abstract_cmd(s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         // write dpc to addr_i so that we know where we resume
         this.write_reg_abstract_cmd(riscv::CSR_DPC, addr_i,
                                     s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         // resume the core
         this.resume_harts(s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         this.halt_harts(s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         // The core should be in the WFI

         this.read_reg_abstract_cmd(riscv::CSR_DPC, dm_dpc,
                                    s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         // check if dpc, dcause and flag bits are ok
         assert(addr_i + 4 === dm_dpc) // did dpc increment?
                else begin
                   $error("dpc is %x, expected %x", dm_dpc, addr_i + 4);
                   error = 1'b1;
                end;

         // restore dpc to entry point
         this.write_reg_abstract_cmd(riscv::CSR_DPC, addr_i,
                                    s_tck, s_tms, s_trstn, s_tdi, s_tdo);

      endtask


      task test_single_stepping_abstract_cmd(
         output logic error,
         input logic [63:0] addr_i,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );

         logic [1:0]         dm_op;
         logic [31:0]        dm_data;
         riscv::dcsr_t       dcsr;
         dm::dmstatus_t      dmstatus;
         logic [6:0]         dm_addr;

         error = 1'b0;

        // check if our hart is halted
         this.read_debug_reg(dm::DMStatus, dmstatus,
                             s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         assert(dmstatus.allhalted == 1'b1)
             else begin
                $error("allhalted flag is not set when entering test");
                error = 1'b1;
             end

         // write short program to single step through
         //this.writeMem(addr_i, { 7'h0, 5'b1, 5'b1, 3'b000, 5'b1, 7'h13 },  // addi xi, xi, i
         //              s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         //this.writeMem(addr_i + 4, { 7'h0, 5'b1, 5'b1, 3'b000, 5'b1, 7'h13 },  // addi xi, xi, i
         //              s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         //this.writeMem(addr_i + 8, { 7'h0, 5'b1, 5'b1, 3'b000, 5'b1, 7'h13 }, // addi xi, xi, i
         //              s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         //this.writeMem(addr_i + 12, { 7'h0, 5'b1, 5'b1, 3'b000, 5'b1, 7'h13 }, // addi xi, xi, i
         //              s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         //this.writeMem(addr_i + 16, {20'b0, 5'b0, 7'b1101111}, // J zero offset
         //              s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         this.writeMem(addr_i, { 7'h0, 5'b1, 5'b1, 3'b000, 5'b1, 7'h13, 7'h0, 5'b1, 5'b1, 3'b000, 5'b1, 7'h13 },  // addi xi, xi, i
                       s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         this.writeMem(addr_i + 8, { 7'h0, 5'b1, 5'b1, 3'b000, 5'b1, 7'h13, 7'h0, 5'b1, 5'b1, 3'b000, 5'b1, 7'h13 }, // addi xi, xi, i
                       s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         this.writeMem(addr_i + 16, {20'b0, 5'b0, 7'b1101111}, // J zero offset
                       s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         assert_rdy_for_abstract_cmd(s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         // set step flag in dcsr
         this.read_reg_abstract_cmd(riscv::CSR_DCSR, dcsr,
                                    s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         dcsr.step = 1;
         this.write_reg_abstract_cmd(riscv::CSR_DCSR, dcsr,
                                     s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         this.read_reg_abstract_cmd(riscv::CSR_DCSR, dcsr,
                                    s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         assert(dcsr.step == 1)
             else begin
                $error("couldn't enter single stepping mode");
                error = 1'b1;
             end;

         // write dpc to addr_i so that we know where we resume
         this.write_reg_abstract_cmd(riscv::CSR_DPC, addr_i,
                                     s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         this.read_reg_abstract_cmd(riscv::CSR_DPC, dm_data, s_tck, s_tms,
                                    s_trstn, s_tdi, s_tdo);

         for (int i = 1; i < 4; i++) begin
            // Make a single step. Like openocd we halt the hart manually even
            // though it might suffice to just check if allhalted is set.
            this.resume_harts(s_tck, s_tms, s_trstn, s_tdi, s_tdo);
            this.halt_harts(s_tck, s_tms, s_trstn, s_tdi, s_tdo);
            // this.block_until_any_halt(s_tck, s_tms, s_trstn, s_tdi, s_tdo);

            this.read_reg_abstract_cmd(riscv::CSR_DPC, dm_data,
                                       s_tck, s_tms, s_trstn, s_tdi, s_tdo);
            // check if dpc, dcause and flag bits are ok
            assert(addr_i + 4*i === dm_data) // did dpc increment?
                else begin
                   $error("dpc is %x, expected %x", dm_data, addr_i + 4);
                   error = 1'b1;
                end;
            this.read_reg_abstract_cmd(riscv::CSR_DCSR, dcsr,
                                       s_tck, s_tms, s_trstn, s_tdi, s_tdo);
            assert(3'h4 === dcsr.cause) // is cause properly given as "step"?
                else begin
                   $error("debug cause is %x, expected %x", dcsr.cause, 3'h4);
                   error = 1'b1;
                end;
         end

         // clear step flag in dcsr
         this.read_reg_abstract_cmd(riscv::CSR_DCSR, dcsr,
                                    s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         dcsr.step = 0;
         this.write_reg_abstract_cmd(riscv::CSR_DCSR, dcsr,
                                     s_tck, s_tms, s_trstn, s_tdi, s_tdo);


      endtask


      task test_single_stepping_edge_cases(
         output logic error,
         input logic [31:0] addr_i,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );

         logic [1:0]         dm_op;
         logic [31:0]        dm_data;
         riscv::dcsr_t       dcsr;
         dm::dmstatus_t      dmstatus;
         logic [6:0]         dm_addr;
         // records the sequence of expected pc changes
         int                 pc_offsets[];

         error = 1'b0;

        // check if our hart is halted
         this.read_debug_reg(dm::DMStatus, dmstatus,
                             s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         assert(dmstatus.allhalted == 1'b1)
             else begin
                $error("allhalted flag is not set when entering test");
                error = 1'b1;
             end

         // write short program to single step through
         //pc_offsets = {4, 8, 16, 20, 24, 28, 32};
         //this.writeMem(addr_i + 0, riscv::nop(),
         //              s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         //this.writeMem(addr_i + 4, riscv::nop(),
         //              s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         //this.writeMem(addr_i + 8, dm::branch(5'h0, 5'h0, 3'b0, 12'h4), // branch to + 16
         //              s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         //this.writeMem(addr_i + 12, riscv::nop(),
         //              s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         //this.writeMem(addr_i + 16, { 7'h0, 5'b1, 5'b1, 3'b000, 5'b1, 7'h13 }, // addi xi, xi, i
         //              s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         //this.writeMem(addr_i + 20, { 7'h0, 5'b1, 5'b1, 3'b000, 5'b1, 7'h13 }, // addi xi, xi, i
         //              s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         //this.writeMem(addr_i + 24, dm::wfi(), // step over wfi
         //              s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         //this.writeMem(addr_i + 28, { 7'h0, 5'b1, 5'b1, 3'b000, 5'b1, 7'h13 }, // addi xi, xi, i
         //              s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         //this.writeMem(addr_i + 32, {20'b0, 5'b0, 7'b1101111}, // J zero offset
         //              s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         pc_offsets = {4, 8, 16, 20, 24, 28, 32};
         this.writeMem(addr_i + 0, { riscv::nop(), riscv::nop() },
                       s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         this.writeMem(addr_i + 8, { riscv::nop(), dm::branch(5'h0, 5'h0, 3'b0, 12'h4) }, // branch to + 16
                       s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         this.writeMem(addr_i + 16, { 7'h0, 5'b1, 5'b1, 3'b000, 5'b1, 7'h13, 7'h0, 5'b1, 5'b1, 3'b000, 5'b1, 7'h13 }, // addi xi, xi, i
                       s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         this.writeMem(addr_i + 24, { 7'h0, 5'b1, 5'b1, 3'b000, 5'b1, 7'h13, dm::wfi() }, // addi xi, xi, i // step over wfi
                       s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         this.writeMem(addr_i + 32, {20'b0, 5'b0, 7'b1101111}, // J zero offset
                       s_tck, s_tms, s_trstn, s_tdi, s_tdo);


         assert_rdy_for_abstract_cmd(s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         // set step flag in dcsr
         this.read_reg_abstract_cmd(riscv::CSR_DCSR, dcsr,
                                    s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         dcsr.step = 1;
         this.write_reg_abstract_cmd(riscv::CSR_DCSR, dcsr,
                                     s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         this.read_reg_abstract_cmd(riscv::CSR_DCSR, dcsr,
                                    s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         assert(dcsr.step == 1)
             else begin
                $error("couldn't enter single stepping mode");
                error = 1'b1;
             end;

         // write dpc to addr_i so that we know where we resume
         this.write_reg_abstract_cmd(riscv::CSR_DPC, addr_i,
                                     s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         this.read_reg_abstract_cmd(riscv::CSR_DPC, dm_data, s_tck, s_tms,
                                    s_trstn, s_tdi, s_tdo);

         for (int i = 0; i < $size(pc_offsets); i++) begin
            // Make a single step. Like openocd we halt the hart manually even
            // though it might suffice to just check if allhalted is set.
            this.resume_harts(s_tck, s_tms, s_trstn, s_tdi, s_tdo);
            this.halt_harts(s_tck, s_tms, s_trstn, s_tdi, s_tdo);
            // this.block_until_any_halt(s_tck, s_tms, s_trstn, s_tdi, s_tdo);

            this.read_reg_abstract_cmd(riscv::CSR_DPC, dm_data,
                                       s_tck, s_tms, s_trstn, s_tdi, s_tdo);
            // check if dpc, dcause and flag bits are ok
            assert(addr_i + pc_offsets[i] === dm_data) // did dpc increment?
                else begin
                   $error("dpc is %x, expected %x", dm_data, addr_i + pc_offsets[i]);
                   error = 1'b1;
                end;
            this.read_reg_abstract_cmd(riscv::CSR_DCSR, dcsr,
                                       s_tck, s_tms, s_trstn, s_tdi, s_tdo);
            assert(dm::CauseSingleStep === dcsr.cause) // is cause properly given as "step"?
                else begin
                   $error("debug cause is %x, expected %x", dcsr.cause, dm::CauseSingleStep);
                   error = 1'b1;
                end;
         end

         // clear step flag in dcsr
         this.read_reg_abstract_cmd(riscv::CSR_DCSR, dcsr,
                                    s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         dcsr.step = 0;
         this.write_reg_abstract_cmd(riscv::CSR_DCSR, dcsr,
                                     s_tck, s_tms, s_trstn, s_tdi, s_tdo);


      endtask


      task test_halt_resume(
         output logic error,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         dm::dmstatus_t dmstatus;
         error = 1'b0;

         // check if our hart is halted
         this.read_debug_reg(dm::DMStatus, dmstatus,
                             s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         assert(dmstatus.allhalted == 1'b1)
             else begin
                $error("allhalted flag is not set when entering test");
                error = 1'b1;
             end

         // resume core and check flags
         this.resume_harts(s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         this.read_debug_reg(dm::DMStatus, dmstatus,
                             s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         assert(dmstatus.allrunning == 1'b1)
             else begin
                $error("allrunning flag is not set after resume request");
                error = 1'b1;
             end

         // halt core and check flags
         this.halt_harts(s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         this.read_debug_reg(dm::DMStatus, dmstatus,
                             s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         assert(dmstatus.allhalted == 1'b1)
             else begin
                $error("allhalted flag is not set after halt request");
                error = 1'b1;
             end

      endtask

      task test_debug_cause_values(
         output logic error,
         input logic [63:0] addr_i,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         dm::dmstatus_t dmstatus;
         riscv::dcsr_t  dcsr;

         error = 1'b0;


         // check if our hart is halted
         this.read_debug_reg(dm::DMStatus, dmstatus,
                             s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         assert(dmstatus.allhalted == 1'b1)
             else begin
                $error("allhalted flag is not set when entering test");
                error = 1'b1;
             end

         //Write while(1) to BEGIN_L2_INSTR
         this.writeMem(addr_i, {25'b0, 7'b1101111},
                       s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         // // check if debug cause is haltrequest
         this.resume_harts(s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         this.halt_harts(s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         this.read_reg_abstract_cmd(riscv::CSR_DCSR, dcsr,
                                    s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         assert(dm::CauseRequest === dcsr.cause)
             else begin
                $error("debug cause is %x, expected %x", dcsr.cause, dm::CauseRequest);
                error = 1'b1;
             end;

         // check if debug request is haltrequest
         this.read_reg_abstract_cmd(riscv::CSR_DCSR, dcsr,
                                    s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         dcsr.step = 1;
         this.write_reg_abstract_cmd(riscv::CSR_DCSR, dcsr,
                                     s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         this.resume_harts(s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         this.block_until_any_halt(s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         //this.halt_harts(s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         this.read_reg_abstract_cmd(riscv::CSR_DCSR, dcsr,
                                    s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         assert(dm::CauseSingleStep === dcsr.cause)
             else begin
                $error("debug cause is %x, expected %x", dcsr.cause, dm::CauseSingleStep);
                error = 1'b1;
             end;

         this.read_reg_abstract_cmd(riscv::CSR_DCSR, dcsr,
                                    s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         dcsr.step = 0;
         this.write_reg_abstract_cmd(riscv::CSR_DCSR, dcsr,
                                     s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         // check if debug request is breakpoint
         //this.writeMem(addr_i + 0, { 7'h0, 5'b1, 5'b1, 3'b000, 5'b1, 7'h13 }, // addi xi, xi, i
         //              s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         //this.writeMem(addr_i + 4, { 7'h0, 5'b1, 5'b1, 3'b000, 5'b1, 7'h13 }, // addi xi, xi, i
         //              s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         //this.writeMem(addr_i + 8, riscv::ebreak(),
         //              s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         //this.writeMem(addr_i + 12, {20'b0, 5'b0, 7'b1101111}, // J zero offset
         //              s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         this.writeMem(addr_i + 0, { 7'h0, 5'b1, 5'b1, 3'b000, 5'b1, 7'h13, 7'h0, 5'b1, 5'b1, 3'b000, 5'b1, 7'h13 }, // addi xi, xi, i
                       s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         this.writeMem(addr_i + 8, {20'b0, 5'b0, 7'b1101111, riscv::ebreak()}, // J zero offset
                       s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         // force ebreak in m-mode to enter debug mode
         this.read_reg_abstract_cmd(riscv::CSR_DCSR, dcsr,
                                    s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         dcsr.ebreakm = 1;
         this.write_reg_abstract_cmd(riscv::CSR_DCSR, dcsr,
                                     s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         this.resume_harts(s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         // TODO: delay here until entering park loop...
         // check halted?

         this.read_reg_abstract_cmd(riscv::CSR_DCSR, dcsr,
                                    s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         assert(dm::CauseBreakpoint === dcsr.cause)
             else begin
                $error("debug cause is %x, expected %x", dcsr.cause, dm::CauseBreakpoint);
                error = 1'b1;
             end;

         this.read_reg_abstract_cmd(riscv::CSR_DCSR, dcsr,
                                    s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         dcsr.ebreakm = 0;
         this.write_reg_abstract_cmd(riscv::CSR_DCSR, dcsr,
                                     s_tck, s_tms, s_trstn, s_tdi, s_tdo);

      endtask


      task test_ebreak_in_program_buffer(
         output logic error,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );

         logic [31:0]   dm_data;
         logic [31:0]   dpc_save, dpc;
         riscv::dcsr_t  dcsr_save, dcsr;
         dm::dmstatus_t dmstatus;

         error = 1'b0;

         // check if our hart is halted
         this.read_debug_reg(dm::DMStatus, dmstatus,
                             s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         assert(dmstatus.allhalted == 1'b1)
             else begin
                $error("allhalted flag is not set when entering test");
                error = 1'b1;
             end

         // save dpc, dcsr.cause
         this.read_reg_abstract_cmd(riscv::CSR_DPC, dpc_save, s_tck, s_tms,
                                    s_trstn, s_tdi, s_tdo);

         this.read_reg_abstract_cmd(riscv::CSR_DCSR, dcsr_save, s_tck, s_tms,
                                    s_trstn, s_tdi, s_tdo);

         // write to program buffer
         this.write_debug_reg(dm::ProgBuf0, riscv::nop(),
                              s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         this.write_debug_reg(dm::ProgBuf0 + 1, riscv::ebreak(),
                              s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         //execute the program buffer
         dm_data = {8'h0, 1'b0, 3'd2, 1'b0, 1'b1, 1'b0, 1'b0, 16'h0};
         this.set_command(dm_data, s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         // check that dpc and dcsr.cause didn't change
         this.read_reg_abstract_cmd(riscv::CSR_DPC, dpc, s_tck, s_tms,
                                    s_trstn, s_tdi, s_tdo);

         this.read_reg_abstract_cmd(riscv::CSR_DCSR, dcsr, s_tck, s_tms,
                                    s_trstn, s_tdi, s_tdo);
         assert(dpc == dpc_save)
             else begin
                $error("dpc changed from %x to %x", dpc_save, dpc);
                error = 1'b1;
             end

         assert(dcsr.cause == dcsr_save.cause)
             else begin
                $error("dcsr changed from %x to %x", dcsr.cause, dcsr_save.cause);
                error = 1'b1;
             end

      endtask

      task test_bad_aarsize (
         output logic error,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );
         // assert busy == 0 and cmderr != 0,1
         logic [1:0] dm_op;
         logic [6:0] dm_addr;
         logic [31:0] dm_data;
         dm::abstractcs_t abstractcs;
         dm::ac_ar_cmd_t command;

         // abstract command with aarsize = 3
         command     = '{default:0, aarsize:3'd3, postexec:1'b0,
                         transfer:1'b1, write:1'b0, regno:16'h1002};

         this.set_dmi(
               2'b10,   //write
               dm::Command,
               {8'h0, command},
               {dm_addr, dm_data, dm_op},
               s_tck,
               s_tms,
               s_trstn,
               s_tdi,
               s_tdo
            );

         do begin
            this.read_debug_reg(dm::AbstractCS, abstractcs,
                                s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         end while(abstractcs.busy == 1'b1);

         assert(abstractcs.busy == 1'b0 && abstractcs.cmderr == dm::CmdErrNotSupported)
             else begin
                $display("Abstract cmd with 64 bit is signaled as supported");
                //error = 1'b1;
                error = 1'b0; //not Error for Ariane core
             end

         // try to clear the error bit
         abstractcs        = 0;
         abstractcs.cmderr = dm::CmdErrNotSupported;

         this.write_debug_reg(dm::AbstractCS, abstractcs,
                              s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         // test if it really got cleared
         this.read_debug_reg(dm::AbstractCS, abstractcs,
                             s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         assert(abstractcs.cmderr == dm::CmdErrNone)
             else begin
                $error("cmderr bit didn't get cleared");
                error = 1'b1;
             end

      endtask


      task test_read_write_csr (
         output logic error,
         ref logic s_tck,
         ref logic s_tms,
         ref logic s_trstn,
         ref logic s_tdi,
         ref logic s_tdo
      );

         dm::abstractcs_t abstractcs;
         logic [31:0]  regs [];
         logic [31:0] contents;


         regs = {riscv::CSR_DPC, riscv::CSR_MSTATUS, riscv::CSR_MISA};

         for (int i = 0; i < $size(regs); i++) begin
            this.read_reg_abstract_cmd(regs[i], contents, s_tck, s_tms,
                                       s_trstn, s_tdi, s_tdo);

            this.read_reg_abstract_cmd(riscv::CSR_MISA, contents, s_tck, s_tms,
                                       s_trstn, s_tdi, s_tdo);

         end


      endtask

      // This runs all test dm tests there are. For that to work we have to run
      // these before we load the binary into the L2 since we make ram and
      // registers dirty. begin_l2_instr contains the boot address which is
      // required when this tests ends so that the program can properly resume
      // after this tests are run once the binary is loaded into l2.
      task run_dm_tests (
         int unsigned fc_core_id,
         int unsigned begin_l2_instr, // required to restart booting process
         output logic error,
         output int   num_err,
         ref logic    s_tck,
         ref logic    s_tms,
         ref logic    s_trstn,
         ref logic    s_tdi,
         ref logic    s_tdo
      );
         logic [31:0] dm_data;
         num_err = 0;

         dump_dm_info(s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         // $display("[TB] %t - TEST discover harts", $realtime);
         // debug_mode_if.test_discover_harts(dm_data[0],
         //                                   s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         // if (error) begin
         //     $display("[TB] %t FAIL", $realtime);
         //     num_err++;
         // end else
         //     $display("[TB] %t OK", $realtime);

         set_hartsel(fc_core_id, s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         set_sbreadonaddr(1'b1, s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         // check if we can read sbcs and some of its entries
         test_read_sbcs(s_tck, s_tms, s_trstn, s_tdi, s_tdo);


         // Make sure that we get into an infinite loop on BEGIN_L2_INSTR
         // this is for our test setup
         // Write while(1) to BEGIN_L2_INSTR
         writeMem(begin_l2_instr, {25'b0, 7'b1101111},
             s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         $display("[JTAG] %t - Resuming the CORE", $realtime);
         resume_harts(s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         $display("[JTAG] %t - Halting the Core", $realtime);
         halt_harts(s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         // simple check whether we can read abstractcs and if progbufsize and
         // datacount are ok
         test_read_abstractcs(s_tck, s_tms, s_trstn, s_tdi, s_tdo);

         // for the following tests we need the cpu to be fetching and running
         $display("[JTAG] %t - TEST halt resume functionality", $realtime);
         test_halt_resume(error, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         if (error) begin
             $display("[JTAG] %t FAIL", $realtime);
             num_err++;
         end else
             $display("[JTAG] %t OK", $realtime);

         $display("[JTAG] %t - TEST wfi wake up logic",$realtime);
         test_wfi_wakeup(error, begin_l2_instr,
             s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         $display("[JTAG] %t OK", $realtime); //otherwise we wouldn't get here

         $display("[JTAG] %t - TEST read/write gpr with abstract command and proper waiting logic",
                  $realtime);
         test_gpr_read_write_abstract_high_level(error, s_tck, s_tms,
             s_trstn, s_tdi, s_tdo);
         if (error) begin
             $display("[JTAG] %t FAIL", $realtime);
             num_err++;
         end else
             $display("[JTAG] %t OK", $realtime);

         $display("[JTAG] %t - TEST dumping register values using abstract command", $realtime);
         read_reg_abstract_cmd(riscv::CSR_DCSR, dm_data, s_tck, s_tms,
             s_trstn, s_tdi, s_tdo);
         $display("[JTAG] %t dcsr is %x", $realtime, dm_data);
         read_reg_abstract_cmd(riscv::CSR_DPC, dm_data, s_tck, s_tms,
             s_trstn, s_tdi, s_tdo);
         $display("[JTAG] %t dpc is %x", $realtime, dm_data);
         read_reg_abstract_cmd(riscv::CSR_MTVEC, dm_data, s_tck, s_tms,
             s_trstn, s_tdi, s_tdo);
         $display("[JTAG] %t mtvec is %x", $realtime, dm_data);
         read_reg_abstract_cmd(riscv::CSR_MCAUSE, dm_data, s_tck, s_tms,
             s_trstn, s_tdi, s_tdo);
         $display("[JTAG] %t mcause is %x", $realtime, dm_data);
         read_reg_abstract_cmd('h1002, dm_data, s_tck, s_tms,
             s_trstn, s_tdi, s_tdo);
         $display("[JTAG] %t x2 is %x", $realtime, dm_data);

         $display("[JTAG] %t - TEST bad abstract command", $realtime);
         test_bad_aarsize (error, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         if(error) begin
             $display("[JTAG] %t FAIL", $realtime);
             num_err++;
         end else
             $display("[JTAG] %t OK", $realtime);

         $display("[JTAG] %t - TEST abstract commands and program buffer", $realtime);
         test_abstract_cmds_prog_buf(error, begin_l2_instr,
             s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         if(error) begin
             $display("[JTAG] %t FAIL", $realtime);
             num_err++;
         end else
             $display("[JTAG] %t OK", $realtime);

         $display("[JTAG] %t - TEST read/write dpc" , $realtime);
         test_read_write_dpc(error, s_tck, s_tms,
             s_trstn, s_tdi, s_tdo);
         if(error) begin
             $display("[JTAG] %t FAIL", $realtime);
             num_err++;
         end else
             $display("[JTAG] %t OK", $realtime);

         $display("[JTAG] %t - TEST read/write csr" , $realtime);
         test_read_write_csr(error, s_tck, s_tms,
             s_trstn, s_tdi, s_tdo);

         $display("[JTAG] %t - TEST read/write csr with program buffer (TODO)", $realtime);
         $display("[JTAG] %t - TEST dret outside debug mode (TODO)", $realtime);

         $display("[JTAG] %t - TEST ebreak in program buffer", $realtime);
         test_ebreak_in_program_buffer(error,
             s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         if(error) begin
             $display("[JTAG] %t FAIL", $realtime);
             num_err++;
         end else
             $display("[JTAG] %t OK", $realtime);


         $display("[JTAG] %t - TEST debug cause values", $realtime);
         test_debug_cause_values(error, {'0, begin_l2_instr},
             s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         if(error) begin
             $display("[JTAG] %t FAIL", $realtime);
             num_err++;
         end else
             $display("[JTAG] %t OK", $realtime);

         $display("[JTAG] %t - TEST single stepping", $realtime);
         test_single_stepping_abstract_cmd(error, begin_l2_instr,
             s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         if(error) begin
             $display("[JTAG] %t FAIL", $realtime);
             num_err++;
         end else
             $display("[JTAG] %t OK", $realtime);

         $display("[JTAG] %t - TEST single stepping edge cases", $realtime);
         test_single_stepping_edge_cases(error, begin_l2_instr,
             s_tck, s_tms, s_trstn, s_tdi, s_tdo);
         if(error) begin
             $display("[JTAG] %t FAIL", $realtime);
             num_err++;
         end else
             $display("[JTAG] %t OK", $realtime);

         $display("[JTAG] %t - TEST wfi in program buffer", $realtime);
         test_wfi_in_program_buffer(error, s_tck, s_tms,
             s_trstn, s_tdi, s_tdo);
         $display("[JTAG] %t OK", $realtime); //otherwise we wouldn't get here

         $display("[JTAG] %t - TEST halt request during wfi (TODO)", $realtime);


         // allows the jtag booting process to smoothly continue once we leave
         // this test
         $display("[JTAG] %t - Writing the boot address into dpc", $realtime);
         write_reg_abstract_cmd(riscv::CSR_DPC, begin_l2_instr,
             s_tck, s_tms, s_trstn, s_tdi, s_tdo);

     endtask
  endclass

endpackage

// Local Variables:
// verilog-indent-level: 3
// End:
