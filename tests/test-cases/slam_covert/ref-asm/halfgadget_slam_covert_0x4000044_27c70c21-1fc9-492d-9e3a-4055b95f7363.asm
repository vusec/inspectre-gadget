--------------------- HALF GADGET ----------------------
         multiple_bb:
4000000  cmp     r8, 0x0
4000004  je      trans1 ; Not Taken   <Bool r8 != 0x0>
4000006  cmp     r8, 0x1
400000a  je      trans2 ; Taken   <Bool r8 == 0x1>
         trans2:
400003b  mov     r9, qword ptr [rdi] ; {Attacker@rdi} -> {Attacker@0x400003b}
400003e  and     rax, 0xff
4000044  mov     r10, qword ptr [r9+rax+0x20] ; {Attacker@0x400003b, Attacker@rax} -> HALF GADGET
4000049  jmp     end

------------------------------------------------
uuid: 27c70c21-1fc9-492d-9e3a-4055b95f7363

Expr: <BV64 0x20 + LOAD_64[<BV64 rdi>]_28 + (0#56 .. rax[7:0])>
Base: <BV64 0x20>
Attacker: <BV64 LOAD_64[<BV64 rdi>]_28 + (0#56 .. rax[7:0])>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: [('0x4000004', <Bool r8 != 0x0>, 'Not Taken'), ('0x400000a', <Bool r8 == 0x1>, 'Taken')]


------------------------------------------------
