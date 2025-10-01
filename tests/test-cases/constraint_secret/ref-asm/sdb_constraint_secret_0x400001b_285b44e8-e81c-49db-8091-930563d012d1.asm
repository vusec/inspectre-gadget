------------ SECRET DEPENDENT BRANCH ------------
         constraint_secret:
4000000  movzx   r9, word ptr [rdi] ; {Attacker@rdi} -> {Secret@0x4000000}
4000004  cmp     r9, 0xffff
400000b  ja      trans1 ; Not Taken   <Bool (0#48 .. LOAD_16[<BV64 rdi>]_20) <= 0xffff>
400000d  mov     rsi, qword ptr [r9-0x80000000]
4000014  cmp     r9, 0xff
400001b  ja      trans1

------------------------------------------------
uuid: 285b44e8-e81c-49db-8091-930563d012d1
transmitter: TransmitterType.SECRET_DEP_BRANCH
CMP operation: ULE

Secret Dependent Branch:
  - Expr: <Bool (0x0 .. LOAD_16[<BV64 rdi>]_20) <= 0xff>
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
  - Expr: <BV64 0xff>
  - Range: 0xff
  - Controlled Expr: None
  - Controlled Range: None

Register Requirements:
  - All: {<BV64 rdi>}
  - Transmission: {<BV64 rdi>}
  - CMP Value: set()

Constraints: []
Branches: [('0x400000b', <Bool (0#48 .. LOAD_16[<BV64 rdi>]_20) <= 0xffff>, 'Not Taken')]
------------------------------------------------
