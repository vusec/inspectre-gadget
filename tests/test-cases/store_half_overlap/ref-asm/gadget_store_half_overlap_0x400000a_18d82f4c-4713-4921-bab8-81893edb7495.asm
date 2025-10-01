----------------- TRANSMISSION -----------------
         store_half_overlap:
4000000  mov     dword ptr [r8], esi
4000003  mov     rdi, qword ptr [r8]
4000006  movzx   r11, word ptr [rdx] ; {Attacker@rdx} -> {Secret@0x4000006}
400000a  mov     rdi, qword ptr [r11+rdi-0x7f000000] ; {Attacker@rsi, Secret@0x4000006, Uncontrolled@MEM_32[<BV64 r8> + 32]_21} -> TRANSMISSION
4000012  jmp     0x400dead

------------------------------------------------
uuid: 18d82f4c-4713-4921-bab8-81893edb7495
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 rdx>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#48 .. LOAD_16[<BV64 rdx>]_22>
  - Range: (0x0,0xffff, 0x1) Exact: True
  - Spread: 0 - 15
  - Number of Bits Inferable: 16
Base:
  - Expr: <BV64 0xffffffff81000000 + ((0#32 .. MEM_32[<BV64 r8> + 32]_21) << 0x20) + (0#32 .. rsi[31:0])>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: False
  - Independent Expr: <BV64 0xffffffff81000000 + ((0#32 .. MEM_32[<BV64 r8> + 32]_21) << 0x20) + (0#32 .. rsi[31:0])>
  - Independent Range: (0x0,0xffffffffffffffff, 0x1) Exact: False
Transmission:
  - Expr: <BV64 0xffffffff81000000 + (0#48 .. LOAD_16[<BV64 rdx>]_22) + (((0#32 .. MEM_32[<BV64 r8> + 32]_21) << 0x20) + (0#32 .. rsi[31:0]))>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: False

Register Requirements: {<BV64 rdx>, <BV64 rsi>, <BV32 MEM_32[<BV64 r8> + 32]_21>}
Constraints: []
Branches: []
------------------------------------------------
