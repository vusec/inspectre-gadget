----------------- TRANSMISSION -----------------
         alias_partially_independent:
4000000  mov     esi, edi
4000002  add     rsi, r12
4000005  mov     rax, qword ptr [r12+0x28] ; {Attacker@r12} -> {Secret@0x4000005}
400000a  mov     r9, qword ptr [rsi+rax] ; {Attacker@r12, Attacker@rdi, Secret@0x4000005} -> TRANSMISSION
400000e  mov     esi, edi
4000010  add     rsi, r12
4000013  mov     eax, dword ptr [r12+0x28]
4000018  mov     r10, qword ptr [rsi+rax]
400001c  mov     esi, edi
400001e  add     rsi, qword ptr [r12+0x20]
4000023  mov     rax, qword ptr [r12+0x28]
4000028  mov     r11, qword ptr [rsi+rax]
400002c  jmp     0x400dead

------------------------------------------------
uuid: 7df0e628-00bd-4ca9-bf8d-638b9d02be27
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 r12 + 0x28>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 r12 + 0x28>]_20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: <BV64 (0#32 .. rdi[31:0]) + r12>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Independent Expr: <BV64 0#32 .. rdi[31:0]>
  - Independent Range: (0x0,0xffffffff, 0x1) Exact: True
Transmission:
  - Expr: <BV64 (0#32 .. rdi[31:0]) + r12 + LOAD_64[<BV64 r12 + 0x28>]_20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: ['<BV64 r12>', '<BV64 rdi>']
Constraints: []
Branches: []
------------------------------------------------
