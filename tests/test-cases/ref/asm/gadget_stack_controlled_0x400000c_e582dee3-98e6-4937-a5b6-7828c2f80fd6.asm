----------------- TRANSMISSION -----------------
         stack_controlled:
4000000  pop     rdi
4000001  pop     rsi
4000002  pop     rdx
4000003  pop     rcx
4000004  movzx   r10, word ptr [rdx+0xff] ; {Attacker@rsp_16} > {Secret@0x4000004}
400000c  mov     r11, qword ptr [rcx+r10] ; {Secret@0x4000004, Attacker@rsp_24} > TRANSMISSION
4000010  jmp     0x400dead

------------------------------------------------
uuid: e582dee3-98e6-4937-a5b6-7828c2f80fd6

Secret Address:
  - Expr: <BV64 rsp_16 + 0xff>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#48 .. LOAD_16[<BV64 rsp_16 + 0xff>]_24>
  - Range: (0x0,0xffff, 0x1) Exact: True
  - Spread: 0 - 15
  - Number of Bits Inferable: 16
Base:
  - Expr: <BV64 rsp_24>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Independent Expr: <BV64 rsp_24>
  - Independent Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmission:
  - Expr: <BV64 rsp_24 + (0#48 .. LOAD_16[<BV64 rsp_16 + 0xff>]_24)>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rsp_16>, <BV64 rsp_24>}
Constraints: []
Branches: []
------------------------------------------------
