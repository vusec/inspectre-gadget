----------------- TRANSMISSION -----------------
         code_load:
4000000  cmp     r8, 0x0
4000004  je      trans1 ; Not Taken   <Bool r8 != 0x0>
4000006  cmp     r8, 0x1
400000a  je      trans2 ; Not Taken   <Bool r8 != 0x1>
400000c  cmp     r8, 0x2
4000010  je      trans3 ; Not Taken   <Bool r8 != 0x2>
         trans0:
4000012  movzx   rsi, word ptr [rdi] ; {Attacker@rdi} > {Secret@0x4000012}
4000016  lea     rax, [rdx+rsi]
400001a  jmp     rax ; {Attacker@rdx, Secret@0x4000012} > TRANSMISSION

------------------------------------------------
uuid: 1ee556ae-b713-48fe-84a9-d9ccf46cf01c

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

Register Requirements: {<BV64 rdx>, <BV64 rdi>}
Constraints: []
Branches: [('0x4000004', <Bool r8 != 0x0>, 'Not Taken'), ('0x400000a', <Bool r8 != 0x1>, 'Not Taken'), ('0x4000010', <Bool r8 != 0x2>, 'Not Taken')]
------------------------------------------------
