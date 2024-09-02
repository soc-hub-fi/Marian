# ------------------------------------------------------------------------------
# axi_xbar_128_ip_run.tcl
#
# Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
# Date     : 12-jan-2024
#
# Description: TCL script to synthesise the 128b AXI xbar IP. 
# ------------------------------------------------------------------------------

# Clear the console output
puts "\n---------------------------------------------------------"
puts "axi_xbar_128_ip_run.tcl - Starting..."
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

set N_AXI_S 2;
set N_AXI_M 6;
set AXI_ADDR_W 64;
set AXI_DATA_W 128;
set AXI_ID_W 5;
set AXI_USER_W 1;
# Map to match addresses defined within marian_fpga_pkg.sv
set BASE_ADDR_DBGM {0x0000000000000000};
set BASE_ADDR_QSPI {0x0000000000003000};
set BASE_ADDR_GPIO {0x0000000000004000};
set BASE_ADDR_TIMR {0x0000000000005000};
set BASE_ADDR_DRAM {0x00000000080000000};
set BASE_ADDR_UART {0x000000000C0000000};


# ------------------------------------------------------------------------------
# Synthesise IP
# ------------------------------------------------------------------------------

create_project ${IP_PROJECT} . -part ${XLNX_PRT_ID}
set_property board_part ${XLNX_BRD_ID} [current_project]

create_ip -name axi_crossbar -vendor xilinx.com -library ip \
  -version 2.1 -module_name ${IP_PROJECT}

set_property -dict [ \
eval list \
  CONFIG.NUM_SI "${N_AXI_S}" \
  CONFIG.NUM_MI "${N_AXI_M}" \
  CONFIG.ADDR_WIDTH "${AXI_ADDR_W}" \
  CONFIG.STRATEGY {2} \
  CONFIG.DATA_WIDTH "${AXI_DATA_W}" \
  CONFIG.ID_WIDTH "${AXI_ID_W}" \
  CONFIG.AWUSER_WIDTH "${AXI_USER_W}" \
  CONFIG.ARUSER_WIDTH "${AXI_USER_W}" \
  CONFIG.WUSER_WIDTH "${AXI_USER_W}" \
  CONFIG.RUSER_WIDTH "${AXI_USER_W}" \
  CONFIG.BUSER_WIDTH "${AXI_USER_W}" \
  CONFIG.S00_THREAD_ID_WIDTH {4} \
  CONFIG.S01_THREAD_ID_WIDTH {4} \
  CONFIG.S02_THREAD_ID_WIDTH {4} \
  CONFIG.S03_THREAD_ID_WIDTH {4} \
  CONFIG.S04_THREAD_ID_WIDTH {4} \
  CONFIG.S05_THREAD_ID_WIDTH {4} \
  CONFIG.S06_THREAD_ID_WIDTH {4} \
  CONFIG.S07_THREAD_ID_WIDTH {4} \
  CONFIG.S08_THREAD_ID_WIDTH {4} \
  CONFIG.S09_THREAD_ID_WIDTH {4} \
  CONFIG.S10_THREAD_ID_WIDTH {4} \
  CONFIG.S11_THREAD_ID_WIDTH {4} \
  CONFIG.S12_THREAD_ID_WIDTH {4} \
  CONFIG.S13_THREAD_ID_WIDTH {4} \
  CONFIG.S14_THREAD_ID_WIDTH {4} \
  CONFIG.S15_THREAD_ID_WIDTH {4} \
  CONFIG.S00_WRITE_ACCEPTANCE {4} \
  CONFIG.S01_WRITE_ACCEPTANCE {4} \
  CONFIG.S02_WRITE_ACCEPTANCE {4} \
  CONFIG.S03_WRITE_ACCEPTANCE {4} \
  CONFIG.S04_WRITE_ACCEPTANCE {4} \
  CONFIG.S05_WRITE_ACCEPTANCE {4} \
  CONFIG.S06_WRITE_ACCEPTANCE {4} \
  CONFIG.S07_WRITE_ACCEPTANCE {4} \
  CONFIG.S08_WRITE_ACCEPTANCE {4} \
  CONFIG.S09_WRITE_ACCEPTANCE {4} \
  CONFIG.S10_WRITE_ACCEPTANCE {4} \
  CONFIG.S11_WRITE_ACCEPTANCE {4} \
  CONFIG.S12_WRITE_ACCEPTANCE {4} \
  CONFIG.S13_WRITE_ACCEPTANCE {4} \
  CONFIG.S14_WRITE_ACCEPTANCE {4} \
  CONFIG.S15_WRITE_ACCEPTANCE {4} \
  CONFIG.S00_READ_ACCEPTANCE {4} \
  CONFIG.S01_READ_ACCEPTANCE {4} \
  CONFIG.S02_READ_ACCEPTANCE {4} \
  CONFIG.S03_READ_ACCEPTANCE {4} \
  CONFIG.S04_READ_ACCEPTANCE {4} \
  CONFIG.S05_READ_ACCEPTANCE {4} \
  CONFIG.S06_READ_ACCEPTANCE {4} \
  CONFIG.S07_READ_ACCEPTANCE {4} \
  CONFIG.S08_READ_ACCEPTANCE {4} \
  CONFIG.S09_READ_ACCEPTANCE {4} \
  CONFIG.S10_READ_ACCEPTANCE {4} \
  CONFIG.S11_READ_ACCEPTANCE {4} \
  CONFIG.S12_READ_ACCEPTANCE {4} \
  CONFIG.S13_READ_ACCEPTANCE {4} \
  CONFIG.S14_READ_ACCEPTANCE {4} \
  CONFIG.S15_READ_ACCEPTANCE {4} \
  CONFIG.M00_WRITE_ISSUING {8} \
  CONFIG.M01_WRITE_ISSUING {8} \
  CONFIG.M02_WRITE_ISSUING {8} \
  CONFIG.M03_WRITE_ISSUING {8} \
  CONFIG.M04_WRITE_ISSUING {8} \
  CONFIG.M05_WRITE_ISSUING {8} \
  CONFIG.M06_WRITE_ISSUING {8} \
  CONFIG.M07_WRITE_ISSUING {8} \
  CONFIG.M08_WRITE_ISSUING {8} \
  CONFIG.M09_WRITE_ISSUING {8} \
  CONFIG.M10_WRITE_ISSUING {8} \
  CONFIG.M11_WRITE_ISSUING {8} \
  CONFIG.M12_WRITE_ISSUING {8} \
  CONFIG.M13_WRITE_ISSUING {8} \
  CONFIG.M14_WRITE_ISSUING {8} \
  CONFIG.M15_WRITE_ISSUING {8} \
  CONFIG.M00_READ_ISSUING {8} \
  CONFIG.M01_READ_ISSUING {8} \
  CONFIG.M02_READ_ISSUING {8} \
  CONFIG.M03_READ_ISSUING {8} \
  CONFIG.M04_READ_ISSUING {8} \
  CONFIG.M05_READ_ISSUING {8} \
  CONFIG.M06_READ_ISSUING {8} \
  CONFIG.M07_READ_ISSUING {8} \
  CONFIG.M08_READ_ISSUING {8} \
  CONFIG.M09_READ_ISSUING {8} \
  CONFIG.M10_READ_ISSUING {8} \
  CONFIG.M11_READ_ISSUING {8} \
  CONFIG.M12_READ_ISSUING {8} \
  CONFIG.M13_READ_ISSUING {8} \
  CONFIG.M14_READ_ISSUING {8} \
  CONFIG.M15_READ_ISSUING {8} \
  CONFIG.S01_BASE_ID {0x00000010} \
  CONFIG.S02_BASE_ID {0x00000020} \
  CONFIG.S03_BASE_ID {0x00000030} \
  CONFIG.S04_BASE_ID {0x00000040} \
  CONFIG.S05_BASE_ID {0x00000050} \
  CONFIG.S06_BASE_ID {0x00000060} \
  CONFIG.S07_BASE_ID {0x00000070} \
  CONFIG.S08_BASE_ID {0x00000080} \
  CONFIG.S09_BASE_ID {0x00000090} \
  CONFIG.S10_BASE_ID {0x000000a0} \
  CONFIG.S11_BASE_ID {0x000000b0} \
  CONFIG.S12_BASE_ID {0x000000c0} \
  CONFIG.S13_BASE_ID {0x000000d0} \
  CONFIG.S14_BASE_ID {0x000000e0} \
  CONFIG.S15_BASE_ID {0x000000f0} \
  CONFIG.M00_A00_BASE_ADDR "${BASE_ADDR_DBGM}" \
  CONFIG.M01_A00_BASE_ADDR "${BASE_ADDR_QSPI}" \
  CONFIG.M02_A00_BASE_ADDR "${BASE_ADDR_GPIO}" \
  CONFIG.M03_A00_BASE_ADDR "${BASE_ADDR_TIMR}" \
  CONFIG.M04_A00_BASE_ADDR "${BASE_ADDR_DRAM}" \
  CONFIG.M05_A00_BASE_ADDR "${BASE_ADDR_UART}" \
  CONFIG.M00_A00_ADDR_WIDTH {12} \
  CONFIG.M01_A00_ADDR_WIDTH {12} \
  CONFIG.M02_A00_ADDR_WIDTH {12} \
  CONFIG.M03_A00_ADDR_WIDTH {12} \
  CONFIG.M04_A00_ADDR_WIDTH {18} \
  CONFIG.M05_A00_ADDR_WIDTH {13} \
] [get_ips ${IP_PROJECT}]

generate_target {all} \
    [get_files  ${IP_PROJECT}.srcs/sources_1/ip/${IP_PROJECT}/${IP_PROJECT}.xci]

create_ip_run \
    [get_files -of_objects [get_fileset sources_1] ${IP_PROJECT}.srcs/sources_1/ip/${IP_PROJECT}/${IP_PROJECT}.xci]

launch_run -jobs 8 ${IP_PROJECT}_synth_1
wait_on_run ${IP_PROJECT}_synth_1

puts "\n---------------------------------------------------------"
puts "axi_xbar_128_ip_run.tcl - Complete!"
puts "---------------------------------------------------------\n"

# ------------------------------------------------------------------------------
# End of Script
# ------------------------------------------------------------------------------