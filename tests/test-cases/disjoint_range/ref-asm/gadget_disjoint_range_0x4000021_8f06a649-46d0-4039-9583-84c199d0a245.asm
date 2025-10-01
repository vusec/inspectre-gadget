----------------- TRANSMISSION -----------------
         disjoint_range:
4000000  mov     rax, qword ptr [rdi+0x28] ; {Attacker@rdi} -> {Attacker@0x4000000}
4000004  mov     rsi, qword ptr [rsi+0x30] ; {Attacker@rsi} -> {Secret@0x4000004}
4000008  cmp     rax, 0xf
400000c  je      exit ; Not Taken   <Bool LOAD_64[<BV64 rdi + 0x28>]_20 != 0xf>
400000e  mov     rcx, qword ptr [rax]
4000011  mov     r8, qword ptr [rax-0x7f000000]
4000018  cmp     rsi, 0xff
400001f  je      exit ; Not Taken   <Bool LOAD_64[<BV64 rsi + 0x30>]_21 != 0xff>
4000021  mov     r9, qword ptr [rsi+rax] ; {Attacker@0x4000000, Secret@0x4000004} -> TRANSMISSION
4000025  cmp     rax, 0xf
4000029  jg      exit

------------------------------------------------
uuid: 8f06a649-46d0-4039-9583-84c199d0a245
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 rsi + 0x30>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rsi + 0x30>]_21>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: <BV64 LOAD_64[<BV64 rdi + 0x28>]_20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Independent Expr: <BV64 LOAD_64[<BV64 rdi + 0x28>]_20>
  - Independent Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 rsi + 0x30>]_21 + LOAD_64[<BV64 rdi + 0x28>]_20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rsi>, <BV64 rdi>}
Constraints: []
Branches: [('0x400000c', <Bool LOAD_64[<BV64 rdi + 0x28>]_20 != 0xf>, 'Not Taken'), ('0x400001f', <Bool LOAD_64[<BV64 rsi + 0x30>]_21 != 0xff>, 'Not Taken')]
------------------------------------------------
