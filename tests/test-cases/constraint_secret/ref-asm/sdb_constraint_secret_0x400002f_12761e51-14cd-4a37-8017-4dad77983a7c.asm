------------ SECRET DEPENDENT BRANCH ------------
         constraint_secret:
4000000  movzx   r9, word ptr [rdi]
4000004  cmp     r9, 0xffff
400000b  ja      trans1 ; Not Taken   <Bool (0#48 .. LOAD_16[<BV64 rdi>]_20) <= 0xffff>
400000d  mov     rsi, qword ptr [r9-0x80000000]
4000014  cmp     r9, 0xff
400001b  ja      trans1 ; Taken   <Bool (0x0 .. LOAD_16[<BV64 rdi>]_20) > 0xff>
         trans1:
4000026  movzx   r9, word ptr [rdi+0x20] ; {Attacker@rdi} -> {Secret@0x4000026}
400002b  cmp     r9, 0x0
400002f  je      end

------------------------------------------------
uuid: 12761e51-14cd-4a37-8017-4dad77983a7c
transmitter: TransmitterType.SECRET_DEP_BRANCH
CMP operation: __eq__

Secret Dependent Branch:
  - Expr: <Bool LOAD_16[<BV64 rdi + 0x20>]_22 == 0x0>
Secret Address:
  - Expr: <BV64 rdi + 0x20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV16 LOAD_16[<BV64 rdi + 0x20>]_22>
  - Range: (0x0,0xffff, 0x1) Exact: True
  - Spread: 0 - 15
  - Number of Bits Inferable: 16
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV16 LOAD_16[<BV64 rdi + 0x20>]_22>
  - Range: (0x0,0xffff, 0x1) Exact: True

CMP Value:
  - Expr: <BV16 0x0>
  - Range: 0x0
  - Controlled Expr: None
  - Controlled Range: None

Register Requirements:
  - All: {<BV64 rdi>}
  - Transmission: {<BV64 rdi>}
  - CMP Value: set()

Constraints: []
Branches: [('0x400000b', <Bool (0#48 .. LOAD_16[<BV64 rdi>]_20) <= 0xffff>, 'Not Taken'), ('0x400001b', <Bool (0x0 .. LOAD_16[<BV64 rdi>]_20) > 0xff>, 'Taken')]
------------------------------------------------
