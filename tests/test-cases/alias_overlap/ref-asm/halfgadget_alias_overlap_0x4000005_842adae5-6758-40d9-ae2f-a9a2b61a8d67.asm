--------------------- HALF GADGET ----------------------
         alias_type_2:
4000000  movzx   r8d, word ptr [rdx+0x28]
4000005  mov     rax, qword ptr [rdx+0x20] ; {Attacker@rdx} -> HALF GADGET
4000009  mov     rcx, qword ptr [rax]
400000c  mov     r11, qword ptr [rcx+r8]
4000010  movzx   r9d, word ptr [rdx+0x24]
4000015  mov     rbx, qword ptr [rdx+0x20]
4000019  mov     rsi, qword ptr [rbx]
400001c  mov     r12, qword ptr [rsi+r9]
4000020  jmp     0x400dead

------------------------------------------------
uuid: 842adae5-6758-40d9-ae2f-a9a2b61a8d67

Expr: <BV64 0x20 + rdx>
Base: <BV64 0x20>
Attacker: <BV64 rdx>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
