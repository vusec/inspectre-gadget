--------------------- HALF GADGET ----------------------
         unsat_conflicting_brs:
4000000  cmp     rbx, 0x10
4000004  jb      cmp2 ; Taken   <Bool rbx < 0x10>
         cmp2:
400000a  cmp     rbx, 0x5
400000e  ja      end ; Not Taken   <Bool rbx <= 0x5>
4000010  mov     rax, qword ptr [r9+rsi] ; {Attacker@r9, Attacker@rsi} -> HALF GADGET
         end:
4000014  jmp     0x400dead

------------------------------------------------
uuid: e6138e9b-2d70-4834-aff0-19a2522b6006

Expr: <BV64 r9 + rsi>
Base: None
Attacker: <BV64 r9 + rsi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: [('0x4000004', <Bool rbx < 0x10>, 'Taken'), ('0x400000e', <Bool rbx <= 0x5>, 'Not Taken')]


------------------------------------------------
