--------------------- TFP ----------------------
         code_load:
4000000  cmp     r8, 0x0
4000004  je      trans1 ; Taken   <Bool r8 == 0x0>
         trans1:
4000012  mov     rax, qword ptr [rdi] ; {Attacker@rdi} > {Attacker@0x4000012}
4000015  jmp     rax ; {Attacker@0x4000012} > TAINTED FUNCTION POINTER

------------------------------------------------
uuid: 7f4fafcf-b828-4eab-aa74-43245b6c8fb7

Reg: rax
Expr: <BV64 LOAD_64[<BV64 rdi>]_21>

Constraints: []
Branches: [(67108868, <Bool r8 == 0x0>, 'Taken')]

CONTROLLED:

REGS ALIASING WITH TFP:
rdi: <BV64 rdi>

Uncontrolled Regs: ['rbp', 'rsp']
Unmodified Regs: ['rbx', 'rcx', 'rdx', 'rsi', 'r8', 'r9', 'r10', 'r11', 'r12', 'r13', 'r14', 'r15']

------------------------------------------------
