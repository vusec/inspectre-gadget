--------------------- TFP ----------------------
         code_load:
4000000  cmp     r8, 0x0
4000004  je      trans1 ; Not Taken   <Bool r8 != 0x0>
         trans0:
4000006  movzx   rsi, word ptr [rdi] ; {Attacker@rdi} > {Attacker@0x4000006}
400000a  mov     rax, rdx
400000d  add     rax, rsi
4000010  jmp     rax ; {Attacker@0x4000006, Attacker@rdx} > TAINTED FUNCTION POINTER

------------------------------------------------
uuid: cd1b1650-20f1-4238-adbc-58bba9223764

Reg: rax
Expr: <BV64 rdx + (0#48 .. LOAD_16[<BV64 rdi>]_20)>

Constraints: []
Branches: [(67108868, <Bool r8 != 0x0>, 'Not Taken')]

CONTROLLED:

REGS ALIASING WITH TFP:
rdx: <BV64 rdx>
rsi: <BV64 0x0 .. LOAD_16[<BV64 rdi>]_20>

Uncontrolled Regs: ['rbp', 'rsp']
Unmodified Regs: ['rbx', 'rcx', 'rdi', 'r8', 'r9', 'r10', 'r11', 'r12', 'r13', 'r14', 'r15']

------------------------------------------------
