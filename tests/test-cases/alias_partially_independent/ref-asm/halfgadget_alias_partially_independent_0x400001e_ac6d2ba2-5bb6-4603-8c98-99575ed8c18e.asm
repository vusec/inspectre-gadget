--------------------- HALF GADGET ----------------------
         alias_partially_independent:
4000000  mov     esi, edi
4000002  add     rsi, r12
4000005  mov     rax, qword ptr [r12+0x28]
400000a  mov     r9, qword ptr [rsi+rax]
400000e  mov     esi, edi
4000010  add     rsi, r12
4000013  mov     eax, dword ptr [r12+0x28]
4000018  mov     r10, qword ptr [rsi+rax]
400001c  mov     esi, edi
400001e  add     rsi, qword ptr [r12+0x20] ; {Attacker@r12} -> HALF GADGET
4000023  mov     rax, qword ptr [r12+0x28]
4000028  mov     r11, qword ptr [rsi+rax]
400002c  jmp     0x400dead

------------------------------------------------
uuid: ac6d2ba2-5bb6-4603-8c98-99575ed8c18e

Expr: <BV64 0x20 + r12>
Base: <BV64 0x20>
Attacker: <BV64 r12>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
