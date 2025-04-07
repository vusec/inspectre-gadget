--------------------- HALF GADGET ----------------------
         sar_instruction:
4000000  cmp     r8, 0x0
4000004  je      trans1 ; Taken   <Bool r8 == 0x0>
         trans1:
4000015  movzx   eax, word ptr [rsi] ; {Attacker@rsi} -> HALF GADGET
4000018  bt      qword ptr [rdi+0xb8], rax
         end:
4000020  jmp     0x400dead

------------------------------------------------
uuid: d83e931a-d81f-4864-8078-aa3d408f8278

Expr: <BV64 rsi>
Base: None
Attacker: <BV64 rsi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: [('0x4000004', <Bool r8 == 0x0>, 'Taken')]


------------------------------------------------
