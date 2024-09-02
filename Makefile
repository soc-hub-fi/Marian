######################################################################
# Marian top-level makefile
# Author(s): Matti Käyrä (Matti.kayra@tuni.fi)
#            Tom Szymkowiak (thomas.szymkowiak@tuni.fi)
# Project: SoC-HUB
# Chip: Bow
######################################################################

START_TIME=`date +%F_%H:%M`
DATE=`date +%F`

SHELL=bash
BUILD_DIR ?= $(realpath $(CURDIR))/build

######################################################################
# Makefile common setup
######################################################################

START_TIME=`date +%F_%H:%M`
SHELL=bash

######################################################################
# Repository targets
######################################################################

repository_init: 
	git fetch 
	git submodule foreach 'git stash' # stash is to avoid override by accident
	git -c submodule."toolchain/riscv-gnu-toolchain".update=none \
      -c submodule."toolchain/riscv-isa-sim".update=none \
      -c submodule."toolchain/verilator".update=none \
      -c submodule."hardware/deps/apb".update=none \
      -c submodule."hardware/deps/axi".update=none \
      -c submodule."hardware/deps/common_cells".update=none \
      -c submodule."hardware/deps/tech_cells_generic".update=none \
      -c submodule."hardware/deps/common_verification".update=none \
      -c submodule."hardware/deps/cva6".update=none \
      -c submodule."toolchain/newlib".update=none \
      -c submodule."toolchain/riscv-llvm".update=none \
      -c submodule."src/axi".update=none \
      -c submodule."src/axi_node".update=none \
      -c submodule."src/axi_riscv_atomics".update=none \
      -c submodule."src/clint".update=none \
      -c submodule."src/common_cells".update=none \
      -c submodule."src/fpga-support".update=none \
      -c submodule."src/riscv_dbg".update=none \
      -c submodule."src/rv_plic".update=none \
      -c submodule."src/tech_cells_generic".update=none \
      -c submodule."fpga/src/apb_uart".update=none \
      -c submodule."fpga/src/apb_node".update=none \
      -c submodule."fpga/src/axi2apb".update=none \
      -c submodule."fpga/src/axi_slice".update=none \
      -c submodule."fpga/src/ariane-ethernet".update=none \
      -c submodule."fpga/src/apb_timer".update=none \
      submodule update --init --recursive # exclude large and unnecessary submodules to save time

.PHONY: check-env
check-env:
	mkdir -p $(BUILD_DIR)/logs/compile
	mkdir -p $(BUILD_DIR)/logs/opt
	mkdir -p $(BUILD_DIR)/logs/sim

######################################################################
# sw build targets 
######################################################################

.PHONY: hex
hex:
	$(MAKE) -C sw compile_sw

######################################################################
# hw build targets 
######################################################################

.PHONY: compile
compile:
	$(MAKE) -C vsim compile BUILD_DIR=$(BUILD_DIR)

.PHONY: compile_tieoff
compile_tieoff:
	$(MAKE) -C vsim compile_tieoff BUILD_DIR=$(BUILD_DIR)

.PHONY: elaborate
elaborate:
	$(MAKE) -C vsim elaborate BUILD_DIR=$(BUILD_DIR)

.PHONY: elab_syn
elab_syn: check-env
	$(MAKE) -C syn elab_syn

.PHONY: elab_lec
elab_lec: check-env
	$(MAKE) -C syn elab_lec

.PHONY: verilate
verilate:
	$(MAKE) -C verilator verilate

######################################################################
# formal targets 
######################################################################

.PHONY: autocheck
autocheck: check-env
	$(MAKE) -C formal qverify_autocheck

.PHONY: xcheck
xcheck: check-env
	$(MAKE) -C formal qverify_xcheck

.PHONY: formal
formal: check-env
	$(MAKE) -C formal qverify_formal

.PHONY: check_formal_result
check_formal_result: check-env
	$(MAKE) -C formal check_formal_result

#########
# hw sim
#########

.PHONY: sanity_check
sanity_check: check-env
	$(MAKE) -C vsim dut_sanity_check

.PHONY: sim
sim:
	$(MAKE) -C vsim run-gui

.PHONY: simc
simc:
	$(MAKE) -C vsim run-batch

.PHONY: simv
simv:
	$(MAKE) -C verilator simv

######################################################################
# CI pipeline variables  targets 
######################################################################

.PHONY: echo_success
echo_success:
	echo -e "\n\n##################################################\n\n OK! \n\n##################################################\n"

.PHONY: CI_result_check
CI_result_check:
	$(MAKE) -C vsim CI_result_check

######################################################################
# clean targets
######################################################################

.PHONY: clean
clean:
	rm -rf build

.PHONY: clean_sw
clean_sw:
	$(MAKE) -C sw clean_all


