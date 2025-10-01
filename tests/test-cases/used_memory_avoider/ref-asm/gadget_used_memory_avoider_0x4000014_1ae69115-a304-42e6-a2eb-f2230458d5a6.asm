----------------- TRANSMISSION -----------------
         used_memory_avoider:
4000000  mov     qword ptr [rcx], 0xff
4000007  mov     r8, qword ptr [rdi] ; {Attacker@rdi} -> {Attacker@0x4000007}
400000a  and     r8, 0xffff
4000011  mov     r9, qword ptr [rsi] ; {Attacker@rsi} -> {Secret@0x4000011}
4000014  mov     r10, qword ptr [r8+r9] ; {Secret@0x4000011, Attacker@0x4000007} -> TRANSMISSION
4000018  jmp     0x400dead

------------------------------------------------
uuid: 1ae69115-a304-42e6-a2eb-f2230458d5a6
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 rsi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rsi>]_22>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: <BV64 0#48 .. LOAD_64[<BV64 rdi>]_21[15:0]>
  - Range: (0x0,0xffff, 0x1) Exact: True
  - Independent Expr: <BV64 0#48 .. LOAD_64[<BV64 rdi>]_21[15:0]>
  - Independent Range: (0x0,0xffff, 0x1) Exact: True
Transmission:
  - Expr: <BV64 (0#48 .. LOAD_64[<BV64 rdi>]_21[15:0]) + LOAD_64[<BV64 rsi>]_22>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rdi>, <BV64 rsi>}
Constraints: []
Branches: []
------------------------------------------------
