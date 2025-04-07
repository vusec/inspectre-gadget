--------------------- HALF GADGET ----------------------
         tfp_independently_controllable:
4000000  mov     rsi, qword ptr [rdi]
4000003  mov     rdx, qword ptr [rdx] ; {Attacker@rdx} -> HALF GADGET
4000006  mov     rbx, qword ptr [rsi]
4000009  add     rcx, rsi
400000c  add     rcx, rdx
400000f  mov     rax, qword ptr [rdi+0x10]
4000013  call    rax

------------------------------------------------
uuid: 7284c56f-cf8e-4743-a2d4-23e915f39b5a

Expr: <BV64 rdx>
Base: None
Attacker: <BV64 rdx>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
