--------------------- HALF GADGET ----------------------
         code_load:
4000000  cmp     r8, 0x0
4000004  je      trans1 ; Taken   <Bool r8 == 0x0>
         trans1:
400001c  mov     rax, qword ptr [rdi] ; {Attacker@rdi} -> HALF GADGET
400001f  jmp     rax

------------------------------------------------
uuid: eb9fba51-0df5-4339-875e-860c2a34a6a2

Expr: <BV64 rdi>
Base: None
Attacker: <BV64 rdi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: [('0x4000004', <Bool r8 == 0x0>, 'Taken')]


------------------------------------------------
