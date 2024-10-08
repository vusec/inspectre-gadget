--------------------- TFP ----------------------
         code_load:
4000000  cmp     r8, 0x0
4000004  je      trans1
4000006  cmp     r8, 0x1
400000a  je      trans2
400000c  cmp     r8, 0x2
4000010  je      trans3
         trans0:
4000012  movzx   rsi, word ptr [rdi] ; {Attacker@rdi} -> {Attacker@0x4000012}
4000016  lea     rax, [rdx+rsi]
400001a  jmp     rax ; {Attacker@rdx, Attacker@0x4000012} -> TAINTED FUNCTION POINTER

------------------------------------------------
uuid: 73b87ab9-e48d-4367-9345-2b8a43e1dbd7

Reg: rax
Expr: <BV64 rdx + (0#48 .. LOAD_16[<BV64 rdi>]_20)>

Constraints: []
Branches: []

CONTROLLED:

REGS ALIASING WITH TFP:
rdx: <BV64 rdx>
rsi: <BV64 0x0 .. LOAD_16[<BV64 rdi>]_20>

Uncontrolled Regs: ['rbp', 'rsp']
Unmodified Regs: ['rbx', 'rcx', 'rdi', 'r8', 'r9', 'r10', 'r11', 'r12', 'r13', 'r14', 'r15']
Potential Secrets: []

------------------------------------------------
