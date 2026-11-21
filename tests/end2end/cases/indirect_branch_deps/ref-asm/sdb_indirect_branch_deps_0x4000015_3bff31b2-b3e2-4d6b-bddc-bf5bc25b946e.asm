------------ SECRET DEPENDENT BRANCH ------------
         dispatch:
4000000  cmp     rax, 0x0
4000004  je      soft_equality ; Taken   <Bool rax == 0x0>
         soft_equality:
4000008  mov     r8, 0x0
400000f  mov     rdi, qword ptr [rdx] ; {Attacker@rdx} -> {Secret@0x400000f}
4000012  cmp     rdi, rsi
4000015  jne     0x400dead ; {Attacker@rsi, Secret@0x400000f} -> SECRET DEPENDENT BRANCH

------------------------------------------------
uuid: 3bff31b2-b3e2-4d6b-bddc-bf5bc25b946e
transmitter: TransmitterType.SECRET_DEP_BRANCH
CMP operation: __eq__

Secret Dependent Branch:
  - Expr: <Bool LOAD_64[<BV64 rdx>]_22 == rsi>
Secret Address:
  - Expr: <BV64 rdx>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rdx>]_22>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 rdx>]_22>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

CMP Value:
  - Expr: <BV64 rsi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Controlled Expr: <BV64 rsi>
  - Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements:
  - All: ['<BV64 rdx>', '<BV64 rsi>']
  - Transmission: {<BV64 rdx>}
  - CMP Value: {<BV64 rsi>}

Constraints: []
Branches: [('0x4000004', '<Bool rax == 0x0>', 'Taken')]
------------------------------------------------
