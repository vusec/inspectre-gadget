----------------- TRANSMISSION -----------------
         multiple_bb:
4000000  cmp     r8, 0x0
4000004  je      trans1 ; Not Taken   <Bool r8 != 0x0>
4000006  cmp     r8, 0x1
400000a  je      trans2 ; Not Taken   <Bool r8 != 0x1>
400000c  cmp     r8, 0x2
4000010  je      trans3 ; Taken   <Bool r8 == 0x2>
         trans3:
400004b  mov     r9, qword ptr [rdi] ; {Attacker@rdi} -> {Secret@0x400004b}
400004e  mov     r10, qword ptr [r9-0x7f000000] ; {Secret@0x400004b} -> TRANSMISSION
4000055  jmp     end

------------------------------------------------
uuid: d68d16ff-9399-43c2-99c7-5426785287df
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 rdi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rdi>]_26>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: <BV64 0xffffffff81000000>
  - Range: 0xffffffff81000000
  - Independent Expr: <BV64 0xffffffff81000000>
  - Independent Range: 0xffffffff81000000
Transmission:
  - Expr: <BV64 0xffffffff81000000 + LOAD_64[<BV64 rdi>]_26>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: ['<BV64 rdi>']
Constraints: []
Branches: [('0x4000004', '<Bool r8 != 0x0>', 'Not Taken'), ('0x400000a', '<Bool r8 != 0x1>', 'Not Taken'), ('0x4000010', '<Bool r8 == 0x2>', 'Taken')]
------------------------------------------------
