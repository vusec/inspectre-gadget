----------------- TRANSMISSION -----------------
         constraints_isolater:
4000000  mov     r8, qword ptr [rdi]
4000003  movzx   r9, word ptr [rdi] ; {Attacker@rdi} > {Secret@0x4000003}
4000007  mov     r10, qword ptr [r9-0x7f000000]
400000e  movzx   rax, word ptr [rdi+0x4]
4000013  mov     r11, qword ptr [rax-0x7f000000]
400001a  mov     ebx, dword ptr [rdi+0x4] ; {Attacker@rdi} > {Attacker@0x400001a}
400001d  mov     r12, qword ptr [rbx-0x7f000000] ; {Attacker@0x400001a} > {Attacker@0x400001d}
4000024  mov     rcx, qword ptr [rdi+0x4]
4000028  mov     r13, qword ptr [rcx-0x7f000000]
400002f  mov     r14, qword ptr [r9+r12] ; {Secret@0x4000003, Attacker@0x400001d} > TRANSMISSION
4000033  jmp     0x400dead

------------------------------------------------
uuid: 01b8b392-a151-4e50-a5be-2f856e3149f8

Secret Address:
  - Expr: <BV64 rdi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 (0#48 .. LOAD_16[<BV64 rdi>]_21) + LOAD_64[<BV64 (0#32 .. LOAD_32[<BV64 rdi + 0x4>]_25) + 0xffffffff81000000>]_26>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 16
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 (0#48 .. LOAD_16[<BV64 rdi>]_21) + LOAD_64[<BV64 (0#32 .. LOAD_32[<BV64 rdi + 0x4>]_25) + 0xffffffff81000000>]_26>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rdi>}
Constraints: []
Branches: []
------------------------------------------------
