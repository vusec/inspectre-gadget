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
4000057  mov     r9, qword ptr [rdi] ; {Attacker@rdi} -> {Secret@0x4000057}
400005a  shl     r9, 0x9
400005e  mov     r10, qword ptr [r9] ; {Secret@0x4000057} -> TRANSMISSION
4000061  mov     r9d, dword ptr [rdi]
4000064  mov     r11, qword ptr [r9-0x7f000000]
400006b  jmp     end

------------------------------------------------
uuid: 8eebe386-a2b1-4f43-a4a8-94e8aa6702f4
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 rdi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 (0#9 .. LOAD_64[<BV64 rdi>]_22[54:0]) << 0x9>
  - Range: (0x0,0xfffffffffffffe00, 0x200) Exact: True
  - Spread: 9 - 63
  - Number of Bits Inferable: 55
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 (0#9 .. LOAD_64[<BV64 rdi>]_22[54:0]) << 0x9>
  - Range: (0x0,0xfffffffffffffe00, 0x200) Exact: True

Register Requirements: {<BV64 rdi>}
Constraints: []
Branches: [('0x4000004', <Bool r8 != 0x0>, 'Not Taken'), ('0x400000a', <Bool r8 != 0x1>, 'Not Taken'), ('0x4000010', <Bool r8 != 0x2>, 'Not Taken'), ('0x4000016', <Bool r8 == 0x3>, 'Taken')]
------------------------------------------------
