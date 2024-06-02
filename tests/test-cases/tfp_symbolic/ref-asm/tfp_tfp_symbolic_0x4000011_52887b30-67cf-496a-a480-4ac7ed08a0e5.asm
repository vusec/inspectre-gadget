--------------------- TFP ----------------------
         tfp_symbolic:
4000000  cmp     r15, 0x0
4000004  je      tfp1
         tfp1:
400000c  add     byte ptr [rdi], bh
400000e  cmovae  eax, ecx
4000011  jmp     qword ptr [rax-0x7db6bd40] ; {Attacker@0x4000011} -> TAINTED FUNCTION POINTER

------------------------------------------------
uuid: 52887b30-67cf-496a-a480-4ac7ed08a0e5

Reg: mem
Expr: <BV64 LOAD_64[<BV64 (0#32 .. rcx[31:0]) + 0xffffffff824942c0>]_27>

Constraints: []
Branches: []

CONTROLLED:

REGS ALIASING WITH TFP:
rax: <BV64 0x0 .. rcx[31:0]>
rcx: <BV64 rcx>

Uncontrolled Regs: ['rbp', 'rsp']
Unmodified Regs: ['rbx', 'rdx', 'rsi', 'rdi', 'r8', 'r9', 'r10', 'r11', 'r12', 'r13', 'r14', 'r15']
Potential Secrets: []

------------------------------------------------
