----------------- TRANSMISSION -----------------
         dispatch:
4000000  cmp     rax, 0x0
4000004  je      direct_alias ; Taken   <Bool rax == 0x0>
         direct_alias:
4000008  mov     r8, 0x0
400000f  mov     rsi, qword ptr [rdx]
4000012  mov     rdi, qword ptr [rdx] ; {Attacker@rdx} -> {Secret@0x4000012}
4000015  cmp     rsi, 0x10
4000019  ja      0x400dead ; Taken   <Bool LOAD_64[<BV64 rdx>]_24 <= 0x10>
400001f  mov     eax, dword ptr [rdi] ; {Secret@0x4000012} -> TRANSMISSION
4000021  jmp     0x400dead

------------------------------------------------
uuid: 1ef69b5a-1b4c-4942-b566-df6cba9875f3
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 rdx>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rdx>]_25>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 rdx>]_25>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: ['<BV64 rdx>']
Constraints: []
Branches: [('0x4000004', '<Bool rax == 0x0>', 'Taken'), ('0x4000019', '<Bool LOAD_64[<BV64 rdx>]_24 <= 0x10>', 'Taken')]
------------------------------------------------
