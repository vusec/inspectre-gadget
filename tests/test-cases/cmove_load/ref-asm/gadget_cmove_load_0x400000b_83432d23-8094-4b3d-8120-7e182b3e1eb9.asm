----------------- TRANSMISSION -----------------
         cmove_sample:
4000000  test    rdi, rdi
4000003  cmove   rdi, rsi
4000007  mov     rdi, qword ptr [rdi+0x18] ; {Attacker@rdi} > {Secret@0x4000007}
400000b  mov     eax, dword ptr [rdi] ; {Secret@0x4000007} > TRANSMISSION
400000d  jmp     0x400dead

------------------------------------------------
uuid: 83432d23-8094-4b3d-8120-7e182b3e1eb9

Secret Address:
  - Expr: <BV64 rdi + 0x18>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: False
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rdi + 0x18>]_20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 rdi + 0x18>]_20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rdi>}
Constraints: [('0x4000007', <Bool rdi != 0x0>)]
Branches: []
------------------------------------------------
