# ------------------------------------------------------------------------------
# marian_fpga_src_files.tcl
#
# Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
# Date     : 23-dec-2023
#
# Description: Source file list for the FPGA prototype of the marian. Adds source
# files/packages to project and sets the project include directories
#
# Ascii art headers generated using https://textkool.com/en/ascii-art-generator
# (style: ANSI Shadow)
# ------------------------------------------------------------------------------

# Clear the console output
puts "\n---------------------------------------------------------";
puts "marian_fpga_src_files.tcl - Starting...";
puts "---------------------------------------------------------\n";

# ██╗███╗   ██╗ ██████╗██╗     ██╗   ██╗██████╗ ███████╗███████╗
# ██║████╗  ██║██╔════╝██║     ██║   ██║██╔══██╗██╔════╝██╔════╝
# ██║██╔██╗ ██║██║     ██║     ██║   ██║██║  ██║█████╗  ███████╗
# ██║██║╚██╗██║██║     ██║     ██║   ██║██║  ██║██╔══╝  ╚════██║
# ██║██║ ╚████║╚██████╗███████╗╚██████╔╝██████╔╝███████╗███████║
# ╚═╝╚═╝  ╚═══╝ ╚═════╝╚══════╝ ╚═════╝ ╚═════╝ ╚══════╝╚══════╝

set MARIAN_FPGA_INCLUDE_PATHS " \
  ${REPO_DIR}/ips/pulp_apb/include/ \
  ${REPO_DIR}/ips/bow_common_ips/ips/axi/include/ \
  ${REPO_DIR}/ips/bow_common_ips/ips/pulp-common-cells/include/ \
  ${REPO_DIR}/ips/pulp_ara/hardware/include/ \
  ${REPO_DIR}/ips/pulp_reg_if/include/ \
";

set_property include_dirs ${MARIAN_FPGA_INCLUDE_PATHS} [current_fileset];
set_property include_dirs ${MARIAN_FPGA_INCLUDE_PATHS} [current_fileset -simset];

# ██████╗ ████████╗██╗         ██████╗ ██╗  ██╗ ██████╗ ███████╗
# ██╔══██╗╚══██╔══╝██║         ██╔══██╗██║ ██╔╝██╔════╝ ██╔════╝
# ██████╔╝   ██║   ██║         ██████╔╝█████╔╝ ██║  ███╗███████╗
# ██╔══██╗   ██║   ██║         ██╔═══╝ ██╔═██╗ ██║   ██║╚════██║
# ██║  ██║   ██║   ███████╗    ██║     ██║  ██╗╚██████╔╝███████║
# ╚═╝  ╚═╝   ╚═╝   ╚══════╝    ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚══════╝                                                                                                                           

set MARIAN_FPGA_RTL_PACKAGES " \
  ${REPO_DIR}/ips/bow_common_ips/ips/pulp-common-cells/src/cf_math_pkg.sv \
  ${REPO_DIR}/ips/pulp_apb/src/apb_pkg.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/axi/src/axi_pkg.sv \
  ${REPO_DIR}/ips/pulp_rv_dbg/src/dm_pkg.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/fpu/src/fpnew_pkg.sv \
  ${REPO_DIR}/src/ip/include/riscv_pkg.sv \
  ${REPO_DIR}/ips/pulp_cva6/include/ariane_pkg.sv \
  ${REPO_DIR}/ips/pulp_cva6/include/std_cache_pkg.sv \
  ${REPO_DIR}/ips/pulp_cva6/include/wt_cache_pkg.sv \
  ${REPO_DIR}/ips/pulp_cva6/include/ariane_axi_pkg.sv \
  ${REPO_DIR}/src/ip/include/ara_pkg.sv \
  ${REPO_DIR}/src/ip/include/rvv_pkg.sv \  
  ${REPO_DIR}/src/ip/include/marian_pkg.sv \
  ${REPO_DIR}/fpga/hdl/include/marian_fpga_pkg.sv \
";

add_files -norecurse -scan_for_includes ${MARIAN_FPGA_RTL_PACKAGES};

# ████████╗██████╗     ██████╗ ██╗  ██╗ ██████╗ ███████╗
# ╚══██╔══╝██╔══██╗    ██╔══██╗██║ ██╔╝██╔════╝ ██╔════╝
#    ██║   ██████╔╝    ██████╔╝█████╔╝ ██║  ███╗███████╗
#    ██║   ██╔══██╗    ██╔═══╝ ██╔═██╗ ██║   ██║╚════██║
#    ██║   ██████╔╝    ██║     ██║  ██╗╚██████╔╝███████║
#    ╚═╝   ╚═════╝     ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚══════╝

set MARIAN_FPGA_TB_PACKAGES " \
  ${REPO_DIR}/ips/pulp_cva6/include/instr_tracer_pkg.sv \
"; 

add_files -norecurse -scan_for_includes -fileset [current_fileset -simset] ${MARIAN_FPGA_TB_PACKAGES};

#  ██████╗ ██████╗ ███╗   ███╗███╗   ███╗ ██████╗ ███╗   ██╗     ██████╗███████╗██╗     ██╗     ███████╗
# ██╔════╝██╔═══██╗████╗ ████║████╗ ████║██╔═══██╗████╗  ██║    ██╔════╝██╔════╝██║     ██║     ██╔════╝
# ██║     ██║   ██║██╔████╔██║██╔████╔██║██║   ██║██╔██╗ ██║    ██║     █████╗  ██║     ██║     ███████╗
# ██║     ██║   ██║██║╚██╔╝██║██║╚██╔╝██║██║   ██║██║╚██╗██║    ██║     ██╔══╝  ██║     ██║     ╚════██║
# ╚██████╗╚██████╔╝██║ ╚═╝ ██║██║ ╚═╝ ██║╚██████╔╝██║ ╚████║    ╚██████╗███████╗███████╗███████╗███████║
#  ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝     ╚═════╝╚══════╝╚══════╝╚══════╝╚══════╝

set MARIAN_FPGA_COMMON_CELLS_SRC " \
  ${REPO_DIR}/ips/bow_common_ips/ips/pulp-common-cells/src/cdc_2phase.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/pulp-common-cells/src/delta_counter.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/pulp-common-cells/src/exp_backoff.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/pulp-common-cells/src/fifo_v3.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/pulp-common-cells/src/lfsr.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/pulp-common-cells/src/onehot_to_bin.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/pulp-common-cells/src/popcount.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/pulp-common-cells/src/rr_arb_tree.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/pulp-common-cells/src/shift_reg.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/pulp-common-cells/src/spill_register_flushable.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/pulp-common-cells/src/stream_demux.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/pulp-common-cells/src/stream_fork.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/pulp-common-cells/src/stream_join.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/pulp-common-cells/src/stream_mux.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/pulp-common-cells/src/unread.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/pulp-common-cells/src/addr_decode.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/pulp-common-cells/src/counter.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/pulp-common-cells/src/lzc.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/pulp-common-cells/src/spill_register.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/pulp-common-cells/src/stream_fifo.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/pulp-common-cells/src/stream_fork_dynamic.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/pulp-common-cells/src/fall_through_register.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/pulp-common-cells/src/id_queue.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/pulp-common-cells/src/stream_to_mem.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/pulp-common-cells/src/stream_arbiter_flushable.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/pulp-common-cells/src/stream_register.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/pulp-common-cells/src/stream_xbar.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/pulp-common-cells/src/stream_arbiter.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/pulp-common-cells/src/deprecated/fifo_v2.sv \
";

add_files -norecurse -scan_for_includes ${MARIAN_FPGA_COMMON_CELLS_SRC};

# ████████╗███████╗ ██████╗██╗  ██╗     ██████╗███████╗██╗     ██╗     ███████╗     ██████╗ ███████╗███╗   ██╗███████╗██████╗ ██╗ ██████╗
# ╚══██╔══╝██╔════╝██╔════╝██║  ██║    ██╔════╝██╔════╝██║     ██║     ██╔════╝    ██╔════╝ ██╔════╝████╗  ██║██╔════╝██╔══██╗██║██╔════╝
#    ██║   █████╗  ██║     ███████║    ██║     █████╗  ██║     ██║     ███████╗    ██║  ███╗█████╗  ██╔██╗ ██║█████╗  ██████╔╝██║██║     
#    ██║   ██╔══╝  ██║     ██╔══██║    ██║     ██╔══╝  ██║     ██║     ╚════██║    ██║   ██║██╔══╝  ██║╚██╗██║██╔══╝  ██╔══██╗██║██║     
#    ██║   ███████╗╚██████╗██║  ██║    ╚██████╗███████╗███████╗███████╗███████║    ╚██████╔╝███████╗██║ ╚████║███████╗██║  ██║██║╚██████╗
#    ╚═╝   ╚══════╝ ╚═════╝╚═╝  ╚═╝     ╚═════╝╚══════╝╚══════╝╚══════╝╚══════╝     ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═╝ ╚═════╝

set MARIAN_FPGA_TECH_CELLS_GENERIC_SRC " \
  ${REPO_DIR}/ips/bow_common_ips/ips/tech_cells_generic/src/deprecated/cluster_clk_cells.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/tech_cells_generic/src/fpga/tc_clk_xilinx.sv \
";

add_files -norecurse -scan_for_includes ${MARIAN_FPGA_TECH_CELLS_GENERIC_SRC};

# ██████╗ ███████╗██████╗ ██╗   ██╗ ██████╗ 
# ██╔══██╗██╔════╝██╔══██╗██║   ██║██╔════╝ 
# ██║  ██║█████╗  ██████╔╝██║   ██║██║  ███╗
# ██║  ██║██╔══╝  ██╔══██╗██║   ██║██║   ██║
# ██████╔╝███████╗██████╔╝╚██████╔╝╚██████╔╝
# ╚═════╝ ╚══════╝╚═════╝  ╚═════╝  ╚═════╝ 

set MARIAN_FPGA_RISCV_DEBUG_SRC " \
  ${REPO_DIR}/ips/pulp_rv_dbg/debug_rom/debug_rom.sv \
  ${REPO_DIR}/ips/pulp_rv_dbg/debug_rom/debug_rom_one_scratch.sv \
  ${REPO_DIR}/ips/pulp_rv_dbg/src/dm_csrs.sv \
  ${REPO_DIR}/ips/pulp_rv_dbg/src/dm_mem.sv \
  ${REPO_DIR}/ips/pulp_rv_dbg/src/dm_top.sv \
  ${REPO_DIR}/ips/pulp_rv_dbg/src/dmi_cdc.sv \
  ${REPO_DIR}/ips/pulp_rv_dbg/src/dmi_jtag.sv \
  ${REPO_DIR}/fpga/hdl/src/dmi_jtag_tap_fpga.sv \
  ${REPO_DIR}/ips/pulp_rv_dbg/src/dm_sba.sv \
";

add_files -norecurse -scan_for_includes ${MARIAN_FPGA_RISCV_DEBUG_SRC};                                          

#  █████╗ ██╗  ██╗██╗
# ██╔══██╗╚██╗██╔╝██║
# ███████║ ╚███╔╝ ██║
# ██╔══██║ ██╔██╗ ██║
# ██║  ██║██╔╝ ██╗██║
# ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝

set MARIAN_FPGA_AXI_SRC " \
  ${REPO_DIR}/ips/bow_common_ips/ips/axi/src/axi_intf.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/axi/src/axi_atop_filter.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/axi/src/axi_burst_splitter.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/axi/src/axi_cut.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/axi/src/axi_multicut.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/axi/src/axi_demux.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/axi/src/axi_lite_demux.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/axi/src/axi_dw_downsizer.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/axi/src/axi_dw_upsizer.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/axi/src/axi_id_prepend.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/axi/src/axi_lite_regs.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/axi/src/axi_lite_to_apb.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/axi/src/axi_err_slv.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/axi/src/axi_dw_converter.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/axi/src/axi_to_axi_lite.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/axi/src/axi_xbar.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/axi/src/axi_mux.sv \
  ${REPO_DIR}/ips/bow_common_ips/ips/axi_mem_if/src/axi2mem.sv \
";

add_files -norecurse -scan_for_includes ${MARIAN_FPGA_AXI_SRC};


#  █████╗ ██████╗ ██████╗     ██╗   ██╗ █████╗ ██████╗ ████████╗
# ██╔══██╗██╔══██╗██╔══██╗    ██║   ██║██╔══██╗██╔══██╗╚══██╔══╝
# ███████║██████╔╝██████╔╝    ██║   ██║███████║██████╔╝   ██║   
# ██╔══██║██╔═══╝ ██╔══██╗    ██║   ██║██╔══██║██╔══██╗   ██║   
# ██║  ██║██║     ██████╔╝    ╚██████╔╝██║  ██║██║  ██║   ██║   
# ╚═╝  ╚═╝╚═╝     ╚═════╝      ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   
                                                              
set MARIAN_FPGA_APB_UART_SRC " \
  ${REPO_DIR}/src/ip/marian/apb_uart/apb_uart.sv \
  ${REPO_DIR}/ips/pulp_apb_uart/uart_rx.sv \
  ${REPO_DIR}/ips/pulp_apb_uart/uart_tx.sv \
  ${REPO_DIR}/ips/pulp_apb_uart/io_generic_fifo.sv \
  ${REPO_DIR}/ips/pulp_apb_uart/uart_interrupt.sv \
"

add_files -norecurse -scan_for_includes ${MARIAN_FPGA_APB_UART_SRC};


#  █████╗ ██████╗ ██████╗     ████████╗██╗███╗   ███╗███████╗██████╗ 
# ██╔══██╗██╔══██╗██╔══██╗    ╚══██╔══╝██║████╗ ████║██╔════╝██╔══██╗
# ███████║██████╔╝██████╔╝       ██║   ██║██╔████╔██║█████╗  ██████╔╝
# ██╔══██║██╔═══╝ ██╔══██╗       ██║   ██║██║╚██╔╝██║██╔══╝  ██╔══██╗
# ██║  ██║██║     ██████╔╝       ██║   ██║██║ ╚═╝ ██║███████╗██║  ██║
# ╚═╝  ╚═╝╚═╝     ╚═════╝        ╚═╝   ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝

set MARIAN_FPGA_APB_TIMER_SRC " \
  ${REPO_DIR}/ips/pulp_apb_timer/src/timer.sv \
"

add_files -norecurse -scan_for_includes ${MARIAN_FPGA_APB_TIMER_SRC};


#  █████╗ ██████╗ ██████╗      ██████╗ ██████╗ ██╗ ██████╗ 
# ██╔══██╗██╔══██╗██╔══██╗    ██╔════╝ ██╔══██╗██║██╔═══██╗
# ███████║██████╔╝██████╔╝    ██║  ███╗██████╔╝██║██║   ██║
# ██╔══██║██╔═══╝ ██╔══██╗    ██║   ██║██╔═══╝ ██║██║   ██║
# ██║  ██║██║     ██████╔╝    ╚██████╔╝██║     ██║╚██████╔╝
# ╚═╝  ╚═╝╚═╝     ╚═════╝      ╚═════╝ ╚═╝     ╚═╝ ╚═════╝ 
                                                         

set MARIAN_FPGA_APB_GPIO_SRC " \
  ${REPO_DIR}/ips/tlp-ss/ips/apb_gpio/rtl/apb_gpio.sv \
"

add_files -norecurse -scan_for_includes ${MARIAN_FPGA_APB_GPIO_SRC};


#  █████╗ ██████╗ ██████╗     ███████╗██████╗ ██╗
# ██╔══██╗██╔══██╗██╔══██╗    ██╔════╝██╔══██╗██║
# ███████║██████╔╝██████╔╝    ███████╗██████╔╝██║
# ██╔══██║██╔═══╝ ██╔══██╗    ╚════██║██╔═══╝ ██║
# ██║  ██║██║     ██████╔╝    ███████║██║     ██║
# ╚═╝  ╚═╝╚═╝     ╚═════╝     ╚══════╝╚═╝     ╚═╝
                                               
set MARIAN_FPGA_APB_SPI_SRC " \
  ${REPO_DIR}/ips/tlp-ss/ips/apb_spi_master/apb_spi_master.sv \
  ${REPO_DIR}/ips/tlp-ss/ips/apb_spi_master/spi_master_apb_if.sv \
  ${REPO_DIR}/ips/tlp-ss/ips/axi_spi_master/spi_master_controller.sv \
  ${REPO_DIR}/ips/tlp-ss/ips/axi_spi_master/spi_master_fifo.sv \
  ${REPO_DIR}/ips/tlp-ss/ips/axi_spi_master/spi_master_clkgen.sv \
  ${REPO_DIR}/ips/tlp-ss/ips/axi_spi_master/spi_master_rx.sv \
  ${REPO_DIR}/ips/tlp-ss/ips/axi_spi_master/spi_master_tx.sv \
"

add_files -norecurse -scan_for_includes ${MARIAN_FPGA_APB_SPI_SRC};


# ██████╗ ███████╗ ██████╗     ██╗███████╗
# ██╔══██╗██╔════╝██╔════╝     ██║██╔════╝
# ██████╔╝█████╗  ██║  ███╗    ██║█████╗  
# ██╔══██╗██╔══╝  ██║   ██║    ██║██╔══╝  
# ██║  ██║███████╗╚██████╔╝    ██║██║     
# ╚═╝  ╚═╝╚══════╝ ╚═════╝     ╚═╝╚═╝     

set MARIAN_FPGA_REG_IF_SRC " \
  ${REPO_DIR}/ips/pulp_reg_if/src/reg_intf.sv \
  ${REPO_DIR}/ips/pulp_reg_if/src/apb_to_reg.sv \
  ${REPO_DIR}/ips/pulp_reg_if/src/axi_to_reg.sv \
  ${REPO_DIR}/ips/pulp_reg_if/src/periph_to_reg.sv \
  ${REPO_DIR}/ips/pulp_reg_if/src/reg_cdc.sv \
  ${REPO_DIR}/ips/pulp_reg_if/src/reg_demux.sv \
  ${REPO_DIR}/ips/pulp_reg_if/src/reg_mux.sv \
  ${REPO_DIR}/ips/pulp_reg_if/src/reg_to_mem.sv \
  ${REPO_DIR}/ips/pulp_reg_if/src/reg_uniform.sv \
  ${REPO_DIR}/ips/pulp_reg_if/src/axi_lite_to_reg.sv \
"

add_files -norecurse -scan_for_includes ${MARIAN_FPGA_REG_IF_SRC};                                        


#  ██████╗██╗   ██╗ █████╗  ██████╗ 
# ██╔════╝██║   ██║██╔══██╗██╔════╝ 
# ██║     ██║   ██║███████║███████╗ 
# ██║     ╚██╗ ██╔╝██╔══██║██╔═══██╗
# ╚██████╗ ╚████╔╝ ██║  ██║╚██████╔╝
#  ╚═════╝  ╚═══╝  ╚═╝  ╚═╝ ╚═════╝                                   

set MARIAN_FPGA_CVA6_SRC " \
  ${REPO_DIR}/src/ip/marian/ariane/fpu/defs_div_sqrt_mvp.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/ariane.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/axi_adapter.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/serdiv.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/ariane_regfile_ff.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/amo_buffer.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/id_stage.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/branch_unit.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/instr_realign.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/load_store_unit.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/controller.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/issue_stage.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/re_name.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/csr_buffer.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/tlb.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/decoder.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/scoreboard.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/perf_counters.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/store_unit.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/fpu_wrap.sv \
  ${REPO_DIR}/src/ip/marian/ariane/csr_regfile.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/commit_stage.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/alu.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/multiplier.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/store_buffer.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/compressed_decoder.sv \
  ${REPO_DIR}/src/ip/marian/ariane/axi_shim.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/ex_stage.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/mmu.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/ptw.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/mult.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/load_unit.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/issue_read_operands.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/acc_dispatcher.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/pmp/src/pmp_entry.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/pmp/src/pmp.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/fpu/src/fpnew_fma.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/fpu/src/fpnew_opgroup_fmt_slice.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/fpu/src/fpnew_divsqrt_multi.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/fpu/src/fpnew_fma_multi.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/fpu/src/fpnew_opgroup_multifmt_slice.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/fpu/src/fpnew_classifier.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/fpu/src/fpnew_noncomp.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/fpu/src/fpnew_cast_multi.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/fpu/src/fpnew_opgroup_block.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/fpu/src/fpnew_rounding.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/fpu/src/fpnew_top.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/fpu/src/fpu_div_sqrt_mvp/hdl/iteration_div_sqrt_mvp.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/fpu/src/fpu_div_sqrt_mvp/hdl/nrbd_nrsc_mvp.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/fpu/src/fpu_div_sqrt_mvp/hdl/div_sqrt_top_mvp.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/fpu/src/fpu_div_sqrt_mvp/hdl/preprocess_mvp.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/fpu/src/fpu_div_sqrt_mvp/hdl/control_mvp.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/fpu/src/fpu_div_sqrt_mvp/hdl/norm_div_sqrt_mvp.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/frontend/frontend.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/frontend/instr_scan.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/frontend/instr_queue.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/frontend/bht.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/frontend/btb.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/frontend/ras.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/cache_subsystem/wt_axi_adapter.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/cache_subsystem/wt_dcache_ctrl.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/cache_subsystem/wt_cache_subsystem.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/cache_subsystem/wt_dcache_missunit.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/cache_subsystem/cva6_icache.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/cache_subsystem/wt_dcache_wbuffer.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/cache_subsystem/wt_dcache_mem.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/cache_subsystem/cva6_icache_axi_wrapper.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/cache_subsystem/wt_dcache.sv \
";

add_files -norecurse -scan_for_includes ${MARIAN_FPGA_CVA6_SRC};

#  █████╗ ██████╗  █████╗ 
# ██╔══██╗██╔══██╗██╔══██╗
# ███████║██████╔╝███████║
# ██╔══██║██╔══██╗██╔══██║
# ██║  ██║██║  ██║██║  ██║
# ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝
                        
set MARIAN_FPGA_ARA_SRC " \
  ${REPO_DIR}/ips/pulp_ara/hardware/src/axi_to_mem.sv \
  ${REPO_DIR}/ips/pulp_ara/hardware/src/axi_inval_filter.sv \
  ${REPO_DIR}/src/ip/marian/ariane/cva6_accel_first_pass_decoder.sv \
  ${REPO_DIR}/ips/pulp_ara/hardware/src/lane/operand_queue.sv \  
  ${REPO_DIR}/ips/pulp_ara/hardware/src/lane/simd_div.sv \
  ${REPO_DIR}/ips/pulp_ara/hardware/src/lane/vector_regfile.sv \
  ${REPO_DIR}/ips/pulp_ara/hardware/src/lane/power_gating_generic.sv \
  ${REPO_DIR}/ips/pulp_ara/hardware/src/masku/masku.sv \
  ${REPO_DIR}/ips/pulp_ara/hardware/src/sldu/p2_stride_gen.sv \
  ${REPO_DIR}/ips/pulp_ara/hardware/src/sldu/sldu_op_dp.sv \
  ${REPO_DIR}/ips/pulp_ara/hardware/src/sldu/sldu.sv \
  ${REPO_DIR}/ips/pulp_ara/hardware/src/lane/vmfpu.sv \
  ${REPO_DIR}/ips/pulp_ara/hardware/src/lane/fixed_p_rounding.sv \
  ${REPO_DIR}/ips/pulp_ara/hardware/src/lane/vector_fus_stage.sv \
"

add_files -norecurse -scan_for_includes ${MARIAN_FPGA_ARA_SRC};


# ███╗   ███╗ █████╗ ██████╗ ██╗ █████╗ ███╗   ██╗
# ████╗ ████║██╔══██╗██╔══██╗██║██╔══██╗████╗  ██║
# ██╔████╔██║███████║██████╔╝██║███████║██╔██╗ ██║
# ██║╚██╔╝██║██╔══██║██╔══██╗██║██╔══██║██║╚██╗██║
# ██║ ╚═╝ ██║██║  ██║██║  ██║██║██║  ██║██║ ╚████║
# ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝

set MARIAN_FPGA_MARIAN_SRC " \
  ${REPO_DIR}/src/ip/marian/marian_top.sv \
  ${REPO_DIR}/src/ip/marian/ara_system.sv \
  ${REPO_DIR}/src/ip/crypto/aes/src/canright_sbox.sv \
  ${REPO_DIR}/src/ip/crypto/aes/src/encdec.sv \
  ${REPO_DIR}/src/ip/crypto/aes/src/key_expansion.sv \  
  ${REPO_DIR}/src/ip/marian/crypto_unit/aes.sv \
  ${REPO_DIR}/src/ip/crypto/aes/src/encdec.sv \
  ${REPO_DIR}/src/ip/crypto/sha2/src/compression.sv \
  ${REPO_DIR}/src/ip/crypto/sha2/src/msg_schedule.sv \
  ${REPO_DIR}/src/ip/crypto/gcm/src/add_mult_ghash.sv \
  ${REPO_DIR}/src/ip/crypto/gcm/src/mult_ghash.sv \
  ${REPO_DIR}/src/ip/marian/crypto_unit/aes.sv \
  ${REPO_DIR}/src/ip/marian/crypto_unit/gcm.sv \
  ${REPO_DIR}/src/ip/marian/crypto_unit/sha.sv \
  ${REPO_DIR}/src/ip/crypto/sm4/src/sm4_key_expansion.sv \
  ${REPO_DIR}/src/ip/crypto/sm4/src/sm4_encdec.sv \
  ${REPO_DIR}/src/ip/crypto/sm3/src/sm3_msg_expansion.sv \
  ${REPO_DIR}/src/ip/crypto/sm3/src/sm3_compression.sv \
  ${REPO_DIR}/src/ip/marian/crypto_unit/sm4.sv \
  ${REPO_DIR}/src/ip/marian/crypto_unit/sm3.sv \
  ${REPO_DIR}/src/ip/marian/crypto_unit/crypto_unit.sv \
  ${REPO_DIR}/src/ip/marian/crypto_unit/execution_units.sv \
  ${REPO_DIR}/src/ip/marian/crypto_unit/operand_collector.sv \
  ${REPO_DIR}/src/ip/marian/crypto_unit/write_back.sv \
  ${REPO_DIR}/src/ip/marian/lane/lane_sequencer.sv \
  ${REPO_DIR}/src/ip/marian/lane/lane.sv \
  ${REPO_DIR}/src/ip/marian/lane/valu.sv \
  ${REPO_DIR}/src/ip/marian/lane/simd_alu.sv \
  ${REPO_DIR}/src/ip/marian/lane/simd_mul.sv \
  ${REPO_DIR}/src/ip/marian/lane/vlsu.sv \
  ${REPO_DIR}/src/ip/marian/lane/operand_queues_stage.sv \
  ${REPO_DIR}/src/ip/marian/lane/operand_requester.sv \
  ${REPO_DIR}/src/ip/marian/ara_dispatcher.sv \
  ${REPO_DIR}/src/ip/marian/ara_sequencer.sv \
  ${REPO_DIR}/src/ip/marian/ara.sv \
  ${REPO_DIR}/src/ip/marian/ariane/entropy_source.sv \
  ${REPO_DIR}/src/ip/marian/debug_system.sv \
  ${REPO_DIR}/src/ip/marian/ctrl_registers.sv \
  ${REPO_DIR}/src/ip/marian/sram.sv \
  ${REPO_DIR}/src/ip/marian/tc_sram.sv \
  ${REPO_DIR}/src/ip/marian/bootrom/boot_rom.sv \
  ${REPO_DIR}/src/ip/marian/bootrom/bootrom_if.sv \
  ${REPO_DIR}/src/ip/marian/plic/plic_regmap.sv \
  ${REPO_DIR}/ips/pulp_rv_plic/rtl/plic_top.sv \
  ${REPO_DIR}/ips/pulp_rv_plic/rtl/prim_subreg_ext.sv \
  ${REPO_DIR}/ips/pulp_rv_plic/rtl/prim_subreg.sv \
  ${REPO_DIR}/ips/pulp_rv_plic/rtl/rv_plic_gateway.sv \
  ${REPO_DIR}/ips/pulp_rv_plic/rtl/rv_plic_reg_top.sv \
  ${REPO_DIR}/ips/pulp_rv_plic/rtl/rv_plic.sv \
  ${REPO_DIR}/ips/pulp_rv_plic/rtl/rv_plic_target.sv \
  ${REPO_DIR}/src/ip/marian/plic/plic_wrapper.sv \
  ${REPO_DIR}/src/ip/marian/clint/clint.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/clint/axi_lite_interface.sv \
  ${REPO_DIR}/src/ip/marian/clint/clint_wrapper.sv \
  ${REPO_DIR}/src/ip/marian/rtc_generator.sv \
  ${REPO_DIR}/src/ip/marian/peripherals.sv \
  ${REPO_DIR}/ips/tlp-ss/ips/apb_node/src/apb_node.sv \
  ${REPO_DIR}/ips/pulp_apb/src/apb_regs.sv \
  ${REPO_DIR}/src/ip/marian/apb_peripherals.sv \
"

add_files -norecurse -scan_for_includes ${MARIAN_FPGA_MARIAN_SRC};

# ███████╗██████╗  ██████╗  █████╗     ██████╗ ████████╗██╗     
# ██╔════╝██╔══██╗██╔════╝ ██╔══██╗    ██╔══██╗╚══██╔══╝██║     
# █████╗  ██████╔╝██║  ███╗███████║    ██████╔╝   ██║   ██║     
# ██╔══╝  ██╔═══╝ ██║   ██║██╔══██║    ██╔══██╗   ██║   ██║     
# ██║     ██║     ╚██████╔╝██║  ██║    ██║  ██║   ██║   ███████╗
# ╚═╝     ╚═╝      ╚═════╝ ╚═╝  ╚═╝    ╚═╝  ╚═╝   ╚═╝   ╚══════╝
                                                              
set MARIAN_FPGA_FPGA_SRC " \
  ${REPO_DIR}/fpga/hdl/src/addrgen_fpga.sv \
  ${REPO_DIR}/fpga/hdl/src/vldu_fpga.sv \
  ${REPO_DIR}/fpga/hdl/src/vstu_fpga.sv \
  ${REPO_DIR}/fpga/hdl/src/tico_generic_fpga.sv \
  ${REPO_DIR}/fpga/hdl/src/xilinx_sp_bram_byte_en.sv \
  ${REPO_DIR}/fpga/hdl/src/marian_fpga_top.sv \
";

add_files -norecurse -scan_for_includes ${MARIAN_FPGA_FPGA_SRC};

# ████████╗██████╗ 
# ╚══██╔══╝██╔══██╗
#    ██║   ██████╔╝
#    ██║   ██╔══██╗
#    ██║   ██████╔╝
#    ╚═╝   ╚═════╝ 

set MARIAN_FPGA_TB_SRC " \
  ${REPO_DIR}/ips/pulp_cva6/tb/common/uart.sv \
  ${REPO_DIR}/ips/pulp_cva6/tb/common/mock_uart.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/util/instr_tracer.sv \
  ${REPO_DIR}/ips/pulp_cva6/src/util/instr_tracer_if.sv \
  ${REPO_DIR}/ips/pulp_ara/hardware/src/accel_dispatcher_ideal.sv \
  ${REPO_DIR}/src/tb/include/marian_jtag_pkg.sv \
  ${REPO_DIR}/fpga/hdl/tb/marian_fpga_top_tb.sv \
  ${REPO_DIR}/ips/pulp_cva6/tb/common/uart.sv \
";

add_files -norecurse -scan_for_includes -fileset [current_fileset -simset] ${MARIAN_FPGA_TB_SRC};

puts "\n---------------------------------------------------------";
puts "marian_fpga_src_files.tcl - Complete!";
puts "---------------------------------------------------------\n";

# ------------------------------------------------------------------------------
# End of Script
# ------------------------------------------------------------------------------