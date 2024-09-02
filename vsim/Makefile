######################################################################
# Marian local vsim makefile
# Author(s): Matti Käyrä (Matti.kayra@tuni.fi)
#						 Tom Szymkowiak (thomas.szymkowiak@tuni.fi)
#
######################################################################
BUILD_DIR ?= $(realpath $(CURDIR)/../build)
START_TIME=`date +%F_%H:%M:%S`
DATE=`date +%F`

SHELL = bash

SRC_DIR    := $(BUILD_DIR)/../src
SCRIPT_DIR := $(BUILD_DIR)/../scripts

# top design for simulation
TOP_MODULE ?= marian_tb
# custom .do file
VSIM_DOFILE := ../vsim/do_files/marian_tb.do
# generate a .wlf in run-batch if this is set to 1
GEN_WLF ?= 0
WLF =
ifeq ($(GEN_WLF), 1)
WLF := -wlf $(TOP_MODULE)_waves.wlf
endif

# L2 initialisation method, valid options are:
# - FILE : Directly initialises L2 memory directly from hex file
# - JTAG : Performs JTAG TAP tests and loads L2 memory with hex using JTAG 
L2_INIT_METHOD ?= FILE

# Used to size the BootRAM within Marian (must be a power of 2)
# BootRAM SRAM is 128b wide, so memory size = (L2_NUM_ROWS * 128)/8
# Target memory size for Marian is ~250kB
# However, regression tests from Ara require a larger memory in simulation
ifdef SIM_MEM
L2_NUM_ROWS ?= 65536
else
L2_NUM_ROWS ?= 16384
endif

# clock period
CLK_PERIOD ?= 13.333

# memory initialisation file used for L2
TEST               ?= hello_world
TEST_FILE          := $(BUILD_DIR)/../sw/hex/$(TEST).hex
CVA6_L2_INIT_FILE  := $(BUILD_DIR)/memory_init/test_init.mem
# results file when running in ideal dispatcher mode
IDEAL_RESULTS_FILE := $(BUILD_DIR)/ideal_results_questa.log
# used for ideal_dispatcher fifo
VTRACE_FILE        ?= $(BUILD_DIR)/../sw/ideal_dispatcher/dispatch.hex
N_VINSN            ?=

# library specific OPTS etc can be appended in actual library target

COMMON_CELLS_INC_DIRS = +incdir+../ips/bow_common_ips/ips/pulp-common-cells/include/
AXI_INC_DIRS = $(COMMON_CELLS_INC_DIRS) +incdir+../ips/bow_common_ips/ips/axi/include/

ARA_INC_DIRS = \
	+incdir+../ips/pulp_apb/include/ \
	+incdir+../ips/bow_common_ips/ips/axi/include/ \
	+incdir+../ips/bow_common_ips/ips/pulp-common-cells/include/ \
	+incdir+../ips/pulp_ara/hardware/include/ \
	+incdir+../ips/pulp_reg_if/include/

LIBS = \
	-L $(BUILD_DIR)/common_cells_lib \
	-L $(BUILD_DIR)/axi_lib \
	-L $(BUILD_DIR)/axi_mem_if_lib \
	-L $(BUILD_DIR)/pll_lib \
	-L $(BUILD_DIR)/common_components_lib \
	-L $(BUILD_DIR)/tech_cells_generic_lib \
	-L $(BUILD_DIR)/vector_crypto_ss_lib \
	-L $(BUILD_DIR)/tb_lib

VOPT_OPTS = "-check_synthesis"
#VOPT_OPTS += "-pedanticerrors"
VOPT_OPTS += "+acc=npr"
#Prints out information where elaboration picks up the module
VOPT_OPTS += "-libverbose=prlib"
VOPT_OPTS += -timescale "1ns / 1ps"

VSIM_OPTS = "-c"

#generally no supresses allowd: need to be approved to be included
VLOG_SUPPRESS = \
	-suppress vlog-2583 \
	-suppress vlog-13314 \
	-suppress vlog-13233

VCOM_SUPPRESS = 

VOPT_SUPPRESS = \
	-suppress vopt-2577 \
	-suppress vopt-2912 \
	-suppress vopt-7033

VSIM_SUPPRESS = \
	-suppress vsim-7033 \
	-suppress vsim-8386

DEFINES = \
	+define+L2_INIT_METHOD=$(L2_INIT_METHOD) \
	+define+L2_MEM_INIT_FILE=$(CVA6_L2_INIT_FILE) \
	+define+IDEAL_RESULTS_FILE=$(IDEAL_RESULTS_FILE) \
	+define+NR_LANES=4 \
	+define+RVV_ARIANE=1 \
	+define+VLEN=512 \
	+define+WT_DCACHE=1 \
	+define+L2_NUM_ROWS=$(L2_NUM_ROWS) \
	+define+CLK_PERIOD=$(CLK_PERIOD) 
	

 #don't use mock uart
ifndef REAL_UART
DEFINES += \
	+define+SIM_UART=1
endif

ifdef EXT_AXI_TEST
DEFINES += \
	+define+EXT_AXI_TEST=1
endif

ifdef SPI_TEST #run spi slave driver
DEFINES += \
	+define+SPI_TEST=1
endif

# set parameters for ideal dispatch
ifdef IDEAL_DISPATCH
DEFINES += \
	+define+VTRACE=$(VTRACE_FILE) \
	+define+V_INSN=$(V_INSN) \
	+define+IDEAL_DISPATCHER=1
endif

# run debug module tests (this only work when L2 is initialised using JTAG)
ifdef DM_TESTS
DEFINES += \
	+define+DM_TESTS=1
endif

# if using synthesisable memory models
ifdef SYNTH_MEM
DEFINES += \
  +define+SYNTH_MEM=1 \
	+define+ARM_UD_MODEL \
	+define+ARM_DISABLE_EMA_CHECK \
	+define+NO_SDTC
endif

# copy selected test file into common location for simulation
.PHONY: mem_init
mem_init:
	@rm -f $(CVA6_L2_INIT_FILE)
	@mkdir -p $(BUILD_DIR)/memory_init
	@echo "Copying $(TEST_FILE) into $(CVA6_L2_INIT_FILE)"
	@cp -f $(TEST_FILE) $(CVA6_L2_INIT_FILE)

PHONY: check_env
check_env:
	mkdir -p $(BUILD_DIR)/logs/compile
	mkdir -p $(BUILD_DIR)/logs/opt
	mkdir -p $(BUILD_DIR)/logs/sim


# This target is used to map the compiled libraries correctly for vsim
.PHONY: library_mapping
library_mapping: check_env
	vmap vector_crypto_ss_lib $(BUILD_DIR)/vector_crypto_ss_lib
	vmap tb_lib $(BUILD_DIR)/tb_lib
	vmap common_cells_lib $(BUILD_DIR)/common_cells_lib
	vmap axi_lib $(BUILD_DIR)/axi_lib
	vmap axi_mem_if_lib $(BUILD_DIR)/axi_mem_if_lib
	vmap pll_lib $(BUILD_DIR)/pll_lib
	vmap common_components_lib $(BUILD_DIR)/common_components_lib
	vmap tech_cells_generic_lib $(BUILD_DIR)/tech_cells_generic_lib
	vmap vector_crypto_ss_lib $(BUILD_DIR)/vector_crypto_ss_lib
	vmap tb_lib $(BUILD_DIR)/tb_lib


.PHONY: compile_bow_common_lib
compile_bow_common_lib:
	$(MAKE) -C ../ips/bow_common_ips/vsim compile BUILD_DIR=$(BUILD_DIR)


.PHONY: compile_vector_crypto_ss_lib
compile_vector_crypto_ss_lib:
	vlib $(BUILD_DIR)/vector_crypto_ss_lib
	vmap vector_crypto_ss_lib $(BUILD_DIR)/vector_crypto_ss_lib
	vlog -sv -work vector_crypto_ss_lib \
	$(DEFINES) \
	$(ARA_INC_DIRS) \
	-f $(SRC_DIR)/vector_crypto_ss-v-hdl-files.list \
	-l $(BUILD_DIR)/logs/compile/$(START_TIME)_vector_crypto_ss_lib_verilog_vlog.log


.PHONY: compile_tb_lib
compile_tb_lib:
	vlib $(BUILD_DIR)/tb_lib
	vmap tb_lib $(BUILD_DIR)/tb_lib
	vlog -sv -work tb_lib \
	$(VLOG_SUPPRESS) \
	$(DEFINES) \
	$(ARA_INC_DIRS) \
	-f $(SRC_DIR)/tb-v-hdl-files.list \
	-l $(BUILD_DIR)/logs/compile/$(START_TIME)_tb_lib_verilog_vlog.log


.PHONY: compile
compile: check_env compile_bow_common_lib compile_vector_crypto_ss_lib compile_tb_lib
	@echo "Compilation Complete"


.PHONY: compile_tieoff
compile_tieoff: check_env
	cd $(BUILD_DIR)
	vlog -sv $(SRC_DIR)/wrapper/vector_crypto_ss_wrapper_tieoff.v \
	-l $(BUILD_DIR)/logs/compile/vlog-tieoff.log

.PHONY: elaborate
elaborate: check_env library_mapping
	cd $(BUILD_DIR)
	vopt \
	$(VOPT_OPTS) \
	$(VOPT_SUPPRESS) \
	$(VSIM_SUPPRESS) \
	$(LIBS) \
	-work $(BUILD_DIR)/tb_lib \
	$(TOP_MODULE) \
	-o $(TOP_MODULE)_opt \
	-l $(BUILD_DIR)/logs/opt/$(START_TIME)_$(TOP_MODULE)_vopt.log


.PHONY: dut_sanity_check
dut_sanity_check: mem_init
	cd $(BUILD_DIR)
	vsim \
	$(VSIM_OPTS) \
	$(VOPT_SUPPRESS) \
	$(VSIM_SUPPRESS) \
	$(LIBS) \
	-work $(BUILD_DIR)/tb_lib \
	$(TOP_MODULE)_opt \
	-do "run 0; exit" \
	-l $(BUILD_DIR)/logs/sim/$(START_TIME)_$(TOP_MODULE)_vsim.log


.PHONY: run-gui
run-gui: check_env mem_init
	cd $(BUILD_DIR) && \
	vsim \
	$(VOPT_SUPPRESS) \
	$(VSIM_SUPPRESS) \
	$(LIBS) \
	-work $(BUILD_DIR)/tb_lib \
	$(WLF) \
	$(TOP_MODULE)_opt \
	-onfinish stop \
	-do $(VSIM_DOFILE)
	cp $(BUILD_DIR)/transcript $(BUILD_DIR)/logs/sim/$(START_TIME)_$(TOP_MODULE)_vsim.log


.PHONY: run-batch
run-batch: check_env mem_init
	cd $(BUILD_DIR) && \
	vsim \
	$(VSIM_OPTS) \
	$(VSIM_SUPPRESS) \
	$(LIBS) \
	-work $(BUILD_DIR)/tb_lib \
	$(WLF) \
	$(TOP_MODULE)_opt \
	-do $(VSIM_DOFILE)
	cp $(BUILD_DIR)/transcript $(BUILD_DIR)/logs/sim/$(START_TIME)_$(TOP_MODULE)_vsim.log

.PHONY: CI_result_check
CI_result_check:
	$(SCRIPT_DIR)/return_status.sh $(BUILD_DIR)/transcript
