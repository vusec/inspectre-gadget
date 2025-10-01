----------------- TRANSMISSION -----------------
         cmove_sample:
4000000  test    rdi, rdi
4000003  cmove   rdi, rsi
4000007  mov     rdi, qword ptr [rdi+0x18] ; {Attacker@rdi} -> {Secret@0x4000007}
400000b  mov     rsi, qword ptr [rsi+0x18] ; {Attacker@rsi} -> {Attacker@0x400000b}
400000f  mov     eax, dword ptr [rdi+rsi] ; {Secret@0x4000007, Attacker@0x400000b} -> TRANSMISSION
4000012  jmp     0x400dead

------------------------------------------------
uuid: 8ebc4141-dd44-46b5-904a-e88e89910e5a
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 rdi + 0x18>
  - Range: (0x19,0x17, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rdi + 0x18>]_20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: <BV64 LOAD_64[<BV64 rsi + 0x18>]_21>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Independent Expr: <BV64 LOAD_64[<BV64 rsi + 0x18>]_21>
  - Independent Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 rdi + 0x18>]_20 + LOAD_64[<BV64 rsi + 0x18>]_21>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rsi>, <BV64 rdi>}
Constraints: [('0x4000003', <Bool rdi != 0x0>, 'ConditionType.CMOVE')]
Branches: []
------------------------------------------------
