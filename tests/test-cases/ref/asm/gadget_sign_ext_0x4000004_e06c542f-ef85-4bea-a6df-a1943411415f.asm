----------------- TRANSMISSION -----------------
         sign_extend:
4000000  movsx   eax, byte ptr [rcx+0x4] ; {Attacker@rcx} > {Secret@0x4000000}
4000004  mov     rdx, qword ptr [rax+0x40] ; {Secret@0x4000000} > TRANSMISSION
4000008  jmp     0x400dead

------------------------------------------------
uuid: e06c542f-ef85-4bea-a6df-a1943411415f

Secret Address:
  - Expr: <BV64 rcx + 0x4>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#56 .. LOAD_8[<BV64 rcx + 0x4>]_20>
  - Range: (0x80,0xff, 0x1) Exact: True
  - Spread: 0 - 7
  - Number of Bits Inferable: 8
Base:
  - Expr: <BV64 0xffffff40>
  - Range: 0xffffff40
  - Independent Expr: <BV64 0xffffff40>
  - Independent Range: 0xffffff40
Transmission:
  - Expr: <BV64 0x40 + (0xffffff00 + (0#56 .. LOAD_8[<BV64 rcx + 0x4>]_20))>
  - Range: (0xffffffc0,0x10000003f, 0x1) Exact: True

Register Requirements: {<BV64 rcx>}
Constraints: [('0x4000004', <Bool LOAD_8[<BV64 rcx + 0x4>]_20[7:7] != 0>)]
Branches: []
------------------------------------------------
