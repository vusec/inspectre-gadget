--------------------- HALF GADGET ----------------------
         multiple_bb:
4000000  mov     r8, qword ptr [rdi] ; {Attacker@rdi} -> HALF GADGET
4000003  movzx   r9, word ptr [rdi]
4000007  cmp     rax, 0x0
400000b  je      trans1

------------------------------------------------
uuid: e23ac214-0a91-4dbb-bea0-25e3e9047aaa

Expr: <BV64 rdi>
Base: None
Attacker: <BV64 rdi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
