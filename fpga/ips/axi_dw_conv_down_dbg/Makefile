# ------------------------------------------------------------------------------
# Makefile for IP creation
#
# Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
# Date     : 04-dec-2023
#
# Description: Makefile to be used to build a specific IP
# ------------------------------------------------------------------------------

## global variables
export IP_PROJECT ?=


## local variables
START_TIME =`date +%F_%H:%M`

IP_LOG_DIR := $(FPGA_LOG_DIR)/$(IP_PROJECT)

IP_XCI := $(FPGA_IP_BUILD_DIR)/$(IP_PROJECT)/$(IP_PROJECT).srcs/sources_1/ip/$(IP_PROJECT)/$(IP_PROJECT).xci
IP_TCL := $(FPGA_IP_DIR)/$(IP_PROJECT)/$(IP_PROJECT)_ip_run.tcl

init:
	mkdir -p $(FPGA_IP_BUILD_DIR)


.PHONY: build_ip
build_ip: init $(IP_XCI)


$(IP_XCI): $(IP_TCL)
	@echo "\nRunning build for $(IP_PROJECT)..."
	@echo "Deleting $(FPGA_IP_BUILD_DIR)/$(IP_PROJECT)"
	@rm -rf $(FPGA_IP_BUILD_DIR)/$(IP_PROJECT)
	@mkdir -p $(FPGA_IP_BUILD_DIR)/$(IP_PROJECT)
	@mkdir -p $(IP_LOG_DIR)
	cd $(FPGA_IP_BUILD_DIR)/$(IP_PROJECT) && \
	vivado -mode batch -source $(IP_TCL) -notrace \
	-log $(IP_LOG_DIR)/$(START_TIME)_vivado_$(IP_PROJECT).log \
	-journal $(IP_LOG_DIR)/$(START_TIME)_vivado_$(IP_PROJECT).jou


.PHONY: clean
clean:
	@echo "Deleting $(FPGA_IP_BUILD_DIR)/$(IP_PROJECT)"
	@rm -rf $(FPGA_IP_BUILD_DIR)/$(IP_PROJECT)
