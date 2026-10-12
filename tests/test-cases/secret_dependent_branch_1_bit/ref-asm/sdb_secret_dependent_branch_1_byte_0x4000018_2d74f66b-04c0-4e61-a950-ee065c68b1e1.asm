------------ SECRET DEPENDENT BRANCH ------------
         t1:
4000000  movzx   r9, byte ptr [rdi+0x10]
4000005  cmp     r9, 0x41
4000009  je      end ; Not Taken   <Bool LOAD_8[<BV64 rdi + 0x10>]_20 != 65>
         t2:
400000b  movzx   r9, byte ptr [rdi+0x20] ; {Attacker@rdi} -> {Secret@0x400000b}
4000010  and     r9, 0x1
4000014  cmp     r9, 0x1
4000018  je      end ; {Secret@0x400000b} -> SECRET DEPENDENT BRANCH

------------------------------------------------
uuid: 2d74f66b-04c0-4e61-a950-ee065c68b1e1
transmitter: TransmitterType.SECRET_DEP_BRANCH
CMP operation: __eq__

Secret Dependent Branch:
  - Expr: <Bool (LOAD_8[<BV64 rdi + 0x20>]_21 & 1) == 1>
Secret Address:
  - Expr: <BV64 rdi + 0x20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV8 0#7 .. LOAD_8[<BV64 rdi + 0x20>]_21[0:0]>
  - Range: (0x0,0x1, 0x1) Exact: True
  - Spread: 0 - 0
  - Number of Bits Inferable: 1
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV8 0#7 .. LOAD_8[<BV64 rdi + 0x20>]_21[0:0]>
  - Range: (0x0,0x1, 0x1) Exact: True

CMP Value:
  - Expr: <BV8 1>
  - Range: 0x1
  - Controlled Expr: None
  - Controlled Range: None

Register Requirements:
  - All: ['<BV64 rdi>']
  - Transmission: {<BV64 rdi>}
  - CMP Value: set()

Constraints: []
Branches: [('0x4000009', '<Bool LOAD_8[<BV64 rdi + 0x10>]_20 != 65>', 'Not Taken')]
------------------------------------------------
