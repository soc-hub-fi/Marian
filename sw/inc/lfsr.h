/*
 * File      : lfsr.h
 * Author(s) : Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
 * Date      : 14-jun-2024
 * Description: Definitions for LFSR implementations
 */

#ifndef __LFSR_H__
#define __LFSR_H__

#include <stdint.h>

/**
 * @brief poll 8-bit galois-lfsr with polynomial x^8+x^6+x^5+x^4+1. 
 * Performs internal LFSR shift
 * 
 * @return uint8_t pseudo-random value
 */
uint8_t poll_rnd8(void);

/**
 * @brief poll 16-bit galois-lfsr with polynomial x^16+x^15+x^13+x^4+1. 
 * Performs internal LFSR shift
 * 
 * @return uint16_t pseudo-random value
 */
uint16_t poll_rnd16(void);

/**
 * @brief poll 32-bit galois-lfsr with polynomial x^32+x^30+x^26+x^25+1. 
 * Performs internal LFSR shift
 * 
 * @return uint32_t pseudo-random value
 */
uint32_t poll_rnd32(void);

/**
 * @brief poll 64-bit galois-lfsr with polynomial x^64+x^63+x^61+x^60+1. 
 * Performs internal LFSR shift
 * 
 * @return uint64_t pseudo-random value
 */
uint64_t poll_rnd64(void);

#endif