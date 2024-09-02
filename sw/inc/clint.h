#ifndef _CLINT_H_
#define _CLINT_H_

/*
 * File      : clint.h
 * Test      : clint
 * Author(s) : Endrit Isufi <endrit.isufi@tuni.fi>
 * Date      : 15-May-2024
 * Description: sets and starts machine timer interrupts
 *
 */

#include "runtime.h"
#include "printf.h"
/*Addresses*/
#define CLINT_BASE_ADDR 0x3000
#define CLINT_IPI_REG *(volatile uint32_t*) (CLINT_BASE_ADDR + 0x8u)
#define CLINT_MTIMECMP_REG *(volatile uint32_t*) (CLINT_BASE_ADDR + 0x20u)
#define CLINT_MTIME_REG *(volatile uint32_t*) (CLINT_BASE_ADDR + 0x40u)
/*********************
*Function definitions*
**********************/

/*
@brief Writes mtimecmp register. Once Clints timer equals this value, CLINT executes timer trap.
@param rtc_cycles - value written to mtimecmp_register.
*/
void set_timer(uint64_t rtc_cycles);

#endif

