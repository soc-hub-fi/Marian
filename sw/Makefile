# ------------------------------------------------------------------------------
# Vector-Crypto Subsystem (Marian) SW Makefile
#
# Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
# Date     : 03-jan-2024
#
# Description: Top Makefile for the software build flow of Marian
# ------------------------------------------------------------------------------

# test to be built
TEST          ?= hello_world
# RISCV GCC install path

# path to tools
RISCV_DIR_GCC  ?=
RISCV_DIR_LLVM ?=
GCC_CC_DIR     := $(RISCV_DIR_GCC)/bin
LLVM_CC_DIR    := $(RISCV_DIR_LLVM)/bin
GCC_CC         ?= $(GCC_CC_DIR)/riscv64-unknown-elf-gcc
CLANG_CC       ?= $(LLVM_CC_DIR)/clang
RISCV_OBJDUMP  ?= $(GCC_CC_DIR)/riscv64-unknown-elf-objdump
PYTHON         ?= python3

## directories
SW_DIR         := $(realpath $(CURDIR))
SRC_DIR        := $(SW_DIR)/src
BIN_DIR        := $(SW_DIR)/bin
DMP_DIR        := $(SW_DIR)/dump
LD_DIR         := $(SW_DIR)/linker_scripts
INC_DIR        := $(SW_DIR)/inc
HEX_DIR        := $(SW_DIR)/hex
TOOLS_DIR      := $(SW_DIR)/tools
COMMON_OBJ_DIR := $(SW_DIR)/obj/common
TEST_OBJ_DIR   := $(SW_DIR)/obj/$(TEST)

COMMON_SRC_DIR := $(SRC_DIR)/common
TEST_DIR       := $(SRC_DIR)/$(TEST)

# get list of all sources (.c, .s, .S) under src/common
COMMON_SRC := \
  $(filter \
	  %.c %.s %.S, \
		$(wildcard $(COMMON_SRC_DIR)/*) \
	)
# get output common object files to be created using GCC or LLVM flow
COMMON_OBJ_GCC  := $(subst $(COMMON_SRC_DIR), $(COMMON_OBJ_DIR), $(COMMON_SRC))
COMMON_OBJ_GCC  := $(COMMON_OBJ_GCC:=_gcc.o)
COMMON_OBJ_LLVM := $(subst $(COMMON_SRC_DIR), $(COMMON_OBJ_DIR), $(COMMON_SRC))
COMMON_OBJ_LLVM := $(COMMON_OBJ_LLVM:=_llvm.o)
# get list of all .c, .s, .S sources under src/<test_name> 
TEST_SRC := $(filter \
	  %.c %.s %.S, \
		$(wildcard $(TEST_DIR)/*) \
	)
# get output test object files to be created using GCC or LLVM flow
TEST_OBJ_GCC  := $(subst $(TEST_DIR), $(TEST_OBJ_DIR), $(TEST_SRC))
TEST_OBJ_GCC  := $(TEST_OBJ_GCC:=_gcc.o)
TEST_OBJ_LLVM := $(subst $(TEST_DIR), $(TEST_OBJ_DIR), $(TEST_SRC))
TEST_OBJ_LLVM := $(TEST_OBJ_LLVM:=_llvm.o)

# build variables
NR_LANES  ?= 4
VLEN      ?= 512
L2_WIDTH  ?= 128
L2_DEPTH  ?= 16384
LD_SCRIPT ?= $(LD_DIR)/link.ld

DEFINES ?= \
  -DNR_LANES=$(NR_LANES) \
  -DVLEN=$(VLEN) \
	-DPRINTF_DISABLE_SUPPORT_EXPONENTIAL \
	-DPRINTF_DISABLE_SUPPORT_FLOAT \
	-DPRINTF_DISABLE_SUPPORT_PTRDIFF_T \
	-DPRINTF_DISABLE_SUPPORT_LONG_LONG

# if we don't want to use the mock UART
ifndef REAL_UART
DEFINES += \
-DSIM_UART
endif

INCLUDES ?= \
	-I$(INC_DIR)

RISCV_CC_WARNS += \
  -Wunused-variable \
  -Wall \
  -Wextra

GCC_CCFLAGS ?= \
  -mcmodel=medany \
	-march=rv64gcv_zvkng_zvbb_zvksed_zvksh \
	-mabi=lp64d \
	$(INCLUDES) \
	-static \
	-std=gnu99 \
	-g \
	-Os \
	-ffast-math \
	-fno-common \
	-fno-builtin-printf \
	-ffreestanding \
	$(DEFINES) \
	$(RISCV_CC_WARNS)

LLVM_CCFLAGS ?= \
  --sysroot=$(RISCV_DIR_GCC)/riscv64-unknown-elf \
	--target=riscv64-unknown-elf \
  -mcmodel=medany \
	-menable-experimental-extensions \
	-march=rv64gcv_zvbb1p0_zvbc1p0_zvkg1p0_zvkned1p0_zvknhb1p0_zvksed1p0_zvksh1p0 \
	-mabi=lp64d \
	-mno-relax \
	-fno-vectorize \
	-Xclang	-target-feature \
	-Xclang +no-optimized-zero-stride-load \
	$(INCLUDES) \
	-static \
	-std=gnu99 \
	-g \
	-Os \
	-ffast-math \
	-fno-common \
	-fno-builtin-printf \
	$(DEFINES) \
	$(RISCV_CC_WARNS)

RISCV_LDFLAGS_LLVM ?= \
	-lm \
	-Wl,--gc-sections \
	-fuse-ld=lld \
	$(LLVM_CCFLAGS) \
	-T$(LD_SCRIPT)

RISCV_LDFLAGS ?= \
	-nostartfiles \
	-lm \
	-lgcc \
	-Wl,--gc-sections \
	$(GCC_CCFLAGS) \
	-T$(LD_SCRIPT)

## recipes ##

## initialise the env
## gcc
.PHONY: init_gcc
init_gcc:
ifeq ($(strip $(RISCV_DIR_GCC)),)
	echo "[ERROR] Environmental Variable RISCV_DIR_GCC is not set!"
	exit 1;
endif 
	@echo "initialising temporary directories..."
	@mkdir -p $(COMMON_OBJ_DIR)
	@mkdir -p $(TEST_OBJ_DIR)
	@mkdir -p $(BIN_DIR)
	@mkdir -p $(DMP_DIR)

# llvm
.PHONY: init_llvm
init_llvm:
ifeq ($(strip $(RISCV_DIR_LLVM)),)
	echo "[ERROR] Environmental Variable RISCV_DIR_LLVM is not set!"
	exit 1;
endif
	@echo "initialising temporary directories..."
	@mkdir -p $(COMMON_OBJ_DIR)
	@mkdir -p $(TEST_OBJ_DIR)
	@mkdir -p $(BIN_DIR)
	@mkdir -p $(DMP_DIR)

## compile test defined by TEST
# gcc
.PHONY: compile_sw_gcc
compile_sw_gcc: init_gcc $(BIN_DIR)/$(TEST)_gcc.elf
	@echo "GCC Build Complete"

# llvm
.PHONY: compile_sw_llvm
compile_sw_llvm: init_llvm $(BIN_DIR)/$(TEST)_llvm.elf
	@echo "LLVM Build Complete"


## compile common sources
#gcc
$(COMMON_OBJ_DIR)/%_gcc.o: $(COMMON_SRC_DIR)/%
	@echo "compiling $< to generate $@ using gcc"
	$(GCC_CC) $(GCC_CCFLAGS) -c $< -o $@

# llvm
$(COMMON_OBJ_DIR)/%_llvm.o: $(COMMON_SRC_DIR)/%
	@echo "compiling $< to generate $@ using llvm"
	$(CLANG_CC) -mllvm -scalable-vectorization=off -mllvm -riscv-v-vector-bits-min=0 $(LLVM_CCFLAGS) -c $< -o $@


## compile test sources
# gcc
$(TEST_OBJ_DIR)/%_gcc.o: $(TEST_DIR)/%
	@echo "compiling $< to generate $@ using gcc"
	$(GCC_CC) $(GCC_CCFLAGS) -c $< -o $@

# llvm
$(TEST_OBJ_DIR)/%_llvm.o: $(TEST_DIR)/%
	@echo "compiling $< to generate $@ using llvm"
	$(CLANG_CC) -mllvm -scalable-vectorization=off -mllvm -riscv-v-vector-bits-min=0 $(LLVM_CCFLAGS) -c $< -o $@
	

## generate test binary, dump + hex
# gcc
$(BIN_DIR)/$(TEST)_gcc.elf: $(COMMON_OBJ_GCC) $(TEST_OBJ_GCC)
	$(GCC_CC) $(RISCV_LDFLAGS) $(COMMON_OBJ_GCC) $(TEST_OBJ_GCC) -o $@
	$(RISCV_OBJDUMP) -fhs $@ > $(DMP_DIR)/$(TEST)_gcc.dump
	$(PYTHON) $(TOOLS_DIR)/dump2hex.py $(DMP_DIR)/$(TEST)_gcc.dump $(L2_WIDTH) $(L2_DEPTH) $(HEX_DIR)/$(TEST).hex 1

# llvm
$(BIN_DIR)/$(TEST)_llvm.elf: $(COMMON_OBJ_LLVM) $(TEST_OBJ_LLVM)
	$(CLANG_CC) -L$(RISCV_DIR_LLVM)/lib/linux $(RISCV_LDFLAGS_LLVM) $(COMMON_OBJ_LLVM) $(TEST_OBJ_LLVM) -o $@
	$(RISCV_OBJDUMP) -fhs $@ > $(DMP_DIR)/$(TEST)_llvm.dump
	$(PYTHON) $(TOOLS_DIR)/dump2hex.py $(DMP_DIR)/$(TEST)_llvm.dump $(L2_WIDTH) $(L2_DEPTH) $(HEX_DIR)/$(TEST).hex 1


.PHONY: clean_all
clean_all:
	@echo "cleaning temporary directories and SW build files..."
	@rm -rf $(COMMON_OBJ_DIR) $(TEST_OBJ_DIR)
	@rm -rf $(BIN_DIR)
	@rm -rf $(DMP_DIR)

