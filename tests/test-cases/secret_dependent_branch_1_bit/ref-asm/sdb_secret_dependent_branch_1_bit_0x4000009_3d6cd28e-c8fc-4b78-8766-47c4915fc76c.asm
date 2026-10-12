------------ SECRET DEPENDENT BRANCH ------------
         t1:
4000000  movzx   r9, byte ptr [rdi+0x10] ; {Attacker@rdi} -> {Secret@0x4000000}
4000005  cmp     r9, 0x41
4000009  je      end ; {Secret@0x4000000} -> SECRET DEPENDENT BRANCH

------------------------------------------------
uuid: 3d6cd28e-c8fc-4b78-8766-47c4915fc76c
transmitter: TransmitterType.SECRET_DEP_BRANCH
CMP operation: __eq__

Secret Dependent Branch:
  - Expr: <Bool LOAD_8[<BV64 rdi + 0x10>]_20 == 65>
Secret Address:
  - Expr: <BV64 rdi + 0x10>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV8 LOAD_8[<BV64 rdi + 0x10>]_20>
  - Range: (0x0,0xff, 0x1) Exact: True
  - Spread: 0 - 7
  - Number of Bits Inferable: 8
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV8 LOAD_8[<BV64 rdi + 0x10>]_20>
  - Range: (0x0,0xff, 0x1) Exact: True

CMP Value:
  - Expr: <BV8 65>
  - Range: 0x41
  - Controlled Expr: None
  - Controlled Range: None

Register Requirements:
  - All: ['<BV64 rdi>']
  - Transmission: {<BV64 rdi>}
  - CMP Value: set()

Constraints: []
Branches: []
------------------------------------------------
