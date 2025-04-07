----------------- TRANSMISSION -----------------
         sbb_instruction:
4000000  mov     rax, qword ptr [rdi+0x28] ; {Attacker@rdi} -> {Secret@0x4000000}
4000004  mov     ebx, eax
4000006  cmp     rbx, 0x10
400000a  sbb     rbx, rbx
400000d  and     ebx, eax
400000f  mov     r10, qword ptr [r9+rbx] ; {Attacker@r9, Secret@0x4000000} -> TRANSMISSION
4000013  jmp     0x400dead

------------------------------------------------
uuid: 5e04911a-d873-4fc8-a6de-050fd694dbed
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 rdi + 0x28>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#32 .. LOAD_64[<BV64 rdi + 0x28>]_20[31:0]>
  - Range: (0x0,0xf, 0x1) Exact: True
  - Spread: 0 - 31
  - Number of Bits Inferable: 32
Base:
  - Expr: <BV64 r9>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Independent Expr: <BV64 r9>
  - Independent Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmission:
  - Expr: <BV64 r9 + (0#32 .. LOAD_64[<BV64 rdi + 0x28>]_20[31:0])>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: False

Register Requirements: {<BV64 r9>, <BV64 rdi>}
Constraints: [('0x400000a', <Bool (0#32 .. LOAD_64[<BV64 rdi + 0x28>]_20[31:0]) < 0x10>, 'ConditionType.CMOVE')]
Branches: []
------------------------------------------------
