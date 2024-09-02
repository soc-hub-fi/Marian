//******************************************************************************
// File        : plic.c
// Author(s)   : Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Date        : 19-jul-2024
// Description : Implementation of functions used to control Pulp PLIC 
//*****************************************************************************/

#include "plic.h"

void plic_set_priority(irq_source_e irq_source, uint32_t prio){
  
  switch (irq_source) {
    case apb_timer_overflow_irq:
      PLIC_APB_TIMER_OVERFLOW_PRI = (prio & 0xFFU);
      break;
    case apb_timer_cmp_irq:
      PLIC_APB_TIMER_COMPARE_PRI = (prio & 0xFFU);
      break;
    case uart_irq:
      PLIC_UART_PRI = (prio & 0xFFU);
      break;
    case qspi_thresh_irq:
      PLIC_QSPI_THRESH_PRI = (prio & 0xFFU);
      break;
    case qspi_eot_irq:
      PLIC_QSPI_EOT_PRI = (prio & 0xFFU);
      break;
    case gpio_irq:
      PLIC_GPIO_PRI = (prio & 0xFFU);
      break;
    case ext_irq:
      PLIC_EXT_PRI = (prio & 0xFFU);
      break;
    default:
      // do nothing
  }
}

void plic_enable_irq(irq_source_e irq_source) {
  PLIC_IRQ_EN_M |= (1u << irq_source);
}


void plic_disable_irq(irq_source_e irq_source) {
  PLIC_IRQ_EN_M &= ~(1u << irq_source);
}