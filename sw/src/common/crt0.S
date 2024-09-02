// Copyright 2020 ETH Zurich and University of Bologna.
//
// SPDX-License-Identifier: Apache-2.0
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Author: Samuel Riedel, ETH Zurich
//         Matheus Cavalcante, ETH Zurich
//         Tom Szymkowiak <thomas.szymkowiak@tuni.fi>

.globl _start
.globl _eoc
.globl _fail
.section .text;
.section .text.init;

#include "encoding.h"

// For the riscv-tests environment
.weak mtvec_handler
.weak stvec_handler
.weak rvtest_init

_start:
    // Initialize global pointer
    .option push
    .option norelax
    1:auipc gp, %pcrel_hi(__global_pointer$)
      addi  gp, gp, %pcrel_lo(1b)
    .option pop

    /* reset vector */
    j reset_vector
reset_vector:
    li      x1, 0
    li      x4, 0
    li      x5, 0
    li      x6, 0
    li      x7, 0
    li      x8, 0
    li      x9, 0
    li      x10, 0
    li      x11, 0
    li      x12, 0
    li      x13, 0
    li      x14, 0
    li      x15, 0
    li      x16, 0
    li      x17, 0
    li      x18, 0
    li      x19, 0
    li      x20, 0
    li      x10, 0
    li      x21, 0
    li      x22, 0
    li      x23, 0
    li      x24, 0
    li      x25, 0
    li      x26, 0
    li      x27, 0
    li      x28, 0
    li      x29, 0
    li      x30, 0
    li      x31, 0
    // Initialize stack at the end of the DRAM region
    la      t0, dram_end_address_reg
    ld      sp, 0(t0)
    // Set up a PMP to permit all accesses
    li t0, (1 << (31 + (__riscv_xlen / 64) * (53 - 31))) - 1
    csrw pmpaddr0, t0
    li t0, PMP_NAPOT | PMP_R | PMP_W | PMP_X
    csrw pmpcfg0, t0
    // Delegate no traps
    csrwi   mie, 0
    la      t0, trap_vector
    csrw    mtvec, t0
    csrwi   medeleg, 0
    csrwi   mideleg, 0
    // If an stvec_handler is defined, delegate exceptions to it
    la t0, stvec_handler
    beqz t0, 1f
    csrw stvec, t0
    li t0, (1 << CAUSE_LOAD_PAGE_FAULT) |  \
           (1 << CAUSE_STORE_PAGE_FAULT) | \
           (1 << CAUSE_FETCH_PAGE_FAULT) | \
           (1 << CAUSE_MISALIGNED_FETCH) | \
           (1 << CAUSE_USER_ECALL) |       \
           (1 << CAUSE_BREAKPOINT)
    csrw medeleg, t0
    .align 2
1:  csrwi mstatus, 0
    // Enable FP Extension
    li      t0, (MSTATUS_FS & (MSTATUS_FS >> 1))
    csrs    mstatus, t0
    csrwi   fcsr, 0
    // Enable Vector Extension
    li      t0, (MSTATUS_VS & (MSTATUS_VS >> 1))
    csrs    mstatus, t0
    // Enable the counters (IR, TIM, CY)
    csrsi   mcounteren, 7
    csrsi   scounteren, 7
    // Call the RISC-V Test initialization function, if it exists
    la t0, rvtest_init
    beqz t0, 1f
    jalr t0
#ifndef SIM_UART /* Don't configure UART in sim */
1:  // configure UART to basic settings
    jal     ra, uart_set_default_cfg
    // print logo and build info
    jal     ra, print_marian
#else
1:  // Call main
#endif
    // enable global M-Mode IRQs
    li       t0, MSTATUS_MIE
    csrs     mstatus, t0
    // enter main
    jal      ra, main
    // Return to _eoc
    j       _eoc

    .align 2
trap_vector:
    // Jump to the mtvec_handler, if it exists
    csrr a0, mcause
    la t5, mtvec_handler
    beqz t5, 1f
    // store context before jumping to handler
    addi sp,sp,-128
    sd ra, 0(sp)
    sd a0, 8(sp)
    sd a1, 16(sp)
    sd a2, 24(sp)
    sd a3, 32(sp)
    sd a4, 40(sp)
    sd a5, 48(sp)
    sd a6, 56(sp)
    sd a7, 64(sp)
    sd t0, 72(sp)
    sd t1, 80(sp)
    sd t2, 88(sp)
    sd t3, 96(sp)
    sd t4, 104(sp)
    sd t5, 112(sp)
    sd t6, 120(sp)
    // jump to handler
    jal  ra, mtvec_handler
    // restore context before executing mret
    ld ra, 0(sp)
    ld a0, 8(sp)
    ld a1, 16(sp)
    ld a2, 24(sp)
    ld a3, 32(sp)
    ld a4, 40(sp)
    ld a5, 48(sp)
    ld a6, 56(sp)
    ld a7, 64(sp)
    ld t0, 72(sp)
    ld t1, 80(sp)
    ld t2, 88(sp)
    ld t3, 96(sp)
    ld t4, 104(sp)
    ld t5, 112(sp)
    ld t6, 120(sp)
    addi sp,sp,128
    mret
1:  j _fail

    .align 2
_eoc:
    la t0, eoc_address_reg
    sd a0, 0(t0)
    jal x0, _eoc

    .align 2
_fail:
    la t0, eoc_address_reg
    sd a0, 0(t0)
    jal x0, _eoc

.section .data
