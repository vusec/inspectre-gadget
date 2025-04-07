--------------------- HALF GADGET ----------------------
         complex_transmission:
4000000  mov     r8, qword ptr [rdi]
4000003  mov     r9, qword ptr [rsi]
4000006  add     r9, r8
4000009  shl     r9, 0x6
400000d  mov     r10, qword ptr [r9]
4000010  mov     r8, qword ptr [rdi] ; {Attacker@rdi} -> HALF GADGET
4000013  mov     r9, qword ptr [rsi]
4000016  mov     rax, 0x8
400001d  mul     r8
4000020  mov     r11, qword ptr [rax]
4000023  mov     rax, r8
4000026  mul     r9
4000029  mov     r12, qword ptr [rax]
400002c  mov     rax, r8
400002f  mul     rdi
4000032  mov     r13, qword ptr [rax]
4000035  jmp     0x400dead

------------------------------------------------
uuid: df63fc26-83dd-4305-952a-062459af736c

Expr: <BV64 rdi>
Base: None
Attacker: <BV64 rdi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
