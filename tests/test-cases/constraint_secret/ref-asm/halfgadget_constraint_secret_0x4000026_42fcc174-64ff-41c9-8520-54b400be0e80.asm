--------------------- HALF GADGET ----------------------
         constraint_secret:
4000000  movzx   r9, word ptr [rdi]
4000004  cmp     r9, 0xffff
400000b  ja      trans1 ; Not Taken   <Bool (0#48 .. LOAD_16[<BV64 rdi>]_20) <= 0xffff>
400000d  mov     rsi, qword ptr [r9-0x80000000]
4000014  cmp     r9, 0xff
400001b  ja      trans1 ; Taken   <Bool (0x0 .. LOAD_16[<BV64 rdi>]_20) > 0xff>
         trans1:
4000026  movzx   r9, word ptr [rdi+0x20] ; {Attacker@rdi} -> HALF GADGET
400002b  cmp     r9, 0x0
400002f  je      end

------------------------------------------------
uuid: 42fcc174-64ff-41c9-8520-54b400be0e80

Expr: <BV64 0x20 + rdi>
Base: <BV64 0x20>
Attacker: <BV64 rdi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: [('0x400000b', <Bool (0#48 .. LOAD_16[<BV64 rdi>]_20) <= 0xffff>, 'Not Taken'), ('0x400001b', <Bool (0x0 .. LOAD_16[<BV64 rdi>]_20) > 0xff>, 'Taken')]


------------------------------------------------
