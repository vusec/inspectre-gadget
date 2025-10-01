----------------- TRANSMISSION -----------------
         alias_overlap:
4000000  nop     
4000001  nop     
         test_symbol:
4000002  jmp     0x4000006 ; Taken   <Bool True>
         ;test_symbol+4:
4000006  nop     
4000007  nop     
4000008  movzx   r8d, word ptr [rdx+0x28] ; {Attacker@rdx} -> {Secret@0x4000008}
400000d  mov     rax, qword ptr [rdx+0x20] ; {Attacker@rdx} -> {Attacker@0x400000d}
4000011  mov     rcx, qword ptr [rax] ; {Attacker@0x400000d} -> {Attacker@0x4000011}
4000014  mov     r11, qword ptr [rcx+r8] ; {Attacker@0x4000011, Secret@0x4000008} -> TRANSMISSION
4000018  movzx   r9d, word ptr [rdx+0x24]
400001d  mov     rbx, qword ptr [rdx+0x20]
4000021  mov     rsi, qword ptr [rbx]
4000024  mov     r12, qword ptr [rsi+r9]
4000028  jmp     0x400dead

------------------------------------------------
uuid: 66b2d39c-f788-4ddc-b0ff-26dbc970e199
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 rdx + 0x28>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#48 .. LOAD_16[<BV64 rdx + 0x28>]_20>
  - Range: (0x0,0xffff, 0x1) Exact: True
  - Spread: 0 - 15
  - Number of Bits Inferable: 16
Base:
  - Expr: <BV64 LOAD_64[<BV64 LOAD_64[<BV64 rdx + 0x20>]_21>]_22>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 LOAD_64[<BV64 rdx + 0x20>]_21>]_22 + (0#48 .. LOAD_16[<BV64 rdx + 0x28>]_20)>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rdx>}
Constraints: []
Branches: [('0x4000002', <Bool True>, 'Taken')]
------------------------------------------------
