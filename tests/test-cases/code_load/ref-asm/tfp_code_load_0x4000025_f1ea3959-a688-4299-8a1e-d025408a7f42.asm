--------------------- TFP ----------------------
         code_load:
4000000  cmp     r8, 0x0
4000004  je      trans1
4000006  cmp     r8, 0x1
400000a  je      trans2
         trans2:
4000021  movzx   rax, word ptr [rdi] ; {Attacker@rdi} -> {Attacker@0x4000021}
4000025  jmp     qword ptr [rax*0x8-0x7f000000] ; {Attacker@0x4000025} -> TAINTED FUNCTION POINTER

------------------------------------------------
uuid: f1ea3959-a688-4299-8a1e-d025408a7f42

Reg: mem
Expr: <BV64 LOAD_64[<BV64 ((0#48 .. LOAD_16[<BV64 rdi>]_22) << 0x3) + 0xffffffff81000000>]_23>

Constraints: []
Branches: []

CONTROLLED:

REGS ALIASING WITH TFP:
rax: <BV64 0x0 .. LOAD_16[<BV64 rdi>]_22>
rdi: <BV64 rdi>

Uncontrolled Regs: ['rbp', 'rsp']
Unmodified Regs: ['rbx', 'rcx', 'rdx', 'rsi', 'r8', 'r9', 'r10', 'r11', 'r12', 'r13', 'r14', 'r15']
Potential Secrets: []

------------------------------------------------
