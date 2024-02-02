----------------- TRANSMISSION -----------------
         cmove_sample:
4000000  test    rdi, rdi
4000003  cmove   rax, rbx
4000007  cmp     rcx, rax
400000a  je      if ; Taken   <Bool rcx == (if rdi == 0x0 then rbx else rax)>
         if:
400000e  mov     rdi, qword ptr [rax+0x18] ; {Attacker@rax} > {Secret@0x400000e}
4000012  mov     eax, dword ptr [rdi] ; {Secret@0x400000e} > TRANSMISSION
4000014  jmp     0x400dead

------------------------------------------------
uuid: e19df2ea-7dda-4963-933e-e5f8ba6f2a17

Secret Address:
  - Expr: <BV64 rax + 0x18>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rax + 0x18>]_22>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 rax + 0x18>]_22>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rax>, <BV64 rdi>}
Constraints: [('0x400000e', <Bool rdi != 0x0>)]
Branches: [(67108874, <Bool rcx == (if rdi == 0x0 then rbx else rax)>, 'Taken')]
------------------------------------------------