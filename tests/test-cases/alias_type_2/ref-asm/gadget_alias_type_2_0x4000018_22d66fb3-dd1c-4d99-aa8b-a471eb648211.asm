----------------- TRANSMISSION -----------------
         alias_type_2:
4000000  movzx   r8d, word ptr [rdi+0x100]
4000008  mov     rsi, qword ptr [rdi]
400000b  mov     r10, qword ptr [rsi+r8]
400000f  movzx   r8d, word ptr [rdx+0x28]
4000014  mov     rax, qword ptr [rdx+0x20] ; {Attacker@rdx} > {Secret@0x4000014}
4000018  mov     rsi, qword ptr [rax] ; {Secret@0x4000014} > TRANSMISSION
400001b  mov     r11, qword ptr [rsi+r8]
400001f  mov     rax, qword ptr [rdi+0x200]
4000026  mov     rsi, qword ptr [rdi+0x240]
400002d  movzx   r8d, word ptr [rax]
4000031  mov     r13, qword ptr [rsi+r8]
4000035  jmp     0x400dead

------------------------------------------------
uuid: 22d66fb3-dd1c-4d99-aa8b-a471eb648211

Secret Address:
  - Expr: <BV64 rdx + 0x20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rdx + 0x20>]_24>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 rdx + 0x20>]_24>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rdx>}
Constraints: []
Branches: []
------------------------------------------------
