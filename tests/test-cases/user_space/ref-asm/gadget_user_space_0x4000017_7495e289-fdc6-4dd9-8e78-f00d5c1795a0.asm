----------------- TRANSMISSION -----------------
         user_space:
4000000  cmp     r8, 0x0
4000004  je      trans ; Taken   <Bool r8 == 0x0>
         trans:
400000b  mov     r9, qword ptr [rsi] ; {Attacker@rsi} -> {Secret@0x400000b}
400000e  and     r9, 0xff
4000015  mov     ecx, ecx
4000017  mov     r10, qword ptr [rcx+r9] ; {Attacker@rcx, Secret@0x400000b} -> TRANSMISSION
400001b  jmp     0x400dead

------------------------------------------------
uuid: 7495e289-fdc6-4dd9-8e78-f00d5c1795a0
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 rsi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#56 .. LOAD_64[<BV64 rsi>]_21[7:0]>
  - Range: (0x0,0xff, 0x1) Exact: True
  - Spread: 0 - 7
  - Number of Bits Inferable: 8
Base:
  - Expr: <BV64 0#32 .. rcx[31:0]>
  - Range: (0x0,0xffffffff, 0x1) Exact: True
  - Independent Expr: <BV64 0#32 .. rcx[31:0]>
  - Independent Range: (0x0,0xffffffff, 0x1) Exact: True
Transmission:
  - Expr: <BV64 (0#32 .. rcx[31:0]) + (0#56 .. LOAD_64[<BV64 rsi>]_21[7:0])>
  - Range: (0x0,0x1000000fe, 0x1) Exact: False

Register Requirements: ['<BV64 rcx>', '<BV64 rsi>']
Constraints: []
Branches: [('0x4000004', '<Bool r8 == 0x0>', 'Taken')]
------------------------------------------------
