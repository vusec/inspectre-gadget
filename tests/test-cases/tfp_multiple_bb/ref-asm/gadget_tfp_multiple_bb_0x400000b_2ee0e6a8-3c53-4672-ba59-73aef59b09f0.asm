----------------- TRANSMISSION -----------------
         tfp_multiple_bb:
4000000  mov     r8, qword ptr [rdi] ; {Attacker@rdi} -> {Secret@0x4000000}
4000003  cmp     rax, 0x0
4000007  je      tfp0 ; Taken   <Bool rax == 0x0>
         tfp0:
400000b  mov     r10, qword ptr [r8-0x7f000000] ; {Secret@0x4000000} -> TRANSMISSION
4000012  jmp     __x86_indirect_thunk_array

------------------------------------------------
uuid: 2ee0e6a8-3c53-4672-ba59-73aef59b09f0
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
  - Expr: <BV64 0xffffffff81000000>
  - Range: 0xffffffff81000000
  - Independent Expr: <BV64 0xffffffff81000000>
  - Independent Range: 0xffffffff81000000
Transmission:
  - Expr: <BV64 0xffffffff81000000 + LOAD_64[<BV64 rdi>]_20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rdi>}
Constraints: []
Branches: [('0x4000007', <Bool rax == 0x0>, 'Taken')]
------------------------------------------------
