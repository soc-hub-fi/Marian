onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider sequencer
add wave -noupdate -childformat {{/marian_tb/i_dut/i_marian_top/i_system/i_ara/i_sequencer/pe_req_o.vl -radix unsigned}} -subitemconfig {/marian_tb/i_dut/i_marian_top/i_system/i_ara/i_sequencer/pe_req_o.vl {-height 17 -radix unsigned}} /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_sequencer/pe_req_o
add wave -noupdate /marian_tb/i_dut/i_marian_top/i_system/i_ara/i_sequencer/pe_req_valid_o
add wave -noupdate -divider lane_sequencer
add wave -noupdate -group {lane_sequencer[0]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/clk_i}
add wave -noupdate -group {lane_sequencer[0]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/rst_ni}
add wave -noupdate -group {lane_sequencer[0]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/lane_id_i}
add wave -noupdate -group {lane_sequencer[0]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/pe_req_i}
add wave -noupdate -group {lane_sequencer[0]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/pe_req_valid_i}
add wave -noupdate -group {lane_sequencer[0]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/pe_vinsn_running_i}
add wave -noupdate -group {lane_sequencer[0]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/pe_req_ready_o}
add wave -noupdate -group {lane_sequencer[0]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/pe_resp_o}
add wave -noupdate -group {lane_sequencer[0]} -color Magenta -subitemconfig {{/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_o[11]} {-color Magenta -height 17} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_o[10]} {-color Magenta -height 17} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_o[9]} {-color Magenta -height 17} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_o[8]} {-color Magenta -height 17} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_o[7]} {-color Magenta -height 17} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_o[6]} {-color Magenta -height 17} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_o[5]} {-color Magenta -height 17} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_o[4]} {-color Magenta -height 17} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_o[3]} {-color Magenta -height 17} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_o[2]} {-color Magenta -height 17} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_o[1]} {-color Magenta -height 17} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_o[1].id} {-color Magenta} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_o[1].vs} {-color Magenta} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_o[1].scale_vl} {-color Magenta} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_o[1].cvt_resize} {-color Magenta} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_o[1].is_reduct} {-color Magenta} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_o[1].eew} {-color Magenta} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_o[1].conv} {-color Magenta} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_o[1].target_fu} {-color Magenta} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_o[1].vtype} {-color Magenta} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_o[1].vl} {-color Magenta} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_o[1].vstart} {-color Magenta} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_o[1].hazard} {-color Magenta} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_o[0]} {-color Magenta -height 17} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_o[0].id} {-color Magenta} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_o[0].vs} {-color Magenta} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_o[0].scale_vl} {-color Magenta} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_o[0].cvt_resize} {-color Magenta} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_o[0].is_reduct} {-color Magenta} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_o[0].eew} {-color Magenta} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_o[0].conv} {-color Magenta} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_o[0].target_fu} {-color Magenta} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_o[0].vtype} {-color Magenta} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_o[0].vl} {-color Magenta} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_o[0].vstart} {-color Magenta} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_o[0].hazard} {-color Magenta}} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_o}
add wave -noupdate -group {lane_sequencer[0]} -color Magenta {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_valid_o}
add wave -noupdate -group {lane_sequencer[0]} -color Magenta {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_ready_i}
add wave -noupdate -group {lane_sequencer[0]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/operand_request_i}
add wave -noupdate -group {lane_sequencer[0]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_lane_sequencer/vfu_operation_d}
add wave -noupdate -group {lane_sequencer[1]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[1]/i_lane/i_lane_sequencer/clk_i}
add wave -noupdate -group {lane_sequencer[1]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[1]/i_lane/i_lane_sequencer/rst_ni}
add wave -noupdate -group {lane_sequencer[1]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[1]/i_lane/i_lane_sequencer/lane_id_i}
add wave -noupdate -group {lane_sequencer[1]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[1]/i_lane/i_lane_sequencer/pe_req_i}
add wave -noupdate -group {lane_sequencer[1]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[1]/i_lane/i_lane_sequencer/pe_req_valid_i}
add wave -noupdate -group {lane_sequencer[1]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[1]/i_lane/i_lane_sequencer/pe_vinsn_running_i}
add wave -noupdate -group {lane_sequencer[1]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[1]/i_lane/i_lane_sequencer/pe_req_ready_o}
add wave -noupdate -group {lane_sequencer[1]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[1]/i_lane/i_lane_sequencer/pe_resp_o}
add wave -noupdate -group {lane_sequencer[1]} -color Magenta {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[1]/i_lane/i_lane_sequencer/operand_request_o}
add wave -noupdate -group {lane_sequencer[1]} -color Magenta {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[1]/i_lane/i_lane_sequencer/operand_request_valid_o}
add wave -noupdate -group {lane_sequencer[1]} -color Magenta {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[1]/i_lane/i_lane_sequencer/operand_request_ready_i}
add wave -noupdate -group {lane_sequencer[1]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[1]/i_lane/i_lane_sequencer/operand_request_i}
add wave -noupdate -group {lane_sequencer[1]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[1]/i_lane/i_lane_sequencer/vfu_operation_d}
add wave -noupdate -group {lane_sequencer[2]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[2]/i_lane/i_lane_sequencer/clk_i}
add wave -noupdate -group {lane_sequencer[2]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[2]/i_lane/i_lane_sequencer/rst_ni}
add wave -noupdate -group {lane_sequencer[2]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[2]/i_lane/i_lane_sequencer/lane_id_i}
add wave -noupdate -group {lane_sequencer[2]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[2]/i_lane/i_lane_sequencer/pe_req_i}
add wave -noupdate -group {lane_sequencer[2]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[2]/i_lane/i_lane_sequencer/pe_req_valid_i}
add wave -noupdate -group {lane_sequencer[2]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[2]/i_lane/i_lane_sequencer/pe_vinsn_running_i}
add wave -noupdate -group {lane_sequencer[2]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[2]/i_lane/i_lane_sequencer/pe_req_ready_o}
add wave -noupdate -group {lane_sequencer[2]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[2]/i_lane/i_lane_sequencer/pe_resp_o}
add wave -noupdate -group {lane_sequencer[2]} -color Magenta {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[2]/i_lane/i_lane_sequencer/operand_request_o}
add wave -noupdate -group {lane_sequencer[2]} -color Magenta {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[2]/i_lane/i_lane_sequencer/operand_request_valid_o}
add wave -noupdate -group {lane_sequencer[2]} -color Magenta {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[2]/i_lane/i_lane_sequencer/operand_request_ready_i}
add wave -noupdate -group {lane_sequencer[2]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[2]/i_lane/i_lane_sequencer/operand_request_i}
add wave -noupdate -group {lane_sequencer[2]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[2]/i_lane/i_lane_sequencer/vfu_operation_d}
add wave -noupdate -group {lane_sequencer[3]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[3]/i_lane/i_lane_sequencer/clk_i}
add wave -noupdate -group {lane_sequencer[3]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[3]/i_lane/i_lane_sequencer/rst_ni}
add wave -noupdate -group {lane_sequencer[3]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[3]/i_lane/i_lane_sequencer/lane_id_i}
add wave -noupdate -group {lane_sequencer[3]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[3]/i_lane/i_lane_sequencer/pe_req_i}
add wave -noupdate -group {lane_sequencer[3]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[3]/i_lane/i_lane_sequencer/pe_req_valid_i}
add wave -noupdate -group {lane_sequencer[3]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[3]/i_lane/i_lane_sequencer/pe_vinsn_running_i}
add wave -noupdate -group {lane_sequencer[3]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[3]/i_lane/i_lane_sequencer/pe_req_ready_o}
add wave -noupdate -group {lane_sequencer[3]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[3]/i_lane/i_lane_sequencer/pe_resp_o}
add wave -noupdate -group {lane_sequencer[3]} -color Magenta {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[3]/i_lane/i_lane_sequencer/operand_request_o}
add wave -noupdate -group {lane_sequencer[3]} -color Magenta {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[3]/i_lane/i_lane_sequencer/operand_request_valid_o}
add wave -noupdate -group {lane_sequencer[3]} -color Magenta {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[3]/i_lane/i_lane_sequencer/operand_request_ready_i}
add wave -noupdate -group {lane_sequencer[3]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[3]/i_lane/i_lane_sequencer/operand_request_i}
add wave -noupdate -group {lane_sequencer[3]} -expand {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[3]/i_lane/i_lane_sequencer/vfu_operation_d}
add wave -noupdate -divider operand_requester
add wave -noupdate -divider {lane[0]}
add wave -noupdate {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_operand_requester/operand_request_i}
add wave -noupdate -group {lane[0]requester[0]} -expand {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_operand_requester/gen_operand_requester[0]/requester_q}
add wave -noupdate -group {lane[0]requester[0]} -expand {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_operand_requester/gen_operand_requester[0]/requester_d}
add wave -noupdate -group {lane[0]requester[0]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_operand_requester/gen_operand_requester[0]/state_q}
add wave -noupdate -group {lane[0]requester[0]} -expand {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_operand_requester/gen_operand_requester[0]/operand_requester_gnt}
add wave -noupdate -group {lane[0]requester[0]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_operand_requester/gen_operand_requester[0]/stall}
add wave -noupdate -group {lane[0]requester[1]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_operand_requester/gen_operand_requester[1]/requester_d}
add wave -noupdate -group {lane[0]requester[1]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_operand_requester/gen_operand_requester[1]/state_q}
add wave -noupdate -group {lane[0]requester[1]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_operand_requester/gen_operand_requester[1]/requester_q}
add wave -noupdate -group {lane[0]requester[1]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_operand_requester/gen_operand_requester[1]/operand_requester_gnt}
add wave -noupdate -group {lane[0]requester[1]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_operand_requester/gen_operand_requester[1]/stall}
add wave -noupdate {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_operand_requester/operand_queue_ready_i}
add wave -noupdate {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_operand_requester/operand_gnt}
add wave -noupdate {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_operand_requester/operand_queue_cmd_o}
add wave -noupdate {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_operand_requester/operand_req}
add wave -noupdate {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_operand_requester/operand_payload}
add wave -noupdate -divider {lane[1]}
add wave -noupdate {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[1]/i_lane/i_operand_requester/operand_request_i}
add wave -noupdate -group {lane[1]requester[0]} -expand {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[1]/i_lane/i_operand_requester/gen_operand_requester[0]/requester_d}
add wave -noupdate -group {lane[1]requester[0]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[1]/i_lane/i_operand_requester/gen_operand_requester[0]/state_q}
add wave -noupdate -group {lane[1]requester[0]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[1]/i_lane/i_operand_requester/gen_operand_requester[0]/requester_q}
add wave -noupdate -group {lane[1]requester[1]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[1]/i_lane/i_operand_requester/gen_operand_requester[1]/requester_d}
add wave -noupdate -group {lane[1]requester[1]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[1]/i_lane/i_operand_requester/gen_operand_requester[1]/state_q}
add wave -noupdate -group {lane[1]requester[1]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[1]/i_lane/i_operand_requester/gen_operand_requester[1]/requester_q}
add wave -noupdate {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[1]/i_lane/i_operand_requester/operand_payload}
add wave -noupdate {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[1]/i_lane/i_operand_requester/operand_req}
add wave -noupdate {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[1]/i_lane/i_operand_requester/operand_queue_cmd_o}
add wave -noupdate -divider {lane[2]}
add wave -noupdate {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[2]/i_lane/i_operand_requester/operand_request_i}
add wave -noupdate -group {lane[2]requester[0]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[2]/i_lane/i_operand_requester/gen_operand_requester[0]/requester_d}
add wave -noupdate -group {lane[2]requester[0]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[2]/i_lane/i_operand_requester/gen_operand_requester[0]/state_q}
add wave -noupdate -group {lane[2]requester[0]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[2]/i_lane/i_operand_requester/gen_operand_requester[0]/requester_q}
add wave -noupdate -group {lane[2]requester[1]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[2]/i_lane/i_operand_requester/gen_operand_requester[1]/requester_d}
add wave -noupdate -group {lane[2]requester[1]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[2]/i_lane/i_operand_requester/gen_operand_requester[1]/state_q}
add wave -noupdate -group {lane[2]requester[1]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[2]/i_lane/i_operand_requester/gen_operand_requester[1]/requester_q}
add wave -noupdate {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[2]/i_lane/i_operand_requester/operand_queue_cmd_o}
add wave -noupdate {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[2]/i_lane/i_operand_requester/operand_req}
add wave -noupdate -subitemconfig {{/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[2]/i_lane/i_operand_requester/operand_payload[12]} -expand {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[2]/i_lane/i_operand_requester/operand_payload[1]} -expand} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[2]/i_lane/i_operand_requester/operand_payload}
add wave -noupdate -divider {lane[3]}
add wave -noupdate {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[3]/i_lane/i_operand_requester/operand_request_i}
add wave -noupdate -group {lane[3]requester[0]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[3]/i_lane/i_operand_requester/gen_operand_requester[0]/requester_d}
add wave -noupdate -group {lane[3]requester[0]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[3]/i_lane/i_operand_requester/gen_operand_requester[0]/state_q}
add wave -noupdate -group {lane[3]requester[0]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[3]/i_lane/i_operand_requester/gen_operand_requester[0]/requester_q}
add wave -noupdate -group {lane[3]requester[1]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[3]/i_lane/i_operand_requester/gen_operand_requester[1]/requester_d}
add wave -noupdate -group {lane[3]requester[1]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[3]/i_lane/i_operand_requester/gen_operand_requester[1]/state_q}
add wave -noupdate -group {lane[3]requester[1]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[3]/i_lane/i_operand_requester/gen_operand_requester[1]/requester_q}
add wave -noupdate {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[3]/i_lane/i_operand_requester/operand_queue_cmd_o}
add wave -noupdate {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[3]/i_lane/i_operand_requester/operand_req}
add wave -noupdate {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[3]/i_lane/i_operand_requester/operand_payload}
add wave -noupdate -divider VRF
add wave -noupdate -group {VRF[0]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_vrf/clk_i}
add wave -noupdate -group {VRF[0]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_vrf/rst_ni}
add wave -noupdate -group {VRF[0]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_vrf/req_i}
add wave -noupdate -group {VRF[0]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_vrf/addr_i}
add wave -noupdate -group {VRF[0]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_vrf/tgt_opqueue_i}
add wave -noupdate -group {VRF[0]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_vrf/wen_i}
add wave -noupdate -group {VRF[0]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_vrf/wdata_i}
add wave -noupdate -group {VRF[0]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_vrf/be_i}
add wave -noupdate -group {VRF[0]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_vrf/operand_o}
add wave -noupdate -group {VRF[0]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_vrf/operand_valid_o}
add wave -noupdate -group {VRF[0]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_vrf/rdata}
add wave -noupdate -group {VRF[0]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_vrf/rdata_valid_q}
add wave -noupdate -group {VRF[0]} {/marian_tb/i_dut/i_marian_top/i_system/i_ara/gen_lanes[0]/i_lane/i_vrf/tgt_opqueue_q}
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 169
configure wave -valuecolwidth 207
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
WaveRestoreZoom {0 ps} {98726250 ps}
