------------ SECRET DEPENDENT BRANCH ------------
         disjoint_range:
4000000  mov     rax, qword ptr [rdi+0x28]
4000004  mov     rsi, qword ptr [rsi+0x30] ; {Attacker@rsi} -> {Secret@0x4000004}
4000008  cmp     rax, 0xf
400000c  je      exit ; Not Taken   <Bool LOAD_64[<BV64 rdi + 0x28>]_20 != 0xf>
400000e  mov     rcx, qword ptr [rax]
4000011  mov     r8, qword ptr [rax-0x7f000000]
4000018  cmp     rsi, 0xff
400001f  je      exit ; {Secret@0x4000004} -> SECRET DEPENDENT BRANCH

------------------------------------------------
uuid: 79fb0567-fccd-44c7-a51c-34adc89a2a98
transmitter: TransmitterType.SECRET_DEP_BRANCH
CMP operation: __eq__

Secret Dependent Branch:
  - Expr: <Bool LOAD_64[<BV64 rsi + 0x30>]_21 == 0xff>
Secret Address:
  - Expr: <BV64 rsi + 0x30>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rsi + 0x30>]_21>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 rsi + 0x30>]_21>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

CMP Value:
  - Expr: <BV64 0xff>
  - Range: 0xff
  - Controlled Expr: None
  - Controlled Range: None

Register Requirements:
  - All: ['<BV64 rsi>']
  - Transmission: {<BV64 rsi>}
  - CMP Value: set()

Constraints: []
Branches: [('0x400000c', '<Bool LOAD_64[<BV64 rdi + 0x28>]_20 != 0xf>', 'Not Taken')]
------------------------------------------------
