----------------- TRANSMISSION -----------------
         uncontrolled_stored_in_mem:
4000000  mov     dword ptr [rdx], 0x7000000
4000006  mov     r8d, dword ptr [rdx]
4000009  mov     r9, qword ptr [rdi+0xff]
4000010  and     r9, 0xffff
4000017  mov     r10, qword ptr [r8+r9-0x7f000000]
400001f  mov     dword ptr [rsi], 0x0
4000025  mov     r9d, dword ptr [rsi]
4000028  and     r9, 0xffff
400002f  mov     r11, qword ptr [r9-0x7f000000]
4000036  mov     rdx, 0xffffffff85000000
400003d  mov     rax, qword ptr [rdx] ; set() > {MaybeAttacker@0x400003d}
4000040  mov     rbx, qword ptr [rax] ; {MaybeAttacker@0x400003d} > {Secret@0x4000040}
4000043  mov     r14, qword ptr [rcx+rbx] ; {Secret@0x4000040, Attacker@rcx} > TRANSMISSION
4000047  jmp     0x400dead

------------------------------------------------
uuid: 44e93470-4a39-4c8e-bbe5-1a7bb083961b

Secret Address:
  - Expr: <BV64 LOAD_64[<BV64 0xffffffff85000000>]_27>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 LOAD_64[<BV64 0xffffffff85000000>]_27>]_28>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: <BV64 rcx>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Independent Expr: <BV64 rcx>
  - Independent Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmission:
  - Expr: <BV64 rcx + LOAD_64[<BV64 LOAD_64[<BV64 0xffffffff85000000>]_27>]_28>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rcx>}
Constraints: []
Branches: []
------------------------------------------------
