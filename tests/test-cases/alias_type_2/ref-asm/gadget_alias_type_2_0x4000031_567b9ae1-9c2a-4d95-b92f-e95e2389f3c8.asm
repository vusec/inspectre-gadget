----------------- TRANSMISSION -----------------
         alias_type_2:
4000000  movzx   r8d, word ptr [rdi+0x100]
4000008  mov     rsi, qword ptr [rdi]
400000b  mov     r10, qword ptr [rsi+r8]
400000f  movzx   r8d, word ptr [rdx+0x28]
4000014  mov     rax, qword ptr [rdx+0x20]
4000018  mov     rsi, qword ptr [rax]
400001b  mov     r11, qword ptr [rsi+r8]
400001f  mov     rax, qword ptr [rdi+0x200] ; {Attacker@rdi} > {Attacker@0x400001f}
4000026  mov     rsi, qword ptr [rdi+0x240] ; {Attacker@rdi} > {Secret@0x4000026}
400002d  movzx   r8d, word ptr [rax] ; {Attacker@0x400001f} > {Attacker@0x400002d}
4000031  mov     r13, qword ptr [rsi+r8] ; {Attacker@0x400002d, Secret@0x4000026} > TRANSMISSION
4000035  jmp     0x400dead

------------------------------------------------
uuid: 567b9ae1-9c2a-4d95-b92f-e95e2389f3c8

Secret Address:
  - Expr: <BV64 rdi + 0x240>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rdi + 0x240>]_28>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: <BV64 0#48 .. LOAD_16[<BV64 LOAD_64[<BV64 rdi + 0x200>]_27>]_29>
  - Range: (0x0,0xffff, 0x1) Exact: True
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 rdi + 0x240>]_28 + (0#48 .. LOAD_16[<BV64 LOAD_64[<BV64 rdi + 0x200>]_27>]_29)>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rdi>}
Constraints: []
Branches: []
------------------------------------------------
