--------------------- HALF GADGET ----------------------
         speculation_stops:
4000000  movzx   r9, word ptr [rdi] ; {Attacker@rdi} -> {Attacker@0x4000000}
4000004  cmp     rax, 0x0
4000008  je      trans1 ; Not Taken   <Bool rax != 0x0>
400000a  cmp     rax, 0x1
400000e  je      trans2 ; Not Taken   <Bool rax != 0x1>
4000010  cmp     rax, 0x2
4000014  je      trans3 ; Taken   <Bool rax == 0x2>
         trans3:
4000035  cpuid   
4000037  mov     r10, qword ptr [rsi+r9] ; {Attacker@rsi, Attacker@0x4000000} -> HALF GADGET
         end:
400003b  jmp     0x400dead

------------------------------------------------
uuid: ab1a47e5-0291-4174-9b80-f512b3af5eaf

Expr: <BV64 rsi + (0#48 .. LOAD_16[<BV64 rdi>]_20)>
Base: None
Attacker: <BV64 rsi + (0#48 .. LOAD_16[<BV64 rdi>]_20)>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: [('0x4000008', <Bool rax != 0x0>, 'Not Taken'), ('0x400000e', <Bool rax != 0x1>, 'Not Taken'), ('0x4000014', <Bool rax == 0x2>, 'Taken')]


------------------------------------------------
