--------------------- HALF GADGET ----------------------
         alias_partially_independent:
4000000  mov     esi, edi
4000002  add     rsi, r12
4000005  mov     rax, qword ptr [r12+0x28] ; {Attacker@r12} -> {Attacker@0x4000005}
400000a  mov     r9, qword ptr [rsi+rax] ; {Attacker@r12, Attacker@rdi, Attacker@0x4000005} -> HALF GADGET
400000e  mov     esi, edi
4000010  add     rsi, r12
4000013  mov     eax, dword ptr [r12+0x28]
4000018  mov     r10, qword ptr [rsi+rax]
400001c  mov     esi, edi
400001e  add     rsi, qword ptr [r12+0x20]
4000023  mov     rax, qword ptr [r12+0x28]
4000028  mov     r11, qword ptr [rsi+rax]
400002c  jmp     0x400dead

------------------------------------------------
uuid: f9a4bb58-8361-4064-8245-3660db47e75e

Expr: <BV64 (0#32 .. rdi[31:0]) + r12 + LOAD_64[<BV64 r12 + 0x28>]_20>
Base: None
Attacker: <BV64 (0#32 .. rdi[31:0]) + r12 + LOAD_64[<BV64 r12 + 0x28>]_20>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
