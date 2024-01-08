--------------------- TFP ----------------------
         tfp_symbolic:
4000000  mov     rax, qword ptr [rcx+rsi] ; {Attacker@rsi, Attacker@rcx} > {Attacker@0x4000000}
4000004  cmp     r15, 0x0
4000008  je      tfp1 ; Not Taken   <Bool r15 != 0x0>
         tfp0:
400000a  jmp     rax ; {Attacker@0x4000000} > TAINTED FUNCTION POINTER

------------------------------------------------
uuid: c7a906f3-7046-4652-a7a8-5be9f39df68c

Reg: rax
Expr: <BV64 LOAD_64[<BV64 rcx + rsi>]_20>

Constraints: []
Branches: [(67108872, <Bool r15 != 0x0>, 'Not Taken')]

CONTROLLED:

REGS ALIASING WITH TFP:

Uncontrolled Regs: ['rbp', 'rsp']
Unmodified Regs: ['rbx', 'rcx', 'rdx', 'rsi', 'rdi', 'r8', 'r9', 'r10', 'r11', 'r12', 'r13', 'r14', 'r15']

------------------------------------------------
