--------------------- HALF GADGET ----------------------
         multiple_bb:
4000000  cmp     r8, 0x0
4000004  je      trans1 ; Not Taken   <Bool r8 != 0x0>
4000006  cmp     r8, 0x1
400000a  je      trans2 ; Not Taken   <Bool r8 != 0x1>
400000c  cmp     r8, 0x2
4000010  je      trans3 ; Not Taken   <Bool r8 != 0x2>
4000012  cmp     r8, 0x3
4000016  je      trans4_5 ; Not Taken   <Bool r8 != 0x3>
         trans0:
4000018  mov     r9, qword ptr [rdi] ; {Attacker@rdi} -> HALF GADGET
400001b  mov     r10, qword ptr [r9+0x5890]
4000022  jmp     end

------------------------------------------------
uuid: 59bf37bd-19bf-463e-a982-efad6e21cfa4

Expr: <BV64 rdi>
Base: None
Attacker: <BV64 rdi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: [('0x4000004', <Bool r8 != 0x0>, 'Not Taken'), ('0x400000a', <Bool r8 != 0x1>, 'Not Taken'), ('0x4000010', <Bool r8 != 0x2>, 'Not Taken'), ('0x4000016', <Bool r8 != 0x3>, 'Not Taken')]


------------------------------------------------
