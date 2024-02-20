----------------- TRANSMISSION -----------------
         alias_type_1:
4000000  movzx   r8d, word ptr [rdi] ; {Attacker@rdi} -> {Secret@0x4000000}
4000004  mov     rcx, qword ptr [r8-0x20] ; {Secret@0x4000000} -> TRANSMISSION
4000008  mov     r10, qword ptr [rdi+r8+0x50]
400000d  mov     r11, qword ptr [rsi]
4000010  movzx   r9d, word ptr [r11]
4000014  mov     rax, qword ptr [r11+r9+0x20]
4000019  jmp     0x400dead

------------------------------------------------
uuid: 30c1054d-961f-424b-8613-62d0e574dc4e
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 rdi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#48 .. LOAD_16[<BV64 rdi>]_20>
  - Range: (0x0,0xffff, 0x1) Exact: True
  - Spread: 0 - 15
  - Number of Bits Inferable: 16
Base:
  - Expr: <BV64 0xffffffffffffffe0>
  - Range: 0xffffffffffffffe0
  - Independent Expr: <BV64 0xffffffffffffffe0>
  - Independent Range: 0xffffffffffffffe0
Transmission:
  - Expr: <BV64 0xffffffffffffffe0 + (0#48 .. LOAD_16[<BV64 rdi>]_20)>
  - Range: (0xffffffffffffffe0,0xffdf, 0x1) Exact: True

Register Requirements: {<BV64 rdi>}
Constraints: []
Branches: []
------------------------------------------------
