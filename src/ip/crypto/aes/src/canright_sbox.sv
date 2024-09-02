//------------------------------------------------------------------------------
// Module   : canright_sbox.sv
//
// Project  : Vector-Crypto Subsystem (Marian)
// Author(s): Tom Szymkowiak <thomas.szymkowiak@tuni.fi>
// Created  : 06-dec-2023
//
// Description: SystemVerilog implementation of the Canright S-Box defined
// within {Canright, D. (2005) A Very Compact Rijndael S-box} (available at
// https://hdl.handle.net/10945/25608). Original implementation is in Verilog.
// This implementation updates syntax to SystemVerilog 2017. Module naming has
// been modified to improve readability. Original comments maintained. Test
// program in original code has been removed and a dedicated comprehensive
// testbench has been created (canright_sbox_tb.sv);
//
// Original Header:
// S-box using all normal bases
// case # 4 : [d^16, d], [alpha^8, alpha^2], [Omega^2, Omega]
// beta^8 = N^2*alpha^2, N = w^2
// optimized using OR gates and NAND gates
//
// Parameters:
//  - None
//
// Inputs:
//  - sbox_byte_i: Input byte
//  - encrypt_sel_i: Control signal to flag for s-box/inverse s-box operations
//
// Outputs:
//  - sbox_byte_o: Transformed output byte
//
// Revision History:
//  - Version 1.0: Initial release
//
//------------------------------------------------------------------------------

/*******************************************************************************
  square in GF(2^2), using normal basis [Omega^2,Omega]
  inverse is the same as square in GF(2^2), using any normal basis
*******************************************************************************/
module GF_SQ_2 (
  input  logic [1:0] A,
  output logic [1:0] Q
);

  assign Q = { A[0], A[1] };

endmodule


/*******************************************************************************
  scale by w = Omega in GF(2^2), using normal basis [Omega^2,Omega]
*******************************************************************************/
module GF_SCLW_2 (
  input  logic [1:0] A,
  output logic [1:0] Q
);

  assign Q = { (A[1] ^ A[0]), A[1] };

endmodule


/*******************************************************************************
  scale by w^2 = Omega^2 in GF(2^2), using normal basis [Omega^2,Omega]
*******************************************************************************/
module GF_SCLW2_2 (
  input  logic [1:0] A,
  output logic [1:0] Q
);

  assign Q = { A[0], (A[1] ^ A[0]) };

endmodule


/*******************************************************************************
  multiply in GF(2^2), shared factors, using normal basis [Omega^2,Omega]
*******************************************************************************/
module GF_MULS_2 (
  input  logic [1:0] A,
  input  logic       ab,
  input  logic [1:0] B,
  input  logic       cd,
  output logic [1:0] Q
);

  wire abcd, p, q;

  assign abcd = ~(ab & cd); /* note: ~& syntax for NAND won’t compile */
  assign p = (~(A[1] & B[1])) ^ abcd;
  assign q = (~(A[0] & B[0])) ^ abcd;
  assign Q = { p, q };

endmodule


/*******************************************************************************
  multiply & scale by N in GF(2^2), shared factors, basis [Omega^2,Omega]
*******************************************************************************/
module GF_MULS_SCL_2 (
  input  logic [1:0] A,
  input  logic       ab,
  input  logic [1:0] B,
  input  logic       cd,
  output logic [1:0] Q
);

  wire t, p, q;

  assign t = ~(A[0] & B[0]); /* note: ~& syntax for NAND won’t compile */
  assign p = (~(ab & cd)) ^ t;
  assign q = (~(A[1] & B[1])) ^ t;
  assign Q = { p, q };

endmodule


/*******************************************************************************
  inverse in GF(2^4)/GF(2^2), using normal basis [alpha^8, alpha^2]
*******************************************************************************/
module GF_INV_4 (
  input  logic [3:0] A,
  output logic [3:0] Q
);

  wire [1:0] a, b, c, d, p, q;
  wire sa, sb, sd; /* for shared factors in multipliers */

  assign a = A[3:2];
  assign b = A[1:0];
  assign sa = a[1] ^ a[0];
  assign sb = b[1] ^ b[0];

/* optimize this section as shown below
  GF_MULS_2 abmul(a, sa, b, sb, ab);
  GF_SQ_2 absq( (a ^ b), ab2);
  GF_SCLW2_2 absclN( ab2, ab2N);
  GF_SQ_2 dinv( (ab ^ ab2N), d); */
  assign c = { /* note: ~| syntax for NOR won’t compile */
              ~(a[1] | b[1]) ^ (~(sa & sb)) ,
              ~(sa | sb) ^ (~(a[0] & b[0]))
             };

  GF_SQ_2 dinv (
    .A ( c ),
    .Q ( d )
  );
  /* end of optimization */

  assign sd = d[1] ^ d[0];

  GF_MULS_2 pmul (
    .A  ( d  ),
    .ab ( sd ),
    .B  ( b  ),
    .cd ( sb ),
    .Q  ( p  )
  );

  GF_MULS_2 qmul (
    .A  ( d  ),
    .ab ( sd ),
    .B  ( a  ),
    .cd ( sa ),
    .Q  ( q  )
  );

  assign Q = { p, q };

endmodule


/*******************************************************************************
  square & scale by nu in GF(2^4)/GF(2^2), normal basis [alpha^8, alpha^2]
  nu = beta^8 = N^2*alpha^2, N = w^2
*******************************************************************************/
module GF_SQ_SCL_4 (
  input  logic [3:0] A,
  output logic [3:0] Q
);

  wire [1:0] a, b, ab2, b2, b2N2;

  assign a = A[3:2];
  assign b = A[1:0];

  GF_SQ_2 absq (
    .A ( a ^ b ),
    .Q ( ab2   )
  );

  GF_SQ_2 bsq (
    .A ( b  ),
    .Q ( b2 )
  );

  GF_SCLW_2 bmulN2(
    .A ( b2   ),
    .Q ( b2N2 )
  );

  assign Q = { ab2, b2N2 };

endmodule


/*******************************************************************************
  multiply in GF(2^4)/GF(2^2), shared factors, basis [alpha^8, alpha^2]
*******************************************************************************/
module GF_MULS_4 (
  input  logic [3:0] A,
  input  logic [1:0] a,
  input  logic       Al,
  input  logic       Ah,
  input  logic       aa,
  input  logic [3:0] B,
  input  logic [1:0] b,
  input  logic       Bl,
  input  logic       Bh,
  input  logic       bb,
  output logic [3:0] Q
);

  wire [1:0] ph, pl, ps, p;
  wire t;

  GF_MULS_2 himul (
    .A  ( A[3:2] ),
    .ab ( Ah     ),
    .B  ( B[3:2] ),
    .cd ( Bh     ),
    .Q  ( ph     )
  );

  GF_MULS_2 lomul (
    .A  ( A[1:0] ),
    .ab ( Al     ),
    .B  ( B[1:0] ),
    .cd ( Bl     ),
    .Q  ( pl     )
  );

  GF_MULS_SCL_2 summul (
    .A  ( a  ),
    .ab ( aa ),
    .B  ( b  ),
    .cd ( bb ),
    .Q  ( p  )
  );

  assign Q = { (ph ^ p), (pl ^ p) };

endmodule


/*******************************************************************************
  inverse in GF(2^8)/GF(2^4), using normal basis [d^16, d]
*******************************************************************************/
module GF_INV_8 (
  input  logic [7:0] A,
  output logic [7:0] Q
);

  wire [3:0] a, b, c, d, p, q;
  wire [1:0] sa, sb, sd, t; /* for shared factors in multipliers */
  wire al, ah, aa, bl, bh, bb, dl, dh, dd; /* for shared factors */
  wire c1, c2, c3; /* for temp var */

  assign a = A[7:4];
  assign b = A[3:0];
  assign sa = a[3:2] ^ a[1:0];
  assign sb = b[3:2] ^ b[1:0];
  assign al = a[1] ^ a[0];
  assign ah = a[3] ^ a[2];
  assign aa = sa[1] ^ sa[0];
  assign bl = b[1] ^ b[0];
  assign bh = b[3] ^ b[2];
  assign bb = sb[1] ^ sb[0];

  /* optimize this section as shown below
  GF_MULS_4 abmul(a, sa, al, ah, aa, b, sb, bl, bh, bb, ab);
  GF_SQ_SCL_4 absq( (a ^ b), ab2);
  GF_INV_4 dinv( (ab ^ ab2), d); */
  assign c1 = ~(ah & bh);
  assign c2 = ~(sa[0] & sb[0]);
  assign c3 = ~(aa & bb);
  assign c = { /* note: ~| syntax for NOR won’t compile */
               (~(sa[0] | sb[0]) ^ (~(a[3] & b[3]))) ^ c1 ^ c3 ,
               (~(sa[1] | sb[1]) ^ (~(a[2] & b[2]))) ^ c1 ^ c2 ,
               (~(al | bl) ^ (~(a[1] & b[1]))) ^ c2 ^ c3 ,
               (~(a[0] | b[0]) ^ (~(al & bl))) ^ (~(sa[1] & sb[1])) ^ c2
             };

  GF_INV_4 dinv (
    .A ( c ),
    .Q ( d )
  );

  /* end of optimization */

  assign sd = d[3:2] ^ d[1:0];
  assign dl = d[1] ^ d[0];
  assign dh = d[3] ^ d[2];
  assign dd = sd[1] ^ sd[0];

  GF_MULS_4 pmul (
    .A  ( d  ),
    .a  ( sd ),
    .Al ( dl ),
    .Ah ( dh ),
    .aa ( dd ),
    .B  ( b  ),
    .b  ( sb ),
    .Bl ( bl ),
    .Bh ( bh ),
    .bb ( bb ),
    .Q  ( p  )
  );

  GF_MULS_4 qmul (
    .A  ( d  ),
    .a  ( sd ),
    .Al ( dl ),
    .Ah ( dh ),
    .aa ( dd ),
    .B  ( a  ),
    .b  ( sa ),
    .Bl ( al ),
    .Bh ( ah ),
    .bb ( aa ),
    .Q  ( q  )
  );

  assign Q = { p, q };

endmodule


/*******************************************************************************
  MUX21I is an inverting 2:1 multiplexor
*******************************************************************************/
module MUX21I (
  input  logic A,
  input  logic B,
  input  logic s,
  output logic Q
);

assign Q = ~ ( s ? A : B ); /* mock-up for FPGA implementation */

endmodule


/*******************************************************************************
  select and invert (NOT) byte, using MUX21I
*******************************************************************************/
module SELECT_NOT_8 (
  input  logic [7:0] A,
  input  logic [7:0] B,
  input  logic       s,
  output logic [7:0] Q
);

  MUX21I m7 (
    .A ( A[7] ),
    .B ( B[7] ),
    .s ( s    ),
    .Q ( Q[7] )
  );

  MUX21I m6 (
    .A ( A[6] ),
    .B ( B[6] ),
    .s ( s    ),
    .Q ( Q[6] )
  );

  MUX21I m5 (
    .A ( A[5] ),
    .B ( B[5] ),
    .s ( s    ),
    .Q ( Q[5] )
  );

  MUX21I m4 (
    .A ( A[4] ),
    .B ( B[4] ),
    .s ( s    ),
    .Q ( Q[4] )
  );

  MUX21I m3 (
    .A ( A[3] ),
    .B ( B[3] ),
    .s ( s    ),
    .Q ( Q[3] )
  );

  MUX21I m2 (
    .A ( A[2] ),
    .B ( B[2] ),
    .s ( s    ),
    .Q ( Q[2] )
  );

  MUX21I m1 (
    .A ( A[1] ),
    .B ( B[1] ),
    .s ( s    ),
    .Q ( Q[1] )
  );

  MUX21I m0 (
    .A ( A[0] ),
    .B ( B[0] ),
    .s ( s    ),
    .Q ( Q[0] )
  );

endmodule


/*******************************************************************************
  find either Sbox or its inverse in GF(2^8), by Canright Algorithm
*******************************************************************************/
module canright_sbox (
  input  logic [7:0] sbox_byte_i,
  input  logic       encrypt_sel_i, /* 1 for Sbox, 0 for inverse Sbox */
  output logic [7:0] sbox_byte_o
);

  wire [7:0] B, C, D, X, Y, Z;
  wire R1, R2, R3, R4, R5, R6, R7, R8, R9;
  wire T1, T2, T3, T4, T5, T6, T7, T8, T9, T10;

  /* change basis from GF(2^8) to GF(2^8)/GF(2^4)/GF(2^2) */
  /* combine with bit inverse matrix multiply of Sbox */
  assign R1 = sbox_byte_i[7] ^ sbox_byte_i[5] ;
  assign R2 = sbox_byte_i[7] ~^ sbox_byte_i[4] ;
  assign R3 = sbox_byte_i[6] ^ sbox_byte_i[0] ;
  assign R4 = sbox_byte_i[5] ~^ R3 ;
  assign R5 = sbox_byte_i[4] ^ R4 ;
  assign R6 = sbox_byte_i[3] ^ sbox_byte_i[0] ;
  assign R7 = sbox_byte_i[2] ^ R1 ;
  assign R8 = sbox_byte_i[1] ^ R3 ;
  assign R9 = sbox_byte_i[3] ^ R8 ;
  assign B[7] = R7 ~^ R8 ;
  assign B[6] = R5 ;
  assign B[5] = sbox_byte_i[1] ^ R4 ;
  assign B[4] = R1 ~^ R3 ;
  assign B[3] = sbox_byte_i[1] ^ R2 ^ R6 ;
  assign B[2] = ~ sbox_byte_i[0] ;
  assign B[1] = R4 ;
  assign B[0] = sbox_byte_i[2] ~^ R9 ;
  assign Y[7] = R2 ;
  assign Y[6] = sbox_byte_i[4] ^ R8 ;
  assign Y[5] = sbox_byte_i[6] ^ sbox_byte_i[4] ;
  assign Y[4] = R9 ;
  assign Y[3] = sbox_byte_i[6] ~^ R2 ;
  assign Y[2] = R7 ;
  assign Y[1] = sbox_byte_i[4] ^ R6 ;
  assign Y[0] = sbox_byte_i[1] ^ R5 ;

  SELECT_NOT_8 sel_in (
    .A ( B             ),
    .B ( Y             ),
    .s ( encrypt_sel_i ),
    .Q ( Z             )
  );

  GF_INV_8 inv (
    .A ( Z ),
    .Q ( C )
  );

  /* change basis back from GF(2^8)/GF(2^4)/GF(2^2) to GF(2^8) */
  assign T1 = C[7] ^ C[3] ;
  assign T2 = C[6] ^ C[4] ;
  assign T3 = C[6] ^ C[0] ;
  assign T4 = C[5] ~^ C[3] ;
  assign T5 = C[5] ~^ T1 ;
  assign T6 = C[5] ~^ C[1] ;
  assign T7 = C[4] ~^ T6 ;
  assign T8 = C[2] ^ T4 ;
  assign T9 = C[1] ^ T2 ;
  assign T10 = T3 ^ T5 ;
  assign D[7] = T4 ;
  assign D[6] = T1 ;
  assign D[5] = T3 ;
  assign D[4] = T5 ;
  assign D[3] = T2 ^ T5 ;
  assign D[2] = T3 ^ T8 ;
  assign D[1] = T7 ;
  assign D[0] = T9 ;
  assign X[7] = C[4] ~^ C[1] ;
  assign X[6] = C[1] ^ T10 ;
  assign X[5] = C[2] ^ T10 ;
  assign X[4] = C[6] ~^ C[1] ;
  assign X[3] = T8 ^ T9 ;
  assign X[2] = C[7] ~^ T7 ;
  assign X[1] = T6 ;
  assign X[0] = ~ C[2] ;

  SELECT_NOT_8 sel_out (
    .A ( D             ),
    .B ( X             ),
    .s ( encrypt_sel_i ),
    .Q ( sbox_byte_o   )
  );

endmodule
