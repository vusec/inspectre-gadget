----------------- TRANSMISSION -----------------
         cmove_sample:
4000000  test    rdi, rdi
4000003  cmove   rdi, rsi
4000007  mov     rdi, qword ptr [rdi+0x18] ; {Attacker@rsi} > {Secret@0x4000007}
400000b  mov     rsi, qword ptr [rsi+0x18] ; {Attacker@rsi} > {Attacker@0x400000b}
400000f  mov     eax, dword ptr [rdi+rsi] ; {Attacker@0x400000b, Secret@0x4000007} > TRANSMISSION
4000012  jmp     0x400dead

------------------------------------------------
uuid: 2388d096-6d44-49c0-ae5d-7ad512dd35c4

Secret Address:
  - Expr: <BV64 rsi + 0x18>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rsi + 0x18>]_23 + LOAD_64[<BV64 rsi + 0x18>]_24>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 rsi + 0x18>]_23 + LOAD_64[<BV64 rsi + 0x18>]_24>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rsi>, <BV64 rdi>}
Constraints: [('0x4000007', <Bool rdi == 0x0>)]
Branches: []
------------------------------------------------
