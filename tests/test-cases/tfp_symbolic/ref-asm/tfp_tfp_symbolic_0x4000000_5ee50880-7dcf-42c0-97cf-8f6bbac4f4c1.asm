--------------------- TFP ----------------------
         tfp_symbolic:
4000000  mov     rax, qword ptr [rcx+rsi] ; {Attacker@0x4000000} > TAINTED FUNCTION POINTER
4000004  jmp     rax

------------------------------------------------
uuid: 5ee50880-7dcf-42c0-97cf-8f6bbac4f4c1

Reg: rax
Expr: <BV64 LOAD_64[<BV64 rcx + rsi>]_20>

Constraints: []
Branches: [(67108864, <Bool True>, 'Taken')]

CONTROLLED:

REGS ALIASING WITH TFP:

Uncontrolled Regs: ['rbp', 'rsp']
Unmodified Regs: ['rbx', 'rcx', 'rdx', 'rsi', 'rdi', 'r8', 'r9', 'r10', 'r11', 'r12', 'r13', 'r14', 'r15']

------------------------------------------------
