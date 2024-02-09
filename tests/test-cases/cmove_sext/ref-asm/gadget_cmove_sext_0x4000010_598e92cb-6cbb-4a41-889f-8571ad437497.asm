----------------- TRANSMISSION -----------------
         cmove_sample:
4000000  mov     edi, dword ptr [rdx+0x18] ; {Attacker@rdx} > {Secret@0x4000000}
4000003  movsxd  rdi, edi
4000006  mov     rbx, rdi
4000009  test    rdi, rdi
400000c  cmove   rdi, rsi
4000010  mov     eax, dword ptr [rdi] ; {Secret@0x4000000} > TRANSMISSION
4000012  mov     ecx, dword ptr [rbx+0x20]
4000015  jmp     0x400dead

------------------------------------------------
uuid: 598e92cb-6cbb-4a41-889f-8571ad437497

Secret Address:
  - Expr: <BV64 rdx + 0x18>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#32 .. LOAD_32[<BV64 rdx + 0x18>]_20>
  - Range: (0x80000000,0xffffffff, 0x1) Exact: True
  - Spread: 0 - 31
  - Number of Bits Inferable: 32
Base:
  - Expr: <BV64 0xffffffff00000000>
  - Range: 0xffffffff00000000
  - Independent Expr: <BV64 0xffffffff00000000>
  - Independent Range: 0xffffffff00000000
Transmission:
  - Expr: <BV64 0xffffffff00000000 + (0#32 .. LOAD_32[<BV64 rdx + 0x18>]_20)>
  - Range: (0xffffffff80000000,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rdx>}
Constraints: [('0x4000010', <Bool LOAD_32[<BV64 rdx + 0x18>]_20[31:31] != 0>), ('0x4000010', <Bool LOAD_32[<BV64 rdx + 0x18>]_20[31:31] != 0>), ('0x4000010', <Bool (0#32 .. LOAD_32[<BV64 rdx + 0x18>]_20) + 0xffffffff00000000 != 0x0>)]
Branches: []
------------------------------------------------
