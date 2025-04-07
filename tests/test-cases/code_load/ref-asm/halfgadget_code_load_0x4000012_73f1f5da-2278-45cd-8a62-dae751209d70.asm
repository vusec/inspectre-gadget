--------------------- HALF GADGET ----------------------
         code_load:
4000000  cmp     r8, 0x0
4000004  je      trans1 ; Not Taken   <Bool r8 != 0x0>
4000006  cmp     r8, 0x1
400000a  je      trans2 ; Not Taken   <Bool r8 != 0x1>
400000c  cmp     r8, 0x2
4000010  je      trans3 ; Not Taken   <Bool r8 != 0x2>
         trans0:
4000012  movzx   rsi, word ptr [rdi] ; {Attacker@rdi} -> HALF GADGET
4000016  lea     rax, [rdx+rsi]
400001a  jmp     rax

------------------------------------------------
uuid: 73f1f5da-2278-45cd-8a62-dae751209d70

Expr: <BV64 rdi>
Base: None
Attacker: <BV64 rdi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: [('0x4000004', <Bool r8 != 0x0>, 'Not Taken'), ('0x400000a', <Bool r8 != 0x1>, 'Not Taken'), ('0x4000010', <Bool r8 != 0x2>, 'Not Taken')]


------------------------------------------------
