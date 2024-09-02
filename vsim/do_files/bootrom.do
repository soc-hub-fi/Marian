################################################################################
# Title       : bootrom.do
# Description : Questa .do file for running vector-crypto-ss testbench.
#             
# Author(s)   : Endrit Isufi <endrit.isufi@tuni.fi>
################################################################################

set StdArithNoWarnings 1;
run 0 ns; 
set StdArithNoWarnings 0;


add wave -position insertpoint  \
sim:/marian_tb/i_dut/marian_top/system_axi_req \
sim:/marian_tb/i_dut/marian_top/system_axi_resp
add wave -position insertpoint  \
sim:/marian_tb/i_dut/marian_top/periph_wide_axi_req \
sim:/marian_tb/i_dut/marian_top/periph_wide_axi_resp
add wave -position insertpoint sim:/marian_tb/i_dut/marian_top/i_boot_rom/*
add wave -position insertpoint sim:/marian_tb/i_dut/marian_top/i_boot_rom/i_axi_to_mem_rom/*
add wave -position insertpoint sim:/marian_tb/i_dut/marian_top/i_boot_rom/i_bootrom_if/*


run -all
