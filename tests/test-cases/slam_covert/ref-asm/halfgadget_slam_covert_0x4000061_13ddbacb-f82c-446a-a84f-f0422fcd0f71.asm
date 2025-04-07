--------------------- HALF GADGET ----------------------
         multiple_bb:
4000000  cmp     r8, 0x0
4000004  je      trans1 ; Not Taken   <Bool r8 != 0x0>
4000006  cmp     r8, 0x1
400000a  je      trans2 ; Not Taken   <Bool r8 != 0x1>
400000c  cmp     r8, 0x2
4000010  je      trans3 ; Not Taken   <Bool r8 != 0x2>
4000012  cmp     r8, 0x3
4000016  je      trans4_5 ; Taken   <Bool r8 == 0x3>
         trans4_5:
4000057  mov     r9, qword ptr [rdi]
400005a  shl     r9, 0x9
400005e  mov     r10, qword ptr [r9]
4000061  mov     r9d, dword ptr [rdi] ; {Attacker@rdi} -> HALF GADGET
4000064  mov     r11, qword ptr [r9-0x7f000000]
400006b  jmp     end

------------------------------------------------
uuid: 13ddbacb-f82c-446a-a84f-f0422fcd0f71

Expr: <BV64 rdi>
Base: None
Attacker: <BV64 rdi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: [('0x4000004', <Bool r8 != 0x0>, 'Not Taken'), ('0x400000a', <Bool r8 != 0x1>, 'Not Taken'), ('0x4000010', <Bool r8 != 0x2>, 'Not Taken'), ('0x4000016', <Bool r8 == 0x3>, 'Taken')]


------------------------------------------------
