# ------------------------------------------------------------------------------
# marian_fpga_common.tcl
#
# Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
# Date     : 23-dec-2023
#
# Description: TCL script containing main variable definitions used across the
# project. 
# ------------------------------------------------------------------------------

puts "\n---------------------------------------------------------";
puts "marian_fpga_common.tcl - Starting...";
puts "---------------------------------------------------------\n";

# check repo path has been defined
if [info exists ::env(REPO_DIR)] {
    set REPO_DIR $::env(REPO_DIR);
} else {
    puts "ERROR - Variable REPO_DIR is not globally defined in Makefile!\n";
    return 1;
}

# check repo path has been defined
if [info exists ::env(FPGA_SIM_DIR)] {
    set FPGA_SIM_DIR $::env(FPGA_SIM_DIR);
} else {
    puts "ERROR - Variable FPGA_SIM_DIR is not globally defined in Makefile!\n";
    return 1;
}

# check that fpga constraints directory has been defined
if [info exists ::env(FPGA_CONSTR_DIR)] {
    set FPGA_CONSTR_DIR $::env(FPGA_CONSTR_DIR);
} else {
    puts "ERROR - Variable FPGA_CONSTR_DIR is not globally defined in Makefile!";
    return 1;
}


# check that fpga board ID has been defined
if [info exists ::env(FPGA_BOARD)] {
    set FPGA_BOARD $::env(FPGA_BOARD);
} else {
    puts "ERROR - Variable FPGA_BOARD is not globally defined in Makefile!";
    puts "Note: Valid values are PYNQZ1, ZCU104 or VCU118.\n";
    return 1;
}


# check top design module has been defined
if [info exists ::env(DUT_TOP_MODULE)] {
    set DUT_TOP_MODULE $::env(DUT_TOP_MODULE);
} else {
    puts "ERROR - Variable DUT_TOP_MODULE is not globally defined in Makefile!\n";
    return 1;
}


# check top testbench module has been defined
if [info exists ::env(TB_TOP_MODULE)] {
    set TB_TOP_MODULE $::env(TB_TOP_MODULE);
} else {
    puts "ERROR - Variable TB_TOP_MODULE is not globally defined in Makefile!\n";
    return 1;
}


# check that synthesis defines have been defined
if [info exists ::env(FPGA_SYNTH_DEFINES)] {
    set FPGA_SYNTH_DEFINES $::env(FPGA_SYNTH_DEFINES);
} else {
    puts "WARNING - Variable FPGA_SYNTH_DEFINES is not globally defined in Makefile and will be set to an empty string!\n";
    set FPGA_SYNTH_DEFINES "";
}


# check that simulation defines have been defined
if [info exists ::env(FPGA_SIM_DEFINES)] {
    set FPGA_SIM_DEFINES $::env(FPGA_SIM_DEFINES);
} else {
    puts "WARNING - Variable FPGA_SIM_DEFINES is not globally defined in Makefile and will be set to an empty string!\n";
    set FPGA_SIM_DEFINES "";
}


# check that top level generics have been defined
if [info exists ::env(FPGA_DUT_PARAMS)] {
    set FPGA_DUT_PARAMS $::env(FPGA_DUT_PARAMS);
} else {
    puts "WARNING - Variable FPGA_DUT_PARAMS is not globally defined in Makefile and will be set to an empty string!\n";
    set FPGA_DUT_PARAMS "";
}


# check that top level generics have been defined
if [info exists ::env(FPGA_TB_PARAMS)] {
    set FPGA_TB_PARAMS $::env(FPGA_TB_PARAMS);
} else {
    puts "WARNING - Variable FPGA_TB_PARAMS is not globally defined in Makefile and will be set to an empty string!\n";
    set FPGA_TB_PARAMS "";
}


# check that IP list has been defined
if [info exists ::env(FPGA_IP_LIST)] {
    set FPGA_IP_LIST $::env(FPGA_IP_LIST);
} else {
    puts "WARNING - Variable FPGA_IP_LIST is not globally defined in Makefile and will be set to an empty string!\n";
    set FPGA_IP_LIST "";
}

# check IP build directory has been defined
if [info exists ::env(FPGA_IP_BUILD_DIR)] {
    set FPGA_IP_BUILD_DIR $::env(FPGA_IP_BUILD_DIR);
} else {
    puts "ERROR - Variable FPGA_IP_BUILD_DIR is not globally defined in Makefile!\n";
    return 1;
}

puts "Project SYNTH Defines: ${FPGA_SYNTH_DEFINES}\n";
puts "Project SIM   Defines: ${FPGA_SIM_DEFINES}\n";
puts "DUT Parameters: ${FPGA_DUT_PARAMS}\n";
puts "Testbench Parameters: ${FPGA_TB_PARAMS}\n";
      
set FPGA_BOARD_CONFIG_SCRIPT ${FPGA_TCL_DIR}/${FPGA_BOARD}.tcl;
set FPGA_SOURCE_FILE_SCRIPT  ${FPGA_TCL_DIR}/${PROJECT_NAME}_src_files.tcl;

puts "\n---------------------------------------------------------";
puts "marian_fpga_common.tcl - Complete!";
puts "---------------------------------------------------------\n";

# ------------------------------------------------------------------------------
# End of Script
# ------------------------------------------------------------------------------