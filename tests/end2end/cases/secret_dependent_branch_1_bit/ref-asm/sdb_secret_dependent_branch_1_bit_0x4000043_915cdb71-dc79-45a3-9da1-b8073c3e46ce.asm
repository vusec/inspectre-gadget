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
400001a  mov     rax, qword ptr [0xffffffff81000000]
4000022  movzx   r9, byte ptr [rdi+0x30]
4000027  shr     r9, 0x7
400002b  cmp     r9, rax
400002e  je      end ; Not Taken   <Bool LShR((0#56 .. LOAD_8[<BV64 rdi + 0x30>]_23), 0x7) != LOAD_64[<BV64 0xffffffff81000000>]_22>
         t4:
4000030  movzx   r9, byte ptr [rdi+0x40] ; {Attacker@rdi} -> {Attacker@0x4000030}
4000035  shr     r9, 0x7
4000039  mov     r8, qword ptr [rdi+0x100] ; {Attacker@rdi} -> {Secret@0x4000039}
4000040  cmp     r9, r8
4000043  je      end ; {Attacker@0x4000030, Secret@0x4000039} -> SECRET DEPENDENT BRANCH

------------------------------------------------
uuid: 915cdb71-dc79-45a3-9da1-b8073c3e46ce
transmitter: TransmitterType.SECRET_DEP_BRANCH
CMP operation: __eq__

Secret Dependent Branch:
  - Expr: <Bool LShR((0#56 .. LOAD_8[<BV64 rdi + 0x40>]_24), 0x7) == LOAD_64[<BV64 rdi + 0x100>]_25>
Secret Address:
  - Expr: <BV64 rdi + 0x100>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rdi + 0x100>]_25>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 rdi + 0x100>]_25>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

CMP Value:
  - Expr: <BV64 LShR((0#56 .. LOAD_8[<BV64 rdi + 0x40>]_24), 0x7)>
  - Range: (0x0,0x1, 0x1) Exact: True
  - Controlled Expr: <BV64 0#63 .. LOAD_8[<BV64 rdi + 0x40>]_24[7:7]>
  - Controlled Range: (0x0,0x1, 0x1) Exact: True

Register Requirements:
  - All: ['<BV64 rdi>']
  - Transmission: {<BV64 rdi>}
  - CMP Value: {<BV64 rdi>}

Constraints: []
Branches: [('0x4000009', '<Bool LOAD_8[<BV64 rdi + 0x10>]_20 != 65>', 'Not Taken'), ('0x4000018', '<Bool (LOAD_8[<BV64 rdi + 0x20>]_21 & 1) != 1>', 'Not Taken'), ('0x400002e', '<Bool LShR((0#56 .. LOAD_8[<BV64 rdi + 0x30>]_23), 0x7) != LOAD_64[<BV64 0xffffffff81000000>]_22>', 'Not Taken')]
------------------------------------------------
