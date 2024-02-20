----------------- TRANSMISSION -----------------
         alias_type_2:
4000000  movzx   r8d, word ptr [rdx+0x28]
4000005  mov     rax, qword ptr [rdx+0x20]
4000009  mov     rcx, qword ptr [rax]
400000c  mov     r11, qword ptr [rcx+r8]
4000010  movzx   r9d, word ptr [rdx+0x24] ; {Attacker@rdx} -> {Secret@0x4000010}
4000015  mov     rbx, qword ptr [rdx+0x20] ; {Attacker@rdx} -> {Attacker@0x4000015}
4000019  mov     rsi, qword ptr [rbx] ; {Attacker@0x4000015} -> {Attacker@0x4000019}
400001c  mov     r12, qword ptr [rsi+r9] ; {Secret@0x4000010, Attacker@0x4000019} -> TRANSMISSION
4000020  jmp     0x400dead

------------------------------------------------
uuid: e7b7c1a8-980f-4cc8-9b5d-1242d4a5d780
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 rdx + 0x24>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 (0#48 .. LOAD_16[<BV64 rdx + 0x24>]_24) + LOAD_64[<BV64 LOAD_64[<BV64 rdx + 0x20>]_25>]_26>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 16
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 LOAD_64[<BV64 rdx + 0x20>]_25>]_26 + (0#48 .. LOAD_16[<BV64 rdx + 0x24>]_24)>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rdx>}
Constraints: []
Branches: []
------------------------------------------------
