--------------------- HALF GADGET ----------------------
         code_load:
4000000  cmp     r8, 0x0
4000004  je      trans1 ; Not Taken   <Bool r8 != 0x0>
4000006  cmp     r8, 0x1
400000a  je      trans2 ; Taken   <Bool r8 == 0x1>
         trans2:
4000021  movzx   rax, word ptr [rdi] ; {Attacker@rdi} -> HALF GADGET
4000025  jmp     qword ptr [rax*0x8-0x7f000000]

------------------------------------------------
uuid: c499ac79-691f-4e84-8dcb-a971301d15d1

Expr: <BV64 rdi>
Base: None
Attacker: <BV64 rdi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: [('0x4000004', <Bool r8 != 0x0>, 'Not Taken'), ('0x400000a', <Bool r8 == 0x1>, 'Taken')]


------------------------------------------------
