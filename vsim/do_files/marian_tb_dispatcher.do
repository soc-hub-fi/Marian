onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/clk_i
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/rst_ni
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/scan_enable_i
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/scan_data_i
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/scan_data_o
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/acc_req_i
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/acc_req_valid_i
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/acc_req_ready_o
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/acc_resp_o
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/acc_resp_valid_o
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/acc_resp_ready_i
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/axi_req_o
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/axi_resp_i
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/ara_req
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/ara_req_valid
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/ara_req_ready
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/ara_resp
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/ara_resp_valid
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/ara_idle
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/core_st_pending
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/load_complete
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/store_complete
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/store_pending
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/fflags_ex
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/fflags_ex_valid
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/vxsat_flag
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/alu_vxrm
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/pe_req
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/pe_req_valid
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/pe_req_ready
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/pe_vinsn_running
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/pe_resp
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/addrgen_ack
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/addrgen_error
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/addrgen_error_vl
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/alu_vinsn_done
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/mfpu_vinsn_done
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/global_hazard_table
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/pe_scalar_resp_ready
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/masku_operand
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/masku_operand_valid
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/masku_operand_ready_masku
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/masku_operand_ready_lane
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/mask
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/mask_valid
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/mask_valid_lane
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/lane_mask_ready
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/result_scalar
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/result_scalar_valid
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/stu_operand
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/stu_operand_valid
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/stu_operand_ready
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/sldu_addrgen_operand
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/sldu_addrgen_operand_target_fu
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/sldu_addrgen_operand_valid
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/sldu_operand_ready
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/sldu_mux_sel
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/addrgen_operand_ready
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/sldu_red_valid
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/ldu_result_req
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/ldu_result_id
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/ldu_result_addr
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/ldu_result_wdata
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/ldu_result_be
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/ldu_result_gnt
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/ldu_result_final_gnt
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/sldu_result_req
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/sldu_result_id
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/sldu_result_addr
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/sldu_result_wdata
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/sldu_result_be
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/sldu_result_gnt
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/sldu_result_final_gnt
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/masku_result_req
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/masku_result_id
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/masku_result_addr
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/masku_result_wdata
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/masku_result_be
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/masku_result_gnt
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/masku_result_final_gnt
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/vldu_mask_ready
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/vstu_mask_ready
add wave -noupdate -expand -group ara_top /marian_tb/i_dut/i_marian_top/i_system/i_ara/sldu_mask_ready
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/clk_i
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/rst_ni
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/acc_req_i
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/acc_req_valid_i
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/acc_req_ready_o
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/acc_resp_o
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/acc_resp_valid_o
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/acc_resp_ready_i
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/ara_req_o
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/ara_req_valid_o
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/ara_req_ready_i
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/ara_resp_i
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/ara_resp_valid_i
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/ara_idle_i
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/fflags_ex_i
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/fflags_ex_valid_i
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/vxsat_flag_i
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/alu_vxrm_o
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/core_st_pending_o
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/load_complete_i
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/store_complete_i
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/store_pending_i
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/vstart_d
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/vstart_q
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/vl_d
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/vl_q
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/vtype_d
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/vtype_q
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/vxsat_d
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/vxsat_q
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/vxrm_d
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/vxrm_q
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/ara_req_d
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/ara_req_valid_d
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/state_d
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/state_q
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/eew_d
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/eew_q
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/eew_valid_d
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/eew_valid_q
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/eew_old_buffer_d
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/eew_old_buffer_q
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/eew_new_buffer_d
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/eew_new_buffer_q
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/rs_lmul_cnt_d
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/rs_lmul_cnt_q
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/rs_lmul_cnt_limit_d
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/rs_lmul_cnt_limit_q
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/rs_mask_request_d
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/rs_mask_request_q
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/vs_buffer_d
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/vs_buffer_q
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/reshuffle_req_d
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/reshuffle_req_q
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/lmul_vs2
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/lmul_vs1
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/is_config
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/is_vload
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/is_vstore
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/ignore_zero_vl_check
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/load_zero_vl
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/store_zero_vl
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/skip_lmul_checks
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/skip_vs1_lmul_checks
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/is_decoding
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/in_lane_op
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/null_vslideup
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/load_complete_q
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/store_complete_q
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/is_stride_np2
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/sldu_popc
add wave -noupdate -expand -group ara_dispatcher /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_dispatcher/illegal_insn
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
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
WaveRestoreZoom {0 ps} {207642750 ps}
