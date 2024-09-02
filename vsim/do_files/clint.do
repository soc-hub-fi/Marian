################################################################################
# Title       : marian_tb.do
# Description : Questa .do file for running vector-crypto-ss testbench.
# Author(s)   : Endrit Isufi <endrit.isufi@tuni.fi> 
################################################################################

set StdArithNoWarnings 1;
run 0 ns; 
set StdArithNoWarnings 0;

add wave -position insertpoint sim:/marian_tb/i_dut/marian_top/i_clint_wrapper/*
add wave -position insertpoint sim:/marian_tb/i_dut/marian_top/i_clint_wrapper/i_clint/*
run -all
