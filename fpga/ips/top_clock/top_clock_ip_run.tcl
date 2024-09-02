# ------------------------------------------------------------------------------
# top_clock_ip_run.tcl
#
# Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
# Date     : 04-dec-2023
#
# Description: TCL script to synthesise a clock wizard IP 
# ------------------------------------------------------------------------------

# Clear the console output
puts "\n---------------------------------------------------------"
puts "top_clock_ip_run.tcl - Starting..."
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
if [info exists ::env(TOP_CLK_FREQ_MHZ)] {
    set TOP_CLK_FREQ_MHZ $::env(TOP_CLK_FREQ_MHZ);
} else {
    puts "ERROR - Variable TOP_CLK_FREQ_MHZ is not globally defined in Makefile!\n";
    return 1;
}

set FPGA_COMMON_SCRIPT ${FPGA_TCL_DIR}/${PROJECT_NAME}_common.tcl

## read in common and board specific variables 
source ${FPGA_COMMON_SCRIPT}
source ${FPGA_BOARD_CONFIG_SCRIPT}

# ------------------------------------------------------------------------------
# IP Configuration Variables
# ------------------------------------------------------------------------------

set INPUT_CLOCK_FREQ_MHZ    ${INPUT_OSC_FREQ_MHZ} ; # input to clocking wizard (read from scripts/<BOARD>.tcl)

# ------------------------------------------------------------------------------
# Synthesise IP
# ------------------------------------------------------------------------------

create_project ${IP_PROJECT} . -part ${XLNX_PRT_ID}
set_property board_part ${XLNX_BRD_ID} [current_project]

create_ip -name clk_wiz -vendor xilinx.com -library ip -module_name ${IP_PROJECT}

set_property -dict [ \
eval list \
  CONFIG.PRIM_IN_FREQ "${INPUT_CLOCK_FREQ_MHZ}" \
  CONFIG.PRIMITIVE {PLL} \
  CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
  CONFIG.NUM_OUT_CLKS {1} \
  CONFIG.USE_RESET {false} \
  CONFIG.USE_LOCKED {true} \
  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ "${TOP_CLK_FREQ_MHZ}" \
] [get_ips ${IP_PROJECT}]

generate_target {all} \
    [get_files  ${IP_PROJECT}.srcs/sources_1/ip/${IP_PROJECT}/${IP_PROJECT}.xci]

create_ip_run \
    [get_files -of_objects [get_fileset sources_1] ${IP_PROJECT}.srcs/sources_1/ip/${IP_PROJECT}/${IP_PROJECT}.xci]

launch_run -jobs 8 ${IP_PROJECT}_synth_1
wait_on_run ${IP_PROJECT}_synth_1

puts "\n---------------------------------------------------------"
puts "top_clock_ip_run.tcl - Complete!"
puts "---------------------------------------------------------\n"

# ------------------------------------------------------------------------------
# End of Script
# ------------------------------------------------------------------------------