//******************************************************************************
// File      : handlers.h
// Author(s) : Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Date      : 20-jul-2024
// Description: Header file for default handlers and callbacks
//******************************************************************************

#ifndef __HANDLERS_H__
#define __HANDLERS_H__

#include <stdint.h>

void default_irq_handler_u_soft(void);
void default_irq_handler_s_soft(void);
void default_irq_handler_vs_soft(void);
void default_irq_handler_m_soft(void);
void default_irq_handler_u_timer(void);
void default_irq_handler_s_timer(void);
void default_irq_handler_vs_timer(void);
void default_irq_handler_m_timer(void);
void default_irq_handler_u_ext(void);
void default_irq_handler_s_ext(void);
void default_irq_handler_vs_ext(void);
// PLIC default handlers
void default_irq_handler_apb_timer_overflow(void);
void default_irq_handler_apb_timer_compare(void);
void default_irq_handler_uart(void);
void default_irq_handler_qspi_thresh(void);
void default_irq_handler_qspi_eot(void);
void default_irq_handler_gpio(void);
void default_irq_handler_ext(void);

// callback registration functions which can be used to assign custom
// IRQ handlers
void register_callback_irq_handler_u_soft(void (*new_handler)(void));
void register_callback_irq_handler_s_soft(void (*new_handler)(void));
void register_callback_irq_handler_vs_soft(void (*new_handler)(void));
void register_callback_irq_handler_m_soft(void (*new_handler)(void));
void register_callback_irq_handler_u_timer(void (*new_handler)(void));
void register_callback_irq_handler_s_timer(void (*new_handler)(void));
void register_callback_irq_handler_vs_timer(void (*new_handler)(void));
void register_callback_irq_handler_m_timer(void (*new_handler)(void));
void register_callback_irq_handler_u_ext(void (*new_handler)(void));
void register_callback_irq_handler_s_ext(void (*new_handler)(void));
void register_callback_irq_handler_vs_ext(void (*new_handler)(void));
void register_callback_irq_handler_apb_timer_overflow(void (*new_handler)(void));
void register_callback_irq_handler_apb_timer_compare(void (*new_handler)(void));
void register_callback_irq_handler_uart(void (*new_handler)(void));
void register_callback_irq_handler_qspi_thresh(void (*new_handler)(void));
void register_callback_irq_handler_qspi_eot(void (*new_handler)(void));
void register_callback_irq_handler_gpio(void (*new_handler)(void));
void register_callback_irq_handler_ext(void (*new_handler)(void));

#endif // __HANDLERS_H__