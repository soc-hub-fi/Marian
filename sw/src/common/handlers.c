/*
 * File      : handlers.c
 * Author(s) : Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
 * Date      : 20-jul-2024
 * Description: Contains implementations of default handlers and callbacks
 */

#include "encoding.h"
#include "handlers.h"
#include "printf.h"

// initialise handlers for achitectural irqs
void (*irq_handler_u_soft)(void)   = &default_irq_handler_u_soft;
void (*irq_handler_s_soft)(void)   = &default_irq_handler_s_soft;
void (*irq_handler_vs_soft)(void)  = &default_irq_handler_vs_soft;
void (*irq_handler_m_soft)(void)   = &default_irq_handler_m_soft;
void (*irq_handler_u_timer)(void)  = &default_irq_handler_u_timer;
void (*irq_handler_s_timer)(void)  = &default_irq_handler_s_timer;
void (*irq_handler_vs_timer)(void) = &default_irq_handler_vs_timer;
void (*irq_handler_m_timer)(void)  = &default_irq_handler_m_timer;
void (*irq_handler_u_ext)(void)    = &default_irq_handler_u_ext;
void (*irq_handler_s_ext)(void)    = &default_irq_handler_s_ext;
void (*irq_handler_vs_ext)(void)   = &default_irq_handler_vs_ext;
// Initialise PLIC handlers
void (*irq_handler_apb_timer_overflow)(void) = &default_irq_handler_apb_timer_overflow;
void (*irq_handler_apb_timer_compare)(void)  = &default_irq_handler_apb_timer_compare;
void (*irq_handler_uart)(void)               = &default_irq_handler_uart;
void (*irq_handler_qspi_thresh)(void)        = &default_irq_handler_qspi_thresh;
void (*irq_handler_qspi_eot)(void)           = &default_irq_handler_qspi_eot;
void (*irq_handler_gpio)(void)               = &default_irq_handler_gpio;
void (*irq_handler_ext)(void)                = &default_irq_handler_ext;

void default_irq_handler_u_soft(void) {
  printf("[INTERRUPT ID 0x%016X] - IRQ_U_SOFT default handler\n", IRQ_U_SOFT);
}

void default_irq_handler_s_soft(void) {
  printf("[INTERRUPT ID 0x%016X] - IRQ_S_SOFT default handler\n", IRQ_S_SOFT);
}

void default_irq_handler_vs_soft(void) {
  printf("[INTERRUPT ID 0x%016X] - IRQ_VS_SOFT default handler\n", IRQ_VS_SOFT);
}

void default_irq_handler_m_soft(void) {
  printf("[INTERRUPT ID 0x%016X] - IRQ_M_SOFT default handler\n", IRQ_M_SOFT);
}

void default_irq_handler_u_timer(void) {
  printf("[INTERRUPT ID 0x%016X] - IRQ_U_TIMER default handler\n", IRQ_U_TIMER);
}

void default_irq_handler_s_timer(void) {
  printf("[INTERRUPT ID 0x%016X] - IRQ_S_TIMER default handler\n", IRQ_S_TIMER);
}

void default_irq_handler_vs_timer(void) {
  printf("[INTERRUPT ID 0x%016X] - IRQ_VS_TIMER default handler\n", IRQ_VS_TIMER);
}

void default_irq_handler_m_timer(void) {
  printf("[INTERRUPT ID 0x%016X] - IRQ_M_TIMER default handler\n", IRQ_M_TIMER);
}

void default_irq_handler_u_ext(void) {
  printf("[INTERRUPT ID 0x%016X] - IRQ_U_EXT default handler\n", IRQ_U_EXT);
}

void default_irq_handler_s_ext(void) {
  printf("[INTERRUPT ID 0x%016X] - IRQ_S_EXT default handler\n", IRQ_S_EXT);
}

void default_irq_handler_vs_ext(void) {
  printf("[INTERRUPT ID 0x%016X] - IRQ_VS_EXT default handler\n", IRQ_VS_EXT);
}

void default_irq_handler_apb_timer_overflow(void) {
  printf("[PLIC] APB_TIMER_OVERFLOW_IRQ default handler\n");
}

void default_irq_handler_apb_timer_compare(void) {
  printf("[PLIC] APB_TIMER_COMPARE_IRQ default handler\n");
}

void default_irq_handler_uart(void) {
  printf("[PLIC] UART_IRQ default handler\n");
}

void default_irq_handler_qspi_thresh(void) {
  printf("[PLIC] QSPI_THRESH_IRQ default handler\n");
}

void default_irq_handler_qspi_eot(void) {
  printf("[PLIC] QSPI_EOT_IRQ default handler\n");
}

void default_irq_handler_gpio(void) {
  printf("[PLIC] GPIO_IRQ default handler\n");
}

void default_irq_handler_ext(void) {
  printf("[PLIC] EXT_IRQ default handler\n");
}

void register_callback_irq_handler_u_soft(void (*new_handler)(void)) {
  irq_handler_u_soft = new_handler;
}

void register_callback_irq_handler_s_soft(void (*new_handler)(void)) {
  irq_handler_s_soft = new_handler;
}

void register_callback_irq_handler_vs_soft(void (*new_handler)(void)) {
  irq_handler_vs_soft = new_handler;
}

void register_callback_irq_handler_m_soft(void (*new_handler)(void)) {
  irq_handler_m_soft = new_handler;
}

void register_callback_irq_handler_u_timer(void (*new_handler)(void)) {
  irq_handler_u_timer = new_handler;
}

void register_callback_irq_handler_s_timer(void (*new_handler)(void)) {
  irq_handler_s_timer = new_handler;
}

void register_callback_irq_handler_vs_timer(void (*new_handler)(void)) {
  irq_handler_vs_timer = new_handler;
}

void register_callback_irq_handler_m_timer(void (*new_handler)(void)) {
  irq_handler_m_timer = new_handler;
}

void register_callback_irq_handler_u_ext(void (*new_handler)(void)) {
  irq_handler_u_ext = new_handler;
}

void register_callback_irq_handler_s_ext(void (*new_handler)(void)) {
  irq_handler_s_ext = new_handler;
}

void register_callback_irq_handler_vs_ext(void (*new_handler)(void)) {
  irq_handler_vs_ext = new_handler;
}

void register_callback_irq_handler_apb_timer_overflow(void (*new_handler)(void)) {
  irq_handler_apb_timer_overflow = new_handler;
}

void register_callback_irq_handler_apb_timer_compare(void (*new_handler)(void)) {
  irq_handler_apb_timer_compare = new_handler;
}

void register_callback_irq_handler_uart(void (*new_handler)(void)) {
  irq_handler_uart = new_handler;
}

void register_callback_irq_handler_qspi_thresh(void (*new_handler)(void)) {
  irq_handler_qspi_thresh = new_handler;
}

void register_callback_irq_handler_qspi_eot(void (*new_handler)(void)) {
  irq_handler_qspi_eot = new_handler;
}

void register_callback_irq_handler_gpio(void (*new_handler)(void)) {
  irq_handler_gpio = new_handler;
}

void register_callback_irq_handler_ext(void (*new_handler)(void)) {
  irq_handler_ext = new_handler;
}