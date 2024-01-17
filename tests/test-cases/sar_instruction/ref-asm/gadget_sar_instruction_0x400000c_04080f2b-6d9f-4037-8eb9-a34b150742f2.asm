----------------- TRANSMISSION -----------------
         sar_instruction:
4000000  cmp     r8, 0x0
4000004  je      trans1 ; Not Taken   <Bool r8 != 0x0>
         trans0:
4000006  movzx   eax, word ptr [rsi] ; {Attacker@rsi} > {Secret@0x4000006}
4000009  sar     eax, 0x8
400000c  mov     r11, qword ptr [rax-0x7f000000] ; {Secret@0x4000006} > TRANSMISSION
4000013  jmp     end

------------------------------------------------
uuid: 04080f2b-6d9f-4037-8eb9-a34b150742f2

Secret Address:
  - Expr: <BV64 rsi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#32 .. (0#48 .. LOAD_16[<BV64 rsi>]_20) >> 0x8[31:0]>
  - Range: (0x0,0xff, 0x1) Exact: False
  - Spread: 0 - 7
  - Number of Bits Inferable: 8
Base:
  - Expr: <BV64 0xffffffff81000000>
  - Range: 0xffffffff81000000
  - Independent Expr: <BV64 0xffffffff81000000>
  - Independent Range: 0xffffffff81000000
Transmission:
  - Expr: <BV64 0xffffffff81000000 + (0#32 .. (0#48 .. LOAD_16[<BV64 rsi>]_20) >> 0x8[31:0])>
  - Range: (0xffffffff81000000,0xffffffff810000ff, 0x1) Exact: False, and_mask: 0xffffffff810000ff, or_mask: 0xffffffff81000000

Register Requirements: {<BV64 rsi>}
Constraints: []
Branches: [(67108868, <Bool r8 != 0x0>, 'Not Taken')]
------------------------------------------------
