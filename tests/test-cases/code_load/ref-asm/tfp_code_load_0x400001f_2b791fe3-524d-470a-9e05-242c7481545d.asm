--------------------- TFP ----------------------
         code_load:
4000000  cmp     r8, 0x0
4000004  je      trans1 ; Taken   <Bool r8 == 0x0>
         trans1:
400001c  mov     rax, qword ptr [rdi] ; {Attacker@rdi} > {Attacker@0x400001c}
400001f  jmp     rax ; {Attacker@0x400001c} > TAINTED FUNCTION POINTER

------------------------------------------------
uuid: 2b791fe3-524d-470a-9e05-242c7481545d

Reg: rax
Expr: <BV64 LOAD_64[<BV64 rdi>]_24>

Constraints: []
Branches: [(67108868, <Bool r8 == 0x0>, 'Taken')]

CONTROLLED:

REGS ALIASING WITH TFP:
rdi: <BV64 rdi>

Uncontrolled Regs: ['rbp', 'rsp']
Unmodified Regs: ['rbx', 'rcx', 'rdx', 'rsi', 'r8', 'r9', 'r10', 'r11', 'r12', 'r13', 'r14', 'r15']

------------------------------------------------
