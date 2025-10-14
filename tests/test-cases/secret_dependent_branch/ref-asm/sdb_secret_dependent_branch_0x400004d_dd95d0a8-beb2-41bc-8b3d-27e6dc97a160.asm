------------ SECRET DEPENDENT BRANCH ------------
         secret_dependent_branch:
4000000  movzx   r9, word ptr [rdi]
4000004  mov     r8, qword ptr [rsi]
4000007  add     r8, 0x50
400000b  cmp     r9, r8
400000e  je      end ; Not Taken   <Bool (0#48 .. LOAD_16[<BV64 rdi>]_20) != LOAD_64[<BV64 rsi>]_21 + 0x50>
         t1:
4000010  movzx   r9, word ptr [rdi+0x10]
4000015  cmp     r9, 0xdead
400001c  je      end ; Not Taken   <Bool LOAD_16[<BV64 rdi + 0x10>]_22 != 0xdead>
         t2:
400001e  movzx   r9, word ptr [rdi+0x20]
4000023  cmp     r9, rdi
4000026  je      end ; Not Taken   <Bool (0#48 .. LOAD_16[<BV64 rdi + 0x20>]_23) != rdi>
         t3:
4000028  mov     rax, qword ptr [0xffffffff81000000]
4000030  movzx   r9, word ptr [rdi+0x30]
4000035  cmp     r9, rax
4000038  je      end ; Not Taken   <Bool (0#48 .. LOAD_16[<BV64 rdi + 0x30>]_25) != LOAD_64[<BV64 0xffffffff81000000>]_24>
         t4:
400003a  mov     rax, qword ptr [0xffffffff81000000] ; {} -> {UncontrolledLoad@0x400003a}
4000042  movzx   r9, word ptr [rdi+0x30] ; {Attacker@rdi} -> {Secret@0x4000042}
4000047  add     r9, rax
400004a  cmp     r9, rsi
400004d  je      end ; {Attacker@rsi, Secret@0x4000042, UncontrolledLoad@0x400003a} -> SECRET DEPENDENT BRANCH

------------------------------------------------
uuid: dd95d0a8-beb2-41bc-8b3d-27e6dc97a160
transmitter: TransmitterType.SECRET_DEP_BRANCH
CMP operation: __eq__

Secret Dependent Branch:
  - Expr: <Bool (0#48 .. LOAD_16[<BV64 rdi + 0x30>]_27) + LOAD_64[<BV64 0xffffffff81000000>]_26 == rsi>
Secret Address:
  - Expr: <BV64 rdi + 0x30>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#48 .. LOAD_16[<BV64 rdi + 0x30>]_27>
  - Range: (0x0,0xffff, 0x1) Exact: True
  - Spread: 0 - 15
  - Number of Bits Inferable: 16
Base:
  - Expr: <BV64 LOAD_64[<BV64 0xffffffff81000000>]_26>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Independent Expr: <BV64 LOAD_64[<BV64 0xffffffff81000000>]_26>
  - Independent Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmission:
  - Expr: <BV64 (0#48 .. LOAD_16[<BV64 rdi + 0x30>]_27) + LOAD_64[<BV64 0xffffffff81000000>]_26>
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
Branches: [('0x400000e', '<Bool (0#48 .. LOAD_16[<BV64 rdi>]_20) != LOAD_64[<BV64 rsi>]_21 + 0x50>', 'Not Taken'), ('0x400001c', '<Bool LOAD_16[<BV64 rdi + 0x10>]_22 != 0xdead>', 'Not Taken'), ('0x4000026', '<Bool (0#48 .. LOAD_16[<BV64 rdi + 0x20>]_23) != rdi>', 'Not Taken'), ('0x4000038', '<Bool (0#48 .. LOAD_16[<BV64 rdi + 0x30>]_25) != LOAD_64[<BV64 0xffffffff81000000>]_24>', 'Not Taken')]
------------------------------------------------
