----------------- TRANSMISSION -----------------
         tfp_independently_controllable:
4000000  mov     rsi, qword ptr [rdi]
4000003  mov     rdx, qword ptr [rdx]
4000006  mov     rbx, qword ptr [rsi]
4000009  add     rcx, rsi
400000c  add     rcx, rdx
400000f  mov     rax, qword ptr [rdi+0x10] ; {Attacker@rdi} -> {Secret@0x400000f}
4000013  call    rax ; {Secret@0x400000f} -> TRANSMISSION

------------------------------------------------
uuid: 7cac5505-da2e-4ef4-9ff3-af24d188d758
transmitter: TransmitterType.CODE_LOAD

Secret Address:
  - Expr: <BV64 rdi + 0x10>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rdi + 0x10>]_23>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 rdi + 0x10>]_23>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rdi>}
Constraints: []
Branches: []
------------------------------------------------
