--------------------- TFP ----------------------
         code_load:
4000000  cmp     r8, 0x0
4000004  je      trans1
4000006  cmp     r8, 0x1
400000a  je      trans2
400000c  cmp     r8, 0x2
4000010  je      trans3
         trans3:
400002c  jmp     qword ptr [rdi] ; {Attacker@0x400002c} -> TAINTED FUNCTION POINTER

------------------------------------------------
uuid: 94713ef2-2d6f-43b8-9c31-9da5ac792feb

Reg: mem
Expr: <BV64 LOAD_64[<BV64 rdi>]_21>

Constraints: []
Branches: []

CONTROLLED:

REGS ALIASING WITH TFP:
rdi: <BV64 rdi>

Uncontrolled Regs: ['rbp', 'rsp']
Unmodified Regs: ['rax', 'rbx', 'rcx', 'rdx', 'rsi', 'r8', 'r9', 'r10', 'r11', 'r12', 'r13', 'r14', 'r15']
Potential Secrets: []

------------------------------------------------
