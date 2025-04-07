----------------- TRANSMISSION -----------------
         code_load:
4000000  cmp     r8, 0x0
4000004  je      trans1 ; Not Taken   <Bool r8 != 0x0>
4000006  cmp     r8, 0x1
400000a  je      trans2 ; Taken   <Bool r8 == 0x1>
         trans2:
4000021  movzx   rax, word ptr [rdi] ; {Attacker@rdi} -> {Secret@0x4000021}
4000025  jmp     qword ptr [rax*0x8-0x7f000000] ; {Secret@0x4000021} -> TRANSMISSION

------------------------------------------------
uuid: ecbf95fb-d67e-4ca7-b971-f9fb3a4ee83d
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 rdi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#45 .. (0#3 .. LOAD_16[<BV64 rdi>]_22) << 0x3>
  - Range: (0x0,0x7fff8, 0x8) Exact: True
  - Spread: 3 - 18
  - Number of Bits Inferable: 16
Base:
  - Expr: <BV64 0xffffffff81000000>
  - Range: 0xffffffff81000000
  - Independent Expr: <BV64 0xffffffff81000000>
  - Independent Range: 0xffffffff81000000
Transmission:
  - Expr: <BV64 0xffffffff81000000 + (0#45 .. (0#3 .. LOAD_16[<BV64 rdi>]_22) << 0x3)>
  - Range: (0xffffffff81000000,0xffffffff8107fff8, 0x8) Exact: True

Register Requirements: {<BV64 rdi>}
Constraints: []
Branches: [('0x4000004', <Bool r8 != 0x0>, 'Not Taken'), ('0x400000a', <Bool r8 == 0x1>, 'Taken')]
------------------------------------------------
