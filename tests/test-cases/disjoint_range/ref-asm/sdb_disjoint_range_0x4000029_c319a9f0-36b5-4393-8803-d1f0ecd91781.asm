------------ SECRET DEPENDENT BRANCH ------------
         disjoint_range:
4000000  mov     rax, qword ptr [rdi+0x28] ; {Attacker@rdi} -> {Secret@0x4000000}
4000004  mov     rsi, qword ptr [rsi+0x30]
4000008  cmp     rax, 0xf
400000c  je      exit ; Not Taken   <Bool LOAD_64[<BV64 rdi + 0x28>]_20 != 0xf>
400000e  mov     rcx, qword ptr [rax]
4000011  mov     r8, qword ptr [rax-0x7f000000]
4000018  cmp     rsi, 0xff
400001f  je      exit ; Not Taken   <Bool LOAD_64[<BV64 rsi + 0x30>]_21 != 0xff>
4000021  mov     r9, qword ptr [rsi+rax]
4000025  cmp     rax, 0xf
4000029  jg      exit

------------------------------------------------
uuid: c319a9f0-36b5-4393-8803-d1f0ecd91781
transmitter: TransmitterType.SECRET_DEP_BRANCH
CMP operation: SLE

Secret Dependent Branch:
  - Expr: <Bool LOAD_64[<BV64 rdi + 0x28>]_20 <=s 0xf>
Secret Address:
  - Expr: <BV64 rdi + 0x28>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rdi + 0x28>]_20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 rdi + 0x28>]_20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

CMP Value:
  - Expr: <BV64 0xf>
  - Range: 0xf
  - Controlled Expr: None
  - Controlled Range: None

Register Requirements:
  - All: {<BV64 rdi>}
  - Transmission: {<BV64 rdi>}
  - CMP Value: set()

Constraints: []
Branches: [('0x400000c', <Bool LOAD_64[<BV64 rdi + 0x28>]_20 != 0xf>, 'Not Taken'), ('0x400001f', <Bool LOAD_64[<BV64 rsi + 0x30>]_21 != 0xff>, 'Not Taken')]
------------------------------------------------
