/*
 * File      : main.c
 * Author(s) : Endrit Isufi <endrit.isufi@tuni.fi>
 *
 * Date      : 5-June-2024
 * Description: Test machine timer & SW interrupts
 *              
 */
#include "clint.h"

/*
@brief configures and runs a timer interrupt test.
@param mtimecmp - timer interrupt executed once CLINT timer reaches this value
*/
void timer_trap_test(uint64_t mtimecmp)
{

  int64_t mcause;
  __asm__ volatile("csrr %0, mcause" : "=r"(mcause));
  int id = mcause & 0x3ff;
  printf("[CLINT] TIMER Interrupt Start\n");
  set_timer(mtimecmp); // set mtimecmp reg.
  start_timer(); // set mip, mie, reset timer var.
  while(id != 7u)// loop until timer is triggered
  {
    id = get_trap_id();
  } 
  
  printf("[CLINT] TIMER Interrupt Passed\n");
}

/*
@brief configures and executes a software interrupt(inter-process-interrupt)test
*/
void sw_trap_test()
{
  int64_t mcause;
  __asm__ volatile("csrr %0, mcause" : "=r"(mcause));
  uint64_t id = mcause & 0x3ff;

  printf("[CLINT] SW Interrupt START\n");
  enable_clint_sw_interrupts();
  CLINT_IPI_REG = 0xf; //trigger sw interrupt
  printf("\n");
  while(id != 3ul) //loop until interrupt handler executed
  {
    id = get_trap_id();
  } // run until timer is triggered
  printf("[CLINT SW] Interrupt Passed\n");

}


int main(void) {

  //timer_trap_test(7u);
  sw_trap_test();
  return 0;
}
