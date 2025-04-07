--------------------- HALF GADGET ----------------------
         constraints_isolater:
4000000  mov     r8, qword ptr [rdi]
4000003  movzx   r9, word ptr [rdi]
4000007  mov     r10, qword ptr [r9-0x7f000000]
400000e  movzx   rax, word ptr [rdi+0x4] ; {Attacker@rdi} -> HALF GADGET
4000013  mov     r11, qword ptr [rax-0x7f000000]
400001a  mov     ebx, dword ptr [rdi+0x4]
400001d  mov     r12, qword ptr [rbx-0x7f000000]
4000024  mov     rcx, qword ptr [rdi+0x4]
4000028  mov     r13, qword ptr [rcx-0x7f000000]
400002f  mov     r14, qword ptr [r9+r12]
4000033  jmp     0x400dead

------------------------------------------------
uuid: c86648bb-e4d7-4fd7-ba66-ebd73a1f873b

Expr: <BV64 0x4 + rdi>
Base: <BV64 0x4>
Attacker: <BV64 rdi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
