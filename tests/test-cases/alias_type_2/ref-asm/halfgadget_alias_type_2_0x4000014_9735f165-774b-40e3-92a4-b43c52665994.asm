--------------------- HALF GADGET ----------------------
         alias_type_2:
4000000  movzx   r8d, word ptr [rdi+0x100]
4000008  mov     rsi, qword ptr [rdi]
400000b  mov     r10, qword ptr [rsi+r8]
400000f  movzx   r8d, word ptr [rdx+0x28]
4000014  mov     rax, qword ptr [rdx+0x20] ; {Attacker@rdx} -> HALF GADGET
4000018  mov     rsi, qword ptr [rax]
400001b  mov     r11, qword ptr [rsi+r8]
400001f  mov     rax, qword ptr [rdi+0x200]
4000026  mov     rsi, qword ptr [rdi+0x240]
400002d  movzx   r8d, word ptr [rax]
4000031  mov     r13, qword ptr [rsi+r8]
4000035  jmp     0x400dead

------------------------------------------------
uuid: 9735f165-774b-40e3-92a4-b43c52665994

Expr: <BV64 0x20 + rdx>
Base: <BV64 0x20>
Attacker: <BV64 rdx>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
