log sim:/marian_fpga_top_tb/*
log sim:/marian_fpga_top_tb/i_dut/i_debug_system/*
log sim:/marian_fpga_top_tb/i_dut/i_debug_system/i_debug_system/*
log sim:/marian_fpga_top_tb/i_dut/i_debug_system/i_debug_system/i_dm_top/*
log sim:/marian_fpga_top_tb/i_dut/i_debug_system/i_debug_system/i_dmi_jtag/*
log sim:/marian_fpga_top_tb/i_dut/i_debug_system/i_debug_system/i_dmi_jtag/i_dmi_jtag_tap/*

config wave -signalnamewidth 1

# prevent reporting of spurious errors
tcheck_set {/marian_fpga_top_tb/i_dut/i_top_clock/inst/plle4_adv_inst} OFF

run 2000ms