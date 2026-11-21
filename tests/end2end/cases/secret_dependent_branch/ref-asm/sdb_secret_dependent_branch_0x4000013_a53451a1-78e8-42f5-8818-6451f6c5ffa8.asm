------------ SECRET DEPENDENT BRANCH ------------
         secret_dependent_branch:
4000000  movzx   r9, word ptr [rdi] ; {Attacker@rdi} -> {Secret@0x4000000}
4000004  mov     r8, qword ptr [rdi+0x10] ; {Attacker@rdi} -> {Attacker@0x4000004}
4000008  movzx   r8, word ptr [r8] ; {Attacker@0x4000004} -> {Attacker@0x4000008}
400000c  add     r8, 0x50
4000010  cmp     r9, r8
4000013  je      end ; {Attacker@0x4000008, Secret@0x4000000} -> SECRET DEPENDENT BRANCH

------------------------------------------------
uuid: a53451a1-78e8-42f5-8818-6451f6c5ffa8
transmitter: TransmitterType.SECRET_DEP_BRANCH
CMP operation: __eq__

Secret Dependent Branch:
  - Expr: <Bool (0#48 .. LOAD_16[<BV64 rdi>]_20) == (0#48 .. LOAD_16[<BV64 LOAD_64[<BV64 rdi + 0x10>]_21>]_22) + 0x50>
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
  - Expr: <BV64 (0#48 .. LOAD_16[<BV64 LOAD_64[<BV64 rdi + 0x10>]_21>]_22) + 0x50>
  - Range: (0x50,0x1004f, 0x1) Exact: True
  - Controlled Expr: <BV64 0#48 .. LOAD_16[<BV64 LOAD_64[<BV64 rdi + 0x10>]_21>]_22>
  - Controlled Range: (0x0,0xffff, 0x1) Exact: True

Register Requirements:
  - All: ['<BV64 rdi>']
  - Transmission: {<BV64 rdi>}
  - CMP Value: {<BV64 rdi>}

Constraints: []
Branches: []
------------------------------------------------
