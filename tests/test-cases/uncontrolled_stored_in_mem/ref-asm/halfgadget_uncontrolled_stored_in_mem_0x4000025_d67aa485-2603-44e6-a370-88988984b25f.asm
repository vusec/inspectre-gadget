--------------------- HALF GADGET ----------------------
         uncontrolled_stored_in_mem:
4000000  mov     dword ptr [rdx], 0x7000000
4000006  mov     r8d, dword ptr [rdx]
4000009  mov     r9, qword ptr [rdi+0xff]
4000010  and     r9, 0xffff
4000017  mov     r10, qword ptr [r8+r9-0x7f000000]
400001f  mov     dword ptr [rsi], 0x0
4000025  mov     r9d, dword ptr [rsi] ; {Attacker@rsi} -> HALF GADGET
4000028  and     r9, 0xffff
400002f  mov     r11, qword ptr [r9-0x7f000000]
4000036  mov     rdx, 0xffffffff85000000
400003d  mov     rax, qword ptr [rdx]
4000040  mov     rbx, qword ptr [rax]
4000043  mov     r14, qword ptr [rcx+rbx]
4000047  jmp     0x400dead

------------------------------------------------
uuid: d67aa485-2603-44e6-a370-88988984b25f

Expr: <BV64 rsi>
Base: None
Attacker: <BV64 rsi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
