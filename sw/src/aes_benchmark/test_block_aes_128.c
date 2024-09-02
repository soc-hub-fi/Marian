/*
 * File      : test_block_aes.c
 * Test      : aes_benchmark
 * Author(s) : Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
 * Date      : 30-jun-2024
 * Description: Basic benchmarking of AES128/256 running in ECB mode. Most code 
 * taken from OpenSSL.
 */

#include <stdlib.h>
#include <string.h>

#include "printf.h"
#include "runtime.h"

#include "crypto/share/benchmarks.h"
#include "crypto/share/util.h"

#include "crypto/aes/api_aes.h"
#include "crypto/aes/zvkned.h"

#define AES_VARIANT_128
#define AES_VARIANT_256

typedef struct {
  // scalar AES128
  perf_log_t aes128_scalar_kse;
  perf_log_t aes128_scalar_enc;
  perf_log_t aes128_scalar_ksd;
  perf_log_t aes128_scalar_dec;
  // scalar AES256
  perf_log_t aes256_scalar_kse;
  perf_log_t aes256_scalar_enc;
  perf_log_t aes256_scalar_ksd;
  perf_log_t aes256_scalar_dec;
  // vector AES128
  perf_log_t aes128_vector_kse;
  perf_log_t aes128_vector_enc;
  perf_log_t aes128_vector_ksd;
  perf_log_t aes128_vector_dec;
  perf_log_t aes128_vector_enfull;
  perf_log_t aes128_vector_defull;
  // vector AES256
  perf_log_t aes256_vector_kse;
  perf_log_t aes256_vector_enc;
  perf_log_t aes256_vector_ksd;
  perf_log_t aes256_vector_dec;
  perf_log_t aes256_vector_enfull;
  perf_log_t aes256_vector_defull;
} aes_perf_log_t;

static uint8_t key_128 [AES_128_KEY_BYTES] __attribute__((aligned(16))) = {0};

static uint8_t key_256 [AES_256_KEY_BYTES] __attribute__((aligned(16))) = {0};

static uint8_t pt [AES_BLOCK_BYTES] __attribute__((aligned(16))) = {0};

static uint8_t pt2_scalar_128 [AES_BLOCK_BYTES] __attribute__((aligned(16))) = {0};
static uint8_t pt2_vector_128 [AES_BLOCK_BYTES] __attribute__((aligned(16))) = {0};
static uint8_t pt2_scalar_256 [AES_BLOCK_BYTES] __attribute__((aligned(16))) = {0};
static uint8_t pt2_vector_256 [AES_BLOCK_BYTES] __attribute__((aligned(16))) = {0};

static uint8_t ct_scalar_128 [AES_BLOCK_BYTES] __attribute__((aligned(16))) = {0};
static uint8_t ct_vector_128 [AES_BLOCK_BYTES] __attribute__((aligned(16))) = {0};
static uint8_t ct_scalar_256 [AES_BLOCK_BYTES] __attribute__((aligned(16))) = {0};
static uint8_t ct_vector_256 [AES_BLOCK_BYTES] __attribute__((aligned(16))) = {0};


static aes_perf_log_t perf_log = {0}; 

void print_elems(const char* name, const uint32_t* arr, const size_t n) {

  printf("\n%s:\n", name);

  for(size_t idx = 0; idx < n; idx++) {
    printf("# [%02lu] - 0x%08X\n", idx, arr[idx]);
  }
}

void test_aes_128(int num_tests) {

  uint32_t erk [AES_128_RK_WORDS] __attribute__((aligned(16))); //!< Roundkeys (encrypt)
  uint32_t drk [AES_128_RK_WORDS] __attribute__((aligned(16))); //!< Roundkeys (decrypt)

  AES_KEY aes128_enc_key = {.rd_key = {0}, .rounds = AES_128_NR};
  AES_KEY aes128_dec_key = {.rd_key = {0}, .rounds = AES_128_NR};
  

  uint64_t start_instrs;
  uint64_t start_cycles;

  memset(pt2_scalar_128, 0, AES_BLOCK_BYTES);
  memset(ct_scalar_128, 0, AES_BLOCK_BYTES);

  for(int i = 0; i < num_tests; i ++) {

    init_vrf();

    printf("#\n#\n# AES 128 Scalar test %d/%d:\n",i+1 , num_tests);

    print_elems("# Scalar 128 - Key", (uint32_t*)(key_128), (AES_128_KEY_BYTES/4));
    print_elems("# Scalar 128 - Plaintext1", (uint32_t*)(pt), (AES_BLOCK_BYTES/4));

    start_instrs        = test_rdinstret();
    start_cycles        = test_rdcycle();
    //aes_128_enc_key_schedule(erk, key_128);
    AES_set_encrypt_key_openssl(key_128, AES128_BITS, &aes128_enc_key);
    uint64_t kse_icount = test_rdinstret() - start_instrs;
    uint64_t kse_ccount = test_rdcycle() - start_cycles;
    perf_log.aes128_scalar_kse.icount[i] = kse_icount;
    perf_log.aes128_scalar_kse.ccount[i] = kse_ccount;

    //print_elems("# Scalar 128 - Expanded Enc Key DEFAULT", (uint32_t*)(erk), AES_128_RK_WORDS);
    print_elems("# Scalar 128 - Expanded Enc Key OPENSSL", (uint32_t*)(aes128_enc_key.rd_key), AES_128_RK_WORDS);

    start_instrs        = test_rdinstret();
    start_cycles        = test_rdcycle();
    //aes_128_ecb_encrypt(ct_scalar_128 , pt, erk);
    AES_encrypt_openssl(pt, ct_scalar_128, &aes128_enc_key);
    uint64_t enc_icount = test_rdinstret() - start_instrs;
    uint64_t enc_ccount = test_rdcycle() - start_cycles;
    perf_log.aes128_scalar_enc.icount[i] = enc_icount;
    perf_log.aes128_scalar_enc.ccount[i] = enc_ccount;

    //print_elems("# Scalar 128 - Ciphertext DEFAULT", (uint32_t*)(ct_scalar_128), (AES_BLOCK_BYTES/4));
    print_elems("# Scalar 128 - Ciphertext OPENSSL", (uint32_t*)(ct_scalar_128), (AES_BLOCK_BYTES/4));
      
    start_instrs        = test_rdinstret();
    start_cycles        = test_rdcycle();
    //aes_128_dec_key_schedule(drk, key_128);
    AES_set_decrypt_key_openssl(key_128, AES128_BITS, &aes128_dec_key); 
    uint64_t ksd_icount = test_rdinstret() - start_instrs;
    uint64_t ksd_ccount = test_rdcycle() - start_cycles;
    perf_log.aes128_scalar_ksd.icount[i] = ksd_icount;
    perf_log.aes128_scalar_ksd.ccount[i] = ksd_ccount;

    //print_elems("# Scalar 128 - Expanded Dec Key DEFAULT", (uint32_t*)(drk), AES_128_RK_WORDS);
    print_elems("# Scalar 128 - Expanded Dec Key OPENSSL", (uint32_t*)(aes128_dec_key.rd_key), AES_128_RK_WORDS);

    start_instrs        = test_rdinstret();
    start_cycles        = test_rdcycle();
    //aes_128_ecb_decrypt(pt2_scalar_128, ct_scalar_128, drk);
    AES_decrypt_openssl(ct_scalar_128, pt2_scalar_128, &aes128_enc_key); // FIXME: Why doesn't this work using the decrypt key
    uint64_t dec_icount = test_rdinstret() - start_instrs;
    uint64_t dec_ccount = test_rdcycle() - start_cycles;
    perf_log.aes128_scalar_dec.icount[i] = dec_icount;
    perf_log.aes128_scalar_dec.ccount[i] = dec_ccount;

    //print_elems("# Scalar 128 - Plaintext2 DEFAULT", (uint32_t*)(pt2_scalar_128), (AES_BLOCK_BYTES/4));
    print_elems("# Scalar 128 - Plaintext2 OPENSSL", (uint32_t*)(pt2_scalar_128), (AES_BLOCK_BYTES/4));
      
    printf("#\n#\tinstret:\n");
    printf("#\t\tenc_key_schedule = %020lu\n", kse_icount);
    printf("#\t\tecb_encrypt      = %020lu\n", enc_icount);
    printf("#\t\tdec_key_schedule = %020lu\n", ksd_icount);
    printf("#\t\tecb_decrypt      = %020lu\n", dec_icount);
    printf("#\tcycles:\n");
    printf("#\t\tenc_key_schedule = %020lu\n", kse_ccount);
    printf("#\t\tecb_encrypt      = %020lu\n", enc_ccount);
    printf("#\t\tdec_key_schedule = %020lu\n", ksd_ccount);
    printf("#\t\tecb_decrypt      = %020lu\n", dec_ccount);

  }
}

void test_aes_256(int num_tests) {

  uint32_t erk [AES_256_RK_WORDS] __attribute__((aligned(16))); //!< Roundkeys (encrypt)
  uint32_t drk [AES_256_RK_WORDS] __attribute__((aligned(16))); //!< Roundkeys (decrypt)

  AES_KEY aes256_enc_key = {.rd_key = {0}, .rounds = AES_256_NR};
  AES_KEY aes256_dec_key = {.rd_key = {0}, .rounds = AES_256_NR};

  uint64_t start_instrs;
  uint64_t start_cycles;

  memset(pt2_scalar_256, 0, AES_BLOCK_BYTES);
  memset(ct_scalar_256, 0, AES_BLOCK_BYTES);

  for(int i = 0; i < num_tests; i ++) {

    init_vrf();

    printf("#\n#\n# AES 256 Scalar test %d/%d:\n",i+1 , num_tests);

    print_elems("# Scalar 256 - Key", (uint32_t*)(key_256), (AES_256_KEY_BYTES/4));
    print_elems("# Scalar 256 - Plaintext1", (uint32_t*)(pt), (AES_BLOCK_BYTES/4));

    start_instrs        = test_rdinstret();
    start_cycles        = test_rdcycle();
    //aes_256_enc_key_schedule(erk, key_256);
    AES_set_encrypt_key_openssl(key_256, AES256_BITS, &aes256_enc_key);
    uint64_t kse_icount = test_rdinstret() - start_instrs;
    uint64_t kse_ccount = test_rdcycle() - start_cycles;
    perf_log.aes256_scalar_kse.icount[i] = kse_icount;
    perf_log.aes256_scalar_kse.ccount[i] = kse_ccount;

    //print_elems("# Scalar 256 - Expanded Enc Key", (uint32_t*)(erk), AES_256_RK_WORDS);
    print_elems("# Scalar 256 - Expanded Enc Key OPENSSL", (uint32_t*)(aes256_enc_key.rd_key), AES_256_RK_WORDS);

    start_instrs        = test_rdinstret();
    start_cycles        = test_rdcycle();
    //aes_256_ecb_encrypt(ct_scalar_256 , pt, erk);
    AES_encrypt_openssl(pt, ct_scalar_256, &aes256_enc_key);
    uint64_t enc_icount = test_rdinstret() - start_instrs;
    uint64_t enc_ccount = test_rdcycle() - start_cycles;
    perf_log.aes256_scalar_enc.icount[i] = enc_icount;
    perf_log.aes256_scalar_enc.ccount[i] = enc_ccount;
    
    //print_elems("# Scalar 256 - Ciphertext", (uint32_t*)(ct_scalar_256), (AES_BLOCK_BYTES/4));
    print_elems("# Scalar 256 - Ciphertext OPENSSL", (uint32_t*)(ct_scalar_256), (AES_BLOCK_BYTES/4));

    start_instrs        = test_rdinstret();
    start_cycles        = test_rdcycle();
    //aes_256_dec_key_schedule(drk, key_256);
    AES_set_decrypt_key_openssl(key_256, AES256_BITS, &aes256_dec_key); 
    uint64_t ksd_icount = test_rdinstret() - start_instrs;
    uint64_t ksd_ccount = test_rdcycle() - start_cycles;
    perf_log.aes256_scalar_ksd.icount[i] = ksd_icount;
    perf_log.aes256_scalar_ksd.ccount[i] = ksd_ccount;

    //print_elems("# Scalar 256 - Expanded Dec Key", (uint32_t*)(drk), AES_256_RK_WORDS);
    print_elems("# Scalar 256 - Expanded Dec Key OPENSSL", (uint32_t*)(aes256_dec_key.rd_key), AES_256_RK_WORDS);

    start_instrs        = test_rdinstret();
    start_cycles        = test_rdcycle();
    //aes_256_ecb_decrypt(pt2_scalar_256, ct_scalar_256, drk);
    AES_decrypt_openssl(ct_scalar_256, pt2_scalar_256, &aes256_enc_key); // FIXME: Why doesn't this work using the decrypt key
    uint64_t dec_icount = test_rdinstret() - start_instrs;
    uint64_t dec_ccount = test_rdcycle() - start_cycles;
    perf_log.aes256_scalar_dec.icount[i] = dec_icount;
    perf_log.aes256_scalar_dec.ccount[i] = dec_ccount;
    
    //print_elems("# Scalar 256 - Plaintext2", (uint32_t*)(pt2_scalar_256), (AES_BLOCK_BYTES/4));
    print_elems("# Scalar 128 - Plaintext2 OPENSSL", (uint32_t*)(pt2_scalar_256), (AES_BLOCK_BYTES/4));

    printf("#\n#\tinstret:\n");
    printf("#\t\tenc_key_schedule = %020lu\n", kse_icount);
    printf("#\t\tecb_encrypt      = %020lu\n", enc_icount);
    printf("#\t\tdec_key_schedule = %020lu\n", ksd_icount);
    printf("#\t\tecb_decrypt      = %020lu\n", dec_icount);
    printf("#\tcycles:\n");
    printf("#\t\tenc_key_schedule = %020lu\n", kse_ccount);
    printf("#\t\tecb_encrypt      = %020lu\n", enc_ccount);
    printf("#\t\tdec_key_schedule = %020lu\n", ksd_ccount);
    printf("#\t\tecb_decrypt      = %020lu\n", dec_ccount);
  }
}

void vec_test_aes_128(int num_tests) {

  uint32_t erk [AES_128_RK_WORDS] __attribute__((aligned(16))); //!< Roundkeys (encrypt)
  uint32_t drk [AES_128_RK_WORDS] __attribute__((aligned(16))); //!< Roundkeys (decrypt)

  // perf counters
  uint64_t start_instrs;
  uint64_t start_cycles;

  memset(pt2_vector_128, 0, AES_BLOCK_BYTES);
  memset(ct_vector_128, 0, AES_BLOCK_BYTES);

  for(int i = 0; i < num_tests; i ++) {

    init_vrf();

    printf("#\n#\n# AES 128 Vector test %d/%d:\n", i+1, num_tests);

    print_elems("# Vector 128 - Key", (uint32_t*)(key_128), (AES_128_KEY_BYTES/4));
    print_elems("# Vector 128 - Plaintext1", (uint32_t*)(pt), (AES_BLOCK_BYTES/4));

    start_instrs = test_rdinstret();
    start_cycles = test_rdcycle();
    zvkned_aes128_expand_key(erk, key_128);
    uint64_t kse_icount = test_rdinstret() - start_instrs;
    uint64_t kse_ccount = test_rdcycle() - start_cycles;
    perf_log.aes128_vector_kse.icount[i] = kse_icount;
    perf_log.aes128_vector_kse.ccount[i] = kse_ccount;

    //print_elems("# Vector 128 - Expanded Enc Key", (uint32_t*)(erk), AES_128_RK_WORDS);

    start_instrs = test_rdinstret();
    start_cycles = test_rdcycle();
    zvkned_aes128_encode_vs_lmul1(ct_vector_128, pt, AES_BLOCK_BYTES, erk);
    uint64_t enc_icount = test_rdinstret() - start_instrs;
    uint64_t enc_ccount = test_rdcycle() - start_cycles;
    perf_log.aes128_vector_enc.icount[i] = enc_icount;
    perf_log.aes128_vector_enc.ccount[i] = enc_ccount;

    start_instrs        = test_rdinstret();
    start_cycles        = test_rdcycle();
    zvkned_aes128_expand_key(drk, key_128);
    uint64_t ksd_icount = test_rdinstret() - start_instrs;
    uint64_t ksd_ccount = test_rdcycle() - start_cycles;
    perf_log.aes128_vector_ksd.icount[i] = ksd_icount;
    perf_log.aes128_vector_ksd.ccount[i] = ksd_ccount;

    //print_elems("# Vector 128 - Expanded Dec Key", (uint32_t*)(drk), AES_128_RK_WORDS);

    start_instrs        = test_rdinstret();
    start_cycles        = test_rdcycle();
    zvkned_aes128_decode_vs_lmul1(pt2_vector_128, ct_vector_128, AES_BLOCK_BYTES, drk);
    uint64_t dec_icount = test_rdinstret() - start_instrs;
    uint64_t dec_ccount = test_rdcycle() - start_cycles;
    perf_log.aes128_vector_dec.icount[i] = dec_icount;
    perf_log.aes128_vector_dec.ccount[i] = dec_ccount;

    print_elems("# Vector 128 - Ciphertext", (uint32_t*)(ct_vector_128), (AES_BLOCK_BYTES/4));
    print_elems("# Vector 128 - Plaintext2", (uint32_t*)(pt2_vector_128), (AES_BLOCK_BYTES/4));

    printf("#\n#\tinstret:\n");
    printf("#\t\tenc_key_schedule = %020lu\n", kse_icount);
    printf("#\t\tecb_encrypt      = %020lu\n", enc_icount);
    printf("#\t\tdec_key_schedule = %020lu\n", ksd_icount);
    printf("#\t\tecb_decrypt      = %020lu\n", dec_icount);

    printf("#\tcycles:\n");
    printf("#\t\tenc_key_schedule = %020lu\n", kse_ccount);
    printf("#\t\tecb_encrypt      = %020lu\n", enc_ccount);
    printf("#\t\tdec_key_schedule = %020lu\n", ksd_ccount);
    printf("#\t\tecb_decrypt      = %020lu\n", dec_ccount);
  }
}

void vec_test_aes_128_full(int num_tests) {

  uint32_t erk [AES_128_RK_WORDS] __attribute__((aligned(16))); //!< Roundkeys (encrypt)
  uint32_t drk [AES_128_RK_WORDS] __attribute__((aligned(16))); //!< Roundkeys (decrypt)

  // perf counters
  uint64_t start_instrs;
  uint64_t start_cycles;

  for(int i = 0; i < num_tests; i ++) {

    init_vrf();

    memset(pt2_vector_128, 0, AES_BLOCK_BYTES);
    memset(ct_vector_128, 0, AES_BLOCK_BYTES);
    memset(erk, 0, AES_256_RK_WORDS);
    memset(drk, 0, AES_256_RK_WORDS);
    // clear expanded key and load initial key into first 4 words
    memcpy(erk, key_128, AES_128_KEY_BYTES);
    memcpy(drk, key_128, AES_128_KEY_BYTES);

    printf("#\n#\n# AES 128 FULL Vector test %d/%d:\n", i+1, num_tests);

    print_elems("# Vector 128 - Key", (uint32_t*)(key_128), (AES_128_KEY_BYTES/4));
    print_elems("# Vector 128 - Plaintext1", (uint32_t*)(pt), (AES_BLOCK_BYTES/4));

    // ENCODE FULL 
    start_instrs         = test_rdinstret();
    start_cycles         = test_rdcycle();
    zvkned_aes128_encode_vv_lmul1(ct_vector_128, pt, AES_BLOCK_BYTES, erk);
    uint64_t enfull_icount = test_rdinstret() - start_instrs;
    uint64_t enfull_ccount = test_rdcycle() - start_cycles;
    perf_log.aes128_vector_enfull.icount[i] = enfull_icount;
    perf_log.aes128_vector_enfull.ccount[i] = enfull_ccount;
    
    // DECODE FULL 
    start_instrs         = test_rdinstret();
    start_cycles         = test_rdcycle();
    zvkned_aes128_decode_vv_lmul1(pt2_vector_128, ct_vector_128, AES_BLOCK_BYTES, drk);
    uint64_t defull_icount = test_rdinstret() - start_instrs;
    uint64_t defull_ccount = test_rdcycle() - start_cycles;
    perf_log.aes128_vector_defull.icount[i] = defull_icount;
    perf_log.aes128_vector_defull.ccount[i] = defull_ccount;

    print_elems("# Vector 128 - FULL Ciphertext", (uint32_t*)(ct_vector_128), (AES_BLOCK_BYTES/4));
    print_elems("# Vector 128 - FULL Plaintext2", (uint32_t*)(pt2_vector_128), (AES_BLOCK_BYTES/4));

    printf("#\n#\tinstret:\n");
    printf("#\t\tfull_encode      = %020lu\n", enfull_icount);
    printf("#\t\tfull_decode      = %020lu\n", defull_icount);
    printf("#\tcycles:\n");
    printf("#\t\tfull_encode      = %020lu\n", enfull_ccount);
    printf("#\t\tfull_decode      = %020lu\n", defull_ccount);
  }
}

void vec_test_aes_256(int num_tests) {

  uint32_t erk [AES_256_RK_WORDS] __attribute__((aligned(16))); //!< Roundkeys (encrypt)
  uint32_t drk [AES_256_RK_WORDS] __attribute__((aligned(16))); //!< Roundkeys (decrypt)

  // perf counters
  uint64_t start_instrs;
  uint64_t start_cycles;

  memset(pt2_vector_256, 0, AES_BLOCK_BYTES);
  memset(ct_vector_256, 0, AES_BLOCK_BYTES);

  for(int i = 0; i < num_tests; i ++) {

    init_vrf();

    printf("#\n#\n# AES 256 Vector test %d/%d:\n", i+1, num_tests);

    print_elems("# Vector 256 - Key", (uint32_t*)(key_256), (AES_256_KEY_BYTES/4));
    print_elems("# Vector 256 - Plaintext1", (uint32_t*)(pt), (AES_BLOCK_BYTES/4));

    start_instrs = test_rdinstret();
    start_cycles = test_rdcycle();
    zvkned_aes256_expand_key(erk, key_256);
    uint64_t kse_icount = test_rdinstret() - start_instrs;
    uint64_t kse_ccount = test_rdcycle() - start_cycles;
    perf_log.aes256_vector_kse.icount[i] = kse_icount;
    perf_log.aes256_vector_kse.ccount[i] = kse_ccount;

    //print_elems("# Vector 256 - Expanded Enc Key", (uint32_t*)(erk), AES_256_RK_WORDS);

    start_instrs = test_rdinstret();
    start_cycles = test_rdcycle();
    zvkned_aes256_encode_vs_lmul1(ct_vector_256, pt, AES_BLOCK_BYTES, erk);
    uint64_t enc_icount = test_rdinstret() - start_instrs;
    uint64_t enc_ccount = test_rdcycle() - start_cycles;
    perf_log.aes256_vector_enc.icount[i] = enc_icount;
    perf_log.aes256_vector_enc.ccount[i] = enc_ccount;

    start_instrs        = test_rdinstret();
    start_cycles        = test_rdcycle();
    zvkned_aes256_expand_key(drk, key_256);
    uint64_t ksd_icount = test_rdinstret() - start_instrs;
    uint64_t ksd_ccount = test_rdcycle() - start_cycles;
    perf_log.aes256_vector_ksd.icount[i] = ksd_icount;
    perf_log.aes256_vector_ksd.ccount[i] = ksd_ccount;

    //print_elems("# Vector 256 - Expanded Dec Key", (uint32_t*)(drk), AES_256_RK_WORDS);

    start_instrs        = test_rdinstret();
    start_cycles        = test_rdcycle();
    zvkned_aes256_decode_vs_lmul1(pt2_vector_256, ct_vector_256, AES_BLOCK_BYTES, drk);
    uint64_t dec_icount = test_rdinstret() - start_instrs;
    uint64_t dec_ccount = test_rdcycle() - start_cycles;
    perf_log.aes256_vector_dec.icount[i] = dec_icount;
    perf_log.aes256_vector_dec.ccount[i] = dec_ccount;

    print_elems("# Vector 256 - Ciphertext", (uint32_t*)(ct_vector_256), (AES_BLOCK_BYTES/4));
    print_elems("# Vector 256 - Plaintext2", (uint32_t*)(pt2_vector_256), (AES_BLOCK_BYTES/4));

    printf("#\n#\tinstret:\n");
    printf("#\t\tenc_key_schedule = %020lu\n", kse_icount);
    printf("#\t\tecb_encrypt      = %020lu\n", enc_icount);
    printf("#\t\tdec_key_schedule = %020lu\n", ksd_icount);
    printf("#\t\tecb_decrypt      = %020lu\n", dec_icount);

    printf("#\tcycles:\n");
    printf("#\t\tenc_key_schedule = %020lu\n", kse_ccount);
    printf("#\t\tecb_encrypt      = %020lu\n", enc_ccount);
    printf("#\t\tdec_key_schedule = %020lu\n", ksd_ccount);
    printf("#\t\tecb_decrypt      = %020lu\n", dec_ccount);
  }
}

void vec_test_aes_256_full(int num_tests) {

  uint32_t erk [AES_256_RK_WORDS] __attribute__((aligned(16))); //!< Roundkeys (encrypt)
  uint32_t drk [AES_256_RK_WORDS] __attribute__((aligned(16))); //!< Roundkeys (decrypt)

  // perf counters
  uint64_t start_instrs;
  uint64_t start_cycles;

  for(int i = 0; i < num_tests; i ++) {

    memset(pt2_vector_256, 0, AES_BLOCK_BYTES);
    memset(ct_vector_256, 0, AES_BLOCK_BYTES);
    memset(erk, 0, AES_128_RK_WORDS);
    memset(drk, 0, AES_128_RK_WORDS);
    // clear expanded key and load initial key into first 8 words
    memcpy(erk, key_256, AES_256_KEY_BYTES);
    memcpy(drk, key_256, AES_256_KEY_BYTES);

    printf("#\n#\n# AES 256 FULL Vector test %d/%d:\n", i+1, num_tests);

    print_elems("# Vector 256 - Key", (uint32_t*)(key_256), (AES_256_KEY_BYTES/4));
    print_elems("# Vector 256 - Plaintext1", (uint32_t*)(pt), (AES_BLOCK_BYTES/4));

    // ENCODE FULL 
    start_instrs         = test_rdinstret();
    start_cycles         = test_rdcycle();
    zvkned_aes256_encode_vv_lmul1(ct_vector_256, pt, AES_BLOCK_BYTES, erk);
    uint64_t enfull_icount = test_rdinstret() - start_instrs;
    uint64_t enfull_ccount = test_rdcycle() - start_cycles;
    perf_log.aes256_vector_enfull.icount[i] = enfull_icount;
    perf_log.aes256_vector_enfull.ccount[i] = enfull_ccount;

    // DECODE FULL 
    start_instrs         = test_rdinstret();
    start_cycles         = test_rdcycle();
    zvkned_aes256_decode_vv_lmul1(pt2_vector_256, ct_vector_256, AES_BLOCK_BYTES, drk);
    uint64_t defull_icount = test_rdinstret() - start_instrs;
    uint64_t defull_ccount = test_rdcycle() - start_cycles;
    perf_log.aes256_vector_defull.icount[i] = defull_icount;
    perf_log.aes256_vector_defull.ccount[i] = defull_ccount;

    print_elems("# Vector 256 - FULL Ciphertext", (uint32_t*)(ct_vector_256), (AES_BLOCK_BYTES/4));
    print_elems("# Vector 256 - FULL Plaintext2", (uint32_t*)(pt2_vector_256), (AES_BLOCK_BYTES/4));

    printf("#\n#\tinstret:\n");
    printf("#\t\tfull_encode      = %020lu\n", enfull_icount);
    printf("#\t\tfull_decode      = %020lu\n", defull_icount);
    printf("#\tcycles:\n");
    printf("#\t\tfull_encode      = %020lu\n", enfull_ccount);
    printf("#\t\tfull_decode      = %020lu\n", defull_ccount);
  }
}

static void init(void) {
  // initialise message with pseudo-random vals
  test_rdrandom(pt, AES_BLOCK_BYTES);
  test_rdrandom(key_128, AES_128_KEY_BYTES);
  test_rdrandom(key_256, AES_256_KEY_BYTES);
}

// uaws ro check that input plaintext == output plaintext and scalar cipher == vector cipher
uint32_t check_arr(uint32_t* arr_a, uint32_t* arr_b) {

  uint32_t fail = 0;

  for(int i = 0; i < (AES_BLOCK_BYTES/4); i++) {
    if(arr_a[i] != arr_b[i]) {
      fail++;
    }
  }
  return fail;
}


int main(void) {

  volatile uint32_t fail = 0;

  init();
  init_vrf();

#ifdef AES_VARIANT_128

  printf("\nbenchmark for AES128 ECB\n\n");

  test_aes_128(TEST_COUNT);
  fail += check_arr((uint32_t*)(pt), (uint32_t*)(pt2_scalar_128));
  vec_test_aes_128(TEST_COUNT);
  fail += check_arr((uint32_t*)(pt), (uint32_t*)(pt2_vector_128));
  //fail += check_arr((uint32_t*)(ct_scalar_128), (uint32_t*)(ct_vector_128));
  //vec_test_aes_128_full(TEST_COUNT);
  //fail += check_arr((uint32_t*)(pt), (uint32_t*)(pt2_vector_128));
  //fail += check_arr((uint32_t*)(ct_scalar_128), (uint32_t*)(ct_vector_128));

  #ifdef AES_VARIANT_256

  printf("\nbenchmark for AES256 ECB\n\n");

  test_aes_256(TEST_COUNT);
  fail += check_arr((uint32_t*)(pt), (uint32_t*)(pt2_scalar_256));
  vec_test_aes_256(TEST_COUNT);
  fail += check_arr((uint32_t*)(pt), (uint32_t*)(pt2_vector_256));
  //fail += check_arr((uint32_t*)(ct_scalar_256), (uint32_t*)(ct_vector_256));
  //vec_test_aes_256_full(TEST_COUNT);
  //fail += check_arr((uint32_t*)(pt), (uint32_t*)(pt2_vector_256));
  //fail += check_arr((uint32_t*)(ct_scalar_256), (uint32_t*)(ct_vector_256));

  #endif

#else
  #ifdef AES_VARIANT_256
  
    printf("benchmark for AES256 ECB\n");

    test_aes_256(TEST_COUNT);
    fail += check_arr((uint32_t*)(pt), (uint32_t*)(pt2_scalar_256));
    vec_test_aes_256(TEST_COUNT);
    fail += check_arr((uint32_t*)(pt), (uint32_t*)(pt2_vector_256));
    //fail += check_arr((uint32_t*)(ct_scalar_256), (uint32_t*)(ct_vector_256));
    //vec_test_aes_256_full(TEST_COUNT);
    //fail += check_arr((uint32_t*)(pt), (uint32_t*)(pt2_vector_256));
    //fail += check_arr((uint32_t*)(ct_scalar_256), (uint32_t*)(ct_vector_256));
  
  #else
  
    printf("No benchmark selected.\n");
  
  #endif
#endif

  // calculate averages
  perf_log.aes128_scalar_kse.ccount_average = average_count(perf_log.aes128_scalar_kse.ccount);
  perf_log.aes128_scalar_kse.icount_average = average_count(perf_log.aes128_scalar_kse.icount);
  perf_log.aes128_scalar_enc.ccount_average = average_count(perf_log.aes128_scalar_enc.ccount);
  perf_log.aes128_scalar_enc.icount_average = average_count(perf_log.aes128_scalar_enc.icount);
  perf_log.aes128_scalar_ksd.ccount_average = average_count(perf_log.aes128_scalar_ksd.ccount);
  perf_log.aes128_scalar_ksd.icount_average = average_count(perf_log.aes128_scalar_ksd.icount);
  perf_log.aes128_scalar_dec.ccount_average = average_count(perf_log.aes128_scalar_dec.ccount);
  perf_log.aes128_scalar_dec.icount_average = average_count(perf_log.aes128_scalar_dec.icount);

  perf_log.aes256_scalar_kse.ccount_average = average_count(perf_log.aes256_scalar_kse.ccount);
  perf_log.aes256_scalar_kse.icount_average = average_count(perf_log.aes256_scalar_kse.icount);
  perf_log.aes256_scalar_enc.ccount_average = average_count(perf_log.aes256_scalar_enc.ccount);
  perf_log.aes256_scalar_enc.icount_average = average_count(perf_log.aes256_scalar_enc.icount);
  perf_log.aes256_scalar_ksd.ccount_average = average_count(perf_log.aes256_scalar_ksd.ccount);
  perf_log.aes256_scalar_ksd.icount_average = average_count(perf_log.aes256_scalar_ksd.icount);
  perf_log.aes256_scalar_dec.ccount_average = average_count(perf_log.aes256_scalar_dec.ccount);
  perf_log.aes256_scalar_dec.icount_average = average_count(perf_log.aes256_scalar_dec.icount);

  perf_log.aes128_vector_kse.ccount_average = average_count(perf_log.aes128_vector_kse.ccount);
  perf_log.aes128_vector_kse.icount_average = average_count(perf_log.aes128_vector_kse.icount);
  perf_log.aes128_vector_enc.ccount_average = average_count(perf_log.aes128_vector_enc.ccount);
  perf_log.aes128_vector_enc.icount_average = average_count(perf_log.aes128_vector_enc.icount);
  perf_log.aes128_vector_ksd.ccount_average = average_count(perf_log.aes128_vector_ksd.ccount);
  perf_log.aes128_vector_ksd.icount_average = average_count(perf_log.aes128_vector_ksd.icount);
  perf_log.aes128_vector_dec.ccount_average = average_count(perf_log.aes128_vector_dec.ccount);
  perf_log.aes128_vector_dec.icount_average = average_count(perf_log.aes128_vector_dec.icount);
  perf_log.aes128_vector_enfull.ccount_average = average_count(perf_log.aes128_vector_enfull.ccount);
  perf_log.aes128_vector_enfull.icount_average = average_count(perf_log.aes128_vector_enfull.icount);
  perf_log.aes128_vector_defull.ccount_average = average_count(perf_log.aes128_vector_defull.ccount);
  perf_log.aes128_vector_defull.icount_average = average_count(perf_log.aes128_vector_defull.icount);

  perf_log.aes256_vector_kse.ccount_average = average_count(perf_log.aes256_vector_kse.ccount);
  perf_log.aes256_vector_kse.icount_average = average_count(perf_log.aes256_vector_kse.icount);
  perf_log.aes256_vector_enc.ccount_average = average_count(perf_log.aes256_vector_enc.ccount);
  perf_log.aes256_vector_enc.icount_average = average_count(perf_log.aes256_vector_enc.icount);
  perf_log.aes256_vector_ksd.ccount_average = average_count(perf_log.aes256_vector_ksd.ccount);
  perf_log.aes256_vector_ksd.icount_average = average_count(perf_log.aes256_vector_ksd.icount);
  perf_log.aes256_vector_dec.ccount_average = average_count(perf_log.aes256_vector_dec.ccount);
  perf_log.aes256_vector_dec.icount_average = average_count(perf_log.aes256_vector_dec.icount);
  perf_log.aes256_vector_enfull.ccount_average = average_count(perf_log.aes256_vector_enfull.ccount);
  perf_log.aes256_vector_enfull.icount_average = average_count(perf_log.aes256_vector_enfull.icount);
  perf_log.aes256_vector_defull.ccount_average = average_count(perf_log.aes256_vector_defull.ccount);
  perf_log.aes256_vector_defull.icount_average = average_count(perf_log.aes256_vector_defull.icount);
    
  printf("\n\n# Result Averages:\n");
  
  printf("#\tScalar:\n");
  printf("#\n#\taes128_scalar_kse.ccount = %05lu\n", perf_log.aes128_scalar_kse.ccount_average);
  printf("#\taes128_scalar_kse.icount = %05lu\n", perf_log.aes128_scalar_kse.icount_average);
  printf("#\taes128_scalar_enc.ccount = %05lu\n", perf_log.aes128_scalar_enc.ccount_average);
  printf("#\taes128_scalar_enc.icount = %05lu\n", perf_log.aes128_scalar_enc.icount_average);
  printf("#\taes128_scalar_ksd.ccount = %05lu\n", perf_log.aes128_scalar_ksd.ccount_average);
  printf("#\taes128_scalar_ksd.icount = %05lu\n", perf_log.aes128_scalar_ksd.icount_average);
  printf("#\taes128_scalar_dec.ccount = %05lu\n", perf_log.aes128_scalar_dec.ccount_average);
  printf("#\taes128_scalar_dec.icount = %05lu\n", perf_log.aes128_scalar_dec.icount_average);

  printf("#\n#\taes256_scalar_kse.ccount = %05lu\n", perf_log.aes256_scalar_kse.ccount_average);
  printf("#\taes256_scalar_kse.icount = %05lu\n", perf_log.aes256_scalar_kse.icount_average);
  printf("#\taes256_scalar_enc.ccount = %05lu\n", perf_log.aes256_scalar_enc.ccount_average);
  printf("#\taes256_scalar_enc.icount = %05lu\n", perf_log.aes256_scalar_enc.icount_average);
  printf("#\taes256_scalar_ksd.ccount = %05lu\n", perf_log.aes256_scalar_ksd.ccount_average);
  printf("#\taes256_scalar_ksd.icount = %05lu\n", perf_log.aes256_scalar_ksd.icount_average);
  printf("#\taes256_scalar_dec.ccount = %05lu\n", perf_log.aes256_scalar_dec.ccount_average);
  printf("#\taes256_scalar_dec.icount = %05lu\n", perf_log.aes256_scalar_dec.icount_average);

  printf("#\tVector:\n");
  printf("#\n#\taes128_vector_kse.ccount = %05lu\n", perf_log.aes128_vector_kse.ccount_average);
  printf("#\taes128_vector_kse.icount = %05lu\n", perf_log.aes128_vector_kse.icount_average);
  printf("#\taes128_vector_enc.ccount = %05lu\n", perf_log.aes128_vector_enc.ccount_average);
  printf("#\taes128_vector_enc.icount = %05lu\n", perf_log.aes128_vector_enc.icount_average);
  printf("#\taes128_vector_ksd.ccount = %05lu\n", perf_log.aes128_vector_ksd.ccount_average);
  printf("#\taes128_vector_ksd.icount = %05lu\n", perf_log.aes128_vector_ksd.icount_average);
  printf("#\taes128_vector_dec.ccount = %05lu\n", perf_log.aes128_vector_dec.ccount_average);
  printf("#\taes128_vector_dec.icount = %05lu\n", perf_log.aes128_vector_dec.icount_average);

  printf("#\n#\taes128_vector_enfull.ccount = %05lu\n", perf_log.aes128_vector_enfull.ccount_average);
  printf("#\taes128_vector_enfull.icount = %05lu\n", perf_log.aes128_vector_enfull.icount_average);
  printf("#\taes128_vector_defull.ccount = %05lu\n", perf_log.aes128_vector_defull.ccount_average);
  printf("#\taes128_vector_defull.icount = %05lu\n", perf_log.aes128_vector_defull.icount_average);

  printf("#\n#\taes256_vector_kse.ccount = %05lu\n", perf_log.aes256_vector_kse.ccount_average);
  printf("#\taes256_vector_kse.icount = %05lu\n", perf_log.aes256_vector_kse.icount_average);
  printf("#\taes256_vector_enc.ccount = %05lu\n", perf_log.aes256_vector_enc.ccount_average);
  printf("#\taes256_vector_enc.icount = %05lu\n", perf_log.aes256_vector_enc.icount_average);
  printf("#\taes256_vector_ksd.ccount = %05lu\n", perf_log.aes256_vector_ksd.ccount_average);
  printf("#\taes256_vector_ksd.icount = %05lu\n", perf_log.aes256_vector_ksd.icount_average);
  printf("#\taes256_vector_dec.ccount = %05lu\n", perf_log.aes256_vector_dec.ccount_average);
  printf("#\taes256_vector_dec.icount = %05lu\n", perf_log.aes256_vector_dec.icount_average);

  printf("#\n#\taes256_vector_enfull.ccount = %05lu\n", perf_log.aes256_vector_enfull.ccount_average);
  printf("#\taes256_vector_enfull.icount = %05lu\n", perf_log.aes256_vector_enfull.icount_average);
  printf("#\taes256_vector_defull.ccount = %05lu\n", perf_log.aes256_vector_defull.ccount_average);
  printf("#\taes256_vector_defull.icount = %05lu\n", perf_log.aes256_vector_defull.icount_average);

  if(fail) {
    printf("\n %u Failures!\n\n", fail);
    return fail;
  } else {
    return 0;
  }
}
