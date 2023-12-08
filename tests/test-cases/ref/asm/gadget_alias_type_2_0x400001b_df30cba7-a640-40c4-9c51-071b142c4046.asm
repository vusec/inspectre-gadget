----------------- TRANSMISSION -----------------
         alias_type_2:
4000000  movzx   r8d, word ptr [rdi+0x100]
4000008  mov     rsi, qword ptr [rdi]
400000b  mov     r10, qword ptr [rsi+r8]
400000f  movzx   r8d, word ptr [rdx+0x28] ; {Attacker@rdx} > {Secret@0x400000f}
4000014  mov     rax, qword ptr [rdx+0x20] ; {Attacker@rdx} > {Attacker@0x4000014}
4000018  mov     rsi, qword ptr [rax] ; {Attacker@0x4000014} > {Attacker@0x4000018}
400001b  mov     r11, qword ptr [rsi+r8] ; {Attacker@0x4000018, Secret@0x400000f} > TRANSMISSION
400001f  mov     rax, qword ptr [rdi+0x200]
4000026  mov     rsi, qword ptr [rdi+0x240]
400002d  movzx   r8d, word ptr [rax]
4000031  mov     r13, qword ptr [rsi+r8]
4000035  jmp     0x400dead

------------------------------------------------
uuid: df30cba7-a640-40c4-9c51-071b142c4046

Secret Address:
  - Expr: <BV64 rdx + 0x28>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#48 .. LOAD_16[<BV64 rdx + 0x28>]_23>
  - Range: (0x0,0xffff, 0x1) Exact: True
  - Spread: 0 - 15
  - Number of Bits Inferable: 16
Base:
  - Expr: <BV64 LOAD_64[<BV64 LOAD_64[<BV64 rdx + 0x20>]_24>]_25>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 LOAD_64[<BV64 rdx + 0x20>]_24>]_25 + (0#48 .. LOAD_16[<BV64 rdx + 0x28>]_23)>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rdx>}
Constraints: []
Branches: []
------------------------------------------------
