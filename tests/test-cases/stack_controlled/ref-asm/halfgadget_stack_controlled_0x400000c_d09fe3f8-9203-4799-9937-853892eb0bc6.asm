--------------------- HALF GADGET ----------------------
         stack_controlled:
4000000  pop     rdi
4000001  pop     rsi
4000002  pop     rdx
4000003  pop     rcx
4000004  movzx   r10, word ptr [rdx+0xff] ; {Attacker@rsp_16} -> {Attacker@0x4000004}
400000c  mov     r11, qword ptr [rcx+r10] ; {Attacker@rsp_24, Attacker@0x4000004} -> HALF GADGET
4000010  jmp     0x400dead

------------------------------------------------
uuid: d09fe3f8-9203-4799-9937-853892eb0bc6

Expr: <BV64 rsp_24 + (0#48 .. LOAD_16[<BV64 rsp_16 + 0xff>]_24)>
Base: None
Attacker: <BV64 rsp_24 + (0#48 .. LOAD_16[<BV64 rsp_16 + 0xff>]_24)>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
