----------------- TRANSMISSION -----------------
         disjoint_range:
4000000  mov     rax, qword ptr [rdi+0x28] ; {Attacker@rdi} -> {Secret@0x4000000}
4000004  mov     rsi, qword ptr [rsi+0x30]
4000008  cmp     rax, 0xf
400000c  je      exit ; Not Taken   <Bool LOAD_64[<BV64 rdi + 0x28>]_20 != 0xf>
400000e  mov     rcx, qword ptr [rax]
4000011  mov     r8, qword ptr [rax-0x7f000000] ; {Secret@0x4000000} -> TRANSMISSION
4000018  cmp     rsi, 0xff
400001f  je      exit

------------------------------------------------
uuid: acc48927-443d-44c7-8036-d36cf7bf8bca
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 rdi + 0x28>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rdi + 0x28>]_20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: <BV64 0xffffffff81000000>
  - Range: 0xffffffff81000000
  - Independent Expr: <BV64 0xffffffff81000000>
  - Independent Range: 0xffffffff81000000
Transmission:
  - Expr: <BV64 0xffffffff81000000 + LOAD_64[<BV64 rdi + 0x28>]_20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rdi>}
Constraints: []
Branches: [('0x400000c', <Bool LOAD_64[<BV64 rdi + 0x28>]_20 != 0xf>, 'Not Taken')]
------------------------------------------------
