/*
 * File      : runtime.c
 * Author(s) : Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
 *             Endrit Isufi   <endrit.isufi@tuni.fi>
 * Date      : 21-feb-2024
 * Description: Contains implementations of runtime functions
 * [TZS 19-jul-2024] Added default exception/trap handlers
 */

#include <stdint.h>

#include <riscv_vector.h>

#include "encoding.h"
#include "plic.h"
#include "printf.h"
#include "runtime.h"
#include "handlers.h"

// handlers defined within handlers.c
extern void (*irq_handler_u_soft)(void);
extern void (*irq_handler_s_soft)(void);
extern void (*irq_handler_vs_soft)(void);
extern void (*irq_handler_m_soft)(void);
extern void (*irq_handler_u_timer)(void);
extern void (*irq_handler_s_timer)(void);
extern void (*irq_handler_vs_timer)(void);
extern void (*irq_handler_m_timer)(void);
extern void (*irq_handler_u_ext)(void);
extern void (*irq_handler_s_ext)(void);
extern void (*irq_handler_vs_ext)(void);
extern void (*irq_handler_apb_timer_overflow)(void);
extern void (*irq_handler_apb_timer_compare)(void);
extern void (*irq_handler_uart)(void);
extern void (*irq_handler_qspi_thresh)(void);
extern void (*irq_handler_qspi_eot)(void);
extern void (*irq_handler_gpio)(void);
extern void (*irq_handler_ext)(void);

static uint64_t interrupt_id = 0;

// return latest ID
uint64_t get_trap_id(){return interrupt_id;}

// directed mode handler
void mtvec_handler(uint64_t mcause) {
  
  uint64_t id = mcause & 0x3ff;
  // update externally accessible id
  interrupt_id = id;

  if((mcause & (1UL << (__riscv_xlen - 1)))) {
    // interrupt
    switch (id) {
      case IRQ_U_SOFT:
        irq_handler_u_soft();
        break;
      case IRQ_S_SOFT:
        irq_handler_s_soft();
        break;
      case IRQ_VS_SOFT:
        irq_handler_vs_soft();
        break;
      case IRQ_M_SOFT:
        irq_handler_m_soft();
        break;
      case IRQ_U_TIMER:
        irq_handler_u_timer();
        break;
      case IRQ_S_TIMER:
        irq_handler_s_timer();
        break;
      case IRQ_VS_TIMER:
        irq_handler_vs_timer();
        break;
      case IRQ_M_TIMER:
        irq_handler_m_timer();
        break;
      case IRQ_U_EXT:
        irq_handler_u_ext();
        break;
      case IRQ_S_EXT:
        irq_handler_s_ext();
        break;
      case IRQ_VS_EXT:
        irq_handler_vs_ext();
        break;
      case IRQ_M_EXT:        
        
        volatile uint32_t plic_claim_id = PLIC_IRQ_CLAIM_M;
        
        switch (plic_claim_id) {
          case APB_TIMER_OVERFLOW_IRQ:
            irq_handler_apb_timer_overflow();
            break;
          case APB_TIMER_COMPARE_IRQ:
            irq_handler_apb_timer_compare();
            break;
          case UART_IRQ:
            irq_handler_uart();
            break;
          case QSPI_THRESH_IRQ:
            irq_handler_qspi_thresh();
            break;
          case QSPI_EOT_IRQ:
            irq_handler_qspi_eot();
            break;
          case GPIO_IRQ:
            irq_handler_gpio();
            break;
          case EXT_IRQ:
            irq_handler_ext();
            break;
          default:
            printf("[PLIC] Claimed UNKNOWN IRQ ID : 0x%016X%\n", id);
        }

        // write back claim to complete IRQ
        PLIC_IRQ_CLAIM_M = plic_claim_id;

        break;

      default:
        printf("[INTERRUPT ID 0x%016X] - UNKNOWN ID\n", id);
    }
  } else {
    // exception
    switch (id) {
      case CAUSE_MISALIGNED_FETCH:
        printf("[EXCEPTION ID 0x%016X] - CAUSE_MISALIGNED_FETCH\n", id);
        break;
      case CAUSE_FETCH_ACCESS:
        printf("[EXCEPTION ID 0x%016X] - CAUSE_FETCH_ACCESS\n", id);
        break;
      case CAUSE_ILLEGAL_INSTRUCTION:
        printf("[EXCEPTION ID 0x%016X] - CAUSE_ILLEGAL_INSTRUCTION\n", id);
        break;
      case CAUSE_BREAKPOINT:
        printf("[EXCEPTION ID 0x%016X] - CAUSE_BREAKPOINT\n", id);
        break;
      case CAUSE_MISALIGNED_LOAD:
        printf("[EXCEPTION ID 0x%016X] - CAUSE_MISALIGNED_LOAD\n", id);
        break;
      case CAUSE_LOAD_ACCESS:
        printf("[EXCEPTION ID 0x%016X] - CAUSE_LOAD_ACCESS\n", id);
        break;
      case CAUSE_MISALIGNED_STORE:
        printf("[EXCEPTION ID 0x%016X] - CAUSE_MISALIGNED_STORE\n", id);
        break;
      case CAUSE_STORE_ACCESS:
        printf("[EXCEPTION ID 0x%016X] - CAUSE_STORE_ACCESS\n", id);
        break;
      case CAUSE_USER_ECALL:
        printf("[EXCEPTION ID 0x%016X] - CAUSE_USER_ECALL\n", id);
        break;
      case CAUSE_SUPERVISOR_ECALL:
        printf("[EXCEPTION ID 0x%016X] - CAUSE_SUPERVISOR_ECALL\n", id);
        break;
      case CAUSE_VIRTUAL_SUPERVISOR_ECALL:
        printf("[EXCEPTION ID 0x%016X] - CAUSE_VIRTUAL_SUPERVISOR_ECALL\n", id);
        break;
      case CAUSE_MACHINE_ECALL:
        printf("[EXCEPTION ID 0x%016X] - CAUSE_MACHINE_ECALL\n", id);
        break;
      case CAUSE_FETCH_PAGE_FAULT:
        printf("[EXCEPTION ID 0x%016X] - CAUSE_FETCH_PAGE_FAULT\n", id);
        break;
      case CAUSE_LOAD_PAGE_FAULT:
        printf("[EXCEPTION ID 0x%016X] - CAUSE_LOAD_PAGE_FAULT\n", id);
        break;
      case CAUSE_STORE_PAGE_FAULT:
        printf("[EXCEPTION ID 0x%016X] - CAUSE_STORE_PAGE_FAULT\n", id);
        break;
      case CAUSE_FETCH_GUEST_PAGE_FAULT:
        printf("[EXCEPTION ID 0x%016X] - CAUSE_FETCH_GUEST_PAGE_FAULT\n", id);
        break;
      case CAUSE_LOAD_GUEST_PAGE_FAULT:
        printf("[EXCEPTION ID 0x%016X] - CAUSE_LOAD_GUEST_PAGE_FAULT\n", id);
        break;
      case CAUSE_VIRTUAL_INSTRUCTION:
        printf("[EXCEPTION ID 0x%016X] - CAUSE_VIRTUAL_INSTRUCTION\n", id);
        break;
      case CAUSE_STORE_GUEST_PAGE_FAULT:
        printf("[EXCEPTION ID 0x%016X] - CAUSE_STORE_GUEST_PAGE_FAULT\n", id);
        break;
      default: 
        printf("[EXCEPTION ID 0x%016X] - UNKNOWN EXCEPTION\n", id);
    }
    // return to fail loop
    return;
  }
  
}

void init_vrf(void) {

  volatile uint64_t vl = __riscv_vsetvl_e8m1(64);
  
  // prevent unused variable warnings
  (void)(vl);

  printf("\nLoading zeroes into VRF...\n");

  // splat vfrs with "0x0"
  asm volatile ("vmv.v.i v0,  0x0");
  asm volatile ("vmv.v.i v1,  0x0");
  asm volatile ("vmv.v.i v2,  0x0");
  asm volatile ("vmv.v.i v3,  0x0");
  asm volatile ("vmv.v.i v4,  0x0");
  asm volatile ("vmv.v.i v5,  0x0");
  asm volatile ("vmv.v.i v6,  0x0");
  asm volatile ("vmv.v.i v7,  0x0");
  asm volatile ("vmv.v.i v8,  0x0");
  asm volatile ("vmv.v.i v9,  0x0");
  asm volatile ("vmv.v.i v10, 0x0");
  asm volatile ("vmv.v.i v11, 0x0");
  asm volatile ("vmv.v.i v12, 0x0");
  asm volatile ("vmv.v.i v13, 0x0");
  asm volatile ("vmv.v.i v14, 0x0");
  asm volatile ("vmv.v.i v15, 0x0");
  asm volatile ("vmv.v.i v16, 0x0");
  asm volatile ("vmv.v.i v17, 0x0");
  asm volatile ("vmv.v.i v18, 0x0");
  asm volatile ("vmv.v.i v19, 0x0");
  asm volatile ("vmv.v.i v20, 0x0");
  asm volatile ("vmv.v.i v21, 0x0");
  asm volatile ("vmv.v.i v22, 0x0");
  asm volatile ("vmv.v.i v23, 0x0");
  asm volatile ("vmv.v.i v24, 0x0");
  asm volatile ("vmv.v.i v25, 0x0");
  asm volatile ("vmv.v.i v26, 0x0");
  asm volatile ("vmv.v.i v27, 0x0");
  asm volatile ("vmv.v.i v28, 0x0");
  asm volatile ("vmv.v.i v29, 0x0");
  asm volatile ("vmv.v.i v30, 0x0");
  asm volatile ("vmv.v.i v31, 0x0");
}
