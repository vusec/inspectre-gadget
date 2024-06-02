--------------------- TFP ----------------------
         tfp_symbolic:
4000000  cmp     r15, 0x0
4000004  je      tfp1
         tfp0:
4000006  mov     rax, qword ptr [rcx+rsi] ; {Attacker@rsi, Attacker@rcx} -> {Attacker@0x4000006}
400000a  call    rax ; {Attacker@0x4000006} -> TAINTED FUNCTION POINTER

------------------------------------------------
uuid: 32ce8986-a59f-41f4-8135-cad44a555c17

Reg: rax
Expr: <BV64 LOAD_64[<BV64 rcx + rsi>]_20>

Constraints: []
Branches: []

CONTROLLED:

REGS ALIASING WITH TFP:

Uncontrolled Regs: ['rbp', 'rsp']
Unmodified Regs: ['rbx', 'rcx', 'rdx', 'rsi', 'rdi', 'r8', 'r9', 'r10', 'r11', 'r12', 'r13', 'r14', 'r15']
Potential Secrets: []

------------------------------------------------
