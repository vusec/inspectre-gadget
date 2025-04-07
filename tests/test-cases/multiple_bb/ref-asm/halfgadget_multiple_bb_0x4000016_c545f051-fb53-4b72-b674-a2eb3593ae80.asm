--------------------- HALF GADGET ----------------------
         multiple_bb:
4000000  mov     r8, qword ptr [rdi]
4000003  movzx   r9, word ptr [rdi]
4000007  cmp     rax, 0x0
400000b  je      trans1 ; Not Taken   <Bool rax != 0x0>
400000d  jmp     trans0 ; Taken   <Bool True>
         trans0:
400000f  mov     r10, qword ptr [r9-0x7f000000]
4000016  mov     r11, qword ptr [rsi] ; {Attacker@rsi} -> HALF GADGET
4000019  jmp     end

------------------------------------------------
uuid: c545f051-fb53-4b72-b674-a2eb3593ae80

Expr: <BV64 rsi>
Base: None
Attacker: <BV64 rsi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: [('0x400000b', <Bool rax != 0x0>, 'Not Taken'), ('0x400000d', <Bool True>, 'Taken')]


------------------------------------------------
