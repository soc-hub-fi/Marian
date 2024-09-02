################################################################################
# Title       : marian_tb.do
# Description : Questa .do file for running vector-crypto-ss testbench.
#               No signals are logged by default
# Author(s)   : Tom Szymkowiak (thomas.szymkowiak@tuni.fi) 
################################################################################

set StdArithNoWarnings 1;
run 0 ns; 
set StdArithNoWarnings 0;

run -all
