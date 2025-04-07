--------------------- HALF GADGET ----------------------
         half_spectre:
4000000  mov     rsi, qword ptr [rdi] ; {Attacker@rdi} -> HALF GADGET
4000003  mov     r10, qword ptr [eax-0x7f000000]
400000b  mov     r11, qword ptr [0xffffffff81000000]
4000013  add     r11, rax
4000016  mov     r12, qword ptr [r11]
         end:
4000019  jmp     0x400dead

------------------------------------------------
uuid: 241a1f76-3123-4c19-ac96-489a8a1c83f4

Expr: <BV64 rdi>
Base: None
Attacker: <BV64 rdi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
