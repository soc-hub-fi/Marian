# ------------------------------------------------------------------------------
# Vector-Crypto Subsystem (Marian) FPGA Makefile
#
# Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
# Date     : 22-dec-2023
#
# Description: Top Makefile for the (Marian) FPGA flow
# ------------------------------------------------------------------------------

## global variables
export SUBSYTEM         ?= marian
export PROJECT_NAME     ?= $(SUBSYTEM)_fpga
export FPGA_BOARD       ?= VCU118
export DUT_TOP_MODULE   ?= marian_fpga_top
export TB_TOP_MODULE    ?= marian_fpga_top_tb

export FPGA_DIR          ?= $(PWD)
export REPO_DIR          ?= $(realpath $(FPGA_DIR)/..)
export FPGA_BUILD_DIR    ?= $(FPGA_DIR)/build
export FPGA_LOG_DIR      ?= $(FPGA_BUILD_DIR)/logs
export FPGA_PROJECT_DIR  ?= $(FPGA_BUILD_DIR)/$(PROJECT_NAME)
export FPGA_TCL_DIR      ?= $(FPGA_DIR)/scripts
export FPGA_IP_DIR       ?= $(FPGA_DIR)/ips
export FPGA_SIM_DIR      ?= $(FPGA_DIR)/sim
export FPGA_IP_BUILD_DIR ?= $(FPGA_BUILD_DIR)/ips
export FPGA_CONSTR_DIR   ?= $(FPGA_DIR)/constraints
export MARIAN_SW_DIR     ?= $(FPGA_DIR)/../sw
export MARIAN_HEX_DIR    ?= $(MARIAN_SW_DIR)/hex
export BOARD_FILES_DIR   ?= $(FPGA_DIR)/board_files

# L2 initialisation method, valid options are:
# - FILE : Directly initialises L2 memory directly from hex file
# - JTAG : Performs JTAG TAP tests and loads L2 memory with hex using JTAG 
L2_INIT_METHOD ?= JTAG

# memory initialisation file used for L2
export TEST              ?= hello_world
export INIT_FILE         := $(MARIAN_HEX_DIR)/loop.hex
export TEST_FILE         := $(MARIAN_HEX_DIR)/$(TEST).hex
# init file will ALWAYS be loaded at start to ensure there is valid code in mem
# test file will overwrite the init code
export CVA6_L2_INIT_FILE := $(FPGA_BUILD_DIR)/memory_init/init.mem
export CVA6_L2_TEST_FILE := $(FPGA_BUILD_DIR)/memory_init/test.mem

# path to Questa Compiled Simulation Libraries
# if Questa simulation is not required, remove this variable
export QUESTA_SIM_LIBS   := /opt/soc/work/tom_szymkowiak/xilinx_libs_2021_2

## IP configuration parameters
# top clock frequency in MHz
export TOP_CLK_FREQ_MHZ := 75
# Depth of L2 memory for BRAM synthesis + simulation (128b wide)
export L2_DEPTH = 16384

# Project synthesis defines
export FPGA_SYNTH_DEFINES ?= \
  L2_MEM_INIT_FILE=$(CVA6_L2_INIT_FILE) \
	L2_MEM_TEST_FILE=$(CVA6_L2_TEST_FILE) \
  NR_LANES=4 \
  RVV_ARIANE=1 \
  VLEN=512 \
  WT_DCACHE=1 \
	FPGA=1 \
	PULP_FPGA_EMUL=1 \
	L2_INIT_METHOD="JTAG" \
	L2_NUM_ROWS=$(L2_DEPTH)

# Project simulation defines
export FPGA_SIM_DEFINES ?= \
  L2_MEM_INIT_FILE=$(CVA6_L2_INIT_FILE) \
	L2_MEM_TEST_FILE=$(CVA6_L2_TEST_FILE) \
  NR_LANES=4 \
  RVV_ARIANE=1 \
  VLEN=512 \
  WT_DCACHE=1 \
	FPGA=1 \
	PULP_FPGA_EMUL=1 \
	L2_NUM_ROWS=$(L2_DEPTH) \
	L2_INIT_METHOD=$(L2_INIT_METHOD) \
	XSIM=1 \
	SIM_UART=1

# Parameters for DUT
export FPGA_DUT_PARAMS ?= 

# Parameters for TB
export FPGA_TB_PARAMS ?=

# List of FPGA IPs used in design
export FPGA_IP_LIST ?= \
	top_clock

## local variables

START_TIME =`date +%F_%H:%M`

TOP_LOG_DIR := $(FPGA_LOG_DIR)/$(PROJECT_NAME)

BITSTREAM   ?= $(FPGA_BUILD_DIR)/$(PROJECT_NAME).bit
# ILA probe file (if exists)
PROBE_FILE  ?= $(FPGA_BUILD_DIR)/$(PROJECT_NAME).ltx
FPGA_IP_XCI := $(foreach ip, $(FPGA_IP_LIST), $(FPGA_IP_BUILD_DIR)/$(ip)/$(ip).srcs)

.PHONY: all
all: clean_all top


.PHONY: init
init:
	@echo "Initialising project $(PROJECT_NAME)"
	@rm -f $(CVA6_L2_INIT_FILE)
	@rm -f $(CVA6_L2_TEST_FILE)
	@mkdir -p $(FPGA_BUILD_DIR)	
	@mkdir -p $(FPGA_BUILD_DIR)/memory_init
	@echo "Copying $(INIT_FILE) into $(CVA6_L2_INIT_FILE)"
	@cp -f $(INIT_FILE) $(CVA6_L2_INIT_FILE)
	@echo "Copying $(TEST_FILE) into $(CVA6_L2_TEST_FILE)"
	@cp -f $(TEST_FILE) $(CVA6_L2_TEST_FILE)


# launch a Vivado project
.PHONY: top
top: init clean_top all_ips
	@rm -f $(BITSTREAM) $(PROBE_FILE)
	@echo "INFO: Building FPGA design for $(PROJECT_NAME)"
	@mkdir -p $(FPGA_PROJECT_DIR)
	@mkdir -p $(TOP_LOG_DIR)
	cd $(FPGA_PROJECT_DIR) && \
	vivado -mode batch -source $(FPGA_TCL_DIR)/$(PROJECT_NAME)_run.tcl -notrace \
	-log $(TOP_LOG_DIR)/$(START_TIME)_vivado_$(PROJECT_NAME).log \
	-journal $(TOP_LOG_DIR)/$(START_TIME)_vivado_$(PROJECT_NAME).jou


.PHONY: all_ips
all_ips: init $(FPGA_IP_LIST)
	@echo "running all_ips recipe for $(PROJECT_NAME)"


$(FPGA_IP_LIST):
	$(MAKE) -C $(FPGA_IP_DIR)/$@ build_ip IP_PROJECT=$@


.PHONY: clean_top
clean_top:
	@echo "INFO: Deleting $(PROJECT_NAME) top build directory and artefacts..."
	@rm -f $(BITSTREAM)
	@rm -f $(PROBE_FILE) 
	@rm -rf $(FPGA_PROJECT_DIR)


.PHONY: clean_ips
clean_ips:
	@echo "INFO: Deleting IP build directory and artefacts..."
	@rm -rf $(FPGA_IP_BUILD_DIR)


.PHONY: clean_all
clean_all:
	@echo "INFO: Deleting build directory..."
	@rm -rf $(FPGA_BUILD_DIR)