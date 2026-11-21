------------ SECRET DEPENDENT BRANCH ------------
         dispatch:
4000000  cmp     rax, 0x0
4000004  je      direct_alias ; Taken   <Bool rax == 0x0>
         direct_alias:
4000008  mov     r8, 0x0
400000f  mov     rsi, qword ptr [rdx] ; {Attacker@rdx} -> {Secret@0x400000f}
4000012  mov     rdi, qword ptr [rdx]
4000015  cmp     rsi, 0x10
4000019  ja      0x400dead ; {Secret@0x400000f} -> SECRET DEPENDENT BRANCH

------------------------------------------------
uuid: f63267d8-59f7-407d-b732-52a345e0b8c2
transmitter: TransmitterType.SECRET_DEP_BRANCH
CMP operation: ULE

Secret Dependent Branch:
  - Expr: <Bool LOAD_64[<BV64 rdx>]_24 <= 0x10>
Secret Address:
  - Expr: <BV64 rdx>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rdx>]_24>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 rdx>]_24>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

CMP Value:
  - Expr: <BV64 0x10>
  - Range: 0x10
  - Controlled Expr: None
  - Controlled Range: None

Register Requirements:
  - All: ['<BV64 rdx>']
  - Transmission: {<BV64 rdx>}
  - CMP Value: set()

Constraints: []
Branches: [('0x4000004', '<Bool rax == 0x0>', 'Taken')]
------------------------------------------------
