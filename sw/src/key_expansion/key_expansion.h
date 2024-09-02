/*
 * File      : key_expansion.h
 * Test      : key_expansion
 * Author(s) : Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
 * Date      : 31-jan-2024
 * Description: Types/Constants to support the key expansion test.
 */

#ifndef __KEY_EXPANSION_H__
#define __KEY_EXPANSION_H__

#include <stdint.h>

  // from FIPS 197, Appendix A.1
  static uint32_t aes128_cipher_key[4] __attribute__((aligned(32))) = {    
    0x16157E2B, 
    0xA6D2AE28, 
    0x8815F7AB, 
    0x3C4FCF09
  };

  // from FIPS 197, Appendix A.3
  static uint32_t aes256_cipher_key[8] __attribute__((aligned(32))) = {    
    0x10EB3D60,
    0xBE71CA15,
    0xF0AE732B,
    0x81777D85,
    0x072C351F,
    0xD708613B,
    0xA310982D,
    0xF4DF1409
  };

  // from FIPS 197, Appendix A.1 used to verify output
  static uint32_t aes128_reference_keys[44] __attribute__((aligned(32))) = { 
    0x16157E2B, 0xA6D2AE28, 0x8815F7AB, 0x3C4FCF09,
    0x17FEFAA0, 0xB12C5488, 0x3939A323, 0x05766C2A,
    0xF295C2F2, 0x43B9967A, 0x7A803559, 0x7FF65973,
    0x7D47803D, 0x3EFE1647, 0x447E231E, 0x3B887A6D,
    0x41A544EF, 0x7F5B52A8, 0x3B2571B6, 0x00AD0BDB,
    0xF8C6D1D4, 0x879D837C, 0xBCB8F2CA, 0xBC15F911,
    0x7AA3886D, 0xFD3E0B11, 0x4186F9DB, 0xFD9300CA,
    0x0EF7544E, 0xF3C95F5F, 0xB24FA684, 0x4FDCA64E,
    0x2173D2EA, 0xD2BA8DB5, 0x60F52B31, 0x2F298D7F,
    0xF36677AC, 0x21DCFA19, 0x4129D128, 0x6E005C57,
    0xA8F914D0, 0x8925EEC9, 0xC80C3FE1, 0xA60C63B6
  };

  // from FIPS 197, Appendix A.3 used to verify output
  static uint32_t aes256_reference_keys[60] __attribute__((aligned(32))) = { 
    0x10EB3D60, 0xBE71CA15, 0xF0AE732B, 0x81777D85,
    0x072C351F, 0xD708613B, 0xA310982D, 0xF4DF1409,
    0x1154A39B, 0xAF25698E, 0x5F8B1AA5, 0xDEFC6720,
    0x1A9CB0A8, 0xCD94D193, 0x6E8449BE, 0x9A5B5DB7,
    0xB8EC9AD5, 0x17C9F35B, 0x4842E9FE, 0x96BE8EDE,
    0x8A32A9B5, 0x47A67826, 0x29223198, 0xB3796C2F,
    0xAD812C81, 0xBA48DFDA, 0xF20A3624, 0x64B4B8FA,
    0xC9BFC598, 0x8E19BDBE, 0xA73B8C26, 0x1442E009,
    0xAC7B0068, 0x1633DFB2, 0xE439E996, 0x808D516C,
    0x04E214C8, 0x8AFBA976, 0x2DC02550, 0x3982C559,
    0x676913DE, 0x715ACC6C, 0x956325FA, 0x15EE7496,
    0x5DCA8658, 0xD7312F2E, 0xFAF10A7E, 0xC373CF27,
    0xAB479C74, 0xDA1D5018, 0x4F7E75E2, 0x5A900174,
    0xE3AAFACA, 0x349BD5E4, 0xCE6ADF9A, 0x0D1910BD,
    0xD19048FE, 0x0B8D18E6, 0x44F36D04, 0x1E636C70
  };

  static uint32_t aes128_round_keys[44] __attribute__((aligned(32))) = {    
    0,0,0,0,
    0,0,0,0,
    0,0,0,0,
    0,0,0,0,
    0,0,0,0,
    0,0,0,0,
    0,0,0,0,
    0,0,0,0,
    0,0,0,0,
    0,0,0,0,
    0,0,0,0
  };

  static uint32_t aes256_round_keys[60] __attribute__((aligned(32))) = {    
    0,0,0,0,
    0,0,0,0,
    0,0,0,0,
    0,0,0,0,
    0,0,0,0,
    0,0,0,0,
    0,0,0,0,
    0,0,0,0,
    0,0,0,0,
    0,0,0,0,
    0,0,0,0,
    0,0,0,0,
    0,0,0,0,
    0,0,0,0,
    0,0,0,0
  };

#endif // __KEY_EXPANSION_H__