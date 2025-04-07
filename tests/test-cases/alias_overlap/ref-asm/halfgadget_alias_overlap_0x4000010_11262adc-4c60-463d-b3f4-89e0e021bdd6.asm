--------------------- HALF GADGET ----------------------
         alias_type_2:
4000000  movzx   r8d, word ptr [rdx+0x28]
4000005  mov     rax, qword ptr [rdx+0x20]
4000009  mov     rcx, qword ptr [rax]
400000c  mov     r11, qword ptr [rcx+r8]
4000010  movzx   r9d, word ptr [rdx+0x24] ; {Attacker@rdx} -> HALF GADGET
4000015  mov     rbx, qword ptr [rdx+0x20]
4000019  mov     rsi, qword ptr [rbx]
400001c  mov     r12, qword ptr [rsi+r9]
4000020  jmp     0x400dead

------------------------------------------------
uuid: 11262adc-4c60-463d-b3f4-89e0e021bdd6

Expr: <BV64 0x24 + rdx>
Base: <BV64 0x24>
Attacker: <BV64 rdx>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
