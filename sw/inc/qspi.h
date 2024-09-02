#ifndef _QSPI_H_
#define _QSPI_H_

/*
 * File      : qspi.h
 * Test      : qspi
 * Author(s) : Endrit Isufi <endrit.isufi@tuni.fi>
 *             Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
 * Date      : 15-May-2024
 * Description: QSPI prototype functions, register addresses and spi master registers
 *              Todo: Add IRQ management
 *
 */

#include "stdint.h"

//QSPI (axi_spi_master) addresses
#define SPI_BASE_ADDR   0xC0001000u
#define SPI_REG_STATUS_ADDR (SPI_BASE_ADDR + 0x00u)
#define SPI_REG_CLKDIV_ADDR (SPI_BASE_ADDR + 0x04u)
#define SPI_REG_SPICMD_ADDR (SPI_BASE_ADDR + 0x08u)
#define SPI_REG_SPIADR_ADDR (SPI_BASE_ADDR + 0x0Cu)
#define SPI_REG_SPILEN_ADDR (SPI_BASE_ADDR + 0x10u)
#define SPI_REG_SPIDUM_ADDR (SPI_BASE_ADDR + 0x14u)
#define SPI_REG_TXFIFO_ADDR (SPI_BASE_ADDR + 0x18u) //NOTE: + 0x18u for apb_spi_master, + 0x20u for axi_spi_master
#define SPI_REG_RXFIFO_ADDR (SPI_BASE_ADDR + 0x20u) //NOTE: + 0x20u for apb_spi_master, + 0x40u for axi_spi_master
#define SPI_REG_INTCFG_ADDR (SPI_BASE_ADDR + 0x24u)
#define SPI_REG_INTSTA_ADDR (SPI_BASE_ADDR + 0x28u)

//qspi master registers
#define SPIM_STATUS  *( volatile uint32_t* )(SPI_REG_STATUS_ADDR)
#define SPIM_CLKDIV  *( volatile uint32_t* )(SPI_REG_CLKDIV_ADDR)
#define SPIM_SPICMD  *( volatile uint32_t* )(SPI_REG_SPICMD_ADDR)
#define SPIM_SPIADR  *( volatile uint32_t* )(SPI_REG_SPIADR_ADDR)
#define SPIM_SPILEN  *( volatile uint32_t* )(SPI_REG_SPILEN_ADDR)
#define SPIM_SPIDUM  *( volatile uint32_t* )(SPI_REG_SPIDUM_ADDR)
#define SPIM_TXFIFO  *( volatile uint32_t* )(SPI_REG_TXFIFO_ADDR)
#define SPIM_RXFIFO  *( volatile uint32_t* )(SPI_REG_RXFIFO_ADDR)
#define SPIM_INTCFG  *( volatile uint32_t* )(SPI_REG_INTCFG_ADDR)
#define SPIM_INTSTA  *( volatile uint32_t* )(SPI_REG_INTSTA_ADDR)

/* --- Function Prototypes ------*/

/**
 * 
 * @brief set length of each message component sent within the SPI operation by writing to SPILEN 
 *    ┌──────────┬─────────┬─────────┐ 
 * bit│31      16│15      8│7       0│ 
 *    ├──────────┼─────────┼─────────┤ 
 *    │ DATA LEN │ ADDR LEN│ CMD LEN │ 
 *    └──────────┴─────────┴─────────┘ 
 * Note that DATA is 16b and ADD/CMD are 8b     
 * 
 * @param data_len length of data in bits
 * @param addr_len length of address in bits
 * @param cmd_len  length of command in bits               
 */
void spi_set_length(uint16_t data_len, uint8_t addr_len, uint8_t cmd_len);

/**
 * @brief set the value of the 32b address component in SPI operation by writing to ADDR register 
 * 
 * @param addr address value to be sent
 */
void spi_set_addr(uint32_t addr);

/**
 * @brief set the value of the 32b address component in SPI operation by writing to ADDR register
 * 
 * @param cmd command value to be sent
 */
void spi_set_cmd(uint32_t cmd);

/**
 * @brief set data to be transmitted
 * 
 * @param data_out data to be sent
 */
void spi_set_data_o(uint32_t data_out);

/**
 * @brief set SPIDUM register:
 *                                   
 *    ┌──────────────┬──────────────┐ 
 * bit│31          16│15           0│ 
 *    ├──────────────┼──────────────┤ 
 *    │ SPI DUMMY WR │ SPI DUMMY RD │ 
 *    └──────────────┴──────────────┘ 
 * 
 * @param rd_cycles number of dummy (empty/without data) cycles to be sent during read operation
 * @param wr_cycles number of dummy (empty/without data) cycles to be sent during write operation
 */
void spi_set_dummy_cycles(uint16_t wr_cycles, uint16_t rd_cycles);

/** 
 * @brief set CLKDIV register, 8b value used to divide SoC clock for SPI transfers
 * 
 * @param clock_div clock divider value used to drive SPI clock freq
 */
void spi_set_clk_div(uint8_t clock_div);

/**
 * @brief set status register values:
 *    ┌─────┬──────┬────┬────┬──────┬──────┬──┬──┐ 
 * bit│31 12│11   8│7  5│  4 │   3  │   2  │ 1│ 0│ 
 *    ├─────┼──────┼────┼────┼──────┼──────┼──┼──┤ 
 *    │ NA  │  CSn │ NA │SRST│QuadWR│QuadRD│WR│RD│ 
 *    └─────┴──────┴────┴────┴──────┴──────┴──┴──┘ 
 *    RD = initiate MISO/MOSI SPI read operation
 *    WR = initiate MISO/MOSI SPI write operation
 *    QuadRD = initiate QSPI read operation
 *    QuadWR = initiate QSPI write operation
 *    SRST = clear Tx/Rx buffer
 *    CSn[3:0] = set CS of corresponding bit (only CS 0 available on Marian [bit 8])
 *
 * @param cs   chip select
 * @param SRST system reset
 * @param QWR  QuadSPI write
 * @param QRD  QuadSPI read
 * @param WR   MISO/MOSI write
 * @param RD   MISO/MOSI read
 */
void spi_set_status_reg(uint8_t cs, uint8_t SRST, uint8_t QWR, uint8_t QRD, uint8_t WR, uint8_t RD);

// Getters

/**
 * @brief get value of Rx data register
 * 
 * @return uint32_t 
 */
uint32_t spi_get_data_in();

/** 
 *  @brief Read SPIM_STATUS register. Note that performing a read operation on the STATUS register
 *  does not return the same data that is written when writing to the status register. 
 *  The read definition returns the following information:
 *     ┌─────┬─────────┬─────┬─────────┬────┬──────────────────────┐
 *  bit│31 29│28     24│23 21│20     16│15 8│7                    0│
 *     ├─────┼─────────┼─────┼─────────┼────┼──────────────────────┤
 *     │  0  │ ELEM Tx │  0  │ ELEM Rx │  0 │ SPI CONTROLLER STATE │
 *     └─────┴─────────┴─────┴─────────┴────┴──────────────────────┘
 *  ELEM Tx = Populated entry count of the Tx FIFO
 *  ELEM Rx = Populated entry count of the Rx FIFO
 *  SPI CONTROLLER STATE (one hot):
 *    8'b0000_0000 = reset
 *    8'b0000_0001 = IDLE
 *    8'b0000_0010 = CMD
 *    8'b0000_0100 = ADDR
 *    8'b0000_1000 = MODE
 *    8'b0001_0000 = DUMMY
 *    8'b0010_0000 = DATA_Tx
 *    8'b0100_0000 = DATA Rx
 *    8'b1000_0000 = WAIT_EDGE
 *    These states are useful to track the status of operations being executed in HW
 *
 * @return uint32_t status register contents
 */
uint32_t spi_get_status(void);

// helper functions

/**
 * @brief waits until the status register is set to idle
 * 
 */
void wait_for_idle(void);

#endif
