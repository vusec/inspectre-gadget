--------------------- HALF GADGET ----------------------
         speculation_stops:
4000000  movzx   r9, word ptr [rdi] ; {Attacker@rdi} -> HALF GADGET
4000004  cmp     rax, 0x0
4000008  je      trans1

------------------------------------------------
uuid: 245758ba-452d-48a5-94fc-f591fbe7bb4e

Expr: <BV64 rdi>
Base: None
Attacker: <BV64 rdi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
