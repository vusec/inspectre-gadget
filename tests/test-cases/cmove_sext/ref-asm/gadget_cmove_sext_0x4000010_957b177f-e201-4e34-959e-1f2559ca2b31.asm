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
uuid: 957b177f-e201-4e34-959e-1f2559ca2b31

Secret Address:
  - Expr: <BV64 rdx + 0x18>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#32 .. LOAD_32[<BV64 rdx + 0x18>]_20>
  - Range: (0x1,0x7fffffff, 0x1) Exact: True
  - Spread: 0 - 31
  - Number of Bits Inferable: 32
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 0#32 .. LOAD_32[<BV64 rdx + 0x18>]_20>
  - Range: (0x1,0x7fffffff, 0x1) Exact: True

Register Requirements: {<BV64 rdx>}
Constraints: [('0x4000010', <Bool LOAD_32[<BV64 rdx + 0x18>]_20[31:31] == 0>), ('0x4000010', <Bool LOAD_32[<BV64 rdx + 0x18>]_20[31:31] == 0>), ('0x4000010', <Bool (0#32 .. LOAD_32[<BV64 rdx + 0x18>]_20) + 0x0 != 0x0>), ('0x4000012', <Bool LOAD_32[<BV64 rdx + 0x18>]_29[31:31] == 0>)]
Branches: []
------------------------------------------------