----------------- TRANSMISSION -----------------
         sar_instruction:
4000000  cmp     r8, 0x0
4000004  je      trans1 ; Taken   <Bool r8 == 0x0>
         trans1:
4000015  movzx   eax, word ptr [rsi] ; {Attacker@rsi} -> {Secret@0x4000015}
4000018  bt      qword ptr [rdi+0xb8], rax ; {Secret@0x4000015, Attacker@rdi} -> TRANSMISSION
         end:
4000020  jmp     0x400dead

------------------------------------------------
uuid: 61dde185-2522-4858-b865-8959ea97adaa
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 rsi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 (0#48 .. LOAD_16[<BV64 rsi>]_22) >> 0x3>
  - Range: (0x0,0x1fff, 0x1) Exact: False
  - Spread: 0 - 12
  - Number of Bits Inferable: 13
Base:
  - Expr: <BV64 0xb8 + rdi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Independent Expr: <BV64 0xb8 + rdi>
  - Independent Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmission:
  - Expr: <BV64 0xb8 + rdi + ((0#48 .. LOAD_16[<BV64 rsi>]_22) >> 0x3)>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rdi>, <BV64 rsi>}
Constraints: []
Branches: [('0x4000004', <Bool r8 == 0x0>, 'Taken')]
------------------------------------------------
