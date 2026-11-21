----------------- TRANSMISSION -----------------
         tfp_independently_controllable:
4000000  mov     rsi, qword ptr [rdi] ; {Attacker@rdi} -> {Secret@0x4000000}
4000003  mov     rdx, qword ptr [rdx]
4000006  mov     rbx, qword ptr [rsi] ; {Secret@0x4000000} -> TRANSMISSION
4000009  add     rcx, rsi
400000c  add     rcx, rdx
400000f  mov     rax, qword ptr [rdi+0x10]
4000013  call    rax

------------------------------------------------
uuid: fc525c81-52e9-4f78-bd7a-2f74b88106e5
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 rdi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rdi>]_20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 rdi>]_20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: ['<BV64 rdi>']
Constraints: []
Branches: []
------------------------------------------------
