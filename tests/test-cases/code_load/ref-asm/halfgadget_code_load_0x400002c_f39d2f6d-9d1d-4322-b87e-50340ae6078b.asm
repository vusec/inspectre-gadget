--------------------- HALF GADGET ----------------------
         code_load:
4000000  cmp     r8, 0x0
4000004  je      trans1 ; Not Taken   <Bool r8 != 0x0>
4000006  cmp     r8, 0x1
400000a  je      trans2 ; Not Taken   <Bool r8 != 0x1>
400000c  cmp     r8, 0x2
4000010  je      trans3 ; Taken   <Bool r8 == 0x2>
         trans3:
400002c  jmp     qword ptr [rdi] ; {Attacker@rdi} -> HALF GADGET

------------------------------------------------
uuid: f39d2f6d-9d1d-4322-b87e-50340ae6078b

Expr: <BV64 rdi>
Base: None
Attacker: <BV64 rdi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: [('0x4000004', <Bool r8 != 0x0>, 'Not Taken'), ('0x400000a', <Bool r8 != 0x1>, 'Not Taken'), ('0x4000010', <Bool r8 == 0x2>, 'Taken')]


------------------------------------------------
