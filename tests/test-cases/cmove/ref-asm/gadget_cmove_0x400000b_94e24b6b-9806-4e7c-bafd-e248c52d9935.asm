----------------- TRANSMISSION -----------------
         cmove_sample:
4000000  mov     rdi, qword ptr [rdx+0x18] ; {Attacker@rdx} -> {Secret@0x4000000}
4000004  test    rdi, rdi
4000007  cmove   rdi, rsi
400000b  mov     eax, dword ptr [rdi] ; {Secret@0x4000000} -> TRANSMISSION
400000d  jmp     0x400dead

------------------------------------------------
uuid: 94e24b6b-9806-4e7c-bafd-e248c52d9935
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 rdx + 0x18>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rdx + 0x18>]_20>
  - Range: (0x1,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 rdx + 0x18>]_20>
  - Range: (0x1,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rdx>}
Constraints: [('0x4000007', <Bool LOAD_64[<BV64 rdx + 0x18>]_20 != 0x0>, 'ConditionType.CMOVE')]
Branches: []
------------------------------------------------
