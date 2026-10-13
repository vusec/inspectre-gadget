------------ SECRET DEPENDENT BRANCH ------------
         t1:
4000000  movzx   r9, byte ptr [rdi+0x10]
4000005  cmp     r9, rsi
4000008  je      end ; Not Taken   <Bool (0#56 .. LOAD_8[<BV64 rdi + 0x10>]_20) != rsi>
         t2:
400000a  movzx   r9, word ptr [rdi+0x20] ; {Attacker@rdi} -> {Secret@0x400000a}
400000f  cmp     r9, rsi
4000012  je      end ; {Attacker@rsi, Secret@0x400000a} -> SECRET DEPENDENT BRANCH

------------------------------------------------
uuid: a1debf9d-87e0-4ae4-9266-9c54ba3996de
transmitter: TransmitterType.SECRET_DEP_BRANCH
CMP operation: __eq__

Secret Dependent Branch:
  - Expr: <Bool (0#48 .. LOAD_16[<BV64 rdi + 0x20>]_21) == rsi>
Secret Address:
  - Expr: <BV64 rdi + 0x20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#48 .. LOAD_16[<BV64 rdi + 0x20>]_21>
  - Range: (0x0,0xffff, 0x1) Exact: True
  - Spread: 0 - 15
  - Number of Bits Inferable: 16
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 0#48 .. LOAD_16[<BV64 rdi + 0x20>]_21>
  - Range: (0x0,0xffff, 0x1) Exact: True

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
Branches: [('0x4000008', '<Bool (0#56 .. LOAD_8[<BV64 rdi + 0x10>]_20) != rsi>', 'Not Taken')]
------------------------------------------------
