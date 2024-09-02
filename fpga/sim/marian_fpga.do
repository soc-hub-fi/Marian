onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -group TB /marian_fpga_top_tb/*
add wave -noupdate -group marian_fpga_top /marian_fpga_top_tb/i_dut/*
add wave -noupdate -group marian_fpga_top -group top_clock /marian_fpga_top_tb/i_dut/i_top_clock/*
add wave -noupdate -group marian_fpga_top -group xbar /marian_fpga_top_tb/i_dut/i_axi_xbar/*
add wave -noupdate -group marian_fpga_top -group debug_system_fpga /marian_fpga_top_tb/i_dut/i_debug_system/*
add wave -noupdate -group marian_fpga_top -group debug_system_fpga -group debug_system /marian_fpga_top_tb/i_dut/i_debug_system/i_debug_system/*
add wave -noupdate -group marian_fpga_top -group debug_system_fpga -group debug_system -group axi_debug_if /marian_fpga_top_tb/i_dut/i_debug_system/i_debug_system/axi_dbg_if/*
add wave -noupdate -group marian_fpga_top -group debug_system_fpga -group debug_system -group dmi_jtag /marian_fpga_top_tb/i_dut/i_debug_system/i_debug_system/i_dmi_jtag/*
add wave -noupdate -group marian_fpga_top -group debug_system_fpga -group debug_system -expand -group dm_top /marian_fpga_top_tb/i_dut/i_debug_system/i_debug_system/*
add wave -noupdate -group marian_fpga_top -group peripheral_system /marian_fpga_top_tb/i_dut/i_peripheral_system/*
add wave -noupdate -group marian_fpga_top -group peripheral_system -group axi_uart /marian_fpga_top_tb/i_dut/i_peripheral_system/i_axi_uart/*
add wave -noupdate -group marian_fpga_top -group memory_system /marian_fpga_top_tb/i_dut/i_memory_system/*
add wave -noupdate -group marian_fpga_top -group memory_system -group axi_bram_wrapper  sim:/marian_fpga_top_tb/i_dut/i_memory_system/i_axi_bram_wrapper/*
add wave -noupdate -group ariane /marian_fpga_top_tb/i_dut/i_marian_system/i_ariane/*
add wave -noupdate -group ariane -group cache_subsystem sim:/marian_fpga_top_tb/i_dut/i_marian_system/i_ariane/i_cache_subsystem/*
add wave -noupdate -group ariane -group cache_subsystem -group cva6_icache sim:/marian_fpga_top_tb/i_dut/i_marian_system/i_ariane/i_cache_subsystem/i_cva6_icache/*
add wave -noupdate -group ara /marian_fpga_top_tb/i_dut/i_marian_system/i_ara/*

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 196
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update

run 100 us

wave zoom full