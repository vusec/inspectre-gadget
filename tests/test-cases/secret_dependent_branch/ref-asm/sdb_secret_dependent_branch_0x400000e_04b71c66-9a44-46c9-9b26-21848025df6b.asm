------------ SECRET DEPENDENT BRANCH ------------
         secret_dependent_branch:
4000000  movzx   r9, word ptr [rdi] ; {Attacker@rdi} -> {Attacker@0x4000000}
4000004  mov     r8, qword ptr [rsi] ; {Attacker@rsi} -> {Secret@0x4000004}
4000007  add     r8, 0x50
400000b  cmp     r9, r8
400000e  je      end ; {Attacker@0x4000000, Secret@0x4000004} -> SECRET DEPENDENT BRANCH

------------------------------------------------
uuid: 04b71c66-9a44-46c9-9b26-21848025df6b
transmitter: TransmitterType.SECRET_DEP_BRANCH
CMP operation: __eq__

Secret Dependent Branch:
  - Expr: <Bool (0#48 .. LOAD_16[<BV64 rdi>]_20) == LOAD_64[<BV64 rsi>]_21 + 0x50>
Secret Address:
  - Expr: <BV64 rsi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rsi>]_21>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: <BV64 0x50>
  - Range: 0x50
  - Independent Expr: <BV64 0x50>
  - Independent Range: 0x50
Transmission:
  - Expr: <BV64 0x50 + LOAD_64[<BV64 rsi>]_21>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

CMP Value:
  - Expr: <BV64 0#48 .. LOAD_16[<BV64 rdi>]_20>
  - Range: (0x0,0xffff, 0x1) Exact: True
  - Controlled Expr: <BV64 0#48 .. LOAD_16[<BV64 rdi>]_20>
  - Controlled Range: (0x0,0xffff, 0x1) Exact: True

Register Requirements:
  - All: ['<BV64 rdi>', '<BV64 rsi>']
  - Transmission: {<BV64 rsi>}
  - CMP Value: {<BV64 rdi>}

Constraints: []
Branches: []
------------------------------------------------
