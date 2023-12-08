----------------- TRANSMISSION -----------------
         store_transmission:
4000000  movabs  rdx, 0xffffffff70000000
400000a  mov     qword ptr [rdx], r8
400000d  mov     r10, qword ptr [rdx]
4000010  mov     rdi, qword ptr [r10+0xff] ; {Attacker@r8} > {Secret@0x4000010}
4000017  and     rdi, 0xffff
400001e  mov     qword ptr [rcx+rdi], rax ; {Secret@0x4000010, Attacker@rcx} > TRANSMISSION
4000022  mov     r10, qword ptr [rdi-0x7f000000]
4000029  jmp     0x400dead

------------------------------------------------
uuid: 7a07407a-0fc1-4d0c-a3f2-90cdf1f52afa

Secret Address:
  - Expr: <BV64 r8 + 0xff>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#48 .. LOAD_64[<BV64 r8 + 0xff>]_22[15:0]>
  - Range: (0x0,0xffff, 0x1) Exact: True
  - Spread: 0 - 15
  - Number of Bits Inferable: 16
Base:
  - Expr: <BV64 rcx>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Independent Expr: <BV64 rcx>
  - Independent Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmission:
  - Expr: <BV64 rcx + (0#48 .. LOAD_64[<BV64 r8 + 0xff>]_22[15:0])>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rcx>, <BV64 r8>}
Constraints: []
Branches: []
------------------------------------------------
