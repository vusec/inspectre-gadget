--------------------- HALF GADGET ----------------------
         sar_instruction:
4000000  cmp     r8, 0x0
4000004  je      trans1 ; Not Taken   <Bool r8 != 0x0>
         trans0:
4000006  movzx   eax, word ptr [rsi] ; {Attacker@rsi} -> HALF GADGET
4000009  sar     eax, 0x8
400000c  mov     r11, qword ptr [rax-0x7f000000]
4000013  jmp     end

------------------------------------------------
uuid: 536d13e2-f9a7-491c-aeae-15ed67ae18df

Expr: <BV64 rsi>
Base: None
Attacker: <BV64 rsi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: [('0x4000004', <Bool r8 != 0x0>, 'Not Taken')]


------------------------------------------------
