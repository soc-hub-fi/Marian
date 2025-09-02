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
	bender update
	bender vendor init

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

.PHONY: clean_build
clean_build:
	rm -rf build

.PHONY: clean_sw
clean_sw:
	$(MAKE) -C sw clean_all

.PHONY: clean_ips
clean_ips:
	rm -fr .bender
	rm -fr src/vendor

.PHONY: clean_all
clean_all: clean_build clean_sw clean_ips


