----------------- TRANSMISSION -----------------
         alias_type_1:
4000000  movzx   r8d, word ptr [rdi] ; {Attacker@rdi} > {Secret@0x4000000}
4000004  mov     rcx, qword ptr [r8-0x20]
4000008  mov     r10, qword ptr [rdi+r8+0x50] ; {Attacker@rdi, Secret@0x4000000} > TRANSMISSION
400000d  mov     r11, qword ptr [rsi]
4000010  movzx   r9d, word ptr [r11]
4000014  mov     rax, qword ptr [r11+r9+0x20]
4000019  jmp     0x400dead

------------------------------------------------
uuid: ccb61920-0524-4704-a156-d5872324e38d

Secret Address:
  - Expr: <BV64 rdi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#48 .. LOAD_16[<BV64 rdi>]_20>
  - Range: (0x0,0xffff, 0x1) Exact: True
  - Spread: 0 - 15
  - Number of Bits Inferable: 16
Base:
  - Expr: <BV64 0x50 + rdi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Independent Expr: <BV64 0x50>
  - Independent Range: 0x50
Transmission:
  - Expr: <BV64 0x50 + rdi + (0#48 .. LOAD_16[<BV64 rdi>]_20)>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rdi>}
Constraints: []
Branches: []
------------------------------------------------
