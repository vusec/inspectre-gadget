----------------- TRANSMISSION -----------------
         attack_stored_in_mem:
4000000  movabs  rdx, 0xffffffff70000000
400000a  mov     qword ptr [rdx], r8
400000d  mov     r10, qword ptr [rdx]
4000010  mov     rdi, qword ptr [r10+0xff] ; {Attacker@r8} -> {Secret@0x4000010}
4000017  and     rdi, 0xffff
400001e  mov     r10, qword ptr [rdi-0x7f000000] ; {Secret@0x4000010} -> TRANSMISSION
4000025  jmp     0x400dead

------------------------------------------------
uuid: 6d753738-6bf9-43fe-be64-e29e50cc4a2b
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 r8 + 0xff>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#48 .. LOAD_64[<BV64 r8 + 0xff>]_22[15:0]>
  - Range: (0x0,0xffff, 0x1) Exact: True
  - Spread: 0 - 15
  - Number of Bits Inferable: 16
Base:
  - Expr: <BV64 0xffffffff81000000>
  - Range: 0xffffffff81000000
  - Independent Expr: <BV64 0xffffffff81000000>
  - Independent Range: 0xffffffff81000000
Transmission:
  - Expr: <BV64 0xffffffff81000000 + (0#48 .. LOAD_64[<BV64 r8 + 0xff>]_22[15:0])>
  - Range: (0xffffffff81000000,0xffffffff8100ffff, 0x1) Exact: True

Register Requirements: {<BV64 r8>}
Constraints: []
Branches: []
------------------------------------------------
