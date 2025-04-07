----------------- TRANSMISSION -----------------
         alias_type_1:
4000000  movzx   r8d, word ptr [rdi]
4000004  mov     rcx, qword ptr [r8-0x20]
4000008  mov     r10, qword ptr [rdi+r8+0x50]
400000d  mov     r11, qword ptr [rsi] ; {Attacker@rsi} -> {Secret@0x400000d}
4000010  movzx   r9d, word ptr [r11] ; {Attacker@0x400000d} -> {Attacker@0x4000010}
4000014  mov     rax, qword ptr [r11+r9+0x20] ; {Secret@0x400000d, Attacker@0x4000010} -> TRANSMISSION
4000019  jmp     0x400dead

------------------------------------------------
uuid: 5a9bfad1-0353-4e30-a92a-c95674f4f0a3
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 rsi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rsi>]_23 + (0#48 .. LOAD_16[<BV64 LOAD_64[<BV64 rsi>]_23>]_24)>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: <BV64 0x20>
  - Range: 0x20
  - Independent Expr: <BV64 0x20>
  - Independent Range: 0x20
Transmission:
  - Expr: <BV64 0x20 + LOAD_64[<BV64 rsi>]_23 + (0#48 .. LOAD_16[<BV64 LOAD_64[<BV64 rsi>]_23>]_24)>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rsi>}
Constraints: []
Branches: []
------------------------------------------------
