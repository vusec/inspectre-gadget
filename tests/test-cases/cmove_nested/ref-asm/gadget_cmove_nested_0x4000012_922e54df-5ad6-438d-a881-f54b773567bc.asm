----------------- TRANSMISSION -----------------
         cmove_sample:
4000000  mov     rdi, qword ptr [rdx+0x18] ; {Attacker@rdx} > {Secret@0x4000000}
4000004  test    rdi, rdi
4000007  cmove   rdi, rsi
400000b  test    rax, rax
400000e  cmove   rax, rdi
4000012  mov     eax, dword ptr [rax+0x24] ; {Secret@0x4000000} > TRANSMISSION
4000015  jmp     0x400dead

------------------------------------------------
uuid: 922e54df-5ad6-438d-a881-f54b773567bc

Secret Address:
  - Expr: <BV64 rdx + 0x18>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rdx + 0x18>]_20>
  - Range: (0x1,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: <BV64 0x24>
  - Range: 0x24
  - Independent Expr: <BV64 0x24>
  - Independent Range: 0x24
Transmission:
  - Expr: <BV64 0x24 + LOAD_64[<BV64 rdx + 0x18>]_20>
  - Range: (0x25,0x23, 0x1) Exact: True

Register Requirements: {<BV64 rdx>, <BV64 rax>}
Constraints: [('0x4000012', <Bool LOAD_64[<BV64 rdx + 0x18>]_20 != 0x0>), ('0x4000012', <Bool rax == 0x0>)]
Branches: []
------------------------------------------------
