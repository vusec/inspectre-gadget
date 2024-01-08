----------------- TRANSMISSION -----------------
         alias_type_2:
4000000  movzx   r8d, word ptr [rdx+0x28] ; {Attacker@rdx} > {Attacker@0x4000000}
4000005  mov     rax, qword ptr [rdx+0x20] ; {Attacker@rdx} > {Attacker@0x4000005}
4000009  mov     rcx, qword ptr [rax] ; {Attacker@0x4000005} > {Secret@0x4000009}
400000c  mov     r11, qword ptr [rcx+r8] ; {Attacker@0x4000000, Secret@0x4000009} > TRANSMISSION
4000010  movzx   r9d, word ptr [rdx+0x24]
4000015  mov     rbx, qword ptr [rdx+0x20]
4000019  mov     rsi, qword ptr [rbx]
400001c  mov     r12, qword ptr [rsi+r9]
4000020  jmp     0x400dead

------------------------------------------------
uuid: 46732019-72ff-4e43-9401-941ecfc2ba92

Secret Address:
  - Expr: <BV64 LOAD_64[<BV64 rdx + 0x20>]_21>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 LOAD_64[<BV64 rdx + 0x20>]_21>]_22>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: <BV64 0#48 .. LOAD_16[<BV64 rdx + 0x28>]_20>
  - Range: (0x0,0xffff, 0x1) Exact: True
  - Independent Expr: <BV64 0#48 .. LOAD_16[<BV64 rdx + 0x28>]_20>
  - Independent Range: (0x0,0xffff, 0x1) Exact: True
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 LOAD_64[<BV64 rdx + 0x20>]_21>]_22 + (0#48 .. LOAD_16[<BV64 rdx + 0x28>]_20)>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rdx>}
Constraints: []
Branches: []
------------------------------------------------
