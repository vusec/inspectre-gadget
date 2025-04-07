--------------------- HALF GADGET ----------------------
         multiple_bb:
4000000  cmp     r8, 0x0
4000004  je      trans1 ; Not Taken   <Bool r8 != 0x0>
4000006  cmp     r8, 0x1
400000a  je      trans2 ; Taken   <Bool r8 == 0x1>
         trans2:
400003b  mov     r9, qword ptr [rdi] ; {Attacker@rdi} -> HALF GADGET
400003e  and     rax, 0xff
4000044  mov     r10, qword ptr [r9+rax+0x20]
4000049  jmp     end

------------------------------------------------
uuid: 03cee1df-14e8-45f0-9ddb-ac87d2a505ea

Expr: <BV64 rdi>
Base: None
Attacker: <BV64 rdi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: [('0x4000004', <Bool r8 != 0x0>, 'Not Taken'), ('0x400000a', <Bool r8 == 0x1>, 'Taken')]


------------------------------------------------
