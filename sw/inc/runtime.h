#ifndef _RUNTIME_H_
#define _RUNTIME_H_

#include <stdint.h>

/**
 * @brief Splats all VRF registers with zero. 
 * Intended to avoid avoid x's in simulation. 
 * 
 */
void init_vrf(void);

#define ENABLE_VEC                                                             \
  asm volatile(                                                                \
      "csrs mstatus, %[bits];" ::[bits] "r"(0x00000600 & (0x00000600 >> 1)))

extern int64_t event_trigger;
extern int64_t timer;

// SoC-level CSR
extern uint64_t hw_cnt_en_reg;

// Return the current value of the cycle counter
inline static int64_t get_cycle_count(void) {
  int64_t cycle_count;
  // The fence is needed to be sure that Ara is idle, and it is not performing
  // the last vector stores when we read mcycle with stop_timer()
  asm volatile("fence; csrr %[cycle_count], cycle"
               : [cycle_count] "=r"(cycle_count));
  return cycle_count;
};

#ifndef SPIKE
// Enable and disable the hw-counter
// Until the HW counter is not enabled, it will not start
// counting even if a vector instruction is dispatched
// Enabling the HW counter does NOT mean that the hardware
// will start counting, but simply that it will be able to start.
#define HW_CNT_READY hw_cnt_en_reg = 1;
#define HW_CNT_NOT_READY hw_cnt_en_reg = 0;

// enable gloabl interrupts and machine timer interrupt
inline static void start_timer(void)
{ 
  //enable global interrupts
  asm volatile("li t0, 0x8");
  asm volatile("csrs mstatus, t0"); //enable global interrupts MIE
  //enable machine timer in
  asm volatile("li t0, 0x80");
  asm volatile("csrs mie, t0"); // enable machine timer interrupts MTIE
  // reset timer
  timer = -get_cycle_count(); //unused
}

// enable global interrupts and machine external interrupts
inline static void enable_plic(void)
{ 
  //enable global interrupts
  asm volatile("li t0, 0x8");
  asm volatile("csrs mstatus, t0"); //enable global interrupts MIE
  //enable machine timer in
  asm volatile("li t0, 0x800");
  asm volatile("csrs mie, t0"); // enable machine external interrupts MEIE
}

inline static void enable_clint_sw_interrupts(void)
{
    //enable global interrupts
  asm volatile("li t0, 0x8");
  asm volatile("csrs mstatus, t0"); //enable global interrupts MIE
  //enable sw interrupts 
  asm volatile("li t0, 0x8");
  asm volatile("csrs mie, t0"); // enable machine software interrupts MSIE
}

inline static void stop_timer(void) { timer += get_cycle_count(); }

// Get the value of the timer
inline static int64_t get_timer(void) { return timer; }
#else
#define HW_CNT_READY ;
#define HW_CNT_NOT_READY ;
// Start and stop the counter
inline static void start_timer(void) {
  while (0)
    ;
}
inline static void stop_timer(void) {
  while (0)
    ;
}

// Get the value of the timer
inline int64_t get_timer() { return 0; }
#endif

/**
 * @brief Delay execution for a defined number of CPU cycles. Can be used as a dirty wait.
 * 
 * @param cycles Number of cycles to delay
 */
inline static void delay_cycles(uint32_t cycles) {
  for(uint32_t i = 0; i < cycles; i++) {
    asm volatile("nop");
  }
}

#endif // _RUNTIME_H_


