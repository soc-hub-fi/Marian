################################################################################
# Title       : marian_tb_qspi.do
# Description : Questa .do file for running vector-crypto-ss testbench.
#               
# Author(s)   : Endrit Isufi <endrit.isufi@tuni.fi>
################################################################################

set StdArithNoWarnings 1;
run 0 ns; 
set StdArithNoWarnings 0;

add wave -position insertpoint  \
sim:/marian_tb/i_dut/marian_top/system_axi_req \
sim:/marian_tb/i_dut/marian_top/system_axi_resp
add wave -position insertpoint  \
sim:/marian_tb/i_dut/marian_top/spi_axi_req \
sim:/marian_tb/i_dut/marian_top/spi_axi_resp
add wave -position insertpoint  \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/events_o \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_clk \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_csn0 \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_csn1 \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_csn2 \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_csn3 \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_mode \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_sdo0 \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_sdo1 \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_sdo2 \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_sdo3 \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_sdi0 \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_sdi1 \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_sdi2 \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_sdi3 \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_clk_div \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_clk_div_valid \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_status \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_addr \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_addr_len \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_cmd \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_cmd_len \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_data_len \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_dummy_rd \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_dummy_wr \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_swrst \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_rd \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_wr \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_qrd \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_qwr \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_csreg \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_data_tx \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_data_tx_valid \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_data_tx_ready \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_data_rx \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_data_rx_valid \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_data_rx_ready \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_ctrl_status \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_ctrl_data_tx \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_ctrl_data_tx_valid \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_ctrl_data_tx_ready \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_ctrl_data_rx \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_ctrl_data_rx_valid \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/spi_ctrl_data_rx_ready \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/s_eot \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/elements_tx \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/elements_rx \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/elements_tx_old \
sim:/marian_tb/i_dut/marian_top/i_axi_spi_master/elements_rx_old
add wave -position insertpoint  \
sim:/marian_tb/i_axi_spi_slave/spi_sclk \
sim:/marian_tb/i_axi_spi_slave/spi_cs \
sim:/marian_tb/i_axi_spi_slave/spi_mode \
sim:/marian_tb/i_axi_spi_slave/spi_sdi0 \
sim:/marian_tb/i_axi_spi_slave/spi_sdi1 \
sim:/marian_tb/i_axi_spi_slave/spi_sdi2 \
sim:/marian_tb/i_axi_spi_slave/spi_sdi3 \
sim:/marian_tb/i_axi_spi_slave/spi_sdo0 \
sim:/marian_tb/i_axi_spi_slave/spi_sdo1 \
sim:/marian_tb/i_axi_spi_slave/spi_sdo2 \
sim:/marian_tb/i_axi_spi_slave/spi_sdo3
add wave -position insertpoint  \
sim:/marian_tb/i_axi_spi_slave/rx_counter \
sim:/marian_tb/i_axi_spi_slave/rx_counter_upd \
sim:/marian_tb/i_axi_spi_slave/rx_data \
sim:/marian_tb/i_axi_spi_slave/rx_data_valid \
sim:/marian_tb/i_axi_spi_slave/tx_counter \
sim:/marian_tb/i_axi_spi_slave/tx_counter_upd \
sim:/marian_tb/i_axi_spi_slave/tx_data \
sim:/marian_tb/i_axi_spi_slave/tx_data_valid \
sim:/marian_tb/i_axi_spi_slave/ctrl_rd_wr \
sim:/marian_tb/i_axi_spi_slave/ctrl_addr \
sim:/marian_tb/i_axi_spi_slave/ctrl_addr_valid \
sim:/marian_tb/i_axi_spi_slave/ctrl_data_rx \
sim:/marian_tb/i_axi_spi_slave/ctrl_data_rx_valid \
sim:/marian_tb/i_axi_spi_slave/ctrl_data_rx_ready \
sim:/marian_tb/i_axi_spi_slave/ctrl_data_tx \
sim:/marian_tb/i_axi_spi_slave/ctrl_data_tx_valid \
sim:/marian_tb/i_axi_spi_slave/ctrl_data_tx_ready \
sim:/marian_tb/i_axi_spi_slave/fifo_data_rx \
sim:/marian_tb/i_axi_spi_slave/fifo_data_rx_valid \
sim:/marian_tb/i_axi_spi_slave/fifo_data_rx_ready \
sim:/marian_tb/i_axi_spi_slave/fifo_data_tx \
sim:/marian_tb/i_axi_spi_slave/fifo_data_tx_valid \
sim:/marian_tb/i_axi_spi_slave/fifo_data_tx_ready \
sim:/marian_tb/i_axi_spi_slave/addr_sync \
sim:/marian_tb/i_axi_spi_slave/addr_valid_sync \
sim:/marian_tb/i_axi_spi_slave/cs_sync \
sim:/marian_tb/i_axi_spi_slave/tx_done \
sim:/marian_tb/i_axi_spi_slave/rd_wr_sync \
sim:/marian_tb/i_axi_spi_slave/wrap_length

add wave -position insertpoint sim:/marian_tb/i_axi_spi_slave/u_rxreg/*


add wave -position insertpoint sim:/marian_tb/i_axi_spi_slave/u_slave_sm/u_spiregs/*
add wave -position insertpoint sim:/marian_tb/i_axi_spi_slave/u_slave_sm/u_cmd_parser/*

add wave -position insertpoint sim:/marian_tb/i_axi_spi_slave/u_axiplug/*

run -all
