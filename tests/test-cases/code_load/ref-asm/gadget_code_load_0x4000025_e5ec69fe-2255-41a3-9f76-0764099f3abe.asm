----------------- TRANSMISSION -----------------
         code_load:
4000000  cmp     r8, 0x0
4000004  je      trans1 ; Not Taken   <Bool r8 != 0x0>
4000006  cmp     r8, 0x1
400000a  je      trans2 ; Taken   <Bool r8 == 0x1>
         trans2:
4000021  movzx   rax, word ptr [rdi] ; {Attacker@rdi} > {Attacker@0x4000021}
4000025  jmp     qword ptr [rax*0x8-0x7f000000] ; {Secret@0x4000025} > TRANSMISSION

------------------------------------------------
uuid: e5ec69fe-2255-41a3-9f76-0764099f3abe

Secret Address:
  - Expr: <BV64 ((0#48 .. LOAD_16[<BV64 rdi>]_22) << 0x3) + 0xffffffff81000000>
  - Range: (0xffffffff81000000,0xffffffff8107fff8, 0x8) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 ((0#48 .. LOAD_16[<BV64 rdi>]_22) << 0x3) + 0xffffffff81000000>]_23>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 ((0#48 .. LOAD_16[<BV64 rdi>]_22) << 0x3) + 0xffffffff81000000>]_23>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rdi>}
Constraints: []
Branches: [(67108868, <Bool r8 != 0x0>, 'Not Taken'), (67108874, <Bool r8 == 0x1>, 'Taken')]
------------------------------------------------
