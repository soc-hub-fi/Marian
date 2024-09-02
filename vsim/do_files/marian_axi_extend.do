################################################################################
# Title       : marian_axi_extend.do
# Description : Questa .do file for running vector-crypto-ss testbench.
#               
# Author(s)   : Endrit Isufi <endrit.isufi@tuni.fi> 
################################################################################

set StdArithNoWarnings 1;
run 0 ns; 
set StdArithNoWarnings 0;

add wave -position insertpoint  \
sim:/marian_tb/axi_dv_m_resp_i \
sim:/marian_tb/axi_dv_m_req_o \
sim:/marian_tb/axi_dv_s_resp_o \
sim:/marian_tb/axi_dv_s_req_i


add wave -position insertpoint  \
sim:/marian_tb/i_dut/marian_top/ext_axi_s_req_o \
sim:/marian_tb/i_dut/marian_top/ext_axi_s_resp_i \
sim:/marian_tb/i_dut/marian_top/ext_axi_m_req_i \
sim:/marian_tb/i_dut/marian_top/ext_axi_m_resp_o

add wave -position insertpoint  \
sim:/marian_tb/i_dut/marian_top/system_axi_req \
sim:/marian_tb/i_dut/marian_top/system_axi_resp

add wave -position insertpoint  \
sim:/marian_tb/i_dut/marian_top/ext_axi_s_req_split \
sim:/marian_tb/i_dut/marian_top/ext_axi_s_resp_split
run -all