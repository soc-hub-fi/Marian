//******************************************************************************
// File      : gpio.h
// Author(s) : Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Date      : 20-jul-2024
// Description: Header file for Pulp APB GPIO Operations 
//******************************************************************************

#ifndef __GPIO_H__
#define __GPIO_H__

#include <stdint.h>

// Registers

#define GPIO_BASE_ADDR 0xC0003000U

#define GPIO_PADDIR_ADDR     (GPIO_BASE_ADDR + 0x00U)         
#define GPIO_GPIOEN_ADDR     (GPIO_BASE_ADDR + 0x04U)         
#define GPIO_PADIN_ADDR      (GPIO_BASE_ADDR + 0x08U)        
#define GPIO_PADOUT_ADDR     (GPIO_BASE_ADDR + 0x0CU)         
#define GPIO_PADOUTSET_ADDR  (GPIO_BASE_ADDR + 0x10U)            
#define GPIO_PADOUTCLR_ADDR  (GPIO_BASE_ADDR + 0x14U)            
#define GPIO_INTEN_ADDR      (GPIO_BASE_ADDR + 0x18U)        
#define GPIO_INTTYPE_ADDR    (GPIO_BASE_ADDR + 0x1CU)             
#define GPIO_INTSTATUS_ADDR  (GPIO_BASE_ADDR + 0x24U)              

#define GPIO_PADDIR          *(volatile uint32_t*)(GPIO_PADDIR_ADDR    )
#define GPIO_GPIOEN          *(volatile uint32_t*)(GPIO_GPIOEN_ADDR    )
#define GPIO_PADIN           *(volatile uint32_t*)(GPIO_PADIN_ADDR     )
#define GPIO_PADOUT          *(volatile uint32_t*)(GPIO_PADOUT_ADDR    )
#define GPIO_PADOUTSET       *(volatile uint32_t*)(GPIO_PADOUTSET_ADDR )
#define GPIO_PADOUTCLR       *(volatile uint32_t*)(GPIO_PADOUTCLR_ADDR )
#define GPIO_INTEN           *(volatile uint32_t*)(GPIO_INTEN_ADDR     )
#define GPIO_INTTYPE         *(volatile uint32_t*)(GPIO_INTTYPE_ADDR   )
#define GPIO_INTSTATUS       *(volatile uint32_t*)(GPIO_INTSTATUS_ADDR )

// GPIO specific types

typedef enum {
  low  = 0,
  high = 1
} gpio_state_e;

typedef enum {
  input  = 0,
  output = 1
} gpio_dir_e;

typedef enum {
  falling_edge = 0,
  rising_edge  = 1,
  both_edges   = 2
} gpio_irq_type_e;

typedef enum {
  gpio_0 = 0,
  gpio_1 = 1
} gpio_pin_e;

typedef struct {
  uint32_t gpio_paddir;
  uint32_t gpio_gpioen;
  uint32_t gpio_padin;
  uint32_t gpio_padout;
  uint32_t gpio_padoutset;
  uint32_t gpio_padoutclr;
  uint32_t gpio_inten;
  uint32_t gpio_inttype;
  uint32_t gpio_unused_inttype; /*gpio 16 -> 31 are unused in Marian*/
  uint32_t gpio_intstatus;
} gpio_reg_t;

// function protoypes


/**
 * @brief set GPIO pin direction
 * 
 * @param gpio_pin ID of gpio pin
 * @param gpio_direction Desired direction
 */
void gpio_dir_set(gpio_pin_e gpio_pin, gpio_dir_e gpio_direction);

/**
 * @brief Gets direction of selected GPIO pin
 * 
 * @param gpio_pin ID of GPIO pin
 * @return gpio_dir_e Direction of selected GPIO pin
 */
gpio_dir_e gpio_dir_get(gpio_pin_e gpio_pin);

/**
 * @brief Returns current value of specified GPIO input state. Note that this 
 * does not check whether the GPIO is configured as an input
 * 
 * @param gpio_pin ID of GPIO pin
 * @return gpio_state_e Input state of selected GPIO pin
 */
gpio_state_e gpio_pin_read(gpio_pin_e gpio_pin);


/**
 * @brief Writes to output register of GPIO pin. Note that this does not check
 * whether the GPIO pin is configured to be an output
 * 
 * @param gpio_pin ID of GPIO pin
 * @param gpio_state Desired output state of selected pin
 */
void gpio_pin_write(gpio_pin_e gpio_pin, gpio_state_e gpio_state);

/**
 * @brief Toggle output state of GPIO pin (i.e. if it is set high, set it low).
 * Note that this does not check whether the GPIO pin is configured to be an 
 * output
 * 
 * @param gpio_pin ID of GPIO pin
 */
void gpio_pin_toggle(gpio_pin_e gpio_pin);

/**
 * @brief Set IRQ configuration 
 * 
 * @param gpio_pin ID of GPIO pin
 * @param gpio_irq_type Desired IRQ type. Note that IRQs are enabled/disabled 
 * independently
 */
void gpio_irq_cfg_set(gpio_pin_e gpio_pin, gpio_irq_type_e gpio_irq_type);


/**
 * @brief Enable IRQ for selected GPIO pin
 * 
 * @param gpio_pin ID of GPIO pin
 */
void gpio_irq_enable(gpio_pin_e gpio_pin);


/**
 * @brief Disable IRQ for selected GPIO pin
 * 
 * @param gpio_pin ID of GPIO pin
 */
void gpio_irq_disable(gpio_pin_e gpio_pin);

#endif // __GPIO_H__