# ------------------------------------------------------------------------------
# VCU118.tcl
#
# Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
# Date     : 03-dec-2023
#
# Description: TCL script containing FPGA board configuration values
# ------------------------------------------------------------------------------

puts "\n---------------------------------------------------------"
puts "VCU118.tcl - Starting..."
puts "---------------------------------------------------------\n"

set XLNX_PRT_ID xcvu9p-flga2104-2L-e
set XLNX_BRD_ID xilinx.com:vcu118:part0:2.0
set INPUT_OSC_FREQ_MHZ 300.000

puts "Board Configuration Parameters are:"
puts "Board Part: ${XLNX_PRT_ID}"
puts "Board ID  : ${XLNX_BRD_ID}"
puts "Clock Freq: ${INPUT_OSC_FREQ_MHZ}Mhz\n"

puts "\n---------------------------------------------------------"
puts "VCU118.tcl - Complete!"
puts "---------------------------------------------------------\n"

# ------------------------------------------------------------------------------
# End of Script
# ------------------------------------------------------------------------------