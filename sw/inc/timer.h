#ifndef _TIMER_H_
#define _TIMER_H_

/*
 * File      : timer.h
 * Test      : timer
 * Author(s) : Endrit Isufi <endrit.isufi@tuni.fi>
 *          
 * Date      : 28-June-2024
 * Description: APB timer test
 *
 */
#include "printf.h"
#include "stdint.h"
#include "runtime.h"


#define TIMER_BASE_ADDR 0xC0002000u

#define CMP_REG         *(volatile uint32_t*) (TIMER_BASE_ADDR + 0x8U)
#define CTRL_REG        *(volatile uint32_t*) (TIMER_BASE_ADDR + 0x4U)
#define TIMER_REG       *(volatile uint32_t*) (TIMER_BASE_ADDR      )


/***********************
* FUNCTION DEFINITIONS *
************************/

/*
@brief writes the timers compare register. Timer compares timer register value to this.

@param val - value written to apb timer compare register
*/
void set_cmp_reg(uint32_t val);

/*
@brief enables apb timer by setting enable register to '1'
*/
void enable_timer(void);

/*
@brief disables apt timer by setting enable register to '0'
*/
void disable_timer(void);

/*@brief returns true if timer register and compare register are equal*/
int32_t are_equal(void);

/*
@brief returns the current value of the timer register
@return uint32_t - value currently stored in REG_TIMER register
*/
uint32_t get_timer_val(void);

#endif