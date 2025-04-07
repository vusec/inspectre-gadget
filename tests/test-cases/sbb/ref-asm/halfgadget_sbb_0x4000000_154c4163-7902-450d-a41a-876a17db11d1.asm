--------------------- HALF GADGET ----------------------
         sbb_instruction:
4000000  mov     rax, qword ptr [rdi+0x28] ; {Attacker@rdi} -> HALF GADGET
4000004  mov     ebx, eax
4000006  cmp     rbx, 0x10
400000a  sbb     rbx, rbx
400000d  and     ebx, eax
400000f  mov     r10, qword ptr [r9+rbx]
4000013  jmp     0x400dead

------------------------------------------------
uuid: 154c4163-7902-450d-a41a-876a17db11d1

Expr: <BV64 0x28 + rdi>
Base: <BV64 0x28>
Attacker: <BV64 rdi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
