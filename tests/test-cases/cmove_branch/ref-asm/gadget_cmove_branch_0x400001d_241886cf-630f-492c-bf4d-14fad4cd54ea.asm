----------------- TRANSMISSION -----------------
         cmove_sample:
4000000  test    rdi, rdi
4000003  cmove   rax, rbx
4000007  cmp     rcx, rax
400000a  je      if ; Not Taken   <Bool rcx != rax>
400000c  jmp     else ; Taken   <Bool True>
         else:
4000019  mov     rsi, qword ptr [rsi+0x18] ; {Attacker@rsi} > {Secret@0x4000019}
400001d  mov     ebx, dword ptr [rsi] ; {Secret@0x4000019} > TRANSMISSION
400001f  jmp     0x400dead

------------------------------------------------
uuid: 241886cf-630f-492c-bf4d-14fad4cd54ea

Secret Address:
  - Expr: <BV64 rsi + 0x18>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rsi + 0x18>]_20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 rsi + 0x18>]_20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rdi>, <BV64 rsi>}
Constraints: [('0x4000003', <Bool rdi != 0x0>, 'ConditionType.CMOVE')]
Branches: [(67108874, <Bool rcx != rax>, 'Not Taken'), (67108876, <Bool True>, 'Taken')]
------------------------------------------------
