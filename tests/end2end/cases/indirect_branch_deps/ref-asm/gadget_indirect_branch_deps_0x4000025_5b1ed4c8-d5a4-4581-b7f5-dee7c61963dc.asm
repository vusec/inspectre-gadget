----------------- TRANSMISSION -----------------
         dispatch:
4000000  cmp     rax, 0x0
4000004  je      soft_equality ; Taken   <Bool rax == 0x0>
         soft_equality:
4000008  mov     r8, 0x0
400000f  mov     rdi, qword ptr [rdx] ; {Attacker@rdx} -> {Secret@0x400000f}
4000012  cmp     rdi, rsi
4000015  jne     0x400dead ; Taken   <Bool LOAD_64[<BV64 rdx>]_22 == rsi>
400001b  cmp     rsi, 0x10
400001f  ja      0x400dead ; Taken   <Bool rsi <= 0x10>
4000025  mov     rax, qword ptr [rdi] ; {Secret@0x400000f} -> TRANSMISSION
4000028  jmp     0x400dead

------------------------------------------------
uuid: 5b1ed4c8-d5a4-4581-b7f5-dee7c61963dc
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 rdx>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rdx>]_22>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 rdx>]_22>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: ['<BV64 rdx>']
Constraints: []
Branches: [('0x4000004', '<Bool rax == 0x0>', 'Taken'), ('0x4000015', '<Bool LOAD_64[<BV64 rdx>]_22 == rsi>', 'Taken'), ('0x400001f', '<Bool rsi <= 0x10>', 'Taken')]
------------------------------------------------
