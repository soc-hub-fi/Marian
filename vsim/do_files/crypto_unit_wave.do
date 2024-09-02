log -r /*

add wave -group  TB  sim:/marian_tb/*
add wave -group  DUT sim:/marian_tb/i_dut/*
add wave -group  execution_units sim:/marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_execution_units/*
add wave -group  write_back sim:/marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_write_back/*
add wave -group  operand_collector sim:/marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector/*
add wave -group  operand_collector -group operand_0 {sim:/marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector/gen_main_operand_logic[0]/*}
add wave -group  operand_collector -group operand_1 {sim:/marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector/gen_main_operand_logic[1]/*}
add wave -group  operand_collector -group operand_2 {sim:/marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector/gen_main_operand_logic[2]/*}
add wave -group  encdec sim:/marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_execution_units/i_aes/i_encdec/*
add wave -group  sha sim:/marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_execution_units/i_sha/*
add wave -group  sha_compression  sim:/marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_execution_units/i_sha/i_compression/*
add wave -group  sha_msg_schedule sim:/marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_execution_units/i_sha/i_msg_schedule/*
add wave -group  gcm sim:/marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_execution_units/i_gcm/*
add wave -group  gcm_add_mult sim:/marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_execution_units/i_gcm/i_add_mult_ghash/*
add wave -group  gcm_mult sim:/marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_execution_units/i_gcm/i_mult_ghash/*

# run simulation
run -all

configure wave -namecolwidth 236
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

wave zoom full
configure wave -signalnamewidth 1