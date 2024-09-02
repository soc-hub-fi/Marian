
/*!
@defgroup test_utils Test Utils
@{
*/


#ifndef __SHARE_BENCHMARKS_H__
#define __SHARE_BENCHMARKS_H__

#include <stddef.h>
#include <stdint.h>

#include "printf.h"

//! Length of test input for a hash function.
#define TEST_HASH_INPUT_LENGTH 1024

//! Number of times test will be repeated
#define TEST_COUNT 1

typedef struct {
    uint64_t icount [TEST_COUNT]; // insns count
    uint64_t ccount [TEST_COUNT]; // cycle count
    uint64_t icount_average;
    uint64_t ccount_average;
} perf_log_t;

/**
 * @brief calculate mean average of array
 * 
 * @param count_arr array containing values to be averaged
 * @return uint64_t mean average
 */
uint64_t average_count(uint64_t* count_arr);

//
// Misc
// ----------------------------------------------------------------------

/*!
@brief Prints a 64-bit input as hex to stdout.
@details Prints in LITTLE ENDIAN mode.
@param [in] in - The thing to print.
*/
void puthex64(uint64_t in);


/*!
@brief Prints a byte string as hex to std out in little endian mode.
@param [in] in - The byte string to print.
@param [in] len - Length of the string to print.
*/
void puthex(unsigned char * in, size_t len);


/*!
@brief Prints a byte string such that it can be read by a python program as
    a giant literal.
@param [in] in - The byte string to print.
@param [in] len - Length of the string to print.
*/
void puthex_py(unsigned char * in, size_t len);


/*!
@brief Read len random bytes into dest.
*/
size_t test_rdrandom(unsigned char * dest, size_t len);



//
// Low level register access.
// ------------------------------------------------------------------

inline static uint64_t test_rdinstret() {
    uint64_t result = 0;

#if ( __riscv_xlen == 32 )

    uint32_t hi1,hi2,lo;

    do {
        asm volatile (
            "rdinstreth %0;"
            "rdinstret  %1;" 
            "rdinstreth %2;" 
            : "=r"(hi1), "=r"(lo), "=r"(hi2)
        );
    } while(hi1 != hi2);

    result = (((uint64_t)hi1) << 32) | lo;

#elif ( __riscv_xlen == 64 )
        
    asm volatile (
        "rdinstret  %0;" 
        : "=r"(result)
    );

#else
    #error "Unsupported RISC-V XLEN: __riscv_xlen, expected 32 or 64"
#endif

    return result;
}


inline static uint64_t test_rdcycle() {
    uint64_t result = 0;

#if ( __riscv_xlen == 32 )

    uint32_t hi1,hi2,lo;

    do {
        __asm__ volatile (
            "rdcycleh %0;"
            "rdcycle  %1;" 
            "rdcycleh %2;" 
            : "=r"(hi1), "=r"(lo), "=r"(hi2)
            : 
        );
    } while(hi1 != hi2);

    result = (((uint64_t)hi1) << 32) | lo;

#elif ( __riscv_xlen == 64 )
        
    __asm__ volatile (
        "rdcycle  %0;" 
        : "=r"(result)
        : 
    );

#else
    #error "Unsupported RISC-V XLEN: __riscv_xlen, expected 32 or 64"
#endif

    return result;
}

inline static uint64_t test_rdtime() {
    uint64_t result = 0;

#if ( __riscv_xlen == 32 )

    uint32_t hi1,hi2,lo;

    do {
        __asm__ volatile (
            "rdtimeh %0;"
            "rdtime  %1;" 
            "rdtimeh %2;" 
            : "=r"(hi1), "=r"(lo), "=r"(hi2)
            : 
        );
    } while(hi1 != hi2);

    result = (((uint64_t)hi1) << 32) | lo;

#elif ( __riscv_xlen == 64 )
        
    __asm__ volatile (
        "rdtime  %0;" 
        : "=r"(result)
        : 
    );

#else
    #error "Unsupported RISC-V XLEN: __riscv_xlen, expected 32 or 64"
#endif

    return result;
}

#endif

//! @}
