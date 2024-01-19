----------------- TRANSMISSION -----------------
         constraints_isolater:
4000000  mov     r8, qword ptr [rdi]
4000003  movzx   r9, word ptr [rdi]
4000007  mov     r10, qword ptr [r9-0x7f000000]
400000e  movzx   rax, word ptr [rdi+0x4]
4000013  mov     r11, qword ptr [rax-0x7f000000]
400001a  mov     ebx, dword ptr [rdi+0x4] ; {Attacker@rdi} > {Secret@0x400001a}
400001d  mov     r12, qword ptr [rbx-0x7f000000] ; {Secret@0x400001a} > TRANSMISSION
4000024  mov     rcx, qword ptr [rdi+0x4]
4000028  mov     r13, qword ptr [rcx-0x7f000000]
400002f  mov     r14, qword ptr [r9+r12]
4000033  jmp     0x400dead

------------------------------------------------
uuid: 59d18a9d-d2bb-40fc-af9e-0ea2b16e57cc

Secret Address:
  - Expr: <BV64 rdi + 0x4>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#32 .. LOAD_32[<BV64 rdi + 0x4>]_25>
  - Range: (0x0,0xffffffff, 0x1) Exact: True
  - Spread: 0 - 31
  - Number of Bits Inferable: 32
Base:
  - Expr: <BV64 0xffffffff81000000>
  - Range: 0xffffffff81000000
  - Independent Expr: <BV64 0xffffffff81000000>
  - Independent Range: 0xffffffff81000000
Transmission:
  - Expr: <BV64 0xffffffff81000000 + (0#32 .. LOAD_32[<BV64 rdi + 0x4>]_25)>
  - Range: (0xffffffff81000000,0x80ffffff, 0x1) Exact: True

Register Requirements: {<BV64 rdi>}
Constraints: []
Branches: []
------------------------------------------------
