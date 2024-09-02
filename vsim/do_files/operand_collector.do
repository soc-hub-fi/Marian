onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/clk_i
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/rst_ni
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/pe_req_i
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/pe_req_valid_i
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/pe_vinsn_running_i
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/pe_req_ready_o
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/pe_resp_o
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/crypto_operand_i
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/crypto_operand_valid_i
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/crypto_operand_ready_o
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/crypto_result_req_o
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/crypto_result_id_o
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/crypto_result_addr_o
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/crypto_result_wdata_o
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/crypto_result_be_o
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/crypto_result_gnt_i
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/crypto_result_final_gnt_i
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/crypto_operand
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/crypto_operand_valid
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/crypto_operand_ready
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/pe_fifo_full_s
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/pe_fifo_empty_s
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/pe_fifo_push_s
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/pe_crypto_req_valid_s
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/pe_crypto_req_ack_s
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/pe_id_d
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/pe_id_q
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/pe_req_valid_q
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/pe_req_valid_rise_s
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/pe_crypto_req_in_s
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/pe_crypto_req_coll_s
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/pe_crypto_req_exec_s
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/pe_crypto_req_wb_q
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/crypto_args_valid_s
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/crypto_args_ready_s
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/wb_valid_s
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/wb_ready_s
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/crypto_args_buff_s
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/crypto_result_s
add wave -noupdate -group crypto_unit /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/wb_done_s
add wave -noupdate -group operand_collector /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector/clk_i
add wave -noupdate -group operand_collector /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector/rst_ni
add wave -noupdate -group operand_collector /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector/pe_crypto_req_i
add wave -noupdate -group operand_collector /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector/pe_req_valid_i
add wave -noupdate -group operand_collector /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector/pe_req_ack_o
add wave -noupdate -group operand_collector /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector/pe_crypto_req_o
add wave -noupdate -group operand_collector /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector/crypto_operand_i
add wave -noupdate -group operand_collector /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector/crypto_operand_valid_i
add wave -noupdate -group operand_collector /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector/crypto_operand_ready_o
add wave -noupdate -group operand_collector /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector/crypto_args_buff_o
add wave -noupdate -group operand_collector /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector/crypto_args_valid_o
add wave -noupdate -group operand_collector /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector/crypto_args_ready_i
add wave -noupdate -group operand_collector /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector/pe_req_ack_s
add wave -noupdate -group operand_collector /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector/pe_operand_done_s
add wave -noupdate -group operand_collector /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector/pe_crypto_req_d
add wave -noupdate -group operand_collector /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector/pe_crypto_req_q
add wave -noupdate -group operand_collector /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector/operand_ready_s
add wave -noupdate -group operand_collector /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector/operand_bytes_s
add wave -noupdate -group operand_collector /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector/operand_valid_s
add wave -noupdate -group operand_collector /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector/operand_active_s
add wave -noupdate -group operand_collector /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector/crypto_operand_s
add wave -noupdate -group operand_collector /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector/crypto_operand_valid_s
add wave -noupdate -group operand_collector /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector/crypto_arg_d
add wave -noupdate -group operand_collector /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector/crypto_arg_q
add wave -noupdate -group operand_collector /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector/crypto_arg_bytes_s
add wave -noupdate -group operand_collector /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector/crypto_arg_vld_d
add wave -noupdate -group operand_collector /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector/crypto_arg_vld_q
add wave -noupdate -group operand_collector /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector/crypto_args_valid_s
add wave -noupdate -group operand_collector /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector/crypto_scalar_arg_d
add wave -noupdate -group operand_collector /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector/crypto_scalar_arg_q
add wave -noupdate -group operand_collector_new /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector_new/clk_i
add wave -noupdate -group operand_collector_new /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector_new/rst_ni
add wave -noupdate -group operand_collector_new /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector_new/pe_crypto_req_i
add wave -noupdate -group operand_collector_new /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector_new/pe_req_valid_i
add wave -noupdate -group operand_collector_new /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector_new/pe_req_ack_o
add wave -noupdate -group operand_collector_new /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector_new/pe_crypto_req_o
add wave -noupdate -group operand_collector_new /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector_new/crypto_operand_i
add wave -noupdate -group operand_collector_new /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector_new/crypto_operand_valid_i
add wave -noupdate -group operand_collector_new /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector_new/crypto_operand_ready_o
add wave -noupdate -group operand_collector_new /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector_new/crypto_args_buff_o
add wave -noupdate -group operand_collector_new /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector_new/crypto_args_valid_o
add wave -noupdate -group operand_collector_new /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector_new/crypto_args_ready_i
add wave -noupdate -group operand_collector_new /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector_new/operand_active_s
add wave -noupdate -group operand_collector_new /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector_new/arg_full_s
add wave -noupdate -group operand_collector_new /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector_new/arg_valid_s
add wave -noupdate -group operand_collector_new /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector_new/operand_logic_en_s
add wave -noupdate -group operand_collector_new /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector_new/arg_buff_valid_d
add wave -noupdate -group operand_collector_new /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector_new/arg_buff_valid_q
add wave -noupdate -group operand_collector_new /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector_new/arg_buff_d
add wave -noupdate -group operand_collector_new /marian_tb/i_dut/marian_top/i_system/i_ara/i_crypto_unit/i_operand_collector_new/arg_buff_q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 322
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
WaveRestoreZoom {765001925 ps} {975810425 ps}

run -all
