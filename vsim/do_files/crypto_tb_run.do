#############
# VARIABLES #
#############

# NOTE: replace example names with your design names!

# list of source files to be compiled
set TB_FILES " \
  ../src/tb/crypto_if.sv \
  ../src/tb/crypto_unit_tb.sv \
"

set PKG_FILES " \
  ../ips/bow_common_ips/ips/pulp-common-cells/src/cb_filter_pkg.sv \
  ../ips/bow_common_ips/ips/pulp-common-cells/src/cf_math_pkg.sv \
  ../ips/bow_common_ips/ips/pulp-common-cells/src/ecc_pkg.sv \
  ../ips/pulp_apb/src/apb_pkg.sv \
  ../ips/bow_common_ips/ips/axi/src/axi_pkg.sv \
  ../ips/bow_common_ips/ips/common_verification/src/rand_id_queue.sv \
  ../ips/bow_common_ips/ips/axi/src/axi_test.sv \
  ../src/ip/include/riscv_pkg.sv \
  ../ips/pulp_rv_dbg/src/dm_pkg.sv \
  ../ips/pulp_cva6/src/fpu/src/fpnew_pkg.sv \
  ../ips/pulp_cva6/include/ariane_pkg.sv \
  ../ips/pulp_cva6/include/std_cache_pkg.sv \
  ../ips/pulp_cva6/include/wt_cache_pkg.sv \
  ../ips/pulp_cva6/src/register_interface/src/reg_intf_pkg.sv \
  ../src/ip/include/rvv_pkg.sv \
  ../src/ip/include/ara_pkg.sv \
  ../src/ip/include/marian_pkg.sv \
  ../ips/pulp_cva6/include/instr_tracer_pkg.sv \
  ../src/tb/include/marian_jtag_pkg.sv \
  ../src/tb/include/crypto_unit_tb_pkg.sv \
"

set SRC_FILES " \
  ../src/ip/crypto/aes/src/canright_sbox.sv \
  ../src/ip/crypto/aes/src/key_expansion.sv \
  ../src/ip/crypto/aes/src/encdec.sv \
  ../src/ip/crypto/sha2/src/compression.sv \
  ../src/ip/crypto/sha2/src/msg_schedule.sv \
  ../src/ip/crypto/gcm/src/add_mult_ghash.sv \
  ../src/ip/crypto/gcm/src/mult_ghash.sv \
  ../src/ip/marian/crypto_unit/aes.sv \
  ../src/ip/marian/crypto_unit/gcm.sv \
  ../src/ip/marian/crypto_unit/sha.sv \
  ../src/ip/marian/crypto_unit/write_back.sv \
  ../src/ip/marian/crypto_unit/execution_units.sv \
  ../src/ip/marian/crypto_unit/operand_collector.sv \
  ../src/ip/marian/crypto_unit/crypto_unit.sv \
"

set DEFINES " \
	+define+NR_LANES=4 \
  +define+RVV_ARIANE=1 \
	+define+VLEN=512 \
	+define+WT_DCACHE=1 \
"

set INC_DIRS " \
  +incdir+../ips/pulp_apb/include \
	+incdir+../ips/bow_common_ips/ips/axi/include \
	+incdir+../ips/bow_common_ips/ips/pulp-common-cells/include \
	+incdir+../ips/pulp_ara/hardware/include \
<<<<<<< HEAD
  +incdir+../ips/pulp_reg_if/include/
=======
  +incdir+../ips/pulp_reg_if/include \
>>>>>>> c157db9c9aaf42702c9fb0c5ef9af457d502bced
"

set VLOG_SUPPRESS " \
	-suppress vlog-2583 \
	-suppress vlog-13314 \
	-suppress vlog-13233 \
"

set VOPT_OPTS "
  -check_synthesis \
  +acc=npr \
  -libverbose=prlib \
  -timescale \"1ns / 1ps\" \
"

set VOPT_SUPPRESS " \
	-suppress vlog-2583 \
	-suppress vlog-13314 \
	-suppress vlog-13233 \
"

set LIBS " \
	-L common_cells_lib \
	-L axi_lib \
	-L axi_mem_if_lib \
	-L pll_lib \
	-L common_components_lib \
	-L tech_cells_generic_lib \
	-L vector_crypto_ss_lib \
	-L tb_lib \
"

set VSIM_SUPPRESS " \
	-suppress vsim-7033 \
	-suppress vsim-8386
"

# name of top level entity (target for simulation)
set TOP_MODULE crypto_unit_tb


# wave file name
set WAVE_FILE "wave_test1.do"

############
# COMMANDS #
############

# compile
eval vlog \
  -sv \
  -work vector_crypto_ss_lib \
  ${VLOG_SUPPRESS} \
  ${DEFINES} \
  ${INC_DIRS} \
  ${PKG_FILES} \
  ${SRC_FILES} \
  ${TB_FILES}

eval vlog \
  -sv \
  -work tb_lib \
  ${VLOG_SUPPRESS} \
  ${DEFINES} \
  ${INC_DIRS} \
  ${PKG_FILES} \
  ${TB_FILES}

# elaborate
eval vopt \
	${VOPT_OPTS} \
	${VOPT_SUPPRESS} \
	${LIBS} \
	-work tb_lib \
	${TOP_MODULE} \
	-o ${TOP_MODULE}_opt

# simulate
vmap work tb_lib
eval vsim \
  ${VSIM_SUPPRESS} \
  ${LIBS} \
  -wlf ${TOP_MODULE}.wlf \
  ${TOP_MODULE}_opt \
  -onfinish stop

log -r /*

add wave -group  TB  sim:/crypto_unit_tb/i_dut/*
add wave -group  DUT sim:/crypto_unit_tb/i_dut/*
add wave -group  execution_units sim:/crypto_unit_tb/i_dut/i_execution_units/*
add wave -group  write_back sim:/crypto_unit_tb/i_dut/i_write_back/*
add wave -expand -group  operand_collector sim:/crypto_unit_tb/i_dut/i_operand_collector/*
add wave -group  operand_collector -expand -group operand_0 {sim:/crypto_unit_tb/i_dut/i_operand_collector/gen_operand_logic[0]/*}
add wave -group  operand_collector -expand -group operand_1 {sim:/crypto_unit_tb/i_dut/i_operand_collector/gen_operand_logic[1]/*}
add wave -group  operand_collector -expand -group operand_2 {sim:/crypto_unit_tb/i_dut/i_operand_collector/gen_operand_logic[2]/*}
add wave -group  encdec sim:/crypto_unit_tb/i_dut/i_execution_units/i_aes/i_encdec/*
add wave -group  sha sim:/crypto_unit_tb/i_dut/i_execution_units/i_sha/*
add wave -group  sha_compression  sim:/crypto_unit_tb/i_dut/i_execution_units/i_sha/i_compression/*
add wave -group  sha_msg_schedule sim:/crypto_unit_tb/i_dut/i_execution_units/i_sha/i_msg_schedule/*
add wave -group  gcm sim:/crypto_unit_tb/i_dut/i_execution_units/i_gcm/*
add wave -group  gcm_add_mult sim:/crypto_unit_tb/i_dut/i_execution_units/i_gcm/i_add_mult_ghash/*
add wave -group  gcm_mult sim:/crypto_unit_tb/i_dut/i_execution_units/i_gcm/i_mult_ghash/*

# run simulation
run 100us

configure wave -namecolwidth 236
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us

wave zoom full
configure wave -signalnamewidth 1

## log all signals
#add log -r sim:/*
#
## prevent unwanted warnings
#set StdArithNoWarnings 1 
#run 0 ns 
#set StdArithNoWarnings 0
#
## call wave.do file
#do ${WAVE_FILE}
#
## run simulation
#run ${SIM_RUNTIME}
#
## resize wave window to show the whole wave
#wave zoom full
