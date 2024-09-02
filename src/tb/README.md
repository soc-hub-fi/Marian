# TESTBENCH

## Directory Structure

```
/src
|--/tb
|  |--/include
|  |--/models

```
- **include**: Contains files with values and types that are relevant in running the testbenches.

- **models**: Model scripts for crypto unit and Ara.

## marian_tb.sv (Questa TB)

### TB Configurable Parameters

When running the testbench (see [Questasim Guidance](../../README.md#questasim)), parameters can be passed to configure the TB so that specific components can be tested. The following table lists the TB parameters which can be controlled when calling the `sim/simc` Make target:

  - `L2_INIT_METHOD=<option>` : Defines whether the TB preloads the bootRAM of Marian directly from the TB or loads the memory using the JTAG interface at runtime. Valid options are `FILE` (preload) or `JTAG`. Note that the JTAG load is quite slow and therefore the default option is set to `FILE`. 

  - `SIM_MEM` : Sets the size of the bootRAM (L2 memory) in Marian to 1MiB. This is to allow the running of Ara regression tests which are large. The default size of Marian bootRAM is 250KiB.

  - `REAL_UART` : Updates the design to instantiate the APB UART rather than the mock UART. Note that using this parameter will disable prints to the console from `printf` calls during simulation. The mock UART is used if this parameter is not defined. 

  - `EXT_AXI_TEST` : When defined, the TB runs a series of reads/writes over the external AXI interface to verify connectivity (see [Running  AXI Reads and Writes](#running--axi-reads-and-writes)). Note that this only runs when `L2_INIT_METHOD` is set to JTAG.

  - `SPI_TEST` : Initialises the AXI slave connected to the TB SPI slave (see [SPI Slave](#spi-slave)) so that reads/writes can be sent over the SPI interface.

  - `IDEAL_DISPATCH` : This has been maintained from Ara and is used to control the configuration of the design, such that only the vector processor is instantiated and a FIFO can be used to deliver vector instructions directly to the vector processor without using the CVA6 (see [Ideal Dispatcher Mode](https://github.com/pulp-platform/ara/blob/main/README.md#ideal-dispatcher-mode)) for details. This is basically untested with Marian and will likely require modifications to work. It has been kept here for future use.

  - `DM_TESTS` : Controls whether a series of tests are run to verify the operation of the PULP RISC-V Debug Module within Ara. Note that `L2_INIT_METHOD` must be set to `JTAG` for this to work.

### SW Test Loading

The `marian_tb` is designed to target the use of the SW tests to drive the various components of Marian. The TB can be used in combination with the SW build flow (see [SW Flow Docs](../../sw/README.md)) to load and run SW tests within simulation. 

To do this, the SW compiles the test to a binary and then a [Python script](../../sw/tools/dump2hex.py) is called which converts the binary to a .hex (.mem) format. When running the testbench using the sim/simc [Make target](../../README.md#questasim), the .hex file (defined using the `TEST` parameter) is copied into a temporary file under `/build/memory_init/memory_init.mem`. The testbench uses this file to either preload the bootRAM or load the contents of the file over JTAG.

### Test Completion Logic

To determine when a SW test has finished executing and therefore the TB has finished running, the marian_tb contains logic which is constantly monitoring the value of the [Exit Control Register](../../doc/component_mem_maps.md#ctrl-registers). When the value bit 0 of the register is set to 1, this indicates that the test is complete. The testbench then takes the value of the remaining bits within the register ([63:1]) to determine whether the test has passed (0) or failed (!0).

Note that the return value of the TB cannot be used directly by the Gitlab CI to determine whether the job has passed/failed and the [script](../../scripts/return_status.sh) is used to check the return status of the TB and exit the job with the appropriate return code.  

### AXI Interface

To be able to exercise the internal modules of Marian by using the external AXI interface, testbench utilities taken from PULP axi_test package are used. These include an AXI bus module and driver classes (AXI_BUS_DV & axi_driver). These contain useful tasks for verification which are applied within in axi_write/read tasks.

The testbench also contains a slave AXI interface to emulate an external slave interface to Marian. The only way the slave interface differs from the AXI master interface, is that it has an "axi_rand_slave" class that returns random data if it receives read operations. 

### AXI Configuration

The following values are used for the default AXI configuratin and defined in /include/marian_tb_pkg.sv:

 | Parameter                  | Value |
|----------------------------|-------|
| AXI_DV_ADDR_WIDTH          | 32    |
| AXI_DV_DATA_WIDTH          | 64    |
| AXI_DV_ID_WIDTH            | 9     |
| AXI_DV_USER_WIDTH          | 1     |

### Usable Tasks

There are two tasks written in the TB for the purpose of generating reads and writes into Marian.

#### axi_write_mst()
This tasks generates a write operation at a desired address. It also has assertions to verify correct response is received back. If parameter print is set, the task also prints the address and data to be written.

```
//                     address               data            strobe            print
task axi_write_mst( input int addr, input longint data, input int strb, input logic print=0);
```

#### axi_read_mst()
This task reads data from a desired address. If parameter print is also set, it prints the read data.

```
//                      addr                data               print
task axi_read_mst( input int addr, output longint data, input logic print=0 );
```
### SPI Slave

To verify the QSPI master module of marian, a SPI slave module is required. The PULP axi_spi_slave module is instantiated for this purpose. This module is also connected to an AXI_BUS and into an axi_rand_slave so that if a read request is sent over the SPI interface, data is returned to Marian.

### Running  AXI Reads and Writes

Booting should be initialised before any reads and writes are attempted. This is why the write/read tasks are added after bootRAM's bootram_rdy register is set.

It is also good to delay any read and writes until the reset has propagated into the design itself. This is why before the reads and writes there is the following code block:

```
  @(posedge i_axi_cdc_split_dst.rstn_sync3); // sync to cdc rst sync3
  #(5*RESET_DELAY_CYCLES*CLOCK_PERIOD);
```

The above two reasons are why it is reccommended to write any test under the "Load L2 with JTAG" part of the file, since the booting and delays are already done there. 

Another thing to remember is to reset AXI slave with the .reset() method and then set it to run with .run() method while reads and writes are concurrently run:

```
`ifdef XYZ_TEST
begin
  axi_rand_slave.reset();
  fork
    axi_rand_slave.run();
    begin 
      // <insert your code here>
    end
  join
end
`endif
```
AXI Master driver should be already reset, since setting bootram_rdy would not have been possible otherwise.

## marian_tb_verilator.sv (Verilator TB)

*note that all testing has been performed on Verilator v5.008*

A simplified TB has been created to support simulation using Verilator. This testbench only supports loading of Marian bootRAM using the FILE based method and does not instantiate the Marian wrapper, but instead the marian_top module is the DUT (this is due to issues which were discovered during the simulation of the AXI CDC modules with Verilator).

The commands to execute the Verilator based simulation can be found within the main repo [README](../../README.md#verilator).