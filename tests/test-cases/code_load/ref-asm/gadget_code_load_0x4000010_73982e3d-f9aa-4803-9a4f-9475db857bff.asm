----------------- TRANSMISSION -----------------
         code_load:
4000000  cmp     r8, 0x0
4000004  je      trans1 ; Not Taken   <Bool r8 != 0x0>
         trans0:
4000006  movzx   rsi, word ptr [rdi] ; {Attacker@rdi} > {Secret@0x4000006}
400000a  mov     rax, rdx
400000d  add     rax, rsi
4000010  jmp     rax ; {Secret@0x4000006, Attacker@rdx} > TRANSMISSION

------------------------------------------------
uuid: 73982e3d-f9aa-4803-9a4f-9475db857bff

Secret Address:
  - Expr: <BV64 rdi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#48 .. LOAD_16[<BV64 rdi>]_20>
  - Range: (0x0,0xffff, 0x1) Exact: True
  - Spread: 0 - 15
  - Number of Bits Inferable: 16
Base:
  - Expr: <BV64 rdx>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Independent Expr: <BV64 rdx>
  - Independent Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmission:
  - Expr: <BV64 rdx + (0#48 .. LOAD_16[<BV64 rdi>]_20)>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rdi>, <BV64 rdx>}
Constraints: []
Branches: [(67108868, <Bool r8 != 0x0>, 'Not Taken')]
------------------------------------------------
