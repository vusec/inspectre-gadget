----------------- TRANSMISSION -----------------
         cmove_sample:
4000000  test    rdi, rdi
4000003  cmove   rax, rbx
4000007  cmp     rcx, rax
400000a  je      if ; Not Taken   <Bool rcx != rax>
400000c  jmp     else ; Taken   <Bool True>
         else:
4000019  mov     rsi, qword ptr [rbx+0x18] ; {Attacker@rbx} -> {Secret@0x4000019}
400001d  mov     ebx, dword ptr [rsi] ; {Secret@0x4000019} -> TRANSMISSION
400001f  jmp     0x400dead

------------------------------------------------
uuid: 482ed1aa-a09b-4f62-b2f1-d7a28ac9e9bf
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 rbx + 0x18>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rbx + 0x18>]_20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 rbx + 0x18>]_20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: ['<BV64 rbx>', '<BV64 rdi>']
Constraints: [('0x4000003', '<Bool rdi != 0x0>', 'ConditionType.CMOVE'), ('0x4000003', '<Bool rdi != 0x0>', 'ConditionType.CMOVE')]
Branches: [('0x400000a', '<Bool rcx != rax>', 'Not Taken'), ('0x400000c', '<Bool True>', 'Taken')]
------------------------------------------------
