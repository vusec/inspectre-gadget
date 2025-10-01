--------------------- HALF GADGET ----------------------
         half_spectre:
4000000  mov     rsi, qword ptr [rdi]
4000003  mov     r10, qword ptr [eax-0x7f000000] ; {Attacker@rax} -> HALF GADGET
400000b  mov     r11, qword ptr [0xffffffff81000000]
4000013  add     r11, rax
4000016  mov     r12, qword ptr [r11]
         end:
4000019  jmp     0x400dead

------------------------------------------------
uuid: 8ab60300-cd24-4056-afd1-36a105eb7d68

Expr: <BV64 0#32 .. 0x81000000 + rax[31:0]>
Base: <BV64 0x81000000>
Attacker: <BV64 0#32 .. rax[31:0]>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
