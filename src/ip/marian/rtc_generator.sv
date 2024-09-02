module rtc_generator
   (
    // Clock and Reset
    input logic  refclk,
    input logic  refrstn,

    //input ariane_ballast_pkg::clustercfg_t clustercfg_i,
    
    output logic rtc_clk_o
    );

   logic 	 rtc_clk_sr;
   logic [31:0]  rtc_clk_counter_sr;
   logic [31:0]  rtc_clk_add_counter_sr;

   /*========*/
   logic [63:0] rtc_cfg0;
   logic [63:0] rtc_cfg1;
   assign rtc_cfg0 = 64'h0000_0394_0000_0393;
   assign rtc_cfg1 = 64'h05f5_e100_0324_a9a7;

   /*========*/

   assign rtc_clk_o = rtc_clk_sr;
   
   // only synchronize enable signal. Software must make sure controls are only changed when
   // rtc is disabled.
   logic 	 rtc_clk_enable_sync2_sr;

   tico_ctsync i_tico_ctsync_rtc_enable
     (.clk(refclk), .rst_n(refrstn), .data_in(1'h1), .data_out(rtc_clk_enable_sync2_sr));

   always_ff @(posedge refclk or negedge refrstn) begin
      if (~refrstn) begin
	 rtc_clk_sr <= '0;
	 rtc_clk_counter_sr <= '0;
	 rtc_clk_add_counter_sr <= '0;
      end else begin
	 if (~rtc_clk_enable_sync2_sr) begin
	    rtc_clk_sr <= '0;
	    rtc_clk_counter_sr <= '0;
	    rtc_clk_add_counter_sr <= '0;
	 end else begin
	    if (rtc_clk_sr) begin
	       if (rtc_clk_counter_sr >= rtc_cfg0[63:32]) begin
		  rtc_clk_counter_sr <= '0;
		  rtc_clk_sr <= '0;
	       end else begin
		  rtc_clk_counter_sr <= rtc_clk_counter_sr + 1;
	       end
	    end else begin
	       // Extend rtc_clk "low" with one clock cycle rtc_cfg1[31:0]-cycles in rtc_cfg1[63:32]-cycles
	       // This way we can get an "arbitrarily" accurate real time clock (accuracy is 1/2^32-1).
	       // Of course the rtc has long term jitter which we cannot avoid
	       if (rtc_clk_add_counter_sr < rtc_cfg1[31:0] &&
		   rtc_cfg1[31:0] != 32'h0) begin
		  if (rtc_clk_counter_sr >= (rtc_cfg0[31:0] + 1)) begin
		     rtc_clk_counter_sr <= '0;
		     rtc_clk_sr <= '1;
		     rtc_clk_add_counter_sr <= rtc_clk_add_counter_sr + 1;
		  end else begin
		     rtc_clk_counter_sr <= rtc_clk_counter_sr + 1;
		  end
	       end else begin
		  if (rtc_clk_counter_sr >= rtc_cfg0[31:0]) begin
		     rtc_clk_counter_sr <= '0;
		     rtc_clk_sr <= '1;
		     if (rtc_clk_add_counter_sr >= rtc_cfg1[63:32]) begin
			rtc_clk_add_counter_sr <= '0;
		     end else begin
			rtc_clk_add_counter_sr <= rtc_clk_add_counter_sr + 1;
		     end
		  end else begin
		     rtc_clk_counter_sr <= rtc_clk_counter_sr + 1;
		  end
	       end
	       
	    end // else: !if(rtc_clk_sr)
	 end // else: !if(~rtc_cfg2[0])
      end // else: !if(~refrstn)
   end // always_ff @

endmodule // rtc_generator
