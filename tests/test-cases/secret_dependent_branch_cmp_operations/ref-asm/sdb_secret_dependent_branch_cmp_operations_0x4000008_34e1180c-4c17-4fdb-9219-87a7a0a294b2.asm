------------ SECRET DEPENDENT BRANCH ------------
         t1:
4000000  movzx   r9, byte ptr [rdi+0x10] ; {Attacker@rdi} -> {Secret@0x4000000}
4000005  cmp     r9, rsi
4000008  je      end ; {Attacker@rsi, Secret@0x4000000} -> SECRET DEPENDENT BRANCH

------------------------------------------------
uuid: 34e1180c-4c17-4fdb-9219-87a7a0a294b2
transmitter: TransmitterType.SECRET_DEP_BRANCH
CMP operation: __eq__

Secret Dependent Branch:
  - Expr: <Bool (0#56 .. LOAD_8[<BV64 rdi + 0x10>]_20) == rsi>
Secret Address:
  - Expr: <BV64 rdi + 0x10>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#56 .. LOAD_8[<BV64 rdi + 0x10>]_20>
  - Range: (0x0,0xff, 0x1) Exact: True
  - Spread: 0 - 7
  - Number of Bits Inferable: 8
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 0#56 .. LOAD_8[<BV64 rdi + 0x10>]_20>
  - Range: (0x0,0xff, 0x1) Exact: True

CMP Value:
  - Expr: <BV64 rsi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Controlled Expr: <BV64 rsi>
  - Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements:
  - All: ['<BV64 rdi>', '<BV64 rsi>']
  - Transmission: {<BV64 rdi>}
  - CMP Value: {<BV64 rsi>}

Constraints: []
Branches: []
------------------------------------------------
