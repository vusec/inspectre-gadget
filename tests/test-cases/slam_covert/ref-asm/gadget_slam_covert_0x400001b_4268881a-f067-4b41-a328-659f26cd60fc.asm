----------------- TRANSMISSION -----------------
         multiple_bb:
4000000  cmp     r8, 0x0
4000004  je      trans1 ; Not Taken   <Bool r8 != 0x0>
4000006  cmp     r8, 0x1
400000a  je      trans2 ; Not Taken   <Bool r8 != 0x1>
400000c  cmp     r8, 0x2
4000010  je      trans3 ; Not Taken   <Bool r8 != 0x2>
4000012  cmp     r8, 0x3
4000016  je      trans4_5 ; Not Taken   <Bool r8 != 0x3>
         trans0:
4000018  mov     r9, qword ptr [rdi] ; {Attacker@rdi} > {Secret@0x4000018}
400001b  mov     r10, qword ptr [r9+0x5890] ; {Secret@0x4000018} > TRANSMISSION
4000022  jmp     end

------------------------------------------------
uuid: 4268881a-f067-4b41-a328-659f26cd60fc

Secret Address:
  - Expr: <BV64 rdi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rdi>]_20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: <BV64 0x5890>
  - Range: 0x5890
  - Independent Expr: <BV64 0x5890>
  - Independent Range: 0x5890
Transmission:
  - Expr: <BV64 0x5890 + LOAD_64[<BV64 rdi>]_20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rdi>}
Constraints: []
Branches: [(67108868, <Bool r8 != 0x0>, 'Not Taken'), (67108874, <Bool r8 != 0x1>, 'Not Taken'), (67108880, <Bool r8 != 0x2>, 'Not Taken'), (67108886, <Bool r8 != 0x3>, 'Not Taken')]
------------------------------------------------
