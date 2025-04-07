--------------------- HALF GADGET ----------------------
         attack_stored_in_mem:
4000000  movabs  rdx, 0xffffffff70000000
400000a  mov     qword ptr [rdx], r8
400000d  mov     r10, qword ptr [rdx]
4000010  mov     rdi, qword ptr [r10+0xff] ; {Attacker@r8} -> HALF GADGET
4000017  and     rdi, 0xffff
400001e  mov     r10, qword ptr [rdi-0x7f000000]
4000025  jmp     0x400dead

------------------------------------------------
uuid: ea08cd6c-90a2-457d-a8f1-e2d136ee2a89

Expr: <BV64 0xff + r8>
Base: <BV64 0xff>
Attacker: <BV64 r8>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
