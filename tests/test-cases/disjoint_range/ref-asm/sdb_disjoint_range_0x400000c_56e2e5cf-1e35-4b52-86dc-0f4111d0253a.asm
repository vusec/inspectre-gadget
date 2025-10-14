------------ SECRET DEPENDENT BRANCH ------------
         disjoint_range:
4000000  mov     rax, qword ptr [rdi+0x28] ; {Attacker@rdi} -> {Secret@0x4000000}
4000004  mov     rsi, qword ptr [rsi+0x30]
4000008  cmp     rax, 0xf
400000c  je      exit ; {Secret@0x4000000} -> SECRET DEPENDENT BRANCH

------------------------------------------------
uuid: 56e2e5cf-1e35-4b52-86dc-0f4111d0253a
transmitter: TransmitterType.SECRET_DEP_BRANCH
CMP operation: __eq__

Secret Dependent Branch:
  - Expr: <Bool LOAD_64[<BV64 rdi + 0x28>]_20 == 0xf>
Secret Address:
  - Expr: <BV64 rdi + 0x28>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rdi + 0x28>]_20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 rdi + 0x28>]_20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

CMP Value:
  - Expr: <BV64 0xf>
  - Range: 0xf
  - Controlled Expr: None
  - Controlled Range: None

Register Requirements:
  - All: ['<BV64 rdi>']
  - Transmission: {<BV64 rdi>}
  - CMP Value: set()

Constraints: []
Branches: []
------------------------------------------------
