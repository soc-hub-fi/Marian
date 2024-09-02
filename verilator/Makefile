######################################################################
# Marian verilator makefile
# Author(s): Tom Szymkowiak (thomas.szymkowiak@tuni.fi)
# Project: SoC-HUB
# Chip: Bow
######################################################################

ifneq ($(words $(CURDIR)),1)
 $(error Unsupported: GNU Make cannot build in directories containing spaces, build elsewhere: '$(CURDIR)')
endif

BUILD_DIR       ?= $(realpath $(CURDIR))/../build
SRC_DIR         ?= $(realpath $(CURDIR))/../src
VERIL_DIR       ?= $(realpath $(CURDIR))/../verilator
VERIL_BUILD_DIR ?= $(BUILD_DIR)/verilator_build
VERIL_LOG       ?= $(VERIL_BUILD_DIR)/verilate.log
VERIL_ERR_LOG   ?= $(VERIL_BUILD_DIR)/verilate_err.log

# if VERILATOR_ROOT is undefined, assume that it is in PATH
ifeq ($(VERILATOR_ROOT),)
VERILATOR = verilator
VERILATOR_COVERAGE = verilator_coverage
else
export VERILATOR_ROOT
VERILATOR = $(VERILATOR_ROOT)/bin/verilator
VERILATOR_COVERAGE = $(VERILATOR_ROOT)/bin/verilator_coverage
endif

TOP_MODULE ?= marian_tb_verilator
VERIL_TOP  ?= $(VERIL_DIR)/$(TOP_MODULE).cpp

# Load L2 using readmem
L2_INIT_METHOD := FILE

# Used to size the BootRAM within Marian (must be a power of 2)
# BootRAM SRAM is 128b wide, so memory size = (L2_NUM_ROWS * 128)/8
L2_NUM_ROWS    ?= 65536 

# clock period
CLK_PERIOD ?= 13.333

# memory initialisation file used for L2
TEST               ?= hello_world
TEST_FILE          := $(BUILD_DIR)/../sw/hex/$(TEST).hex
CVA6_L2_INIT_FILE  := $(BUILD_DIR)/memory_init/test_init.mem
# results file when running in ideal dispatcher mode
IDEAL_RESULTS_FILE := $(BUILD_DIR)/ideal_results_veril.log
# used for ideal_dispatcher fifo
VTRACE_FILE        ?= $(BUILD_DIR)/../sw/ideal_dispatcher/dispatch.hex
N_VINSN            ?=

VERIL_WARN_SUPPRESS ?= \
  -Wno-BLKANDNBLK      \
  -Wno-CASEINCOMPLETE  \
  -Wno-CMPCONST        \
  -Wno-LATCH           \
  -Wno-LITENDIAN       \
  -Wno-UNOPTFLAT       \
  -Wno-UNPACKED        \
  -Wno-UNSIGNED        \
  -Wno-WIDTH           \
  -Wno-WIDTHCONCAT     \
  -Wno-ENUMVALUE       \
  -Wno-COMBDLY         \
	-Wno-TIMESCALEMOD
       
VERIL_DEFINES ?= \
	+define+L2_INIT_METHOD=$(L2_INIT_METHOD) \
	+define+L2_MEM_INIT_FILE=$(CVA6_L2_INIT_FILE) \
	+define+IDEAL_RESULTS_FILE=$(IDEAL_RESULTS_FILE) \
  +define+NR_LANES=4 \
  +define+RVV_ARIANE=1 \
  +define+VLEN=512 \
	+define+WT_DCACHE=1 \
	+define+VERILATOR=1 \
	+define+L2_NUM_ROWS=$(L2_NUM_ROWS) \
	+define+SIM_UART=1 \
	+define+CLK_PERIOD=$(CLK_PERIOD)

# set parameters for ideal dispatch
ifdef IDEAL_DISPATCH
VERIL_DEFINES += \
	+define+VTRACE=$(VTRACE_FILE) \
	+define+V_INSN=$(V_INSN) \
	+define+IDEAL_DISPATCHER=1
endif

VERIL_INCLUDES ?= \
  +incdir+../ips/pulp_apb/include/ \
  +incdir+../ips/bow_common_ips/ips/axi/include/ \
  +incdir+../ips/bow_common_ips/ips/pulp-common-cells/include/ \
  +incdir+../ips/pulp_ara/hardware/include/ \
	+incdir+../ips/pulp_reg_if/include/

RTL_SRC_LIST ?= $(SRC_DIR)/vector_crypto_ss-v-hdl-files.list
TB_SRC_LIST  ?= $(SRC_DIR)/tb-v-hdl-files.list


VERIL_FLAGS ?= \
	-f $(VERIL_DIR)/ver_file.list \
	$(VERIL_DEFINES) \
	$(VERIL_INCLUDES) \
	$(VERIL_PARAMS) \
	$(VERIL_WARN_SUPPRESS) \
	-O3 \
	-sv \
	--timing \
	--trace \
	--trace-structs \
	--trace-params \
	--hierarchical \
	$(VERIL_DIR)/$(TOP_MODULE).vlt \
	--exe --cc \
	$(VERIL_TOP) \
	--top-module $(TOP_MODULE) \
	--Mdir $(VERIL_BUILD_DIR) \
	--build \
	-j 8


.PHONY: init
init:
	@mkdir -p $(BUILD_DIR)
	@mkdir -p $(VERIL_BUILD_DIR)
	@rm -f $(CVA6_L2_INIT_FILE)
	@mkdir -p $(BUILD_DIR)/memory_init
	@echo "Copying $(TEST_FILE) into $(CVA6_L2_INIT_FILE)"
	@cp -f $(TEST_FILE) $(CVA6_L2_INIT_FILE)


.PHONY: verilate
verilate: clean init
	$(VERILATOR) $(VERIL_FLAGS)


.PHONY: simv
simv: init
	cd $(VERIL_BUILD_DIR) && \
	./V$(TOP_MODULE)


.PHONY: clean
clean:
	@rm -rf $(VERIL_BUILD_DIR)
