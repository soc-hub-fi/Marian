/*
 * File      : test_sm3.c
 * Test      : sm3_benchmark
 * Author(s) : Endrit Isufi <endrit.isufi@tuni.fi
 * Date      : 25-jul-2024
 * Description: Basic benchmarking of SM3
 * Based on <https://github.com/rvkrypto/rvk-misc/blob/main/sm3/test_sm3.c>
 */
#include "crypto/sm3/sm3_api.h"
#include "stdio.h"
#include "crypto/sm3/zvksh.h"
#include "crypto/share/benchmarks.h"
#include <string.h>


typedef struct {
  perf_log_t sm3_scalar;   // scalar SM3
  perf_log_t sm3_vector_m1; // lmul = 1
  perf_log_t sm3_vector_m2; // lmul = 2
  perf_log_t sm3_vector_m4; // lmul = 4
} sm3_perf_log_t;

static uint8_t message [1024] __attribute__((aligned(16))) = {0};
static sm3_perf_log_t perf_log = {0};
SM3_CTX c;
uint8_t md[32];

void test_sm3_vec()
{

	uint8_t  in[1024];
	volatile uint64_t start_instrs;
  volatile uint64_t start_cycles;

	//	simplified test with "abc" test vector from the standard
	sm3_256(md, "abc", 3);

	//	created with openssl
	for (size_t i = 0; i < 256; i++) {
		in[i] = i;
	}
	sm3_256(md, in, 256);

	for (size_t i = 0; i < 1024; i++) {
		in[i] = i & 0xFF;
	}
	start_instrs        = test_rdinstret();
  start_cycles        = test_rdcycle();
	sm3_compress((uint32_t *) md, (uint32_t *) in, 1024);	
	volatile uint64_t sm_icount = test_rdinstret() - start_instrs;
  volatile uint64_t sm_ccount = test_rdcycle() - start_cycles;
	//rvkat_dec("SM3 hash / 1024 B:", cc);
	printf("#\n# SM3 test results\n");
  printf("#\tinstret = %020lu\n", sm_icount);
  printf("#\tcycles  = %020lu\n", sm_ccount);
}

void test_sm3_scalar(int num_tests){
	volatile uint64_t start_instrs = 0;
  volatile uint64_t start_cycles = 0;

  printf("=== SM3 Scalar Intrinsics (sm3_cf256_zksh) ===\n");
	sm3_compress = &sm3_cf256_zksh;

  for(int i = 0; i < num_tests; i++)
  {
    start_instrs        = test_rdinstret();
    start_cycles        = test_rdcycle();
    //sm3_compress((uint32_t *) md, (uint32_t *) message, 1024);	
    ossl_sm3_init(&c);
    ossl_sm3_update(&c, message, 1024);
    ossl_sm3_final(md, &c);
    volatile uint64_t sm_icount = test_rdinstret() - start_instrs;
    volatile uint64_t sm_ccount = test_rdcycle() - start_cycles;
    perf_log.sm3_scalar.icount[i] = sm_icount;
    perf_log.sm3_scalar.ccount[i] = sm_ccount;

    printf("#\n# SM3 test scalar results\n");
    printf("#\tinstret = %020lu\n", sm_icount);
    printf("#\tcycles  = %020lu\n", sm_ccount);
  }
}


void test_sm3_vec_m1(int num_tests){
  uint8_t md[32];
	volatile uint64_t start_instrs = 0;
  volatile uint64_t start_cycles = 0;

	printf("=== SM3 Vector (sm3_cf256_zvksh_lmul1) ===\n");
	sm3_compress = &sm3_cf256_zvksh_lmul1;

  for(int i = 0; i < num_tests; i++)
  {
    start_instrs        = test_rdinstret();
    start_cycles        = test_rdcycle();
    sm3_compress((uint32_t *) md, (uint32_t *) message, 1024);	// 16 blocks
    volatile uint64_t sm_icount = test_rdinstret() - start_instrs;
    volatile uint64_t sm_ccount = test_rdcycle() - start_cycles;
    perf_log.sm3_vector_m1.icount[i] = sm_icount;
    perf_log.sm3_vector_m1.ccount[i] = sm_ccount;

    printf("#\n# SM3 test (lmul = 1) results\n");
    printf("#\tinstret = %020lu\n", sm_icount);
    printf("#\tcycles  = %020lu\n", sm_ccount);
  }
}

void test_sm3_vec_m2(int num_tests){
  uint8_t md[32];
	volatile uint64_t start_instrs = 0;
  volatile uint64_t start_cycles = 0;

	printf("=== SM3 (sm3_cf256_zvksh_lmul2) ===\n");
	sm3_compress = &sm3_cf256_zvksh_lmul2;

  for(int i = 0; i < num_tests; i++)
  {
    start_instrs        = test_rdinstret();
    start_cycles        = test_rdcycle();
    sm3_compress((uint32_t *) md, (uint32_t *) message, 1024);	// 16 blocks
    volatile uint64_t sm_icount = test_rdinstret() - start_instrs;
    volatile uint64_t sm_ccount = test_rdcycle() - start_cycles;
    perf_log.sm3_vector_m2.icount[i] = sm_icount;
    perf_log.sm3_vector_m2.ccount[i] = sm_ccount;

    printf("#\n# SM3 test (lmul = 2) results\n");
    printf("#\tinstret = %020lu\n", sm_icount);
    printf("#\tcycles  = %020lu\n", sm_ccount);
  }
}

void test_sm3_vec_m4(int num_tests){
  uint8_t md[32];
	volatile uint64_t start_instrs = 0;
  volatile uint64_t start_cycles = 0;

	printf("=== SM3 (sm3_cf256_zvksh_lmul4) ===\n");
	sm3_compress = &sm3_cf256_zvksh_lmul4;

  for(int i = 0; i < num_tests; i++)
  {
    start_instrs        = test_rdinstret();
    start_cycles        = test_rdcycle();
    sm3_compress((uint32_t *) md, (uint32_t *) message, 1024);	// 16 blocks
    volatile uint64_t sm_icount = test_rdinstret() - start_instrs;
    volatile uint64_t sm_ccount = test_rdcycle() - start_cycles;
    perf_log.sm3_vector_m4.icount[i] = sm_icount;
    perf_log.sm3_vector_m4.ccount[i] = sm_ccount;

    printf("#\n# SM3 test (lmul = 4) results\n");
    printf("#\tinstret = %020lu\n", sm_icount);
    printf("#\tcycles  = %020lu\n", sm_ccount);
  }
}

int test_sm3()
{
	printf("=== SM3 Scalar Intrinsics (sm3_cf256_zksh) ===\n");
	sm3_compress = &sm3_cf256_zksh;
	test_sm3_vec();

	printf("=== SM3 Vector (sm3_cf256_zvksh_lmul1) ===\n");
	sm3_compress = &sm3_cf256_zvksh_lmul1;
	test_sm3_vec();


	printf("=== SM3 (sm3_cf256_zvksh_lmul2) ===\n");
	sm3_compress = &sm3_cf256_zvksh_lmul2;
	test_sm3_vec();

	printf("=== SM3 (sm3_cf256_zvksh_lmul4) ===\n");
	sm3_compress = &sm3_cf256_zvksh_lmul4;
	test_sm3_vec();


	return 0;
}

static void init(void){
  //initialise message with pseudo-random values
  test_rdrandom(message, TEST_HASH_INPUT_LENGTH);
}

int main(void){
  //init_vrf();
  init(); 
  //test_sm3();
  test_sm3_scalar(TEST_COUNT);
  test_sm3_vec_m1(TEST_COUNT);
  test_sm3_vec_m2(TEST_COUNT);
  test_sm3_vec_m4(TEST_COUNT);

  perf_log.sm3_scalar.ccount_average = average_count(perf_log.sm3_scalar.ccount);
  perf_log.sm3_scalar.icount_average = average_count(perf_log.sm3_scalar.icount);

  perf_log.sm3_vector_m1.ccount_average = average_count(perf_log.sm3_vector_m1.ccount);
  perf_log.sm3_vector_m1.icount_average = average_count(perf_log.sm3_vector_m1.icount);

  perf_log.sm3_vector_m2.ccount_average = average_count(perf_log.sm3_vector_m2.ccount);
  perf_log.sm3_vector_m2.icount_average = average_count(perf_log.sm3_vector_m2.icount);

  perf_log.sm3_vector_m4.ccount_average = average_count(perf_log.sm3_vector_m4.ccount);
  perf_log.sm3_vector_m4.icount_average = average_count(perf_log.sm3_vector_m4.icount);


  printf("\n\n# Result Averages:\n");

  printf("#\tScalar:\n");
  printf("#\tsm3_scalar.icount = %05lu\n", perf_log.sm3_scalar.icount_average);
  printf("#\tsm3_scalar.ccount = %05lu\n", perf_log.sm3_scalar.ccount_average);

  printf("#\tVector:\n");
  printf("#\tsm3_vector_m1.icount = %05lu\n", perf_log.sm3_vector_m1.icount_average);
  printf("#\tsm3_vector_m1.ccount = %05lu\n", perf_log.sm3_vector_m1.ccount_average);
  printf("#\tsm3_vector_m2.icount = %05lu\n", perf_log.sm3_vector_m2.icount_average);
  printf("#\tsm3_vector_m2.ccount = %05lu\n", perf_log.sm3_vector_m2.ccount_average);
  printf("#\tsm3_vector_m4.icount = %05lu\n", perf_log.sm3_vector_m4.icount_average);
  printf("#\tsm3_vector_m4.ccount = %05lu\n", perf_log.sm3_vector_m4.ccount_average);


  return 0;
}





/*
##################################################################
############################## OpenSSL############################
##################################################################
*/

/*
 * Copyright 2017-2021 The OpenSSL Project Authors. All Rights Reserved.
 * Copyright 2017 Ribose Inc. All Rights Reserved.
 * Ported from Ribose contributions from Botan.
 *
 * Licensed under the Apache License 2.0 (the "License").  You may not use
 * this file except in compliance with the License.  You can obtain a copy
 * in the file LICENSE in the source distribution or at
 * https://www.openssl.org/source/license.html
 */
#define ROTATE(a,n)     (((a)<<(n))|(((a)&0xffffffff)>>(32-(n))))

#ifndef P0
# define P0(X) (X ^ ROTATE(X, 9) ^ ROTATE(X, 17))
#endif
#ifndef P1
# define P1(X) (X ^ ROTATE(X, 15) ^ ROTATE(X, 23))
#endif

#define FF0(X,Y,Z) (X ^ Y ^ Z)
#define GG0(X,Y,Z) (X ^ Y ^ Z)

#define FF1(X,Y,Z) ((X & Y) | ((X | Y) & Z))
#define GG1(X,Y,Z) ((Z ^ (X & (Y ^ Z))))

#  define HOST_l2c(l,c)  (*((c)++)=(unsigned char)(((l)>>24)&0xff),      \
                         *((c)++)=(unsigned char)(((l)>>16)&0xff),      \
                         *((c)++)=(unsigned char)(((l)>> 8)&0xff),      \
                         *((c)++)=(unsigned char)(((l)    )&0xff),      \
                         l)

#  define HOST_c2l(c,l)  (l =(((unsigned long)(*((c)++)))<<24),          \
                         l|=(((unsigned long)(*((c)++)))<<16),          \
                         l|=(((unsigned long)(*((c)++)))<< 8),          \
                         l|=(((unsigned long)(*((c)++)))    )           )

#define EXPAND(W0,W7,W13,W3,W10) \
   (P1(W0 ^ W7 ^ ROTATE(W13, 15)) ^ ROTATE(W3, 7) ^ W10)

#define RND(A, B, C, D, E, F, G, H, TJ, Wi, Wj, FF, GG)           \
     do {                                                         \
       const SM3_WORD A12 = ROTATE(A, 12);                        \
       const SM3_WORD A12_SM = A12 + E + TJ;                      \
       const SM3_WORD SS1 = ROTATE(A12_SM, 7);                    \
       const SM3_WORD TT1 = FF(A, B, C) + D + (SS1 ^ A12) + (Wj); \
       const SM3_WORD TT2 = GG(E, F, G) + H + SS1 + Wi;           \
       B = ROTATE(B, 9);                                          \
       D = TT1;                                                   \
       F = ROTATE(F, 19);                                         \
       H = P0(TT2);                                               \
     } while(0)

#define R1(A,B,C,D,E,F,G,H,TJ,Wi,Wj) \
   RND(A,B,C,D,E,F,G,H,TJ,Wi,Wj,FF0,GG0)

#define R2(A,B,C,D,E,F,G,H,TJ,Wi,Wj) \
   RND(A,B,C,D,E,F,G,H,TJ,Wi,Wj,FF1,GG1)

#define SM3_A 0x7380166fUL
#define SM3_B 0x4914b2b9UL
#define SM3_C 0x172442d7UL
#define SM3_D 0xda8a0600UL
#define SM3_E 0xa96f30bcUL
#define SM3_F 0x163138aaUL
#define SM3_G 0xe38dee4dUL
#define SM3_H 0xb0fb0e4eUL

int ossl_sm3_init(SM3_CTX *c)
{
    memset(c, 0, sizeof(*c));
    c->A = SM3_A;
    c->B = SM3_B;
    c->C = SM3_C;
    c->D = SM3_D;
    c->E = SM3_E;
    c->F = SM3_F;
    c->G = SM3_G;
    c->H = SM3_H;
    return 1;
}

void ossl_sm3_block_data_order(SM3_CTX *ctx, const void *p, size_t num)
{
    const unsigned char *data = p;
    register unsigned int A, B, C, D, E, F, G, H;

    unsigned int W00, W01, W02, W03, W04, W05, W06, W07,
        W08, W09, W10, W11, W12, W13, W14, W15;

    for (; num--;) {

        A = ctx->A;
        B = ctx->B;
        C = ctx->C;
        D = ctx->D;
        E = ctx->E;
        F = ctx->F;
        G = ctx->G;
        H = ctx->H;

        /*
        * We have to load all message bytes immediately since SM3 reads
        * them slightly out of order.
        */
        (void)HOST_c2l(data, W00);
        (void)HOST_c2l(data, W01);
        (void)HOST_c2l(data, W02);
        (void)HOST_c2l(data, W03);
        (void)HOST_c2l(data, W04);
        (void)HOST_c2l(data, W05);
        (void)HOST_c2l(data, W06);
        (void)HOST_c2l(data, W07);
        (void)HOST_c2l(data, W08);
        (void)HOST_c2l(data, W09);
        (void)HOST_c2l(data, W10);
        (void)HOST_c2l(data, W11);
        (void)HOST_c2l(data, W12);
        (void)HOST_c2l(data, W13);
        (void)HOST_c2l(data, W14);
        (void)HOST_c2l(data, W15);

        R1(A, B, C, D, E, F, G, H, 0x79CC4519, W00, W00 ^ W04);
        W00 = EXPAND(W00, W07, W13, W03, W10);
        R1(D, A, B, C, H, E, F, G, 0xF3988A32, W01, W01 ^ W05);
        W01 = EXPAND(W01, W08, W14, W04, W11);
        R1(C, D, A, B, G, H, E, F, 0xE7311465, W02, W02 ^ W06);
        W02 = EXPAND(W02, W09, W15, W05, W12);
        R1(B, C, D, A, F, G, H, E, 0xCE6228CB, W03, W03 ^ W07);
        W03 = EXPAND(W03, W10, W00, W06, W13);
        R1(A, B, C, D, E, F, G, H, 0x9CC45197, W04, W04 ^ W08);
        W04 = EXPAND(W04, W11, W01, W07, W14);
        R1(D, A, B, C, H, E, F, G, 0x3988A32F, W05, W05 ^ W09);
        W05 = EXPAND(W05, W12, W02, W08, W15);
        R1(C, D, A, B, G, H, E, F, 0x7311465E, W06, W06 ^ W10);
        W06 = EXPAND(W06, W13, W03, W09, W00);
        R1(B, C, D, A, F, G, H, E, 0xE6228CBC, W07, W07 ^ W11);
        W07 = EXPAND(W07, W14, W04, W10, W01);
        R1(A, B, C, D, E, F, G, H, 0xCC451979, W08, W08 ^ W12);
        W08 = EXPAND(W08, W15, W05, W11, W02);
        R1(D, A, B, C, H, E, F, G, 0x988A32F3, W09, W09 ^ W13);
        W09 = EXPAND(W09, W00, W06, W12, W03);
        R1(C, D, A, B, G, H, E, F, 0x311465E7, W10, W10 ^ W14);
        W10 = EXPAND(W10, W01, W07, W13, W04);
        R1(B, C, D, A, F, G, H, E, 0x6228CBCE, W11, W11 ^ W15);
        W11 = EXPAND(W11, W02, W08, W14, W05);
        R1(A, B, C, D, E, F, G, H, 0xC451979C, W12, W12 ^ W00);
        W12 = EXPAND(W12, W03, W09, W15, W06);
        R1(D, A, B, C, H, E, F, G, 0x88A32F39, W13, W13 ^ W01);
        W13 = EXPAND(W13, W04, W10, W00, W07);
        R1(C, D, A, B, G, H, E, F, 0x11465E73, W14, W14 ^ W02);
        W14 = EXPAND(W14, W05, W11, W01, W08);
        R1(B, C, D, A, F, G, H, E, 0x228CBCE6, W15, W15 ^ W03);
        W15 = EXPAND(W15, W06, W12, W02, W09);
        R2(A, B, C, D, E, F, G, H, 0x9D8A7A87, W00, W00 ^ W04);
        W00 = EXPAND(W00, W07, W13, W03, W10);
        R2(D, A, B, C, H, E, F, G, 0x3B14F50F, W01, W01 ^ W05);
        W01 = EXPAND(W01, W08, W14, W04, W11);
        R2(C, D, A, B, G, H, E, F, 0x7629EA1E, W02, W02 ^ W06);
        W02 = EXPAND(W02, W09, W15, W05, W12);
        R2(B, C, D, A, F, G, H, E, 0xEC53D43C, W03, W03 ^ W07);
        W03 = EXPAND(W03, W10, W00, W06, W13);
        R2(A, B, C, D, E, F, G, H, 0xD8A7A879, W04, W04 ^ W08);
        W04 = EXPAND(W04, W11, W01, W07, W14);
        R2(D, A, B, C, H, E, F, G, 0xB14F50F3, W05, W05 ^ W09);
        W05 = EXPAND(W05, W12, W02, W08, W15);
        R2(C, D, A, B, G, H, E, F, 0x629EA1E7, W06, W06 ^ W10);
        W06 = EXPAND(W06, W13, W03, W09, W00);
        R2(B, C, D, A, F, G, H, E, 0xC53D43CE, W07, W07 ^ W11);
        W07 = EXPAND(W07, W14, W04, W10, W01);
        R2(A, B, C, D, E, F, G, H, 0x8A7A879D, W08, W08 ^ W12);
        W08 = EXPAND(W08, W15, W05, W11, W02);
        R2(D, A, B, C, H, E, F, G, 0x14F50F3B, W09, W09 ^ W13);
        W09 = EXPAND(W09, W00, W06, W12, W03);
        R2(C, D, A, B, G, H, E, F, 0x29EA1E76, W10, W10 ^ W14);
        W10 = EXPAND(W10, W01, W07, W13, W04);
        R2(B, C, D, A, F, G, H, E, 0x53D43CEC, W11, W11 ^ W15);
        W11 = EXPAND(W11, W02, W08, W14, W05);
        R2(A, B, C, D, E, F, G, H, 0xA7A879D8, W12, W12 ^ W00);
        W12 = EXPAND(W12, W03, W09, W15, W06);
        R2(D, A, B, C, H, E, F, G, 0x4F50F3B1, W13, W13 ^ W01);
        W13 = EXPAND(W13, W04, W10, W00, W07);
        R2(C, D, A, B, G, H, E, F, 0x9EA1E762, W14, W14 ^ W02);
        W14 = EXPAND(W14, W05, W11, W01, W08);
        R2(B, C, D, A, F, G, H, E, 0x3D43CEC5, W15, W15 ^ W03);
        W15 = EXPAND(W15, W06, W12, W02, W09);
        R2(A, B, C, D, E, F, G, H, 0x7A879D8A, W00, W00 ^ W04);
        W00 = EXPAND(W00, W07, W13, W03, W10);
        R2(D, A, B, C, H, E, F, G, 0xF50F3B14, W01, W01 ^ W05);
        W01 = EXPAND(W01, W08, W14, W04, W11);
        R2(C, D, A, B, G, H, E, F, 0xEA1E7629, W02, W02 ^ W06);
        W02 = EXPAND(W02, W09, W15, W05, W12);
        R2(B, C, D, A, F, G, H, E, 0xD43CEC53, W03, W03 ^ W07);
        W03 = EXPAND(W03, W10, W00, W06, W13);
        R2(A, B, C, D, E, F, G, H, 0xA879D8A7, W04, W04 ^ W08);
        W04 = EXPAND(W04, W11, W01, W07, W14);
        R2(D, A, B, C, H, E, F, G, 0x50F3B14F, W05, W05 ^ W09);
        W05 = EXPAND(W05, W12, W02, W08, W15);
        R2(C, D, A, B, G, H, E, F, 0xA1E7629E, W06, W06 ^ W10);
        W06 = EXPAND(W06, W13, W03, W09, W00);
        R2(B, C, D, A, F, G, H, E, 0x43CEC53D, W07, W07 ^ W11);
        W07 = EXPAND(W07, W14, W04, W10, W01);
        R2(A, B, C, D, E, F, G, H, 0x879D8A7A, W08, W08 ^ W12);
        W08 = EXPAND(W08, W15, W05, W11, W02);
        R2(D, A, B, C, H, E, F, G, 0x0F3B14F5, W09, W09 ^ W13);
        W09 = EXPAND(W09, W00, W06, W12, W03);
        R2(C, D, A, B, G, H, E, F, 0x1E7629EA, W10, W10 ^ W14);
        W10 = EXPAND(W10, W01, W07, W13, W04);
        R2(B, C, D, A, F, G, H, E, 0x3CEC53D4, W11, W11 ^ W15);
        W11 = EXPAND(W11, W02, W08, W14, W05);
        R2(A, B, C, D, E, F, G, H, 0x79D8A7A8, W12, W12 ^ W00);
        W12 = EXPAND(W12, W03, W09, W15, W06);
        R2(D, A, B, C, H, E, F, G, 0xF3B14F50, W13, W13 ^ W01);
        W13 = EXPAND(W13, W04, W10, W00, W07);
        R2(C, D, A, B, G, H, E, F, 0xE7629EA1, W14, W14 ^ W02);
        W14 = EXPAND(W14, W05, W11, W01, W08);
        R2(B, C, D, A, F, G, H, E, 0xCEC53D43, W15, W15 ^ W03);
        W15 = EXPAND(W15, W06, W12, W02, W09);
        R2(A, B, C, D, E, F, G, H, 0x9D8A7A87, W00, W00 ^ W04);
        W00 = EXPAND(W00, W07, W13, W03, W10);
        R2(D, A, B, C, H, E, F, G, 0x3B14F50F, W01, W01 ^ W05);
        W01 = EXPAND(W01, W08, W14, W04, W11);
        R2(C, D, A, B, G, H, E, F, 0x7629EA1E, W02, W02 ^ W06);
        W02 = EXPAND(W02, W09, W15, W05, W12);
        R2(B, C, D, A, F, G, H, E, 0xEC53D43C, W03, W03 ^ W07);
        W03 = EXPAND(W03, W10, W00, W06, W13);
        R2(A, B, C, D, E, F, G, H, 0xD8A7A879, W04, W04 ^ W08);
        R2(D, A, B, C, H, E, F, G, 0xB14F50F3, W05, W05 ^ W09);
        R2(C, D, A, B, G, H, E, F, 0x629EA1E7, W06, W06 ^ W10);
        R2(B, C, D, A, F, G, H, E, 0xC53D43CE, W07, W07 ^ W11);
        R2(A, B, C, D, E, F, G, H, 0x8A7A879D, W08, W08 ^ W12);
        R2(D, A, B, C, H, E, F, G, 0x14F50F3B, W09, W09 ^ W13);
        R2(C, D, A, B, G, H, E, F, 0x29EA1E76, W10, W10 ^ W14);
        R2(B, C, D, A, F, G, H, E, 0x53D43CEC, W11, W11 ^ W15);
        R2(A, B, C, D, E, F, G, H, 0xA7A879D8, W12, W12 ^ W00);
        R2(D, A, B, C, H, E, F, G, 0x4F50F3B1, W13, W13 ^ W01);
        R2(C, D, A, B, G, H, E, F, 0x9EA1E762, W14, W14 ^ W02);
        R2(B, C, D, A, F, G, H, E, 0x3D43CEC5, W15, W15 ^ W03);

        ctx->A ^= A;
        ctx->B ^= B;
        ctx->C ^= C;
        ctx->D ^= D;
        ctx->E ^= E;
        ctx->F ^= F;
        ctx->G ^= G;
        ctx->H ^= H;
    }
}

int ossl_sm3_final(unsigned char *md, SM3_CTX *c)
{
    unsigned char *p = (unsigned char *)c->data;
    size_t n = c->num;

    p[n] = 0x80;                /* there is always room for one */
    n++;

    if (n > (SM3_CBLOCK - 8)) {
        memset(p + n, 0, SM3_CBLOCK - n);
        n = 0;
        ossl_sm3_block_data_order(c, p, 1);
    }
    memset(p + n, 0, SM3_CBLOCK - 8 - n);

    p += SM3_CBLOCK - 8;
# if   defined(DATA_ORDER_IS_BIG_ENDIAN)
    (void)HOST_l2c(c->Nh, p);
    (void)HOST_l2c(c->Nl, p);
# elif defined(DATA_ORDER_IS_LITTLE_ENDIAN)
    (void)HOST_l2c(c->Nl, p);
    (void)HOST_l2c(c->Nh, p);
# endif
    p -= SM3_CBLOCK;
    ossl_sm3_block_data_order(c, p, 1);
    c->num = 0;
    memset(p,0, SM3_CBLOCK);

    return 1;
}


int ossl_sm3_update(SM3_CTX *c, const void *data_, size_t len)
{
    const unsigned char *data = data_;
    unsigned char *p;
    long l;
    size_t n;

    if (len == 0)
        return 1;

    l = (c->Nl + (((long) len) << 3)) & 0xffffffffUL;
    if (l < c->Nl)              /* overflow */
        c->Nh++;
    c->Nh += (long) (len >> 29); /* might cause compiler warning on
                                       * 16-bit */
    c->Nl = l;

    n = c->num;
    if (n != 0) {
        p = (unsigned char *)c->data;

        if (len >= SM3_CBLOCK || len + n >= SM3_CBLOCK) {
            memcpy(p + n, data, SM3_CBLOCK - n);
            ossl_sm3_block_data_order(c, p, 1);
            n = SM3_CBLOCK - n;
            data += n;
            len -= n;
            c->num = 0;
            /*
             * We use memset rather than OPENSSL_cleanse() here deliberately.
             * Using OPENSSL_cleanse() here could be a performance issue. It
             * will get properly cleansed on finalisation so this isn't a
             * security problem.
             */
            memset(p, 0, SM3_CBLOCK); /* keep it zeroed */
        } else {
            memcpy(p + n, data, len);
            c->num += (unsigned int)len;
            return 1;
        }
    }

    n = len / SM3_CBLOCK;
    if (n > 0) {
        ossl_sm3_block_data_order(c, data, n);
        n *= SM3_CBLOCK;
        data += n;
        len -= n;
    }

    if (len != 0) {
        p = (unsigned char *)c->data;
        c->num = (unsigned int)len;
        memcpy(p, data, len);
    }
    return 1;
}