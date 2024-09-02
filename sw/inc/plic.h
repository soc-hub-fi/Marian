#ifndef _PLIC_H_
#define _PLIC_H_

/*
 * File      : plic.h
 * Test      : plic
 * Author(s) : Endrit Isufi <endrit.isufi@tuni.fi>
 *             Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
 *          
 * Date      : 15-May-2024
 * Description: PLIC addresses and function prototypes for plic testing
 *              
 */
#include "printf.h"
#include "stdint.h"
#include "runtime.h"

// ID of IRQs to be used with PLIC functions
#define APB_TIMER_OVERFLOW_IRQ 1U
#define APB_TIMER_COMPARE_IRQ  2U
#define UART_IRQ               3U
#define QSPI_THRESH_IRQ        4U
#define QSPI_EOT_IRQ           5U
#define GPIO_IRQ               6U
#define EXT_IRQ                7U

// Registers

#define PLIC_BASE_ADDR            0xCC000000U

#define PLIC_APB_TIMER_OVERFLOW_PRI_ADDR (PLIC_BASE_ADDR + (0x4U * (APB_TIMER_OVERFLOW_IRQ)))
#define PLIC_APB_TIMER_COMPARE_PRI_ADDR  (PLIC_BASE_ADDR + (0x4U * (APB_TIMER_COMPARE_IRQ)) )                          
#define PLIC_UART_PRI_ADDR               (PLIC_BASE_ADDR + (0x4U * (UART_IRQ))              )             
#define PLIC_QSPI_THRESH_PRI_ADDR        (PLIC_BASE_ADDR + (0x4U * (QSPI_THRESH_IRQ))       )                    
#define PLIC_QSPI_EOT_PRI_ADDR           (PLIC_BASE_ADDR + (0x4U * (QSPI_EOT_IRQ))          )                 
#define PLIC_GPIO_PRI_ADDR               (PLIC_BASE_ADDR + (0x4U * (GPIO_IRQ))              )             
#define PLIC_EXT_PRI_ADDR                (PLIC_BASE_ADDR + (0x4U * (EXT_IRQ))               )            
#define PLIC_IRQ_PENDING_ADDR            (PLIC_BASE_ADDR + 0x1000U                          )
#define PLIC_IRQ_EN_M_ADDR               (PLIC_BASE_ADDR + 0x2000U                          )
#define PLIC_IRQ_EN_S_ADDR               (PLIC_BASE_ADDR + 0x2080U                          )
#define PLIC_IRQ_THRESH_M_ADDR           (PLIC_BASE_ADDR + 0x200000U                        )
#define PLIC_IRQ_THRESH_S_ADDR           (PLIC_BASE_ADDR + 0x201000U                        )
#define PLIC_IRQ_CLAIM_M_ADDR            (PLIC_BASE_ADDR + 0x200004U                        )
#define PLIC_IRQ_CLAIM_S_ADDR            (PLIC_BASE_ADDR + 0x201004U                        )

#define PLIC_APB_TIMER_OVERFLOW_PRI *(volatile uint32_t*)(PLIC_APB_TIMER_OVERFLOW_PRI_ADDR )
#define PLIC_APB_TIMER_COMPARE_PRI  *(volatile uint32_t*)(PLIC_APB_TIMER_COMPARE_PRI_ADDR  )
#define PLIC_UART_PRI               *(volatile uint32_t*)(PLIC_UART_PRI_ADDR               )
#define PLIC_QSPI_THRESH_PRI        *(volatile uint32_t*)(PLIC_QSPI_THRESH_PRI_ADDR        )
#define PLIC_QSPI_EOT_PRI           *(volatile uint32_t*)(PLIC_QSPI_EOT_PRI_ADDR           )
#define PLIC_GPIO_PRI               *(volatile uint32_t*)(PLIC_GPIO_PRI_ADDR               )
#define PLIC_EXT_PRI                *(volatile uint32_t*)(PLIC_EXT_PRI_ADDR                )
#define PLIC_IRQ_PENDING            *(volatile uint32_t*)(PLIC_IRQ_PENDING_ADDR            )
#define PLIC_IRQ_EN_M               *(volatile uint32_t*)(PLIC_IRQ_EN_M_ADDR               )
#define PLIC_IRQ_EN_S               *(volatile uint32_t*)(PLIC_IRQ_EN_S_ADDR               )
#define PLIC_IRQ_THRESH_M           *(volatile uint32_t*)(PLIC_IRQ_THRESH_M_ADDR           )
#define PLIC_IRQ_THRESH_S           *(volatile uint32_t*)(PLIC_IRQ_THRESH_S_ADDR           )
#define PLIC_IRQ_CLAIM_M            *(volatile uint32_t*)(PLIC_IRQ_CLAIM_M_ADDR            )
#define PLIC_IRQ_CLAIM_S            *(volatile uint32_t*)(PLIC_IRQ_CLAIM_S_ADDR            )

#define PLIC_PRIREG_OFFSET_ADDR(id)      (PLIC_BASE_ADDR + (0x4 * id))

//PLIC interrupt id enable
#define PLIC_IE_BIT  8
#define PLIC_IE_MASK  0x1

#define PLIC_NBITS 8

/* CLIC interrupt id control */
#define PLIC_CTL_MASK	  0xff
#define PLIC_CTL_OFFSET 24 + (8 - PLIC_NBITS)

#define PRIORITY_REG *(volatile uint32_t*) (PLIC_BASE_ADDR + 0x8) 



/********
* Types *
*********/

  typedef enum {
    apb_timer_overflow_irq = 1,
    apb_timer_cmp_irq      = 2,
    uart_irq               = 3,
    qspi_thresh_irq        = 4,
    qspi_eot_irq           = 5,
    gpio_irq               = 6,
    ext_irq                = 7
  } irq_source_e;

/*********************
*FUNCTION DEFINITIONS*
**********************/

/*
  @brief set priority value to external interrupt
  
  @param irq_source - ID of the interrupt
  @param prio - priority level
*/
void plic_set_priority(irq_source_e irq_source, uint32_t prio);

/**
 * @brief Set PLIC IRQ enable bit corresponding to IRQ source
 * 
 * @param irq_source ID of IRQ to be enabled
 */
void plic_enable_irq(irq_source_e irq_source);


/**
 * @brief Clear PLIC IRQ enable bit corresponding to IRQ source 
 * 
 * @param irq_source ID of IRQ to be disabled
 */
void plic_disable_irq(irq_source_e irq_source);


#endif
