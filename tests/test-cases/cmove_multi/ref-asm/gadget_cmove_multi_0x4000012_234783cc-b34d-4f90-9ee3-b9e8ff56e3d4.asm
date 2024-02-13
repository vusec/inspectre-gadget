----------------- TRANSMISSION -----------------
         cmove_sample:
4000000  mov     rdi, qword ptr [rdx+0x18] ; {Attacker@rdx} > {Secret@0x4000000}
4000004  test    rdi, rdi
4000007  cmove   rdi, rsi
400000b  test    rax, rax
400000e  cmove   rax, rbx
4000012  mov     eax, dword ptr [rax+rdi] ; {Secret@0x4000000, Attacker@rbx} > TRANSMISSION
4000015  jmp     0x400dead

------------------------------------------------
uuid: 234783cc-b34d-4f90-9ee3-b9e8ff56e3d4

Secret Address:
  - Expr: <BV64 rdx + 0x18>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rdx + 0x18>]_20>
  - Range: (0x1,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: <BV64 rbx>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Independent Expr: <BV64 rbx>
  - Independent Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmission:
  - Expr: <BV64 rbx + LOAD_64[<BV64 rdx + 0x18>]_20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: False

Register Requirements: {<BV64 rdx>, <BV64 rax>, <BV64 rbx>}
Constraints: [('0x4000007', <Bool LOAD_64[<BV64 rdx + 0x18>]_20 != 0x0>, 'ConditionType.CMOVE'), ('0x400000e', <Bool rax == 0x0>, 'ConditionType.CMOVE')]
Branches: []
------------------------------------------------
