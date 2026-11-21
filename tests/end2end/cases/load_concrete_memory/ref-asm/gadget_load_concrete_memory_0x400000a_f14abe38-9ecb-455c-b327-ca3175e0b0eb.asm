----------------- TRANSMISSION -----------------
         load_concrete_memory:
4000000  mov     rax, qword ptr [global_offset]
4000007  mov     r9, qword ptr [rdi] ; {Attacker@rdi} -> {Secret@0x4000007}
400000a  mov     r10, qword ptr [r9+rax] ; {Secret@0x4000007} -> TRANSMISSION
400000e  jmp     0x400dead

------------------------------------------------
uuid: f14abe38-9ecb-455c-b327-ca3175e0b0eb
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 rdi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rdi>]_21>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: <BV64 0x1337000>
  - Range: 0x1337000
  - Independent Expr: <BV64 0x1337000>
  - Independent Range: 0x1337000
Transmission:
  - Expr: <BV64 0x1337000 + LOAD_64[<BV64 rdi>]_21>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: ['<BV64 rdi>']
Constraints: []
Branches: []
------------------------------------------------
