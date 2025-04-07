----------------- TRANSMISSION -----------------
         tainted_func_ptr:
4000000  mov     rsi, qword ptr [rdi] ; {Attacker@rdi} -> {Secret@0x4000000}
4000003  mov     rax, qword ptr [rcx+rsi] ; {Attacker@rcx, Secret@0x4000000} -> TRANSMISSION
4000007  mov     rcx, qword ptr [rdi+0x20]
400000b  mov     r12, qword ptr [r8]
400000e  xor     r8, r8
4000011  shl     rax, 0x2
4000015  jmp     __x86_indirect_thunk_array

------------------------------------------------
uuid: efc84a78-01c8-4fe3-aebc-2916b81ddce8
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
  - Expr: <BV64 rcx>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Independent Expr: <BV64 rcx>
  - Independent Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmission:
  - Expr: <BV64 rcx + LOAD_64[<BV64 rdi>]_20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rdi>, <BV64 rcx>}
Constraints: []
Branches: []
------------------------------------------------
