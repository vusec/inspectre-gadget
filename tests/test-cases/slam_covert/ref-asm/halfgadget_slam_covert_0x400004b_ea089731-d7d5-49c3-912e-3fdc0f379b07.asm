--------------------- HALF GADGET ----------------------
         multiple_bb:
4000000  cmp     r8, 0x0
4000004  je      trans1 ; Not Taken   <Bool r8 != 0x0>
4000006  cmp     r8, 0x1
400000a  je      trans2 ; Not Taken   <Bool r8 != 0x1>
400000c  cmp     r8, 0x2
4000010  je      trans3 ; Taken   <Bool r8 == 0x2>
         trans3:
400004b  mov     r9, qword ptr [rdi] ; {Attacker@rdi} -> HALF GADGET
400004e  mov     r10, qword ptr [r9-0x7f000000]
4000055  jmp     end

------------------------------------------------
uuid: ea089731-d7d5-49c3-912e-3fdc0f379b07

Expr: <BV64 rdi>
Base: None
Attacker: <BV64 rdi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: [('0x4000004', <Bool r8 != 0x0>, 'Not Taken'), ('0x400000a', <Bool r8 != 0x1>, 'Not Taken'), ('0x4000010', <Bool r8 == 0x2>, 'Taken')]


------------------------------------------------
