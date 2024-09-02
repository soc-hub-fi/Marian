/*
 * File      : lfsr.c
 * Author(s) : Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
 * Date      : 14-jun-2024
 * Description: Implementation of multiple maximal length linear feedback shift
 *              registers for easy pseudo-random number generation 
 */

#include "lfsr.h"

// varying precision lfsr values initialised with a random seed
static uint8_t  _lfsr8  = (uint8_t)(0xDF);
static uint16_t _lfsr16 = (uint16_t)(0x12972);
static uint32_t _lfsr32 = (uint32_t)(0x8AA110028);
static uint64_t _lfsr64 = (uint64_t)(0x4E25EC9EE92F96F4);

uint8_t poll_rnd8(void) {

  uint8_t lsb = _lfsr8 & 0x1u;
  _lfsr8 >>= 1;
  
  if(lsb) {
    _lfsr8 ^= (uint8_t)(0xB8);
  }

  return _lfsr8;
}

uint16_t poll_rnd16(void) {

  uint16_t lsb = _lfsr16 & 0x1u;
  _lfsr16 >>= 1;
  
  if(lsb) {
    _lfsr16 ^= (uint16_t)(0xD008);
  }

  return _lfsr16;

}

uint32_t poll_rnd32(void) {

  uint32_t lsb = _lfsr32 & 0x1u;
  _lfsr32 >>= 1;
  
  if(lsb) {
    _lfsr32 ^= (uint32_t)(0xA3000000);
  }

  return _lfsr32;

}

uint64_t poll_rnd64(void) {

  uint64_t lsb = _lfsr64 & 0x1lu;
  _lfsr64 >>= 1;
  
  if(lsb) {
    _lfsr64 ^= (uint64_t)(0xD800000000000000UL);
  }

  return _lfsr64;

}