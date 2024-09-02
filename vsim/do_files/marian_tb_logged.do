################################################################################
# Title       : marian_tb_logged.do
# Description : Questa .do file for running vector-crypto-ss testbench.
#               All signals are logged by default
# Author(s)   : Tom Szymkowiak (thomas.szymkowiak@tuni.fi) 
################################################################################

add log -r sim:/*;

set StdArithNoWarnings 1;
run 0 ns; 
set StdArithNoWarnings 0;

run -all;