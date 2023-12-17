----------------- TRANSMISSION -----------------
         disjoint_range:
4000000  mov     rax, qword ptr [rdi+0x28] ; {Attacker@rdi} > {Secret@0x4000000}
4000004  cmp     rax, 0x10
4000008  je      0x400dead ; Taken   <Bool LOAD_64[<BV64 rdi + 0x28>]_20 != 0x10>
400000e  mov     rcx, qword ptr [rax] ; {Secret@0x4000000} > TRANSMISSION
4000011  jg      0x400dead

------------------------------------------------
uuid: 29964fb8-ff79-4dce-a2e8-b315cf2f77f8

Secret Address:
  - Expr: <BV64 rdi + 0x28>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rdi + 0x28>]_20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 rdi + 0x28>]_20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rdi>}
Constraints: []
Branches: [(67108872, <Bool LOAD_64[<BV64 rdi + 0x28>]_20 != 0x10>, 'Taken')]
------------------------------------------------
