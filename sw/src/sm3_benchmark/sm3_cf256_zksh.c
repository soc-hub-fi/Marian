/*
 * File      : sm3_cf256_zksh.c
 * Test      : sm3_benchmark
 * Author(s) : Endrit Isufi <endrit.isufi@tuni.fi
 * Date      : 25-jul-2024
 * Description: Scalar operations for SM3 algorithm.
 * Based on <https://github.com/rvkrypto/rvk-misc/blob/main/sm3/sm3_cf256_zksh.c>
 */
#include "crypto/sm3/sm3_api.h"
#include "crypto/share/util.h"

//permutation functions
#define SMP0(x) (x ^ ROTL32(x, 9) ^ ROTL32(x,17))
#define SMP1(x) (x ^ ROTL32(x, 15) ^ ROTL32(x,23))

//	key schedule
#define STEP_SM3_KEY(w0, w3, w7, wa, wd) {	\
	t = w0 ^ w7 ^ ROTR32(wd, 17);	\
	t = SMP1(t);					\
	w0 = wa ^ ROTR32(w3, 25) ^ t;	}

//	rounds 0..15
#define STEP_SM3_RF0(a, b, c, d, e, f, g, h, w0, w4) {	\
	h = h + w0;											\
	t = ROTR32(a, 20);							        \
	u = t + e + tj;										\
	u = ROTR32(u, 25);							        \
	d = d + (t ^ u) + (a ^ b ^ c);						\
	b = ROTR32(b, 23);							        \
	h = h + u + (e ^ f ^ g);							\
	h = SMP0(h);								        \
	f = ROTR32(f, 13);							        \
	d = d + (w0 ^ w4);									\
	tj = ROTR32(tj, 31);	}

//	rounds 16..63
#define STEP_SM3_RF1(a, b, c, d, e, f, g, h, w0, w4) {	\
	h = h + w0;											\
	t = ROTR32(a, 20);							        \
	u = t + e + tj;										\
	u = ROTR32(u, 25);							        \
	d = d + (t ^ u) + (((a | c) & b) | (a & c));		\
	b = ROTR32(b, 23);							        \
	h = h + u + ((e & f) ^ (g &~ e));					\
	h = SMP0(h);								        \
	f = ROTR32(f, 13);							        \
	d = d + (w0 ^ w4);									\
	tj = ROTR32(tj, 31);	}


//	compression function (this one does *not* modify mp[])

void sm3_cf256_zksh(uint32_t *sp, const uint32_t *mp, size_t n)
{
	int i;
	uint32_t a, b, c, d, e, f, g, h;
	uint32_t m0, m1, m2, m3, m4, m5, m6, m7, m8, m9, ma, mb, mc, md, me, mf;
	uint32_t tj, t, u;

	for (i = 0; i < 8; i++) {
		sp[i] = REV8_BE32(sp[i]);
	}

	while (n >= 64) {

		n -= 64;

		a = sp[0];
		b = sp[1];
		c = sp[2];
		d = sp[3];
		e = sp[4];
		f = sp[5];
		g = sp[6];
		h = sp[7];

		//	load and reverse bytes

		m0 = REV8_BE32(mp[0]);
		m1 = REV8_BE32(mp[1]);
		m2 = REV8_BE32(mp[2]);
		m3 = REV8_BE32(mp[3]);
		m4 = REV8_BE32(mp[4]);
		m5 = REV8_BE32(mp[5]);
		m6 = REV8_BE32(mp[6]);
		m7 = REV8_BE32(mp[7]);
		m8 = REV8_BE32(mp[8]);
		m9 = REV8_BE32(mp[9]);
		ma = REV8_BE32(mp[10]);
		mb = REV8_BE32(mp[11]);
		mc = REV8_BE32(mp[12]);
		md = REV8_BE32(mp[13]);
		me = REV8_BE32(mp[14]);
		mf = REV8_BE32(mp[15]);
		mp += 16;

		tj = 0x79CC4519;

		STEP_SM3_RF0(a, b, c, d, e, f, g, h, m0, m4);
		STEP_SM3_RF0(d, a, b, c, h, e, f, g, m1, m5);
		STEP_SM3_RF0(c, d, a, b, g, h, e, f, m2, m6);
		STEP_SM3_RF0(b, c, d, a, f, g, h, e, m3, m7);

		STEP_SM3_RF0(a, b, c, d, e, f, g, h, m4, m8);
		STEP_SM3_RF0(d, a, b, c, h, e, f, g, m5, m9);
		STEP_SM3_RF0(c, d, a, b, g, h, e, f, m6, ma);
		STEP_SM3_RF0(b, c, d, a, f, g, h, e, m7, mb);

		STEP_SM3_RF0(a, b, c, d, e, f, g, h, m8, mc);
		STEP_SM3_RF0(d, a, b, c, h, e, f, g, m9, md);
		STEP_SM3_RF0(c, d, a, b, g, h, e, f, ma, me);
		STEP_SM3_RF0(b, c, d, a, f, g, h, e, mb, mf);

		STEP_SM3_KEY(m0, m3, m7, ma, md);
		STEP_SM3_KEY(m1, m4, m8, mb, me);
		STEP_SM3_KEY(m2, m5, m9, mc, mf);
		STEP_SM3_KEY(m3, m6, ma, md, m0);

		STEP_SM3_RF0(a, b, c, d, e, f, g, h, mc, m0);
		STEP_SM3_RF0(d, a, b, c, h, e, f, g, md, m1);
		STEP_SM3_RF0(c, d, a, b, g, h, e, f, me, m2);
		STEP_SM3_RF0(b, c, d, a, f, g, h, e, mf, m3);

		tj = 0x9D8A7A87;

		for (i = 0; i < 3; i++) {

			STEP_SM3_KEY(m4, m7, mb, me, m1);
			STEP_SM3_KEY(m5, m8, mc, mf, m2);
			STEP_SM3_KEY(m6, m9, md, m0, m3);
			STEP_SM3_KEY(m7, ma, me, m1, m4);

			STEP_SM3_RF1(a, b, c, d, e, f, g, h, m0, m4);
			STEP_SM3_RF1(d, a, b, c, h, e, f, g, m1, m5);
			STEP_SM3_RF1(c, d, a, b, g, h, e, f, m2, m6);
			STEP_SM3_RF1(b, c, d, a, f, g, h, e, m3, m7);

			STEP_SM3_KEY(m8, mb, mf, m2, m5);
			STEP_SM3_KEY(m9, mc, m0, m3, m6);
			STEP_SM3_KEY(ma, md, m1, m4, m7);
			STEP_SM3_KEY(mb, me, m2, m5, m8);

			STEP_SM3_RF1(a, b, c, d, e, f, g, h, m4, m8);
			STEP_SM3_RF1(d, a, b, c, h, e, f, g, m5, m9);
			STEP_SM3_RF1(c, d, a, b, g, h, e, f, m6, ma);
			STEP_SM3_RF1(b, c, d, a, f, g, h, e, m7, mb);

			STEP_SM3_KEY(mc, mf, m3, m6, m9);
			STEP_SM3_KEY(md, m0, m4, m7, ma);
			STEP_SM3_KEY(me, m1, m5, m8, mb);
			STEP_SM3_KEY(mf, m2, m6, m9, mc);

			STEP_SM3_RF1(a, b, c, d, e, f, g, h, m8, mc);
			STEP_SM3_RF1(d, a, b, c, h, e, f, g, m9, md);
			STEP_SM3_RF1(c, d, a, b, g, h, e, f, ma, me);
			STEP_SM3_RF1(b, c, d, a, f, g, h, e, mb, mf);

			STEP_SM3_KEY(m0, m3, m7, ma, md);
			STEP_SM3_KEY(m1, m4, m8, mb, me);
			STEP_SM3_KEY(m2, m5, m9, mc, mf);
			STEP_SM3_KEY(m3, m6, ma, md, m0);

			STEP_SM3_RF1(a, b, c, d, e, f, g, h, mc, m0);
			STEP_SM3_RF1(d, a, b, c, h, e, f, g, md, m1);
			STEP_SM3_RF1(c, d, a, b, g, h, e, f, me, m2);
			STEP_SM3_RF1(b, c, d, a, f, g, h, e, mf, m3);

		}

		sp[0] = sp[0] ^ a;
		sp[1] = sp[1] ^ b;
		sp[2] = sp[2] ^ c;
		sp[3] = sp[3] ^ d;
		sp[4] = sp[4] ^ e;
		sp[5] = sp[5] ^ f;
		sp[6] = sp[6] ^ g;
		sp[7] = sp[7] ^ h;
	}

	for (i = 0; i < 8; i++) {
		sp[i] = REV8_BE32(sp[i]);
	}
}
