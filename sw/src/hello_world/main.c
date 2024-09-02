/*
 * File      : main.c
 * Test      : hello_world
 * Author(s) : Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
 * Date      : 03-jan-2024
 * Description: Main source file for the embedded software project.
 *
 * This file contains the entry point (main function) for the embedded
 * application. It initializes the system, configures peripherals, and
 * enters the main application loop. Modify this file to add your
 * application-specific code.
 *
 */

#include "printf.h"

int main(void) {

  printf("Hello from Marian!\r\n");

  return 0;
}
