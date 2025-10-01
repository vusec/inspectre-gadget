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
400001e  movzx   r9, word ptr [rdi+0x20] ; {Attacker@rdi} -> {Secret@0x400001e}
4000023  cmp     r9, rdi
4000026  je      end ; {Secret@0x400001e, Attacker@rdi} -> SECRET DEPENDENT BRANCH

------------------------------------------------
uuid: 1efdd9b9-fa1a-4b18-9117-23d11955811f
transmitter: TransmitterType.SECRET_DEP_BRANCH
CMP operation: __eq__

Secret Dependent Branch:
  - Expr: <Bool (0#48 .. LOAD_16[<BV64 rdi + 0x20>]_23) == rdi>
Secret Address:
  - Expr: <BV64 rdi + 0x20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#48 .. LOAD_16[<BV64 rdi + 0x20>]_23>
  - Range: (0x0,0xffff, 0x1) Exact: True
  - Spread: 0 - 15
  - Number of Bits Inferable: 16
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 0#48 .. LOAD_16[<BV64 rdi + 0x20>]_23>
  - Range: (0x0,0xffff, 0x1) Exact: True

CMP Value:
  - Expr: <BV64 rdi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Controlled Expr: <BV64 rdi>
  - Controlled Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements:
  - All: {<BV64 rdi>}
  - Transmission: {<BV64 rdi>}
  - CMP Value: {<BV64 rdi>}

Constraints: []
Branches: [('0x400000e', <Bool (0#48 .. LOAD_16[<BV64 rdi>]_20) != LOAD_64[<BV64 rsi>]_21 + 0x50>, 'Not Taken'), ('0x400001c', <Bool LOAD_16[<BV64 rdi + 0x10>]_22 != 0xdead>, 'Not Taken')]
------------------------------------------------
