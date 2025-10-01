----------------- TRANSMISSION -----------------
         constraints_isolater:
4000000  mov     r8, qword ptr [rdi]
4000003  movzx   r9, word ptr [rdi]
4000007  mov     r10, qword ptr [r9-0x7f000000]
400000e  movzx   rax, word ptr [rdi+0x4]
4000013  mov     r11, qword ptr [rax-0x7f000000]
400001a  mov     ebx, dword ptr [rdi+0x4]
400001d  mov     r12, qword ptr [rbx-0x7f000000]
4000024  mov     rcx, qword ptr [rdi+0x4] ; {Attacker@rdi} -> {Secret@0x4000024}
4000028  mov     r13, qword ptr [rcx-0x7f000000] ; {Secret@0x4000024} -> TRANSMISSION
400002f  mov     r14, qword ptr [r9+r12]
4000033  jmp     0x400dead

------------------------------------------------
uuid: cbe195f0-7fe9-471a-ac5d-43d38b00992c
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 rdi + 0x4>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rdi + 0x4>]_27>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: <BV64 0xffffffff81000000>
  - Range: 0xffffffff81000000
  - Independent Expr: <BV64 0xffffffff81000000>
  - Independent Range: 0xffffffff81000000
Transmission:
  - Expr: <BV64 0xffffffff81000000 + LOAD_64[<BV64 rdi + 0x4>]_27>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rdi>}
Constraints: []
Branches: []
------------------------------------------------
