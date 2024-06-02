--------------------- TFP ----------------------
         code_load:
4000000  cmp     r8, 0x0
4000004  je      trans1
         trans1:
400001c  mov     rax, qword ptr [rdi] ; {Attacker@rdi} -> {Attacker@0x400001c}
400001f  jmp     rax ; {Attacker@0x400001c} -> TAINTED FUNCTION POINTER

------------------------------------------------
uuid: 172feaad-5798-494d-96b0-64286bd2f7e6

Reg: rax
Expr: <BV64 LOAD_64[<BV64 rdi>]_24>

Constraints: []
Branches: []

CONTROLLED:

REGS ALIASING WITH TFP:
rdi: <BV64 rdi>

Uncontrolled Regs: ['rbp', 'rsp']
Unmodified Regs: ['rbx', 'rcx', 'rdx', 'rsi', 'r8', 'r9', 'r10', 'r11', 'r12', 'r13', 'r14', 'r15']
Potential Secrets: []

------------------------------------------------
