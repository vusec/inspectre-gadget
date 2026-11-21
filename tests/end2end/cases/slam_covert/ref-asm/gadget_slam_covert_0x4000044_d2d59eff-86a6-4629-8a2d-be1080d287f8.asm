----------------- TRANSMISSION -----------------
         multiple_bb:
4000000  cmp     r8, 0x0
4000004  je      trans1 ; Not Taken   <Bool r8 != 0x0>
4000006  cmp     r8, 0x1
400000a  je      trans2 ; Taken   <Bool r8 == 0x1>
         trans2:
400003b  mov     r9, qword ptr [rdi] ; {Attacker@rdi} -> {Secret@0x400003b}
400003e  and     rax, 0xff
4000044  mov     r10, qword ptr [r9+rax+0x20] ; {Attacker@rax, Secret@0x400003b} -> TRANSMISSION
4000049  jmp     end

------------------------------------------------
uuid: d2d59eff-86a6-4629-8a2d-be1080d287f8
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 rdi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rdi>]_28>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: <BV64 0x20 + (0#56 .. rax[7:0])>
  - Range: (0x20,0x11f, 0x1) Exact: True
  - Independent Expr: <BV64 0x20 + (0#56 .. rax[7:0])>
  - Independent Range: (0x20,0x11f, 0x1) Exact: True
Transmission:
  - Expr: <BV64 0x20 + LOAD_64[<BV64 rdi>]_28 + (0#56 .. rax[7:0])>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: ['<BV64 rax>', '<BV64 rdi>']
Constraints: []
Branches: [('0x4000004', '<Bool r8 != 0x0>', 'Not Taken'), ('0x400000a', '<Bool r8 == 0x1>', 'Taken')]
------------------------------------------------
