------------ SECRET DEPENDENT BRANCH ------------
         secret_dependent_branch:
4000000  movzx   r9, word ptr [rdi]
4000004  mov     r8, qword ptr [rsi]
4000007  add     r8, 0x50
400000b  cmp     r9, r8
400000e  je      end ; Not Taken   <Bool (0#48 .. LOAD_16[<BV64 rdi>]_20) != LOAD_64[<BV64 rsi>]_21 + 0x50>
         t1:
4000010  movzx   r9, word ptr [rdi+0x10] ; {Attacker@rdi} -> {Secret@0x4000010}
4000015  cmp     r9, 0xdead
400001c  je      end ; {Secret@0x4000010} -> SECRET DEPENDENT BRANCH

------------------------------------------------
uuid: ea55c37b-e905-4ba5-8c64-68514cf27bd3
transmitter: TransmitterType.SECRET_DEP_BRANCH
CMP operation: __eq__

Secret Dependent Branch:
  - Expr: <Bool LOAD_16[<BV64 rdi + 0x10>]_22 == 0xdead>
Secret Address:
  - Expr: <BV64 rdi + 0x10>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV16 LOAD_16[<BV64 rdi + 0x10>]_22>
  - Range: (0x0,0xffff, 0x1) Exact: True
  - Spread: 0 - 15
  - Number of Bits Inferable: 16
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV16 LOAD_16[<BV64 rdi + 0x10>]_22>
  - Range: (0x0,0xffff, 0x1) Exact: True

CMP Value:
  - Expr: <BV16 0xdead>
  - Range: 0xdead
  - Controlled Expr: None
  - Controlled Range: None

Register Requirements:
  - All: {<BV64 rdi>}
  - Transmission: {<BV64 rdi>}
  - CMP Value: set()

Constraints: []
Branches: [('0x400000e', <Bool (0#48 .. LOAD_16[<BV64 rdi>]_20) != LOAD_64[<BV64 rsi>]_21 + 0x50>, 'Not Taken')]
------------------------------------------------
