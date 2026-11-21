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
4000030  mov     rax, qword ptr [0xffffffff81000000]
4000038  movzx   r9, word ptr [rdi+0x30]
400003d  cmp     r9, rax
4000040  je      end ; Not Taken   <Bool (0#48 .. LOAD_16[<BV64 rdi + 0x30>]_27) != LOAD_64[<BV64 0xffffffff81000000>]_26>
         t5:
4000042  mov     rax, qword ptr [0xffffffff81000000] ; {} -> {UncontrolledLoad@0x4000042}
400004a  movzx   r9, word ptr [rdi+0x30] ; {Attacker@rdi} -> {Secret@0x400004a}
400004f  add     r9, rax
4000052  cmp     r9, rsi
4000055  je      end ; {Attacker@rsi, Secret@0x400004a, UncontrolledLoad@0x4000042} -> SECRET DEPENDENT BRANCH

------------------------------------------------
uuid: cd283185-51d7-4f29-b30d-92d6637f8402
transmitter: TransmitterType.SECRET_DEP_BRANCH
CMP operation: __eq__

Secret Dependent Branch:
  - Expr: <Bool (0#48 .. LOAD_16[<BV64 rdi + 0x30>]_29) + LOAD_64[<BV64 0xffffffff81000000>]_28 == rsi>
Secret Address:
  - Expr: <BV64 rdi + 0x30>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#48 .. LOAD_16[<BV64 rdi + 0x30>]_29>
  - Range: (0x0,0xffff, 0x1) Exact: True
  - Spread: 0 - 15
  - Number of Bits Inferable: 16
Base:
  - Expr: <BV64 LOAD_64[<BV64 0xffffffff81000000>]_28>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Independent Expr: <BV64 LOAD_64[<BV64 0xffffffff81000000>]_28>
  - Independent Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmission:
  - Expr: <BV64 (0#48 .. LOAD_16[<BV64 rdi + 0x30>]_29) + LOAD_64[<BV64 0xffffffff81000000>]_28>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

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
Branches: [('0x4000013', '<Bool (0#48 .. LOAD_16[<BV64 rdi>]_20) != (0#48 .. LOAD_16[<BV64 LOAD_64[<BV64 rdi + 0x10>]_21>]_22) + 0x50>', 'Not Taken'), ('0x400001d', '<Bool (0#48 .. LOAD_16[<BV64 rdi + 0x20>]_23) != rdi>', 'Not Taken'), ('0x400002e', '<Bool (0#48 .. LOAD_16[<BV64 rdi + 0x20>]_24) != LOAD_64[<BV64 rdi + 0x100>]_25>', 'Not Taken'), ('0x4000040', '<Bool (0#48 .. LOAD_16[<BV64 rdi + 0x30>]_27) != LOAD_64[<BV64 0xffffffff81000000>]_26>', 'Not Taken')]
------------------------------------------------
