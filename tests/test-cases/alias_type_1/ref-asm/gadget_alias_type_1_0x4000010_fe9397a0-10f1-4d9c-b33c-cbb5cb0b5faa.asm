----------------- TRANSMISSION -----------------
         alias_type_1:
4000000  movzx   r8d, word ptr [rdi]
4000004  mov     rcx, qword ptr [r8-0x20]
4000008  mov     r10, qword ptr [rdi+r8+0x50]
400000d  mov     r11, qword ptr [rsi] ; {Attacker@rsi} > {Secret@0x400000d}
4000010  movzx   r9d, word ptr [r11] ; {Secret@0x400000d} > TRANSMISSION
4000014  mov     rax, qword ptr [r11+r9+0x20]
4000019  jmp     0x400dead

------------------------------------------------
uuid: fe9397a0-10f1-4d9c-b33c-cbb5cb0b5faa

Secret Address:
  - Expr: <BV64 rsi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rsi>]_23>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 rsi>]_23>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rsi>}
Constraints: []
Branches: []
------------------------------------------------
