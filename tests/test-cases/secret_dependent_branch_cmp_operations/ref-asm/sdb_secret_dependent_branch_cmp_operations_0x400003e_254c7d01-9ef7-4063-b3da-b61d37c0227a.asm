------------ SECRET DEPENDENT BRANCH ------------
         t1:
4000000  movzx   r9, byte ptr [rdi+0x10]
4000005  cmp     r9, rsi
4000008  je      end ; Not Taken   <Bool (0#56 .. LOAD_8[<BV64 rdi + 0x10>]_20) != rsi>
         t2:
400000a  movzx   r9, word ptr [rdi+0x20]
400000f  cmp     r9, rsi
4000012  je      end ; Not Taken   <Bool (0#48 .. LOAD_16[<BV64 rdi + 0x20>]_21) != rsi>
         t3:
4000014  mov     r9d, dword ptr [rdi+0x30]
4000018  cmp     r9, rsi
400001b  je      end ; Not Taken   <Bool (0#32 .. LOAD_32[<BV64 rdi + 0x30>]_22) != rsi>
         t4:
400001d  mov     r9d, dword ptr [rdi+0x40]
4000021  cmp     r9, rsi
4000024  jb      end ; Not Taken   <Bool (0#32 .. LOAD_32[<BV64 rdi + 0x40>]_23) >= rsi>
         t5:
4000026  mov     r9d, dword ptr [rdi+0x50]
400002a  cmp     r9, rsi
400002d  jl      end ; Not Taken   <Bool (0#32 .. LOAD_32[<BV64 rdi + 0x50>]_24) >=s rsi>
         t6:
400002f  movzx   r9, byte ptr [rdi+0x60] ; {Attacker@rdi} -> {Secret@0x400002f}
4000034  mov     r8, rsi
4000037  and     r8, 0xf
400003b  cmp     r9, r8
400003e  je      end ; {Attacker@rsi, Secret@0x400002f} -> SECRET DEPENDENT BRANCH

------------------------------------------------
uuid: 254c7d01-9ef7-4063-b3da-b61d37c0227a
transmitter: TransmitterType.SECRET_DEP_BRANCH
CMP operation: __eq__

Secret Dependent Branch:
  - Expr: <Bool (0#56 .. LOAD_8[<BV64 rdi + 0x60>]_25) == (rsi & 0xf)>
Secret Address:
  - Expr: <BV64 rdi + 0x60>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#56 .. LOAD_8[<BV64 rdi + 0x60>]_25>
  - Range: (0x0,0xff, 0x1) Exact: True
  - Spread: 0 - 7
  - Number of Bits Inferable: 8
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 0#56 .. LOAD_8[<BV64 rdi + 0x60>]_25>
  - Range: (0x0,0xff, 0x1) Exact: True

CMP Value:
  - Expr: <BV64 rsi & 0xf>
  - Range: (0x0,0xf, 0x1) Exact: True
  - Controlled Expr: <BV64 0#60 .. rsi[3:0]>
  - Controlled Range: (0x0,0xf, 0x1) Exact: True

Register Requirements:
  - All: ['<BV64 rdi>', '<BV64 rsi>']
  - Transmission: {<BV64 rdi>}
  - CMP Value: {<BV64 rsi>}

Constraints: []
Branches: [('0x4000008', '<Bool (0#56 .. LOAD_8[<BV64 rdi + 0x10>]_20) != rsi>', 'Not Taken'), ('0x4000012', '<Bool (0#48 .. LOAD_16[<BV64 rdi + 0x20>]_21) != rsi>', 'Not Taken'), ('0x400001b', '<Bool (0#32 .. LOAD_32[<BV64 rdi + 0x30>]_22) != rsi>', 'Not Taken'), ('0x4000024', '<Bool (0#32 .. LOAD_32[<BV64 rdi + 0x40>]_23) >= rsi>', 'Not Taken'), ('0x400002d', '<Bool (0#32 .. LOAD_32[<BV64 rdi + 0x50>]_24) >=s rsi>', 'Not Taken')]
------------------------------------------------
