# Component Memory Maps

More detailed memory maps for each peripheral component within Marian is defined here.

## Contents
- [Debug Module](#debug-module)
- [Ctrl Registers](#ctrl-registers)
- [CLINT](#clint)
- [UART](#uart)
- [QSPI](#qspi)
- [APB Timer](#apb-timer)
- [GPIO](#gpio)
- [PLIC](#plic)


## Debug Module

The Debug Module used within Marian is the [PULP Project RISC-V Debug Module (commit #9e823a6)](https://github.com/pulp-platform/riscv-dbg/tree/9e823a60e11947fcf0c5d95845e634fe5e60cf03). The repo contains documentation covering the registers of the debug module ([here](./../ips/pulp_rv_dbg/doc/debug-system.md)). To avoid redundancy of information, the registers will not be repeateds here.

## Ctrl Registers

Base Address: 0x0000_2000

Group: 64b Peripheral

|      Name      |   Address   | R/W? | Reset Value | Notes                                                                                                                                       |
|:--------------:|:-----------:|------|-------------|---------------------------------------------------------------------------------------------------------------------------------------------|
|      Exit      | 0x0000_2000 | RW   | 0           | Used for simulation, relic of Ara                                                                                                                        |
| DRAM Base Addr | 0x0000_2008 | RO   | 0x8000_0000 | Unused, relic of Ara                                                                                                                        |
|  DRAM End Addr | 0x0000_2010 | RO   | 0x8010_0000 | Unused, relic of Ara                                                                                                                        |
|  event_trigger | 0x0000_2018 | RW   | 0           | Unused, relic of Ara                                                                                                                        |
|    hw_cnt_en   | 0x0000_2020 | RW   | 0           | Unused, relic of Ara                                                                                                                        |
|  BootRAM Addr  | 0x0000_2028 | RW   | 0x8000_0000 | Contains Address value which execution jumps to once BootRAM ready is set to a non-zero value.                                              |
|  BootRAM Ready | 0x0000_2030 | RW   | 0           | Register polled by bootROM. When register contains a non-zero value, execution jumps to the address stores within BootRAM address register. |

## CLINT

Base Address: 0x0000_3000

Group: 64b Peripherals

|   Name   |   Address   | R/W? | Reset Value | Notes                                                                         |
|:--------:|:-----------:|------|-------------|-------------------------------------------------------------------------------|
|   msip   | 0x0000_3008 | RW   | 0           | Writing 0x1 to this register will cause a software interrupt to begin pending |
| mtimecmp | 0x0000_3020 | RW   | 0           | 64b mtimecmp value                                                            |
|   mtime  | 0x0000_3040 | RW   | 0           | Current value of mtime (32kHz monotonic timer)                                |

## UART

Base Address: 0xC000_0000

Group: 32b Peripherals

| Name | LCR bit 7 value |   Address   | R/W? | Reset Value |                      Notes                      |
|:----:|:---------------:|:-----------:|:----:|:-----------:|:-----------------------------------------------:|
|  RBR |        0        | 0xC000_0000 |  RO  |      0      |             Receiver Buffer Register            |
|  THR |        0        | 0xC000_0000 |  WO  |      0      |           Transmitter Holding Register          |
|  DLL |        1        | 0xC000_0000 |  RW  |      0      | Divisor Latch (Least Significant Byte) Register |
|  IER |        0        | 0xC000_0004 |  RW  |      0      |            Interrupt Enable Register            |
|  DLM |        1        | 0xC000_0004 |  RW  |      0      |  Divisor Latch (Most Significant Byte) Register |
|  IIR |        0        | 0xC000_0008 |  RO  |      0      |        Interrupt Identification Register        |
|  FCR |        x        | 0xC000_0008 |  WO  |      0      |              FIFO Control Register              |
|  FCR |        1        | 0xC000_0008 |  RO  |      0      |              FIFO Control Register              |
|  LCR |        x        | 0xC000_000C |  RW  |      0      |              Line Control Register              |
|  MCR |        x        | 0xC000_0010 |  RW  |      0      |              Modem Control Register             |
|  LSR |        x        | 0xC000_0014 |  RW  |      0      |               Line Status Register              |
|  MSR |        x        | 0xC000_0018 |  RW  |      0      |              Modem Status Register              |
|  SCR |        x        | 0xC000_001C |  RW  |      0      |                 Scratch Register                |

## QSPI

Base Address: 0xC000_1000

Group: 32b Peripherals

|      Name     |   Address   | R/W? | Reset Value | Notes                                                                                                                                                                                                                                                                                                                                               |
|:-------------:|:-----------:|:----:|:-----------:|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|   SPI Status  | 0xC000_1000 |  RW  |      0      | [11:8] Chip select (only [8] in use), [4] Software Reset - Clear FIFOs and abort active transfers, [3] Quad Write Command - Perform a write using Quad SPI mode, [2] Quad Read Command - Perform a read using Quad SPI mode, [1] Write Command - Perform a write using standard SPI mode, [0] Read Command - Perform a read using standard SPI mode |
| SPI Clock Div | 0xC000_1004 |  RW  |      0      | [8:0] CKLDIV                                                                                                                                                                                                                                                                                                                                        |
|  SPI Command  | 0xC000_1008 |  RW  |      0      | [31:0] SPICMD When performing a read or write transfer the SPI command is sent first before any data is read or written. The length of the SPI command can be controlled with the SPILEN register.                                                                                                                                                  |
|  SPI Address  | 0xC000_100C |  RW  |      0      | [31:0] SPIADR When performing a read or write transfer the SPI command is sent first before any data is read or written, after this the SPI address is sent. The length of the SPI address can be controlled with the SPILEN register                                                                                                               |
|   SPI Length  | 0xC000_1010 |  RW  |      0      | [31:16] DATALEN - The number of bits read or written. Note that first the SPI command and address are written to an SPI slave device, [13:8] ADDRLEN - The number of bits of the SPI address that should be sent, [5:0] CMDLEN - The number of bits of the SPI command that should be sent                                                          |
|   SPI Dummy   | 0xC000_1014 |  RW  |      0      | [31:16] DUMMYWR - Dummy cycles (nothing being written or read) between sending the SPI command + SPI address and writing the data. [15:0] DUMMYRD - Dummy cycles (nothing being written or read) between sending the SPI command + SPI address and reading the data.                                                                                |
|  SPI Tx FIFO  | 0xC000_1018 |  RW  |      0      | [31:0] Tx - Write data into the FIFO                                                                                                                                                                                                                                                                                                                |
|  SPI Rx FIFO  | 0xC000_1020 |  RO  |      0      | [31:0] Rx - Read data from the FIFO.                                                                                                                                                                                                                                                                                                                |

## APB Timer

Base Address: 0xC000_2000

Group: 32b Peripherals

|     Name    |   Address   | R/W? | Reset Value | Notes                                     |
|:-----------:|:-----------:|:----:|:-----------:|-------------------------------------------|
| Timer Value | 0xC000_2000 |  RW  |      0      | Current Timer Value                       |
|  Timer CMP  | 0xC000_2004 |  RW  |      0      | Compare value                             |
|  Timer Ctrl | 0xC000_2008 |  RW  |      0      | Set to 1 to start timer, 0 to stop timer. |

## GPIO

Base Address: 0xC000_3000

Group: 32b Peripherals

|       Name      |   Address   | R/W? | Reset Value | Notes                                                  |
|:---------------:|:-----------:|:----:|:-----------:|--------------------------------------------------------|
|  Pad Direction  | 0xC000_3000 |  RW  |      0      | 0 = input, 1 = output                                  |
| GPIO Clk Enable | 0xC000_3004 |  RW  |      0      | GPIO Clk enable must be set if GPIO is set as an input |
|     GPIO in     | 0xC000_3008 |  RW  |      0      |                                                        |
|     GPIO out    | 0xC000_300C |  RW  |      0      |                                                        |
|   GPIO out set  | 0xC000_3010 |  RW  |      0      |                                                        |
|   GPIO out clr  | 0xC000_3014 |  RW  |      0      |                                                        |
|    IRQ Enable   | 0xC000_3018 |  RW  |      0      |                                                        |
|     IRQ Type    | 0xC000_301C |  RW  |      0      | 00 = falling edge, 01 = rising edge, 10 = both edges   |
|    IRQ Status   | 0xC000_3024 |  RW  |      0      |                                                        |

## PLIC

Base Address: 0xCC00_0000

Group: 32b Peripherals

The register map for the PLIC is defined within the [RISC-V PLIC Specification](https://github.com/riscv/riscv-plic-spec) and is not listed here. PLIC IRQ IDs are defined within the [Marian Datasheet](../README.md#plic-irq-ids)