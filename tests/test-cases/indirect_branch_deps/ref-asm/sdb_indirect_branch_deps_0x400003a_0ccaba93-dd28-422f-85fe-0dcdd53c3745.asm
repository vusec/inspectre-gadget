------------ SECRET DEPENDENT BRANCH ------------
         dispatch:
4000000  cmp     rax, 0x0
4000004  je      soft_equality ; Not Taken   <Bool rax != 0x0>
4000006  jmp     soft_inequality ; Taken   <Bool True>
         soft_inequality:
400002d  mov     r8, 0x0
4000034  mov     rdi, qword ptr [rdx] ; {Attacker@rdx} -> {Secret@0x4000034}
4000037  cmp     rdi, rsi
400003a  ja      0x400dead ; {Attacker@rsi, Secret@0x4000034} -> SECRET DEPENDENT BRANCH

------------------------------------------------
uuid: 0ccaba93-dd28-422f-85fe-0dcdd53c3745
transmitter: TransmitterType.SECRET_DEP_BRANCH
CMP operation: ULE

Secret Dependent Branch:
  - Expr: <Bool LOAD_64[<BV64 rdx>]_20 <= rsi>
Secret Address:
  - Expr: <BV64 rdx>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rdx>]_20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 rdx>]_20>
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
Branches: [('0x4000004', '<Bool rax != 0x0>', 'Not Taken'), ('0x4000006', '<Bool True>', 'Taken')]
------------------------------------------------
