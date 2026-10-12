------------ SECRET DEPENDENT BRANCH ------------
         secret_dependent_branch:
4000000  movzx   r9, word ptr [rdi]
4000004  mov     r8, qword ptr [rdi+0x10]
4000008  movzx   r8, word ptr [r8]
400000c  add     r8, 0x50
4000010  cmp     r9, r8
4000013  je      end ; Not Taken   <Bool (0#48 .. LOAD_16[<BV64 rdi>]_20) != (0#48 .. LOAD_16[<BV64 LOAD_64[<BV64 rdi + 0x10>]_21>]_22) + 0x50>
         t1:
4000015  movzx   r9, word ptr [rdi+0x20]
400001a  cmp     r9, rdi
400001d  je      end ; Not Taken   <Bool (0#48 .. LOAD_16[<BV64 rdi + 0x20>]_23) != rdi>
         t2:
400001f  movzx   r9, word ptr [rdi+0x20]
4000024  mov     r8, qword ptr [rdi+0x100]
400002b  cmp     r9, r8
400002e  je      end ; Not Taken   <Bool (0#48 .. LOAD_16[<BV64 rdi + 0x20>]_24) != LOAD_64[<BV64 rdi + 0x100>]_25>
         t3:
4000030  mov     rax, qword ptr [0xffffffff81000000] ; {} -> {UncontrolledLoad@0x4000030}
4000038  movzx   r9, word ptr [rdi+0x30] ; {Attacker@rdi} -> {Secret@0x4000038}
400003d  cmp     r9, rax
4000040  je      end ; {Secret@0x4000038, UncontrolledLoad@0x4000030} -> SECRET DEPENDENT BRANCH

------------------------------------------------
uuid: dda63fde-ef33-47b3-858c-775d5af7b404
transmitter: TransmitterType.SECRET_DEP_BRANCH
CMP operation: __eq__

Secret Dependent Branch:
  - Expr: <Bool (0#48 .. LOAD_16[<BV64 rdi + 0x30>]_27) == LOAD_64[<BV64 0xffffffff81000000>]_26>
Secret Address:
  - Expr: <BV64 rdi + 0x30>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#48 .. LOAD_16[<BV64 rdi + 0x30>]_27>
  - Range: (0x0,0xffff, 0x1) Exact: True
  - Spread: 0 - 15
  - Number of Bits Inferable: 16
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 0#48 .. LOAD_16[<BV64 rdi + 0x30>]_27>
  - Range: (0x0,0xffff, 0x1) Exact: True

CMP Value:
  - Expr: <BV64 LOAD_64[<BV64 0xffffffff81000000>]_26>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Controlled Expr: None
  - Controlled Range: None

Register Requirements:
  - All: ['<BV64 rdi>']
  - Transmission: {<BV64 rdi>}
  - CMP Value: set()

Constraints: []
Branches: [('0x4000013', '<Bool (0#48 .. LOAD_16[<BV64 rdi>]_20) != (0#48 .. LOAD_16[<BV64 LOAD_64[<BV64 rdi + 0x10>]_21>]_22) + 0x50>', 'Not Taken'), ('0x400001d', '<Bool (0#48 .. LOAD_16[<BV64 rdi + 0x20>]_23) != rdi>', 'Not Taken'), ('0x400002e', '<Bool (0#48 .. LOAD_16[<BV64 rdi + 0x20>]_24) != LOAD_64[<BV64 rdi + 0x100>]_25>', 'Not Taken')]
------------------------------------------------
