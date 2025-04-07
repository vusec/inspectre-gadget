--------------------- HALF GADGET ----------------------
         tfp_symbolic:
4000000  cmp     r15, 0x0
4000004  je      tfp1 ; Taken   <Bool r15 == 0x0>
         tfp1:
400000c  add     byte ptr [rdi], bh
400000e  cmovae  eax, ecx
4000011  jmp     qword ptr [rax-0x7db6bd40] ; {Attacker@rcx} -> HALF GADGET

------------------------------------------------
uuid: 2fa26de3-fd2f-474d-8abf-ac8b3551b8a9

Expr: <BV64 0xffffffff824942c0 + (0#32 .. rcx[31:0])>
Base: <BV64 0xffffffff824942c0>
Attacker: <BV64 0#32 .. rcx[31:0]>
ControlType: ControlType.CONTROLLED

Constraints: [('0x400000e', <Bool LOAD_8[<BV64 rdi>]_22 + rbx[15:8] >= LOAD_8[<BV64 rdi>]_22>, 'ConditionType.CMOVE')]
Branches: [('0x4000004', <Bool r15 == 0x0>, 'Taken')]


------------------------------------------------
