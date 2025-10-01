----------------- TRANSMISSION -----------------
         code_load:
4000000  cmp     r8, 0x0
4000004  je      trans1 ; Not Taken   <Bool r8 != 0x0>
4000006  cmp     r8, 0x1
400000a  je      trans2 ; Taken   <Bool r8 == 0x1>
         trans2:
4000021  movzx   rax, word ptr [rdi] ; {Attacker@rdi} -> {Attacker@0x4000021}
4000025  jmp     qword ptr [rax*0x8-0x7f000000] ; {Secret@0x4000025} -> TRANSMISSION

------------------------------------------------
uuid: daa8f36e-f0eb-4e12-b122-5c7bbad5c3f2
transmitter: TransmitterType.CODE_LOAD

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
Branches: [('0x4000004', <Bool r8 != 0x0>, 'Not Taken'), ('0x400000a', <Bool r8 == 0x1>, 'Taken')]
------------------------------------------------
