------------ SECRET DEPENDENT BRANCH ------------
         secret_dependent_branch:
4000000  movzx   r9, word ptr [rdi] ; {Attacker@rdi} -> {Secret@0x4000000}
4000004  mov     r8, qword ptr [rsi] ; {Attacker@rsi} -> {Attacker@0x4000004}
4000007  add     r8, 0x50
400000b  cmp     r9, r8
400000e  je      end ; {Attacker@0x4000004, Secret@0x4000000} -> SECRET DEPENDENT BRANCH

------------------------------------------------
uuid: 9b8a891d-7531-4060-aafe-b4010aafa814
transmitter: TransmitterType.SECRET_DEP_BRANCH
CMP operation: __eq__

Secret Dependent Branch:
  - Expr: <Bool (0#48 .. LOAD_16[<BV64 rdi>]_20) == LOAD_64[<BV64 rsi>]_21 + 0x50>
Secret Address:
  - Expr: <BV64 rdi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#48 .. LOAD_16[<BV64 rdi>]_20>
  - Range: (0x0,0xffff, 0x1) Exact: True
  - Spread: 0 - 15
  - Number of Bits Inferable: 16
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 0#48 .. LOAD_16[<BV64 rdi>]_20>
  - Range: (0x0,0xffff, 0x1) Exact: True

CMP Value:
  - Expr: <BV64 LOAD_64[<BV64 rsi>]_21 + 0x50>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Controlled Expr: <BV64 LOAD_64[<BV64 rsi>]_21>
  - Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements:
  - All: ['<BV64 rdi>', '<BV64 rsi>']
  - Transmission: {<BV64 rdi>}
  - CMP Value: {<BV64 rsi>}

Constraints: []
Branches: []
------------------------------------------------
