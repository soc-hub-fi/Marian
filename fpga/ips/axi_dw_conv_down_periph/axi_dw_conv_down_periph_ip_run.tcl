# ------------------------------------------------------------------------------
# axi_dw_conv_down_periph_ip_run.tcl
#
# Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
# Date     : 12-jan-2024
#
# Description: TCL script to synthesise the System AXI data width converter IP 
# ------------------------------------------------------------------------------

# Clear the console output
puts "\n---------------------------------------------------------"
puts "axi_dw_conv_down_periph_ip_run.tcl - Starting..."
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

set AXI_ADDR_WIDTH    64;
set AXI_S_DATA_WIDTH 128;
set AXI_M_DATA_WIDTH  32;
set AXI_S_ID_WIDTH     5;

# ------------------------------------------------------------------------------
# Synthesise IP
# ------------------------------------------------------------------------------

create_project ${IP_PROJECT} . -part ${XLNX_PRT_ID}
set_property board_part ${XLNX_BRD_ID} [current_project]

create_ip -name axi_dwidth_converter -vendor xilinx.com -library ip \
  -version 2.1 -module_name ${IP_PROJECT}

set_property -dict [ \
eval list \
  CONFIG.ADDR_WIDTH "${AXI_ADDR_WIDTH}" \
  CONFIG.SI_DATA_WIDTH "${AXI_S_DATA_WIDTH}" \
  CONFIG.MI_DATA_WIDTH "${AXI_M_DATA_WIDTH}" \
  CONFIG.SI_ID_WIDTH "${AXI_S_ID_WIDTH}" \
] [get_ips ${IP_PROJECT}]

generate_target {all} \
    [get_files  ${IP_PROJECT}.srcs/sources_1/ip/${IP_PROJECT}/${IP_PROJECT}.xci]

create_ip_run \
    [get_files -of_objects [get_fileset sources_1] ${IP_PROJECT}.srcs/sources_1/ip/${IP_PROJECT}/${IP_PROJECT}.xci]

launch_run -jobs 8 ${IP_PROJECT}_synth_1
wait_on_run ${IP_PROJECT}_synth_1

puts "\n---------------------------------------------------------"
puts "axi_dw_conv_down_periph_ip_run.tcl - Complete!"
puts "---------------------------------------------------------\n"

# ------------------------------------------------------------------------------
# End of Script
# ------------------------------------------------------------------------------