----------------- TRANSMISSION -----------------
         alias_type_2:
4000000  movzx   r8d, word ptr [rdx+0x28] ; {Attacker@rdx} > {Secret@0x4000000}
4000005  mov     rax, qword ptr [rdx+0x20] ; {Attacker@rdx} > {Attacker@0x4000005}
4000009  mov     rcx, qword ptr [rax] ; {Attacker@0x4000005} > {Attacker@0x4000009}
400000c  mov     r11, qword ptr [rcx+r8] ; {Attacker@0x4000009, Secret@0x4000000} > TRANSMISSION
4000010  movzx   r9d, word ptr [rdx+0x24]
4000015  mov     rbx, qword ptr [rdx+0x20]
4000019  mov     rsi, qword ptr [rbx]
400001c  mov     r12, qword ptr [rsi+r9]
4000020  jmp     0x400dead

------------------------------------------------
uuid: 1b43d77c-074b-44c0-9ac8-e426cc29d7a8

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
Branches: []
------------------------------------------------
