--------------------- HALF GADGET ----------------------
         secret_stored_in_mem:
4000000  mov     r8d, dword ptr [rsi] ; {Attacker@rsi} -> HALF GADGET
4000003  mov     rdx, 0xffffffff82000000
400000a  mov     qword ptr [rdx], r8
400000d  mov     r10, qword ptr [rdx]
4000010  and     r10, 0xffff
4000017  mov     rcx, qword ptr [r10-0x7f000000]
400001e  movzx   r11, word ptr [rdx]
4000022  mov     rdi, qword ptr [r11-0x7f000000]
4000029  jmp     0x400dead

------------------------------------------------
uuid: 35a9ce7a-6348-444d-86fa-83d2d89791fd

Expr: <BV64 rsi>
Base: None
Attacker: <BV64 rsi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
