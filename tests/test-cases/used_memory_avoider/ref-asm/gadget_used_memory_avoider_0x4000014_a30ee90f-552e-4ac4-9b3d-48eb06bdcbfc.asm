----------------- TRANSMISSION -----------------
         used_memory_avoider:
4000000  mov     qword ptr [rcx], 0xff
4000007  mov     r8, qword ptr [rdi] ; {Attacker@rdi} > {Secret@0x4000007}
400000a  and     r8, 0xffff
4000011  mov     r9, qword ptr [rsi] ; {Attacker@rsi} > {Attacker@0x4000011}
4000014  mov     r10, qword ptr [r8+r9] ; {Secret@0x4000007, Attacker@0x4000011} > TRANSMISSION
4000018  jmp     0x400dead

------------------------------------------------
uuid: a30ee90f-552e-4ac4-9b3d-48eb06bdcbfc

Secret Address:
  - Expr: <BV64 rdi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#48 .. LOAD_64[<BV64 rdi>]_21[15:0]>
  - Range: (0x0,0xffff, 0x1) Exact: True
  - Spread: 0 - 15
  - Number of Bits Inferable: 16
Base:
  - Expr: <BV64 LOAD_64[<BV64 rsi>]_22>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Independent Expr: <BV64 LOAD_64[<BV64 rsi>]_22>
  - Independent Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmission:
  - Expr: <BV64 (0#48 .. LOAD_64[<BV64 rdi>]_21[15:0]) + LOAD_64[<BV64 rsi>]_22>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rsi>, <BV64 rdi>}
Constraints: []
Branches: []
------------------------------------------------
