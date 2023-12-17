----------------- TRANSMISSION -----------------
         cmove_sample:
4000000  test    rdi, rdi
4000003  cmove   rax, rbx
4000007  cmp     rcx, rax
400000a  je      if ; Taken   <Bool rcx == (if rdi == 0x0 then rbx else rax)>
         if:
400000e  mov     rdi, qword ptr [rax+0x18] ; {Attacker@rbx} > {Secret@0x400000e}
4000012  mov     eax, dword ptr [rdi] ; {Secret@0x400000e} > TRANSMISSION
4000014  jmp     0x400dead

------------------------------------------------
uuid: 679e58f0-bc40-4702-936e-fb247cf60667

Secret Address:
  - Expr: <BV64 rbx + 0x18>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rbx + 0x18>]_24>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 rbx + 0x18>]_24>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rbx>, <BV64 rdi>}
Constraints: [('0x400000e', <Bool rdi == 0x0>)]
Branches: [(67108874, <Bool rcx == (if rdi == 0x0 then rbx else rax)>, 'Taken')]
------------------------------------------------
