#include <stdint.h>

#include "marian.h"
#include "uart16550.h"

#ifdef SIM_UART

 #define FAKE_UART_ADDR 0xC0000000U
 #define FAKE_UART      *(volatile uint32_t*)(FAKE_UART_ADDR)

void _putchar(char character) {
  // send char to console
  FAKE_UART = character;
}

#else

// definition of putchar
void _putchar(char character) {
  // send to base of UART when in simulation
  transmit_char(character);
}

#endif
