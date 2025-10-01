--------------------- HALF GADGET ----------------------
         half_spectre:
4000000  mov     rsi, qword ptr [rdi]
4000003  mov     r10, qword ptr [eax-0x7f000000]
400000b  mov     r11, qword ptr [0xffffffff81000000] ; set() -> {UncontrolledLoad@0x400000b}
4000013  add     r11, rax
4000016  mov     r12, qword ptr [r11] ; {UncontrolledLoad@0x400000b, Attacker@rax} -> HALF GADGET
         end:
4000019  jmp     0x400dead

------------------------------------------------
uuid: 96147c1f-3ce2-417e-b836-d0ea30287fcb

Expr: <BV64 LOAD_64[<BV64 0xffffffff81000000>]_22 + rax>
Base: <BV64 LOAD_64[<BV64 0xffffffff81000000>]_22>
Attacker: <BV64 rax>
ControlType: ControlType.REQUIRES_MEM_LEAK

Constraints: []
Branches: []


------------------------------------------------
