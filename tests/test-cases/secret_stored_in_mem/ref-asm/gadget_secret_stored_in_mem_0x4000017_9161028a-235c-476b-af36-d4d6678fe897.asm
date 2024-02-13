----------------- TRANSMISSION -----------------
         secret_stored_in_mem:
4000000  mov     r8d, dword ptr [rsi] ; {Attacker@rsi} > {Secret@0x4000000}
4000003  mov     rdx, 0xffffffff82000000
400000a  mov     qword ptr [rdx], r8
400000d  mov     r10, qword ptr [rdx]
4000010  and     r10, 0xffff
4000017  mov     rcx, qword ptr [r10-0x7f000000] ; {Secret@0x4000000} > TRANSMISSION
400001e  movzx   r11, word ptr [rdx]
4000022  mov     rdi, qword ptr [r11-0x7f000000]
4000029  jmp     0x400dead

------------------------------------------------
uuid: 9161028a-235c-476b-af36-d4d6678fe897

Secret Address:
  - Expr: <BV64 rsi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#48 .. LOAD_32[<BV64 rsi>]_20[15:0]>
  - Range: (0x0,0xffff, 0x1) Exact: True
  - Spread: 0 - 15
  - Number of Bits Inferable: 16
Base:
  - Expr: <BV64 0xffffffff81000000>
  - Range: 0xffffffff81000000
  - Independent Expr: <BV64 0xffffffff81000000>
  - Independent Range: 0xffffffff81000000
Transmission:
  - Expr: <BV64 0xffffffff81000000 + (0#48 .. LOAD_32[<BV64 rsi>]_20[15:0])>
  - Range: (0xffffffff81000000,0xffffffff8100ffff, 0x1) Exact: True

Register Requirements: {<BV64 rsi>}
Constraints: []
Branches: []
------------------------------------------------
