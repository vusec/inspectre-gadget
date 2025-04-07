--------------------- HALF GADGET ----------------------
         tfp_multiple_bb:
4000000  mov     r8, qword ptr [rdi] ; {Attacker@rdi} -> HALF GADGET
4000003  cmp     rax, 0x0
4000007  je      tfp0

------------------------------------------------
uuid: 0c8111e1-d114-412c-a6cc-83e89bb68654

Expr: <BV64 rdi>
Base: None
Attacker: <BV64 rdi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
