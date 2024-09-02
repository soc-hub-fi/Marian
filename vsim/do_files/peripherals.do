################################################################################
# Title       : peripherals.do
# Description : Questa .do file for running vector-crypto-ss testbench.
#               No signals are logged by default
# Author(s)   : Endrit Isufi <endrit.isufi@tuni.fi>
################################################################################

set StdArithNoWarnings 1;
run 0 ns; 
set StdArithNoWarnings 0;

add wave -group PERIPH_TOP sim:/marian_tb/i_dut/marian_top/i_peripherals/*
add wave -group PLIC_WRAPPER sim:/marian_tb/i_dut/marian_top/i_peripherals/i_plic_wrapper/*
add wave -group PLIC_AXI_LITE_TO_REG sim:/marian_tb/i_dut/marian_top/i_peripherals/i_plic_wrapper/i_axi_lite_to_reg_plic/*
add wave -group PLIC_TOP sim:/marian_tb/i_dut/marian_top/i_peripherals/i_plic_wrapper/i_plic_top/*

add wave -position insertpoint  \
sim:/marian_tb/i_dut/marian_top/i_system/i_ariane/csr_regfile_i/mstatus_q
add wave -position insertpoint  \
sim:/marian_tb/i_dut/marian_top/i_system/i_ariane/csr_regfile_i/mtvec_q
add wave -position insertpoint  \
sim:/marian_tb/i_dut/marian_top/i_system/i_ariane/csr_regfile_i/mtvec_d
add wave -position insertpoint  \
sim:/marian_tb/i_dut/marian_top/i_system/i_ariane/csr_regfile_i/mie_q
add wave -position insertpoint  \
sim:/marian_tb/i_dut/marian_top/i_system/i_ariane/csr_regfile_i/mip_q
add wave -position insertpoint  \
sim:/marian_tb/i_dut/marian_top/i_system/i_ariane/csr_regfile_i/mcause_q
add wave -group I_TARGET {sim:/marian_tb/i_dut/marian_top/i_peripherals/i_plic_wrapper/i_plic_top/gen_target[0]/i_target/*}

run -all
