--------------------- HALF GADGET ----------------------
         unsat_conflicting_brs:
4000000  cmp     rbx, 0x10
4000004  jb      cmp2 ; Not Taken   <Bool rbx >= 0x10>
4000006  movzx   r9, word ptr [rdi] ; {Attacker@rdi} -> HALF GADGET
         cmp2:
400000a  cmp     rbx, 0x5
400000e  ja      end

------------------------------------------------
uuid: 41c6f27c-3c22-4f72-9536-a00af2ef7ecd

Expr: <BV64 rdi>
Base: None
Attacker: <BV64 rdi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: [('0x4000004', <Bool rbx >= 0x10>, 'Not Taken')]


------------------------------------------------
