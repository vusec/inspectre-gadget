--------------------- HALF GADGET ----------------------
         store_half_overlap:
4000000  mov     dword ptr [r8], esi
4000003  mov     rdi, qword ptr [r8]
4000006  movzx   r11, word ptr [rdx] ; {Attacker@rdx} -> HALF GADGET
400000a  mov     rdi, qword ptr [r11+rdi-0x7f000000]
4000012  jmp     0x400dead

------------------------------------------------
uuid: 1916bc08-2995-4077-bd48-944e67bd5b2d

Expr: <BV64 rdx>
Base: None
Attacker: <BV64 rdx>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
