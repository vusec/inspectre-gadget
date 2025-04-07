--------------------- HALF GADGET ----------------------
         speculation_stops:
4000000  movzx   r9, word ptr [rdi] ; {Attacker@rdi} -> {Attacker@0x4000000}
4000004  cmp     rax, 0x0
4000008  je      trans1 ; Not Taken   <Bool rax != 0x0>
400000a  cmp     rax, 0x1
400000e  je      trans2 ; Taken   <Bool rax == 0x1>
         trans2:
400002c  mfence  
400002f  mov     r10, qword ptr [rsi+r9] ; {Attacker@rsi, Attacker@0x4000000} -> HALF GADGET
4000033  jmp     end

------------------------------------------------
uuid: 1ab553ed-9b97-4464-be3b-91e6b60d5227

Expr: <BV64 rsi + (0#48 .. LOAD_16[<BV64 rdi>]_20)>
Base: None
Attacker: <BV64 rsi + (0#48 .. LOAD_16[<BV64 rdi>]_20)>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: [('0x4000008', <Bool rax != 0x0>, 'Not Taken'), ('0x400000e', <Bool rax == 0x1>, 'Taken')]


------------------------------------------------
