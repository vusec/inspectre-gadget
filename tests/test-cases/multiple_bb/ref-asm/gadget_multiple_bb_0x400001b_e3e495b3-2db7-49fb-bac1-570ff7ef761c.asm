----------------- TRANSMISSION -----------------
         multiple_bb:
4000000  mov     r8, qword ptr [rdi] ; {Attacker@rdi} -> {Secret@0x4000000}
4000003  movzx   r9, word ptr [rdi]
4000007  cmp     rax, 0x0
400000b  je      trans1 ; Taken   <Bool rax == 0x0>
         trans1:
400001b  mov     r10, qword ptr [r8+rax-0x10] ; {Secret@0x4000000, Attacker@rax} -> TRANSMISSION
4000020  mov     r11, qword ptr [rsi]
         end:
4000023  jmp     0x400dead

------------------------------------------------
uuid: e3e495b3-2db7-49fb-bac1-570ff7ef761c
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 rdi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rdi>]_20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: <BV64 0xfffffffffffffff0 + rax>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Independent Expr: <BV64 0xfffffffffffffff0 + rax>
  - Independent Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmission:
  - Expr: <BV64 0xfffffffffffffff0 + LOAD_64[<BV64 rdi>]_20 + rax>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rax>, <BV64 rdi>}
Constraints: []
Branches: [('0x400000b', <Bool rax == 0x0>, 'Taken')]
------------------------------------------------
