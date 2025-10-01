--------------------- HALF GADGET ----------------------
         unsat_conflicting_brs:
4000000  cmp     rbx, 0x10
4000004  jb      cmp2 ; Not Taken   <Bool rbx >= 0x10>
4000006  movzx   r9, word ptr [rdi] ; {Attacker@rdi} -> {Attacker@0x4000006}
         cmp2:
400000a  cmp     rbx, 0x5
400000e  ja      end ; Not Taken   <Bool UNSAT>
4000010  mov     rax, qword ptr [r9+rsi] ; {Attacker@0x4000006, Attacker@rsi} -> HALF GADGET
         end:
4000014  jmp     0x400dead

------------------------------------------------
uuid: 5401192a-0b91-4a04-8a9f-375545c15654

Expr: <BV64 (0#48 .. LOAD_16[<BV64 rdi>]_20) + rsi>
Base: None
Attacker: <BV64 (0#48 .. LOAD_16[<BV64 rdi>]_20) + rsi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: [('0x4000004', <Bool rbx >= 0x10>, 'Not Taken'), ('0x400000e', <Bool UNSAT>, 'Not Taken')]


------------------------------------------------
