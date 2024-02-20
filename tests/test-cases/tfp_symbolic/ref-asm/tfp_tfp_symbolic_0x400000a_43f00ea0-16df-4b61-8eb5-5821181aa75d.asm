--------------------- TFP ----------------------
         tfp_symbolic:
4000000  mov     rax, qword ptr [rcx+rsi] ; {Attacker@rcx, Attacker@rsi} -> {Attacker@0x4000000}
4000004  cmp     r15, 0x0
4000008  je      tfp1 ; Not Taken   <Bool r15 != 0x0>
         tfp0:
400000a  jmp     rax ; {Attacker@0x4000000} -> TAINTED FUNCTION POINTER

------------------------------------------------
uuid: 43f00ea0-16df-4b61-8eb5-5821181aa75d

Reg: rax
Expr: <BV64 LOAD_64[<BV64 rcx + rsi>]_20>

Constraints: []
Branches: [('0x4000008', <Bool r15 != 0x0>, 'Not Taken')]

CONTROLLED:

REGS ALIASING WITH TFP:

Uncontrolled Regs: ['rbp', 'rsp']
Unmodified Regs: ['rbx', 'rcx', 'rdx', 'rsi', 'rdi', 'r8', 'r9', 'r10', 'r11', 'r12', 'r13', 'r14', 'r15']
Potential Secrets: []

------------------------------------------------
