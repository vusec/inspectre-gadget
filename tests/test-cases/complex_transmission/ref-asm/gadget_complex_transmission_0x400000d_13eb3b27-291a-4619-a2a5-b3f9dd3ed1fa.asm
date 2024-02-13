----------------- TRANSMISSION -----------------
         complex_transmission:
4000000  mov     r8, qword ptr [rdi] ; {Attacker@rdi} > {Attacker@0x4000000}
4000003  mov     r9, qword ptr [rsi] ; {Attacker@rsi} > {Secret@0x4000003}
4000006  add     r9, r8
4000009  shl     r9, 0x6
400000d  mov     r10, qword ptr [r9] ; {Attacker@0x4000000, Secret@0x4000003} > TRANSMISSION
4000010  mov     r8, qword ptr [rdi]
4000013  mov     r9, qword ptr [rsi]
4000016  mov     rax, 0x8
400001d  mul     r8
4000020  mov     r11, qword ptr [rax]
4000023  mov     rax, r8
4000026  mul     r9
4000029  mov     r12, qword ptr [rax]
400002c  mov     rax, r8
400002f  mul     rdi
4000032  mov     r13, qword ptr [rax]
4000035  jmp     0x400dead

------------------------------------------------
uuid: 13eb3b27-291a-4619-a2a5-b3f9dd3ed1fa

Secret Address:
  - Expr: <BV64 rsi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 (0#6 .. LOAD_64[<BV64 rsi>]_21[57:0]) << 0x6>
  - Range: (0x0,0xffffffffffffffc0, 0x40) Exact: True
  - Spread: 6 - 63
  - Number of Bits Inferable: 58
Base:
  - Expr: <BV64 (0#6 .. LOAD_64[<BV64 rdi>]_20[57:0]) << 0x6>
  - Range: (0x0,0xffffffffffffffc0, 0x40) Exact: True
  - Independent Expr: <BV64 (0#6 .. LOAD_64[<BV64 rdi>]_20[57:0]) << 0x6>
  - Independent Range: (0x0,0xffffffffffffffc0, 0x40) Exact: True
Transmission:
  - Expr: <BV64 ((0#6 .. LOAD_64[<BV64 rsi>]_21[57:0]) << 0x6) + ((0#6 .. LOAD_64[<BV64 rdi>]_20[57:0]) << 0x6)>
  - Range: (0x0,0xffffffffffffffc0, 0x40) Exact: False

Register Requirements: {<BV64 rsi>, <BV64 rdi>}
Constraints: []
Branches: []
------------------------------------------------
