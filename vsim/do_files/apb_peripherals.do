################################################################################
# Title       : peripherals.do
# Description : Questa .do file for running vector-crypto-ss testbench.
#               No signals are logged by default
# Author(s)   : Endrit Isufi <endrit.isufi@tuni.fi>
################################################################################

set StdArithNoWarnings 1;
run 0 ns; 
set StdArithNoWarnings 0;

add wave -group  spi sim:/marian_tb/i_dut/marian_top/i_apb_peripherals/i_apb_spi_master/*
add wave -group  axiregs sim:/marian_tb/i_dut/marian_top/i_apb_peripherals/i_apb_spi_master/u_axiregs/*
add wave -group  txfifo sim:/marian_tb/i_dut/marian_top/i_apb_peripherals/i_apb_spi_master/u_txfifo/*
add wave -group  spictrl  sim:/marian_tb/i_dut/marian_top/i_apb_peripherals/i_apb_spi_master/u_spictrl/*
add wave -group txreg sim:/marian_tb/i_dut/marian_top/i_apb_peripherals/i_apb_spi_master/u_spictrl/u_txreg/*
add wave -group spi_slave sim:/marian_tb/i_axi_spi_slave/*
add wave -group slave_state_machine sim:/marian_tb/i_axi_spi_slave/u_slave_sm/*
run -all
