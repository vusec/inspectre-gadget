----------------- TRANSMISSION -----------------
         tainted_func_ptr:
4000000  mov     rsi, qword ptr [rdi] ; {Attacker@rdi} -> {Attacker@0x4000000}
4000003  mov     rax, qword ptr [rcx+rsi] ; {Attacker@0x4000000, Attacker@rcx} -> {Secret@0x4000003}
4000007  mov     rcx, qword ptr [rdi+0x20]
400000b  mov     r12, qword ptr [r8]
400000e  xor     r8, r8
4000011  shl     rax, 0x2
4000015  jmp     __x86_indirect_thunk_array ; {Secret@0x4000003} -> TRANSMISSION

------------------------------------------------
uuid: 339e1c2e-29eb-4720-b79d-ffd2734eb0ef
transmitter: TransmitterType.CODE_LOAD

Secret Address:
  - Expr: <BV64 rcx + LOAD_64[<BV64 rdi>]_20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 (0#2 .. LOAD_64[<BV64 rcx + LOAD_64[<BV64 rdi>]_20>]_21[61:0]) << 0x2>
  - Range: (0x0,0xfffffffffffffffc, 0x4) Exact: True
  - Spread: 2 - 63
  - Number of Bits Inferable: 62
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 (0#2 .. LOAD_64[<BV64 rcx + LOAD_64[<BV64 rdi>]_20>]_21[61:0]) << 0x2>
  - Range: (0x0,0xfffffffffffffffc, 0x4) Exact: True

Register Requirements: {<BV64 rdi>, <BV64 rcx>}
Constraints: []
Branches: []
------------------------------------------------
