------------ SECRET DEPENDENT BRANCH ------------
         t1:
4000000  movzx   r9, byte ptr [rdi+0x10]
4000005  cmp     r9, 0x41
4000009  je      end ; Not Taken   <Bool LOAD_8[<BV64 rdi + 0x10>]_20 != 65>
         t2:
400000b  movzx   r9, byte ptr [rdi+0x20]
4000010  and     r9, 0x1
4000014  cmp     r9, 0x1
4000018  je      end ; Not Taken   <Bool (LOAD_8[<BV64 rdi + 0x20>]_21 & 1) != 1>
         t3:
400001a  mov     rax, qword ptr [0xffffffff81000000] ; {} -> {UncontrolledLoad@0x400001a}
4000022  movzx   r9, byte ptr [rdi+0x30] ; {Attacker@rdi} -> {Secret@0x4000022}
4000027  shr     r9, 0x7
400002b  cmp     r9, rax
400002e  je      end ; {Secret@0x4000022, UncontrolledLoad@0x400001a} -> SECRET DEPENDENT BRANCH

------------------------------------------------
uuid: 5aacc282-d779-4505-9bb0-08048c3e0681
transmitter: TransmitterType.SECRET_DEP_BRANCH
CMP operation: __eq__

Secret Dependent Branch:
  - Expr: <Bool LShR((0#56 .. LOAD_8[<BV64 rdi + 0x30>]_23), 0x7) == LOAD_64[<BV64 0xffffffff81000000>]_22>
Secret Address:
  - Expr: <BV64 rdi + 0x30>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#63 .. LOAD_8[<BV64 rdi + 0x30>]_23[7:7]>
  - Range: (0x0,0x1, 0x1) Exact: True
  - Spread: 0 - 0
  - Number of Bits Inferable: 1
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 0#63 .. LOAD_8[<BV64 rdi + 0x30>]_23[7:7]>
  - Range: (0x0,0x1, 0x1) Exact: True

CMP Value:
  - Expr: <BV64 LOAD_64[<BV64 0xffffffff81000000>]_22>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Controlled Expr: None
  - Controlled Range: None

Register Requirements:
  - All: ['<BV64 rdi>']
  - Transmission: {<BV64 rdi>}
  - CMP Value: set()

Constraints: []
Branches: [('0x4000009', '<Bool LOAD_8[<BV64 rdi + 0x10>]_20 != 65>', 'Not Taken'), ('0x4000018', '<Bool (LOAD_8[<BV64 rdi + 0x20>]_21 & 1) != 1>', 'Not Taken')]
------------------------------------------------
