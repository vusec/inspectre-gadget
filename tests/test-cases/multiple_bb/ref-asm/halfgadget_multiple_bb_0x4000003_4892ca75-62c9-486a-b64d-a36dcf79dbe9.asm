--------------------- HALF GADGET ----------------------
         multiple_bb:
4000000  mov     r8, qword ptr [rdi]
4000003  movzx   r9, word ptr [rdi] ; {Attacker@rdi} -> HALF GADGET
4000007  cmp     rax, 0x0
400000b  je      trans1

------------------------------------------------
uuid: 4892ca75-62c9-486a-b64d-a36dcf79dbe9

Expr: <BV64 rdi>
Base: None
Attacker: <BV64 rdi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
