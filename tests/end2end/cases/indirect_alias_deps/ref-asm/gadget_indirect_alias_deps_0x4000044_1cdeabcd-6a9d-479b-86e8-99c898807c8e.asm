----------------- TRANSMISSION -----------------
         dispatch:
4000000  cmp     rax, 0x0
4000004  je      direct_alias ; Not Taken   <Bool rax != 0x0>
4000006  jmp     cmove_through_alias ; Taken   <Bool True>
         cmove_through_alias:
4000026  mov     r8, qword ptr [rdx]
4000029  mov     r9, qword ptr [rdx] ; {Attacker@rdx} -> {Secret@0x4000029}
400002c  mov     rdi, 0x0
4000033  cmp     r8, rsi
4000036  cmove   rdi, r9
400003a  cmp     rsi, 0x10
400003e  ja      0x400dead ; Taken   <Bool rsi <= 0x10>
4000044  mov     rax, qword ptr [rdi] ; {Secret@0x4000029} -> TRANSMISSION
4000047  jmp     0x400dead

------------------------------------------------
uuid: 1cdeabcd-6a9d-479b-86e8-99c898807c8e
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 rdx>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rdx>]_21>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: False
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 rdx>]_21>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: False

Register Requirements: ['<BV64 rdx>', '<BV64 rsi>']
Constraints: [('0x4000036', '<Bool LOAD_64[<BV64 rdx>]_20 == rsi>', 'ConditionType.CMOVE')]
Branches: [('0x4000004', '<Bool rax != 0x0>', 'Not Taken'), ('0x4000006', '<Bool True>', 'Taken'), ('0x400003e', '<Bool rsi <= 0x10>', 'Taken')]
------------------------------------------------
