----------------- TRANSMISSION -----------------
         alias_overlap:
4000000  nop     
4000001  nop     
         test_symbol:
4000002  jmp     0x4000006 ; Taken   <Bool True>
         ;test_symbol+4:
4000006  nop     
4000007  nop     
4000008  movzx   r8d, word ptr [rdx+0x28]
400000d  mov     rax, qword ptr [rdx+0x20]
4000011  mov     rcx, qword ptr [rax]
4000014  mov     r11, qword ptr [rcx+r8]
4000018  movzx   r9d, word ptr [rdx+0x24]
400001d  mov     rbx, qword ptr [rdx+0x20] ; {Attacker@rdx} -> {Secret@0x400001d}
4000021  mov     rsi, qword ptr [rbx] ; {Secret@0x400001d} -> TRANSMISSION
4000024  mov     r12, qword ptr [rsi+r9]
4000028  jmp     0x400dead

------------------------------------------------
uuid: c54680a7-8f99-4463-92e6-4985c655b323
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 rdx + 0x20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rdx + 0x20>]_25>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 rdx + 0x20>]_25>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: ['<BV64 rdx>']
Constraints: []
Branches: [('0x4000002', '<Bool True>', 'Taken')]
------------------------------------------------
