# Software Flow of Vector-Crypto Subsystem (Marian) for Bow

## Contents
- [Overview](#overview)
  - [Directory Structure](#directory-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Building RISC-V GCC](#building-risc-v-gcc)
- [Usage](#usage)
  - [Compilation](#compilation)
  - [Hex File Configuration](#hex-file-configuration)
  - [Creating a Test](#creating-a-test)
    - [C stdlib Functions](#c-stdlib-functions)
    - [UART Configuration](#uart-configuration)



## Overview

The software flow for Marian is used to generate .elf and .hex files for testing the hardware design. It is not designed to be used for building complex projects, but simple test cases with a low number of source files.

### Directory Structure

```
/
|-- bin/
|-- doc/
|-- dump/
|   |-- vc_test1.dump
|   |-- vc_test2.dump
|-- hex/
|   |-- vc_test1.hex
|   |-- vc_test2.hex
|   |-- ideal_dispatcher/
|      |-- ideal.hex
|   |-- regression/
|      |--<regression_tests>.hex
|-- inc/
|   |-- common.h
|   |-- vc_test1.h
|   |-- vc_test2.h
|-- linker_scripts/
|   |-- link.ld
|-- obj/
|-- src/
|   |-- vc_test1/
|       |-- main.c
|       |-- vc_test1.h
|   |-- vc_test2/
|       |-- main.c
|       |-- vc_test2.h
|   |-- common/
|   |   |-- crt0.s
|-- tools/
```

- **bin**: Temporary Executable files directory (generated during the build
  process).

- **doc**: Specific documentation for SW flow

- **dump**: Temporary directory containing human readable objdump of compiled
  executables (used for debugging, generated during the build process)

- **inc**: Header file directory.

    + common.h: Common header file used across tests.

    + vc_test1.h and vc_test2.h: Header files for individual tests.

    + Header files for individual tests should be copied into this directory as
      this directory is used by build scripts.

- **hex**: hex files used for simulation (generated using elf2hex on binaries)

   + Newly compiled hex files will be stored in the root of the directory.

   + Hex files within the ideal_dispatcher directory are used to initialise the ideal dispatcher within the TB (ToDo...)

   + The regression directory holds precompiled Ara and RISCV tests which are used to test pre-existing functionality.

   + :warning: **BE CAREFUL WHEN MODIFYING CONTENTS AS THIS CONTAINS ARTEFACTS
     WHICH CANNOT BE REGENERATED FROM THE SOURCES WITHIN THIS REPO!** :warning:

- **linker_scripts**: Linker scripts for compilation.

- **obj**: Temporary object files directory (generated during the build
  process).

- **src**: Source code directory containing the main application and modularized
  code.

    + vc_test1/ and vc_test2/: Directories containing source/include files for
      individual tests. Main will always be used as the entry point for each
      test.

    + common/ contains source files which are applicable to all tests.

  - **tools**: Scripts and executables used by software flow

## Getting Started

### Prerequisites

GNU Make

[RISC-V GNU Toolchain (64b + Newlib)](https://github.com/riscv-collab/riscv-gnu-toolchain). The version of GCC must support the Zvk extension (tested with tag `2023.12.12`).

Python 3.9 (or greater)

### Building RISC-V GCC

General installation instructions for RISC-V GCC can be found in the [RISC-V GNU Toolchain repo](https://github.com/riscv-collab/riscv-gnu-toolchain), however, as Marian uses the Zvk extensions some specific options are required when building the cross-compiler...

When configuring the installation, the following options should be used:
```
./configure --prefix=$RISCV_GCC --with-arch=rv64gcvzvkng --enable-multilib --with-cmodel=medany
```
...where the environment variable `$RISCV_GCC` is the installation path for GCC.

Note that the cmodel=medany is required as the default address of the bootRAM in Marian (the main memory used by tests) is 0x8000_0000. If you are unfamiliar with RISC-V code models, there is a nice guide [here](https://www.sifive.com/blog/all-aboard-part-4-risc-v-code-models).

## Usage

### Compilation

To keep things easy, the environment variable `RISCV_DIR` must be set to the path of the compiler installation before us e.g. on Ubuntu+bash this can be done using `export RISCV_DIR=<path to installation>`.

(Alternatively, the path of the compiler installation directory can be passed as a variable when executing the make target.)

To compile an existing test the following make target can be executed from the repository root:
```
make hex
```
The default test is set to *hello_world* and running the above command will create the following artefacts:
+ `sw/bin/hello_world.elf` - the binary of the test, 
+ `sw/dump/hello_world.dump` - a dump of the .elf contents (generated using riscv64-unknown-elf-objdump -fhs) 
+ `sw/hex/hello_world.hex` - A hex file of the .elf which can be used to load the L2 memory contents of Marian when executing the `marian_tb` testbench. 

The test compilation target can be set to a different existing test using the `TEST` variable e.g.
```
make compile_sw TEST=vc_test1
```

To delete the build artefacts the following make target can be called from the repo root:
```
make clean_sw
```
This will remove all generated .o, .elf and .dump files. **Note that the .hex files are preserved as they are tracked in git.**

#### Hex File Configuration

The generated hex file is generated using the [dump2hex.py](tools/dump2hex.py) script. This script reads the generated .elf dump, extracts the .elf section data and writes it out to the .hex file in a format which is configured through the following parameters:
+ `L2_WIDTH` - The bit width of each row within the L2 memory (default: 128)
+ `L2_DEPTH` - The number of rows within the memory (default: 16384)

The above values can be passed when calling the `make compile_sw` target in the same way as the `TEST` variable.

**Note that currently the dump2hex.py script is brittle and will not work if the dump file is not formatted as expected. Therefore, if you modify the flags which are passed to objdump, the hex file generation will fail!**

## Creating a Test

To create a new test, firstly create a directory under `sw/src` which is named using the test name. For example, to create a test called my_test, the directory `sw/src/my_test` must be created.

The created test directory must contain a `main.c` which acts as the entry point of the test, called from the C runtime initialisation routines defined within [crt0.S](src/common/crt0.S).

Any test-specific headers should be stored both within the new test directory and within the `sw/inc` directory (see [structure](#directory-structure) for guidance).

For ease, a template directory has been created which can be copied/renamed to create a new test.

Once the new test is created, it can be compiled as described [above](#compilation).

### C stdlib Functions

#### printf

To use printf within a test, the header [printf.h](inc/printf.h) should be included instead of `stdio.h`. This uses a lightweight implementation ([printf.c](src/common/printf.c)) of printf which is suitable for embedded platforms.

### UART Configuration

When running Marian in simulation, the `mock_uart` component is used to emulate the UART in order to improve simulation performance. This component prints directly to stdout in the simulator instead of sending data serially over the uart_tx bus. This is the default option used when compiling code for Marian.

However, if you are compiling for the FPGA-protoype or you want to test the real `apb_uart`, you must pass the flag `REAL_UART` when compiling e.g.

```
make compile_sw TEST=vc_test1 REAL_UART=1
```
This will replace the code used to print over the `mock_uart` with the functions used to interface with the UART16550 `apb_uart`. Note that when compiling with this option, the baudrate will be initialised to 115200 Baud (see [init_function](src/common/uart16550.c#101)).


