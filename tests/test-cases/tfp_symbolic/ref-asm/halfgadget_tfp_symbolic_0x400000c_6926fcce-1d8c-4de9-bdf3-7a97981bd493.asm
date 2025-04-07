--------------------- HALF GADGET ----------------------
         tfp_symbolic:
4000000  cmp     r15, 0x0
4000004  je      tfp1 ; Taken   <Bool r15 == 0x0>
         tfp1:
400000c  add     byte ptr [rdi], bh ; {Attacker@rdi} -> HALF GADGET
400000e  cmovae  eax, ecx
4000011  jmp     qword ptr [rax-0x7db6bd40]

------------------------------------------------
uuid: 6926fcce-1d8c-4de9-bdf3-7a97981bd493

Expr: <BV64 rdi>
Base: None
Attacker: <BV64 rdi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: [('0x4000004', <Bool r15 == 0x0>, 'Taken')]


------------------------------------------------
