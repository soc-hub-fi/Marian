/*
 * File      : test_sha.c
 * Test      : sha_benchmark
 * Author(s) : Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
 * Date      : 27-jul-2024
 * Description: Basic benchmarking of SHA256/512.
 */

#include <stddef.h>
#include <string.h>

#include "printf.h"

#include "crypto/share/benchmarks.h"
#include "crypto/share/util.h"

#include "crypto/sha/api_sha256.h"
#include "crypto/sha/api_sha512.h"

#define MESSAGE_LEN_BYTES 1024

#define SHA_VARIANT_256
#define SHA_VARIANT_512

typedef struct {
  // scalar AES128
  perf_log_t sha256_scalar;
  perf_log_t sha256_vector;
  perf_log_t sha512_scalar;
  perf_log_t sha512_vector;
} sha_perf_log_t;

static uint32_t scalar_digest_256  [8]  __attribute__((aligned(16))) = {0};
static uint64_t scalar_digest_512  [8]  __attribute__((aligned(16))) = {0};
static uint32_t vector_digest_256  [8]  __attribute__((aligned(16))) = {0};
static uint64_t vector_digest_512  [8]  __attribute__((aligned(16))) = {0};

static uint8_t message [1024] __attribute__((aligned(16))) = {0};

static sha_perf_log_t perf_log = {0};

void print_elems(const char* name, const uint32_t* arr, const size_t n) {

  printf("\n%s:\n", name);

  for(size_t idx = 0; idx < n; idx++) {
    printf("[%02lu] - 0x%08X\n", idx, arr[idx]);
  }
}

static void test_sha256(int num_tests) {

  volatile uint64_t start_instrs;
  volatile uint64_t start_cycles;

  for(int i = 0; i < num_tests; i++) {

    printf("#\n# SHA 256 Scalar test %d/%d:\n", i+1, num_tests);

    SHA256_CTX hash_state;

    start_instrs        = test_rdinstret();
    start_cycles        = test_rdcycle();
    //sha256_hash(scalar_digest_256, message, MESSAGE_LEN_BYTES);
    SHA256_Init(&hash_state);
    SHA256_Update(&hash_state, message, MESSAGE_LEN_BYTES);
    SHA256_Final((uint8_t*)(scalar_digest_256), &hash_state);
    volatile uint64_t sha_icount = test_rdinstret() - start_instrs;
    volatile uint64_t sha_ccount = test_rdcycle() - start_cycles;
    perf_log.sha256_scalar.icount[i] = sha_icount;
    perf_log.sha256_scalar.ccount[i] = sha_ccount;

    print_elems("Digest", (uint32_t*)(scalar_digest_256), 8);    
    printf("#\tinstret = %020lu\n", sha_icount);
    printf("#\tcycles  = %020lu\n", sha_ccount);
  }
}

static void test_sha512(int num_tests) {

  volatile uint64_t start_instrs;
  volatile uint64_t start_cycles;

  for(int i = 0; i < num_tests; i++) {

    printf("#\n# SHA 512 Scalar test %d/%d:\n", i+1, num_tests);

    SHA512_CTX hash_state;

    start_instrs        = test_rdinstret();
    start_cycles        = test_rdcycle();
    //sha512_hash(scalar_digest_512, message, MESSAGE_LEN_BYTES);    
    SHA512_Init(&hash_state);
    SHA512_Update(&hash_state, message, MESSAGE_LEN_BYTES);
    SHA512_Final((uint8_t*)(scalar_digest_512), &hash_state);
    volatile uint64_t sha_icount = test_rdinstret() - start_instrs;
    volatile uint64_t sha_ccount = test_rdcycle() - start_cycles;
    perf_log.sha512_scalar.icount[i] = sha_icount;
    perf_log.sha512_scalar.ccount[i] = sha_ccount;

    print_elems("Digest", (uint32_t*)(scalar_digest_512), 16);
    printf("#\tinstret = %020lu\n", sha_icount);
    printf("#\tcycles  = %020lu\n", sha_ccount);
  }
}

static void test_sha256_vec(int num_tests) {

  volatile uint64_t start_instrs = 0;
  volatile uint64_t start_cycles = 0;

  for(int i = 0; i < num_tests; i++) {

    printf("#\n# SHA 256 Vector test %d/%d:\n", i+1, num_tests);

    start_instrs        = test_rdinstret();
    start_cycles        = test_rdcycle();
    sha256_hash_vec(vector_digest_256, message, MESSAGE_LEN_BYTES);
    volatile uint64_t sha_icount = test_rdinstret() - start_instrs;
    volatile uint64_t sha_ccount = test_rdcycle() - start_cycles;
    perf_log.sha256_vector.icount[i] = sha_icount;
    perf_log.sha256_vector.ccount[i] = sha_ccount;
    
    print_elems("Digest", (uint32_t*)(vector_digest_256), 8);    
    printf("#\tinstret = %020lu\n", sha_icount);
    printf("#\tcycles  = %020lu\n", sha_ccount);
  }
}

static void test_sha512_vec(int num_tests) {

  volatile uint64_t start_instrs;
  volatile uint64_t start_cycles;

  for(int i = 0; i < num_tests; i++) {

    printf("#\n# SHA 512 Vector test %d/%d:\n", i+1, num_tests);

    start_instrs        = test_rdinstret();
    start_cycles        = test_rdcycle();
    sha512_hash_vec(vector_digest_512, message, MESSAGE_LEN_BYTES);
    volatile uint64_t sha_icount = test_rdinstret() - start_instrs;
    volatile uint64_t sha_ccount = test_rdcycle() - start_cycles;
    perf_log.sha512_vector.icount[i] = sha_icount;
    perf_log.sha512_vector.ccount[i] = sha_ccount;

    print_elems("Digest", (uint32_t*)(vector_digest_512), 16);    
    printf("#\tinstret = %020lu\n", sha_icount);
    printf("#\tcycles  = %020lu\n", sha_ccount);
  }
}

static void init(void) {
  // initialise message with pseudo-random vals
  test_rdrandom(message, MESSAGE_LEN_BYTES);
}

static uint32_t check_hash_256(uint32_t* H_s, uint32_t* H_v) {
  uint32_t fail = 0;

  for (int i = 0; i < 8; i++) {
    if (H_s[i] != H_v[i]) {
      fail++;
    }
  }
  return fail;
};

static uint32_t check_hash_512(uint64_t* H_s, uint64_t* H_v) {
  uint32_t fail = 0;

  for (int i = 0; i < 8; i++) {
    if (H_s[i] != H_v[i]) {
      fail++;
    }
  }
  return fail;
};

int main(void) {

  volatile uint32_t fail = 0;

  // initialise "random" message
  init();

#ifdef SHA_VARIANT_256

  printf("\nBenchmark for SHA256 with %d Byte Message \n", MESSAGE_LEN_BYTES);

  test_sha256(TEST_COUNT);
  test_sha256_vec(TEST_COUNT);

  fail += check_hash_256(scalar_digest_256, vector_digest_256);

  #ifdef SHA_VARIANT_512

  printf("\nBenchmark for SHA512 with %d Byte Message \n", MESSAGE_LEN_BYTES);

  test_sha512(TEST_COUNT);
  test_sha512_vec(TEST_COUNT);

  fail += check_hash_512(scalar_digest_512, vector_digest_512);

  #endif

#else

  #ifdef SHA_VARIANT_512

  printf("\nBenchmark for SHA512 with %d Byte Message \n", MESSAGE_LEN_BYTES);

  test_sha512(TEST_COUNT);
  test_sha512_vec(TEST_COUNT);

  fail += check_hash_512(scalar_digest_512, vector_digest_512);

  #else
  
    printf("No benchmark selected.\n");

  #endif
#endif

  perf_log.sha256_scalar.ccount_average = average_count(perf_log.sha256_scalar.ccount);
  perf_log.sha256_scalar.icount_average = average_count(perf_log.sha256_scalar.icount);
  perf_log.sha256_vector.ccount_average = average_count(perf_log.sha256_vector.ccount);
  perf_log.sha256_vector.icount_average = average_count(perf_log.sha256_vector.icount);

  perf_log.sha512_scalar.ccount_average = average_count(perf_log.sha512_scalar.ccount);
  perf_log.sha512_scalar.icount_average = average_count(perf_log.sha512_scalar.icount);
  perf_log.sha512_vector.ccount_average = average_count(perf_log.sha512_vector.ccount);
  perf_log.sha512_vector.icount_average = average_count(perf_log.sha512_vector.icount); 

  printf("\n\n# Result Averages:\n");

  printf("#\tScalar:\n");
  printf("#\tsha256_scalar.icount = %05lu\n", perf_log.sha256_scalar.icount_average);
  printf("#\tsha256_scalar.ccount = %05lu\n", perf_log.sha256_scalar.ccount_average);
  printf("#\tsha512_scalar.icount = %05lu\n", perf_log.sha512_scalar.icount_average);
  printf("#\tsha512_scalar.ccount = %05lu\n", perf_log.sha512_scalar.ccount_average);

  printf("#\tVector:\n");
  printf("#\tsha256_vector.icount = %05lu\n", perf_log.sha256_vector.icount_average);
  printf("#\tsha256_vector.ccount = %05lu\n", perf_log.sha256_vector.ccount_average);
  printf("#\tsha512_vector.icount = %05lu\n", perf_log.sha512_vector.icount_average);
  printf("#\tsha512_vector.ccount = %05lu\n", perf_log.sha512_vector.ccount_average);

  if(fail) {
    printf("\n %u Failures!\n\n", fail);
    return fail;
  } else {
    return 0;
  }
}