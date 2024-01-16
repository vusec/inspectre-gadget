--------------------- TFP ----------------------
         tfp_symbolic:
4000000  mov     rax, qword ptr [rcx+rsi] ; {Attacker@rsi, Attacker@rcx} > {Attacker@0x4000000}
4000004  cmp     r15, 0x0
4000008  je      tfp1 ; Taken   <Bool r15 == 0x0>
         tfp1:
400000c  call    rax ; {Attacker@0x4000000} > TAINTED FUNCTION POINTER

------------------------------------------------
uuid: 691e7c24-b91f-4796-985b-cbe2397246de

Reg: rax
Expr: <BV64 LOAD_64[<BV64 rcx + rsi>]_20>

Constraints: []
Branches: [(67108872, <Bool r15 == 0x0>, 'Taken')]

CONTROLLED:

REGS ALIASING WITH TFP:

Uncontrolled Regs: ['rbp', 'rsp']
Unmodified Regs: ['rbx', 'rcx', 'rdx', 'rsi', 'rdi', 'r8', 'r9', 'r10', 'r11', 'r12', 'r13', 'r14', 'r15']

------------------------------------------------
