----------------- TRANSMISSION -----------------
         multiple_bb:
4000000  cmp     r8, 0x0
4000004  je      trans1 ; Not Taken   <Bool r8 != 0x0>
4000006  cmp     r8, 0x1
400000a  je      trans2 ; Not Taken   <Bool r8 != 0x1>
400000c  cmp     r8, 0x2
4000010  je      trans3 ; Not Taken   <Bool r8 != 0x2>
4000012  cmp     r8, 0x3
4000016  je      trans4_5 ; Taken   <Bool r8 == 0x3>
         trans4_5:
4000057  mov     r9, qword ptr [rdi]
400005a  shl     r9, 0x9
400005e  mov     r10, qword ptr [r9]
4000061  mov     r9d, dword ptr [rdi] ; {Attacker@rdi} -> {Secret@0x4000061}
4000064  mov     r11, qword ptr [r9-0x7f000000] ; {Secret@0x4000061} -> TRANSMISSION
400006b  jmp     end

------------------------------------------------
uuid: aca90b1e-5486-4f8c-9aaa-28ffeaf898ab
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 rdi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#32 .. LOAD_32[<BV64 rdi>]_24>
  - Range: (0x0,0xffffffff, 0x1) Exact: True
  - Spread: 0 - 31
  - Number of Bits Inferable: 32
Base:
  - Expr: <BV64 0xffffffff81000000>
  - Range: 0xffffffff81000000
  - Independent Expr: <BV64 0xffffffff81000000>
  - Independent Range: 0xffffffff81000000
Transmission:
  - Expr: <BV64 0xffffffff81000000 + (0#32 .. LOAD_32[<BV64 rdi>]_24)>
  - Range: (0xffffffff81000000,0x80ffffff, 0x1) Exact: True

Register Requirements: {<BV64 rdi>}
Constraints: []
Branches: [('0x4000004', <Bool r8 != 0x0>, 'Not Taken'), ('0x400000a', <Bool r8 != 0x1>, 'Not Taken'), ('0x4000010', <Bool r8 != 0x2>, 'Not Taken'), ('0x4000016', <Bool r8 == 0x3>, 'Taken')]
------------------------------------------------
