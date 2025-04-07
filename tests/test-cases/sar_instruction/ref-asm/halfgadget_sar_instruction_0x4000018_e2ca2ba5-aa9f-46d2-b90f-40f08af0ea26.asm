--------------------- HALF GADGET ----------------------
         sar_instruction:
4000000  cmp     r8, 0x0
4000004  je      trans1 ; Taken   <Bool r8 == 0x0>
         trans1:
4000015  movzx   eax, word ptr [rsi] ; {Attacker@rsi} -> {Attacker@0x4000015}
4000018  bt      qword ptr [rdi+0xb8], rax ; {Attacker@rdi, Attacker@0x4000015} -> HALF GADGET
         end:
4000020  jmp     0x400dead

------------------------------------------------
uuid: e2ca2ba5-aa9f-46d2-b90f-40f08af0ea26

Expr: <BV64 0xb8 + rdi + ((0#48 .. LOAD_16[<BV64 rsi>]_22) >> 0x3)>
Base: <BV64 0xb8>
Attacker: <BV64 rdi + ((0#48 .. LOAD_16[<BV64 rsi>]_22) >> 0x3)>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: [('0x4000004', <Bool r8 == 0x0>, 'Taken')]


------------------------------------------------
