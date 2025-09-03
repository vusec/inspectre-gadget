--------------------- HALF GADGET ----------------------
         store_half_overlap:
4000000  mov     dword ptr [r8], esi
4000003  mov     rdi, qword ptr [r8] ; {Attacker@r8} -> HALF GADGET
4000006  movzx   r11, word ptr [rdx]
400000a  mov     rdi, qword ptr [r11+rdi-0x7f000000]
4000012  jmp     0x400dead

------------------------------------------------
uuid: 0e4c8bc1-80fb-44a8-aa64-9cea2e7a0d9a

Expr: <BV64 r8>
Base: None
Attacker: <BV64 r8>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
