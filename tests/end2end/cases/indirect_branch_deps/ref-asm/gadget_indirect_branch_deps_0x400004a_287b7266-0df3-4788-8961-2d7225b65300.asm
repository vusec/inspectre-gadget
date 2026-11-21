----------------- TRANSMISSION -----------------
         dispatch:
4000000  cmp     rax, 0x0
4000004  je      soft_equality ; Not Taken   <Bool rax != 0x0>
4000006  jmp     soft_inequality ; Taken   <Bool True>
         soft_inequality:
400002d  mov     r8, 0x0
4000034  mov     rdi, qword ptr [rdx] ; {Attacker@rdx} -> {Secret@0x4000034}
4000037  cmp     rdi, rsi
400003a  ja      0x400dead ; Taken   <Bool LOAD_64[<BV64 rdx>]_20 <= rsi>
4000040  cmp     rsi, 0x10
4000044  ja      0x400dead ; Taken   <Bool rsi <= 0x10>
400004a  mov     rax, qword ptr [rdi] ; {Secret@0x4000034} -> TRANSMISSION
400004d  jmp     0x400dead

------------------------------------------------
uuid: 287b7266-0df3-4788-8961-2d7225b65300
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 rdx>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rdx>]_20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 rdx>]_20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: ['<BV64 rdx>']
Constraints: []
Branches: [('0x4000004', '<Bool rax != 0x0>', 'Not Taken'), ('0x4000006', '<Bool True>', 'Taken'), ('0x400003a', '<Bool LOAD_64[<BV64 rdx>]_20 <= rsi>', 'Taken'), ('0x4000044', '<Bool rsi <= 0x10>', 'Taken')]
------------------------------------------------
