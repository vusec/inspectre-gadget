----------------- TRANSMISSION -----------------
         alias_type_2:
4000000  movzx   r8d, word ptr [rdi+0x100] ; {Attacker@rdi} -> {Attacker@0x4000000}
4000008  mov     rsi, qword ptr [rdi] ; {Attacker@rdi} -> {Secret@0x4000008}
400000b  mov     r10, qword ptr [rsi+r8] ; {Secret@0x4000008, Attacker@0x4000000} -> TRANSMISSION
400000f  movzx   r8d, word ptr [rdx+0x28]
4000014  mov     rax, qword ptr [rdx+0x20]
4000018  mov     rsi, qword ptr [rax]
400001b  mov     r11, qword ptr [rsi+r8]
400001f  mov     rax, qword ptr [rdi+0x200]
4000026  mov     rsi, qword ptr [rdi+0x240]
400002d  movzx   r8d, word ptr [rax]
4000031  mov     r13, qword ptr [rsi+r8]
4000035  jmp     0x400dead

------------------------------------------------
uuid: 149c626d-ea68-4b28-89cd-f76479091089
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 rdi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rdi>]_21>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: <BV64 0#48 .. LOAD_16[<BV64 rdi + 0x100>]_20>
  - Range: (0x0,0xffff, 0x1) Exact: True
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 rdi>]_21 + (0#48 .. LOAD_16[<BV64 rdi + 0x100>]_20)>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rdi>}
Constraints: []
Branches: []
------------------------------------------------
