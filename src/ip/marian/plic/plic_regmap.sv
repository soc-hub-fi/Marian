// Do not edit - auto-generated
module plic_regs #(
  parameter type reg_req_t  = logic,
  parameter type reg_rsp_t  = logic
)(
  input logic [7:0][2:0] prio_i,
  output logic [7:0][2:0] prio_o,
  output logic [7:0] prio_we_o,
  output logic [7:0] prio_re_o,
  input logic [0:0][7:0] ip_i,
  output logic [0:0] ip_re_o,
  input logic [1:0][7:0] ie_i,
  output logic [1:0][7:0] ie_o,
  output logic [1:0] ie_we_o,
  output logic [1:0] ie_re_o,
  input logic [1:0][2:0] threshold_i,
  output logic [1:0][2:0] threshold_o,
  output logic [1:0] threshold_we_o,
  output logic [1:0] threshold_re_o,
  input logic [1:0][2:0] cc_i,
  output logic [1:0][2:0] cc_o,
  output logic [1:0] cc_we_o,
  output logic [1:0] cc_re_o,
  // Bus Interface
  input  reg_req_t req_i,
  output reg_rsp_t resp_o
);
always_comb begin
  resp_o.ready = 1'b1;
  resp_o.rdata = '0;
  resp_o.error = '0;
  prio_o = '0;
  prio_we_o = '0;
  prio_re_o = '0;
  ie_o = '0;
  ie_we_o = '0;
  ie_re_o = '0;
  threshold_o = '0;
  threshold_we_o = '0;
  threshold_re_o = '0;
  cc_o = '0;
  cc_we_o = '0;
  cc_re_o = '0;
  ip_re_o = '0;
  if (req_i.valid) begin
    if (req_i.write) begin
      unique case(req_i.addr)
        32'hcc000000: begin
          prio_o[0][2:0] = req_i.wdata[2:0];
          prio_we_o[0] = 1'b1;
        end
        32'hcc000004: begin
          prio_o[1][2:0] = req_i.wdata[2:0];
          prio_we_o[1] = 1'b1;
        end
        32'hcc000008: begin
          prio_o[2][2:0] = req_i.wdata[2:0];
          prio_we_o[2] = 1'b1;
        end
        32'hcc00000c: begin
          prio_o[3][2:0] = req_i.wdata[2:0];
          prio_we_o[3] = 1'b1;
        end
        32'hcc000010: begin
          prio_o[4][2:0] = req_i.wdata[2:0];
          prio_we_o[4] = 1'b1;
        end
        32'hcc000014: begin
          prio_o[5][2:0] = req_i.wdata[2:0];
          prio_we_o[5] = 1'b1;
        end
        32'hcc000018: begin
          prio_o[6][2:0] = req_i.wdata[2:0];
          prio_we_o[6] = 1'b1;
        end
        32'hcc00001c: begin
          prio_o[7][2:0] = req_i.wdata[2:0];
          prio_we_o[7] = 1'b1;
        end
        32'hcc002000: begin
          ie_o[0][7:0] = req_i.wdata[7:0];
          ie_we_o[0] = 1'b1;
        end
        32'hcc002080: begin
          ie_o[1][7:0] = req_i.wdata[7:0];
          ie_we_o[1] = 1'b1;
        end
        32'hcc200000: begin
          threshold_o[0][2:0] = req_i.wdata[2:0];
          threshold_we_o[0] = 1'b1;
        end
        32'hcc201000: begin
          threshold_o[1][2:0] = req_i.wdata[2:0];
          threshold_we_o[1] = 1'b1;
        end
        32'hcc200004: begin
          cc_o[0][2:0] = req_i.wdata[2:0];
          cc_we_o[0] = 1'b1;
        end
        32'hcc201004: begin
          cc_o[1][2:0] = req_i.wdata[2:0];
          cc_we_o[1] = 1'b1;
        end
        default: resp_o.error = 1'b1;
      endcase
    end else begin
      unique case(req_i.addr)
        32'hcc000000: begin
          resp_o.rdata[2:0] = prio_i[0][2:0];
          prio_re_o[0] = 1'b1;
        end
        32'hcc000004: begin
          resp_o.rdata[2:0] = prio_i[1][2:0];
          prio_re_o[1] = 1'b1;
        end
        32'hcc000008: begin
          resp_o.rdata[2:0] = prio_i[2][2:0];
          prio_re_o[2] = 1'b1;
        end
        32'hcc00000c: begin
          resp_o.rdata[2:0] = prio_i[3][2:0];
          prio_re_o[3] = 1'b1;
        end
        32'hcc000010: begin
          resp_o.rdata[2:0] = prio_i[4][2:0];
          prio_re_o[4] = 1'b1;
        end
        32'hcc000014: begin
          resp_o.rdata[2:0] = prio_i[5][2:0];
          prio_re_o[5] = 1'b1;
        end
        32'hcc000018: begin
          resp_o.rdata[2:0] = prio_i[6][2:0];
          prio_re_o[6] = 1'b1;
        end
        32'hcc00001c: begin
          resp_o.rdata[2:0] = prio_i[7][2:0];
          prio_re_o[7] = 1'b1;
        end
        32'hcc001000: begin
          resp_o.rdata[7:0] = ip_i[0][7:0];
          ip_re_o[0] = 1'b1;
        end
        32'hcc002000: begin
          resp_o.rdata[7:0] = ie_i[0][7:0];
          ie_re_o[0] = 1'b1;
        end
        32'hcc002080: begin
          resp_o.rdata[7:0] = ie_i[1][7:0];
          ie_re_o[1] = 1'b1;
        end
        32'hcc200000: begin
          resp_o.rdata[2:0] = threshold_i[0][2:0];
          threshold_re_o[0] = 1'b1;
        end
        32'hcc201000: begin
          resp_o.rdata[2:0] = threshold_i[1][2:0];
          threshold_re_o[1] = 1'b1;
        end
        32'hcc200004: begin
          resp_o.rdata[2:0] = cc_i[0][2:0];
          cc_re_o[0] = 1'b1;
        end
        32'hcc201004: begin
          resp_o.rdata[2:0] = cc_i[1][2:0];
          cc_re_o[1] = 1'b1;
        end
        default: resp_o.error = 1'b1;
      endcase
    end
  end
end
endmodule

