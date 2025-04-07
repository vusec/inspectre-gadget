--------------------- HALF GADGET ----------------------
         alias_type_1:
4000000  movzx   r8d, word ptr [rdi] ; {Attacker@rdi} -> HALF GADGET
4000004  mov     rcx, qword ptr [r8-0x20]
4000008  mov     r10, qword ptr [rdi+r8+0x50]
400000d  mov     r11, qword ptr [rsi]
4000010  movzx   r9d, word ptr [r11]
4000014  mov     rax, qword ptr [r11+r9+0x20]
4000019  jmp     0x400dead

------------------------------------------------
uuid: a017000c-d233-4626-8324-31242aa70f29

Expr: <BV64 rdi>
Base: None
Attacker: <BV64 rdi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
