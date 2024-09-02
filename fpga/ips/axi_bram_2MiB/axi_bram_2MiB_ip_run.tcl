# ------------------------------------------------------------------------------
# axi_bram_2MiB_ip_run.tcl
#
# Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
# Date     : 26-feb-2024
#
# Description: TCL script to synthesise AXI BRAM controller for 2MiB of BRAM
# ------------------------------------------------------------------------------

# Clear the console output
puts "\n---------------------------------------------------------"
puts "axi_bram_2MiB_ip_run.tcl - Starting..."
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

# check that the output clock frequency has been defined
if [info exists ::env(L2_DEPTH)] {
    set L2_DEPTH $::env(L2_DEPTH);
} else {
    puts "ERROR - Variable L2_DEPTH is not globally defined in Makefile!\n";
    return 1;
}

set FPGA_COMMON_SCRIPT ${FPGA_TCL_DIR}/${PROJECT_NAME}_common.tcl

## read in common and board specific variables 
source ${FPGA_COMMON_SCRIPT}
source ${FPGA_BOARD_CONFIG_SCRIPT}

# ------------------------------------------------------------------------------
# IP Configuration Variables
# ------------------------------------------------------------------------------

set AXI_DATA_WIDTH 128;
set AXI_ID_WIDTH     5;
set BRAM_DEPTH     ${L2_DEPTH};

# ------------------------------------------------------------------------------
# Synthesise IP
# ------------------------------------------------------------------------------

create_project ${IP_PROJECT} . -part ${XLNX_PRT_ID}
set_property board_part ${XLNX_BRD_ID} [current_project]

create_ip -name axi_bram_ctrl -vendor xilinx.com -library ip \
  -version 4.1 -module_name ${IP_PROJECT}

set_property -dict [ \
eval list \
  CONFIG.DATA_WIDTH "${AXI_DATA_WIDTH}" \
  CONFIG.ID_WIDTH "${AXI_ID_WIDTH}" \
  CONFIG.SINGLE_PORT_BRAM {1} \
  CONFIG.Component_Name "${IP_PROJECT}" \
  CONFIG.MEM_DEPTH "${BRAM_DEPTH}" \
] [get_ips ${IP_PROJECT}]

generate_target {all} \
    [get_files  ${IP_PROJECT}.srcs/sources_1/ip/${IP_PROJECT}/${IP_PROJECT}.xci]

create_ip_run \
    [get_files -of_objects [get_fileset sources_1] ${IP_PROJECT}.srcs/sources_1/ip/${IP_PROJECT}/${IP_PROJECT}.xci]

launch_run -jobs 8 ${IP_PROJECT}_synth_1
wait_on_run ${IP_PROJECT}_synth_1

puts "\n---------------------------------------------------------"
puts "axi_bram_2MiB_ip_run.tcl - Complete!"
puts "---------------------------------------------------------\n"

# ------------------------------------------------------------------------------
# End of Script
# ------------------------------------------------------------------------------