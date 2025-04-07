--------------------- HALF GADGET ----------------------
         alias_type_1:
4000000  movzx   r8d, word ptr [rdi] ; {Attacker@rdi} -> {Attacker@0x4000000}
4000004  mov     rcx, qword ptr [r8-0x20]
4000008  mov     r10, qword ptr [rdi+r8+0x50] ; {Attacker@rdi, Attacker@0x4000000} -> HALF GADGET
400000d  mov     r11, qword ptr [rsi]
4000010  movzx   r9d, word ptr [r11]
4000014  mov     rax, qword ptr [r11+r9+0x20]
4000019  jmp     0x400dead

------------------------------------------------
uuid: ec8b1469-7775-4d25-9654-312dcd8ce3e0

Expr: <BV64 0x50 + rdi + (0#48 .. LOAD_16[<BV64 rdi>]_20)>
Base: <BV64 0x50>
Attacker: <BV64 rdi + (0#48 .. LOAD_16[<BV64 rdi>]_20)>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
