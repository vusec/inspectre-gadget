--------------------- HALF GADGET ----------------------
         stack_controlled:
4000000  pop     rdi
4000001  pop     rsi
4000002  pop     rdx
4000003  pop     rcx
4000004  movzx   r10, word ptr [rdx+0xff] ; {Attacker@rsp_16} -> HALF GADGET
400000c  mov     r11, qword ptr [rcx+r10]
4000010  jmp     0x400dead

------------------------------------------------
uuid: 0d62ad64-2177-49af-8e36-5a0db3e4fca3

Expr: <BV64 0xff + rsp_16>
Base: <BV64 0xff>
Attacker: <BV64 rsp_16>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
