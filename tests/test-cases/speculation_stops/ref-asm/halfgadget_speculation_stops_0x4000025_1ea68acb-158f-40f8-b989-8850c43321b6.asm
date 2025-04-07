--------------------- HALF GADGET ----------------------
         speculation_stops:
4000000  movzx   r9, word ptr [rdi] ; {Attacker@rdi} -> {Attacker@0x4000000}
4000004  cmp     rax, 0x0
4000008  je      trans1 ; Taken   <Bool rax == 0x0>
         trans1:
4000022  lfence  
4000025  mov     r10, qword ptr [rsi+r9-0x10] ; {Attacker@rsi, Attacker@0x4000000} -> HALF GADGET
400002a  jmp     end

------------------------------------------------
uuid: 1ea68acb-158f-40f8-b989-8850c43321b6

Expr: <BV64 0xfffffffffffffff0 + rsi + (0#48 .. LOAD_16[<BV64 rdi>]_20)>
Base: <BV64 0xfffffffffffffff0>
Attacker: <BV64 rsi + (0#48 .. LOAD_16[<BV64 rdi>]_20)>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: [('0x4000008', <Bool rax == 0x0>, 'Taken')]


------------------------------------------------
