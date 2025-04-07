--------------------- HALF GADGET ----------------------
         tfp_independently_controllable:
4000000  mov     rsi, qword ptr [rdi] ; {Attacker@rdi} -> HALF GADGET
4000003  mov     rdx, qword ptr [rdx]
4000006  mov     rbx, qword ptr [rsi]
4000009  add     rcx, rsi
400000c  add     rcx, rdx
400000f  mov     rax, qword ptr [rdi+0x10]
4000013  call    rax

------------------------------------------------
uuid: e104432e-3b68-4891-88ea-769a64fc2e1e

Expr: <BV64 rdi>
Base: None
Attacker: <BV64 rdi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
