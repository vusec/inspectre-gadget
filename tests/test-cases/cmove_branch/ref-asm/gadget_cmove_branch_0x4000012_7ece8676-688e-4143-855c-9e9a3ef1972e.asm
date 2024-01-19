----------------- TRANSMISSION -----------------
         cmove_sample:
4000000  test    rdi, rdi
4000003  cmove   rax, rbx
4000007  cmp     rcx, rax
400000a  je      if ; Taken   <Bool rcx == (if rdi == 0x0 then rbx else rax)>
         if:
400000e  mov     rdi, qword ptr [rdi+0x18] ; {Attacker@rdi} > {Secret@0x400000e}
4000012  mov     eax, dword ptr [rdi] ; {Secret@0x400000e} > TRANSMISSION
4000014  jmp     0x400dead

------------------------------------------------
uuid: 7ece8676-688e-4143-855c-9e9a3ef1972e

Secret Address:
  - Expr: <BV64 rdi + 0x18>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rdi + 0x18>]_22>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 rdi + 0x18>]_22>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rdi>}
Constraints: []
Branches: [(67108874, <Bool rcx == (if rdi == 0x0 then rbx else rax)>, 'Taken')]
------------------------------------------------
