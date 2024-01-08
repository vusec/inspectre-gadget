----------------- TRANSMISSION -----------------
         complex_transmission:
4000000  mov     r8, qword ptr [rdi]
4000003  mov     r9, qword ptr [rsi]
4000006  add     r9, r8
4000009  shl     r9, 0x6
400000d  mov     r10, qword ptr [r9]
4000010  mov     r8, qword ptr [rdi] ; {Attacker@rdi} > {Secret@0x4000010}
4000013  mov     r9, qword ptr [rsi]
4000016  mov     rax, 0x8
400001d  mul     r8
4000020  mov     r11, qword ptr [rax] ; {Secret@0x4000010} > TRANSMISSION
4000023  mov     rax, r8
4000026  mul     r9
4000029  mov     r12, qword ptr [rax]
400002c  mov     rax, r8
400002f  mul     rdi
4000032  mov     r13, qword ptr [rax]
4000035  jmp     0x400dead

------------------------------------------------
uuid: 771e8198-40f9-42d1-8041-2fff185483b5

Secret Address:
  - Expr: <BV64 rdi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0x8 * LOAD_64[<BV64 rdi>]_23>
  - Range: (0x0,0xfffffffffffffff8, 0x1) Exact: True
  - Spread: 3 - 63
  - Number of Bits Inferable: 61
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 0x8 * LOAD_64[<BV64 rdi>]_23>
  - Range: (0x0,0xfffffffffffffff8, 0x1) Exact: True

Register Requirements: {<BV64 rdi>}
Constraints: []
Branches: []
------------------------------------------------
