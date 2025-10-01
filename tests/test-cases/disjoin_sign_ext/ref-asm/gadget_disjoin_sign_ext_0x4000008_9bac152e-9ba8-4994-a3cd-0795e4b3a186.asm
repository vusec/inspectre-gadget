----------------- TRANSMISSION -----------------
         disjoin_sign_extend:
4000000  movsxd  rax, dword ptr [rcx+0x4] ; {Attacker@rcx} -> {Secret@0x4000000}
4000004  movzx   rsi, word ptr [rdi] ; {Attacker@rdi} -> {Attacker@0x4000004}
4000008  mov     rdx, qword ptr [rax+rsi+0x4096] ; {Secret@0x4000000, Attacker@0x4000004} -> TRANSMISSION
4000010  jmp     0x400dead

------------------------------------------------
uuid: 9bac152e-9ba8-4994-a3cd-0795e4b3a186
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 rcx + 0x4>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#32 .. LOAD_32[<BV64 rcx + 0x4>]_20>
  - Range: (0x0,0x7fffffff, 0x1) Exact: True
  - Spread: 0 - 31
  - Number of Bits Inferable: 32
Base:
  - Expr: <BV64 0x4096 + (0#48 .. LOAD_16[<BV64 rdi>]_21)>
  - Range: (0x4096,0x14095, 0x1) Exact: True
  - Independent Expr: <BV64 0x4096 + (0#48 .. LOAD_16[<BV64 rdi>]_21)>
  - Independent Range: (0x4096,0x14095, 0x1) Exact: True
Transmission:
  - Expr: <BV64 0x4096 + (0#32 .. LOAD_32[<BV64 rcx + 0x4>]_20) + (0#48 .. LOAD_16[<BV64 rdi>]_21)>
  - Range: (0x4096,0x80014094, 0x1) Exact: False

Register Requirements: {<BV64 rcx>, <BV64 rdi>}
Constraints: [('0x4000000', <Bool LOAD_32[<BV64 rcx + 0x4>]_20[31:31] == 0>, 'ConditionType.SIGN_EXT')]
Branches: []
------------------------------------------------
