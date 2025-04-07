--------------------- HALF GADGET ----------------------
         multiple_bb:
4000000  mov     r8, qword ptr [rdi] ; {Attacker@rdi} -> {Attacker@0x4000000}
4000003  movzx   r9, word ptr [rdi]
4000007  cmp     rax, 0x0
400000b  je      trans1 ; Taken   <Bool rax == 0x0>
         trans1:
400001b  mov     r10, qword ptr [r8+rax-0x10] ; {Attacker@0x4000000, Attacker@rax} -> HALF GADGET
4000020  mov     r11, qword ptr [rsi]
         end:
4000023  jmp     0x400dead

------------------------------------------------
uuid: feab6bba-41a9-4799-b3e0-cedb08411a1e

Expr: <BV64 0xfffffffffffffff0 + LOAD_64[<BV64 rdi>]_20 + rax>
Base: <BV64 0xfffffffffffffff0>
Attacker: <BV64 LOAD_64[<BV64 rdi>]_20 + rax>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: [('0x400000b', <Bool rax == 0x0>, 'Taken')]


------------------------------------------------
