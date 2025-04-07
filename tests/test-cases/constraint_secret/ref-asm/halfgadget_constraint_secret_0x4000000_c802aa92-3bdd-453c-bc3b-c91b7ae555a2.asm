--------------------- HALF GADGET ----------------------
         constraint_secret:
4000000  movzx   r9, word ptr [rdi] ; {Attacker@rdi} -> HALF GADGET
4000004  cmp     r9, 0xffff
400000b  ja      trans1

------------------------------------------------
uuid: c802aa92-3bdd-453c-bc3b-c91b7ae555a2

Expr: <BV64 rdi>
Base: None
Attacker: <BV64 rdi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
