----------------- TRANSMISSION -----------------
         code_load:
4000000  cmp     r8, 0x0
4000004  je      trans1 ; Taken   <Bool r8 == 0x0>
         trans1:
400001c  mov     rax, qword ptr [rdi] ; {Attacker@rdi} -> {Secret@0x400001c}
400001f  jmp     rax ; {Secret@0x400001c} -> TRANSMISSION

------------------------------------------------
uuid: a84942f4-bbda-412b-8c47-e9b2e3ee53ce
transmitter: TransmitterType.CODE_LOAD

Secret Address:
  - Expr: <BV64 rdi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rdi>]_24>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 rdi>]_24>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rdi>}
Constraints: []
Branches: [('0x4000004', <Bool r8 == 0x0>, 'Taken')]
------------------------------------------------
