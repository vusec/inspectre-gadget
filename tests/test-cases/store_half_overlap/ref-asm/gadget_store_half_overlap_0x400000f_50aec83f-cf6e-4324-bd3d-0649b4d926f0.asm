----------------- TRANSMISSION -----------------
         store_half_overlap:
4000000  mov     qword ptr [r8], rsi
4000003  mov     qword ptr [r8+0xa], rdi
4000007  mov     rdi, qword ptr [r8+0x4] ; {Attacker@r8} -> {Secret@0x4000007}
400000b  movzx   r11, word ptr [rdx] ; {Attacker@rdx} -> {Attacker@0x400000b}
400000f  mov     rdi, qword ptr [r11+rdi-0x7f000000] ; {Attacker@0x400000b, Attacker@rdi, Attacker@rsi, Secret@0x4000007} -> TRANSMISSION
4000017  jmp     0x400dead

------------------------------------------------
uuid: 50aec83f-cf6e-4324-bd3d-0649b4d926f0
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 r8 + 0x4>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#16 .. (0#32 .. LOAD_64[<BV64 r8 + 0x4>_22[47:32]) << 0x20>
  - Range: (0x0,0xffff00000000, 0x100000000) Exact: True
  - Spread: 32 - 47
  - Number of Bits Inferable: 16
Base:
  - Expr: <BV64 0xffffffff81000000 + (0#48 .. LOAD_16[<BV64 rdx>]_23) + ((0#48 .. rdi[15:0]) << 0x30) + (0#16 .. (0#16 .. rsi[63:32]))>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: False
  - Independent Expr: <BV64 0xffffffff81000000 + (0#48 .. LOAD_16[<BV64 rdx>]_23) + ((0#48 .. rdi[15:0]) << 0x30) + (0#16 .. (0#16 .. rsi[63:32]))>
  - Independent Range: (0x0,0xffffffffffffffff, 0x1) Exact: False
Transmission:
  - Expr: <BV64 0xffffffff81000000 + (0#48 .. LOAD_16[<BV64 rdx>]_23) + (((0#48 .. rdi[15:0]) << 0x30) + (0#16 .. ((0#32 .. LOAD_64[<BV64 r8 + 0x4>_22[47:32]) << 0x20) + (0#16 .. rsi[63:32])))>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: False

Register Requirements: ['<BV64 r8>', '<BV64 rdi>', '<BV64 rdx>', '<BV64 rsi>']
Constraints: []
Branches: []
------------------------------------------------
