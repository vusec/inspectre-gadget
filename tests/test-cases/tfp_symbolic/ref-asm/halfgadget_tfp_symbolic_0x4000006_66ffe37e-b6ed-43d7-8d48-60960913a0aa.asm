--------------------- HALF GADGET ----------------------
         tfp_symbolic:
4000000  cmp     r15, 0x0
4000004  je      tfp1 ; Not Taken   <Bool r15 != 0x0>
         tfp0:
4000006  mov     rax, qword ptr [rcx+rsi] ; {Attacker@rcx, Attacker@rsi} -> HALF GADGET
400000a  call    rax

------------------------------------------------
uuid: 66ffe37e-b6ed-43d7-8d48-60960913a0aa

Expr: <BV64 rcx + rsi>
Base: None
Attacker: <BV64 rcx + rsi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: [('0x4000004', <Bool r15 != 0x0>, 'Not Taken')]


------------------------------------------------
