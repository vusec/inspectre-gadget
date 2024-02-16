----------------- TRANSMISSION -----------------
         disjoint_range:
4000000  mov     rax, qword ptr [rdi+0x28]
4000004  mov     rsi, qword ptr [rsi+0x30] ; {Attacker@rsi} > {Secret@0x4000004}
4000008  cmp     rax, 0xf
400000c  je      exit ; Not Taken   <Bool LOAD_64[<BV64 rdi + 0x28>]_20 != 0xf>
400000e  mov     rcx, qword ptr [rax]
4000011  mov     r8, qword ptr [rax-0x7f000000]
4000018  cmp     rsi, 0xff
400001f  je      exit ; Not Taken   <Bool LOAD_64[<BV64 rsi + 0x30>]_21 != 0xff>
4000021  mov     r9, qword ptr [rsi+rax]
4000025  cmp     rax, 0xf
4000029  jg      exit ; Not Taken   <Bool LOAD_64[<BV64 rdi + 0x28>]_20 <=s 0xf>
400002b  mov     rdx, qword ptr [rax]
400002e  cmp     rsi, 0xffff
4000035  ja      exit ; Not Taken   <Bool LOAD_64[<BV64 rsi + 0x30>]_21 <= 0xffff>
4000037  mov     rdx, qword ptr [rsi]
400003a  mov     rbx, qword ptr [rsi-0x7f000000] ; {Secret@0x4000004} > TRANSMISSION
4000041  jmp     exit

------------------------------------------------
uuid: 997eff1e-47a9-4c7a-a633-88158e51836d

Secret Address:
  - Expr: <BV64 rsi + 0x30>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rsi + 0x30>]_21>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: <BV64 0xffffffff81000000>
  - Range: 0xffffffff81000000
  - Independent Expr: <BV64 0xffffffff81000000>
  - Independent Range: 0xffffffff81000000
Transmission:
  - Expr: <BV64 0xffffffff81000000 + LOAD_64[<BV64 rsi + 0x30>]_21>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rsi>}
Constraints: []
Branches: [(67108876, <Bool LOAD_64[<BV64 rdi + 0x28>]_20 != 0xf>, 'Not Taken'), (67108895, <Bool LOAD_64[<BV64 rsi + 0x30>]_21 != 0xff>, 'Not Taken'), (67108905, <Bool LOAD_64[<BV64 rdi + 0x28>]_20 <=s 0xf>, 'Not Taken'), (67108917, <Bool LOAD_64[<BV64 rsi + 0x30>]_21 <= 0xffff>, 'Not Taken')]
------------------------------------------------
