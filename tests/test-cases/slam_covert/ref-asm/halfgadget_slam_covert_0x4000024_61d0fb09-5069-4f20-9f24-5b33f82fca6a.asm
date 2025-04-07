--------------------- HALF GADGET ----------------------
         multiple_bb:
4000000  cmp     r8, 0x0
4000004  je      trans1 ; Taken   <Bool r8 == 0x0>
         trans1:
4000024  mov     r9, qword ptr [rdi] ; {Attacker@rdi} -> HALF GADGET
4000027  add     r9, 0x821
400002e  shl     r9, 0x10
4000032  add     r9, 0x33
4000036  mov     r10, qword ptr [r9]
4000039  jmp     end

------------------------------------------------
uuid: 61d0fb09-5069-4f20-9f24-5b33f82fca6a

Expr: <BV64 rdi>
Base: None
Attacker: <BV64 rdi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: [('0x4000004', <Bool r8 == 0x0>, 'Taken')]


------------------------------------------------
