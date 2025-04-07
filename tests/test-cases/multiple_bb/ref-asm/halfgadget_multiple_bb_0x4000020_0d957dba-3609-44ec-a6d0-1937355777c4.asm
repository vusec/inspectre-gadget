--------------------- HALF GADGET ----------------------
         multiple_bb:
4000000  mov     r8, qword ptr [rdi]
4000003  movzx   r9, word ptr [rdi]
4000007  cmp     rax, 0x0
400000b  je      trans1 ; Taken   <Bool rax == 0x0>
         trans1:
400001b  mov     r10, qword ptr [r8+rax-0x10]
4000020  mov     r11, qword ptr [rsi] ; {Attacker@rsi} -> HALF GADGET
         end:
4000023  jmp     0x400dead

------------------------------------------------
uuid: 0d957dba-3609-44ec-a6d0-1937355777c4

Expr: <BV64 rsi>
Base: None
Attacker: <BV64 rsi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: [('0x400000b', <Bool rax == 0x0>, 'Taken')]


------------------------------------------------
