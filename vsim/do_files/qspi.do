log -r /*

onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/s_axi_aclk
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/s_axi_aresetn
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/s_axi_awvalid
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/s_axi_awid
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/s_axi_awlen
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/s_axi_awaddr
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/s_axi_awuser
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/s_axi_awready
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/s_axi_wvalid
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/s_axi_wdata
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/s_axi_wstrb
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/s_axi_wlast
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/s_axi_wuser
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/s_axi_wready
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/s_axi_bvalid
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/s_axi_bid
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/s_axi_bresp
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/s_axi_buser
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/s_axi_bready
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/s_axi_arvalid
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/s_axi_arid
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/s_axi_arlen
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/s_axi_araddr
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/s_axi_aruser
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/s_axi_arready
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/s_axi_rvalid
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/s_axi_rid
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/s_axi_rdata
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/s_axi_rresp
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/s_axi_rlast
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/s_axi_ruser
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/s_axi_rready
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/events_o
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_clk
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_csn0
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_csn1
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_csn2
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_csn3
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_mode
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_sdo0
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_sdo1
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_sdo2
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_sdo3
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_sdi0
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_sdi1
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_sdi2
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_sdi3
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_clk_div
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_clk_div_valid
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_status
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_addr
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_addr_len
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_cmd
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_cmd_len
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_data_len
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_dummy_rd
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_dummy_wr
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_swrst
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_rd
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_wr
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_qrd
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_qwr
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_csreg
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_data_tx
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_data_tx_valid
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_data_tx_ready
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_data_rx
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_data_rx_valid
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_data_rx_ready
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_ctrl_status
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_ctrl_data_tx
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_ctrl_data_tx_valid
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_ctrl_data_tx_ready
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_ctrl_data_rx
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_ctrl_data_rx_valid
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/spi_ctrl_data_rx_ready
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/s_eot
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/elements_tx
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/elements_rx
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/elements_tx_old
add wave -noupdate -expand -group axi_spi_master /marian_tb/i_dut/marian_top/i_axi_spi_master/elements_rx_old
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/clk
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/rstn
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/eot
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_clk_div
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_clk_div_valid
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_status
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_addr
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_addr_len
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_cmd
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_cmd_len
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_data_len
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_dummy_rd
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_dummy_wr
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_csreg
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_swrst
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_rd
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_wr
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_qrd
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_qwr
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_ctrl_data_tx
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_ctrl_data_tx_valid
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_ctrl_data_tx_ready
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_ctrl_data_rx
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_ctrl_data_rx_valid
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_ctrl_data_rx_ready
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_clk
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_csn0
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_csn1
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_csn2
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_csn3
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_mode
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_sdo0
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_sdo1
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_sdo2
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_sdo3
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_sdi0
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_sdi1
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_sdi2
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_sdi3
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_rise
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_fall
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_clock_en
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_en_tx
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_en_rx
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/counter_tx
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/counter_tx_valid
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/counter_rx
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/counter_rx_valid
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/data_to_tx
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/data_to_tx_valid
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/data_to_tx_ready
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/en_quad
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/en_quad_int
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/do_tx
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/do_rx
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/tx_done
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/rx_done
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/s_spi_mode
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/ctrl_data_valid
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/spi_cs
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/tx_clk_en
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/rx_clk_en
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/ctrl_data_mux
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/state
add wave -noupdate -expand -group spi_master_controller /marian_tb/i_dut/marian_top/i_axi_spi_master/u_spictrl/state_next
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {95223162 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 179
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
WaveRestoreZoom {0 ps} {107157750 ps}
