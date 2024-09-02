# ------------------------------------------------------------------------------
# axi_qspi_ip_run.tcl
#
# Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
# Date     : 12-jan-2024
#
# Description: TCL script to synthesise the full AXI Quad SPI. 
# ------------------------------------------------------------------------------

# Clear the console output
puts "\n---------------------------------------------------------"
puts "axi_qspi_ip_run.tcl - Starting..."
puts "---------------------------------------------------------\n"

# ------------------------------------------------------------------------------
# Check/set basic variables
# ------------------------------------------------------------------------------

# check tcl directory has been defined
if [info exists ::env(FPGA_TCL_DIR)] {
    set FPGA_TCL_DIR $::env(FPGA_TCL_DIR);
} else {
    puts "ERROR - Variable FPGA_TCL_DIR is not globally defined in Makefile!\n";
    return 1;
}

# check Subsystem project name has been defined
if [info exists ::env(PROJECT_NAME)] {
    set PROJECT_NAME $::env(PROJECT_NAME);
} else {
    puts "ERROR - Variable PROJECT_NAME is not globally defined in Makefile!\n";
    return 1;
}

# check Vivado project name has been defined
if [info exists ::env(IP_PROJECT)] {
    set IP_PROJECT $::env(IP_PROJECT);
} else {
    puts "ERROR - Variable IP_PROJECT is not globally defined in Makefile!\n";
    return 1;
}

set FPGA_COMMON_SCRIPT ${FPGA_TCL_DIR}/${PROJECT_NAME}_common.tcl

## read in common and board specific variables 
source ${FPGA_COMMON_SCRIPT}
source ${FPGA_BOARD_CONFIG_SCRIPT}

# ------------------------------------------------------------------------------
# IP Configuration Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Synthesise IP
# ------------------------------------------------------------------------------

create_project ${IP_PROJECT} . -part ${XLNX_PRT_ID}
set_property board_part ${XLNX_BRD_ID} [current_project]

create_ip -name axi_quad_spi -vendor xilinx.com -library ip \
  -version 3.2 -module_name ${IP_PROJECT}

set_property -dict [ \
eval list \
  CONFIG.C_SPI_MEMORY {0} \
  CONFIG.C_SPI_MODE {2} \
  CONFIG.C_SCK_RATIO {2} \
  CONFIG.C_XIP_MODE {0} \
  CONFIG.C_TYPE_OF_AXI4_INTERFACE {1} \
  CONFIG.Async_Clk {0} \
] [get_ips ${IP_PROJECT}]

generate_target {all} \
    [get_files  ${IP_PROJECT}.srcs/sources_1/ip/${IP_PROJECT}/${IP_PROJECT}.xci]

create_ip_run \
    [get_files -of_objects [get_fileset sources_1] ${IP_PROJECT}.srcs/sources_1/ip/${IP_PROJECT}/${IP_PROJECT}.xci]

launch_run -jobs 8 ${IP_PROJECT}_synth_1
wait_on_run ${IP_PROJECT}_synth_1

puts "\n---------------------------------------------------------"
puts "axi_qspi_ip_run.tcl - Complete!"
puts "---------------------------------------------------------\n"

# ------------------------------------------------------------------------------
# End of Script
# ------------------------------------------------------------------------------