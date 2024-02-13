--------------------- TFP ----------------------
         code_load:
4000000  cmp     r8, 0x0
4000004  je      trans1 ; Not Taken   <Bool r8 != 0x0>
4000006  cmp     r8, 0x1
400000a  je      trans2 ; Taken   <Bool r8 == 0x1>
         trans2:
4000021  movzx   rax, word ptr [rdi] ; {Attacker@rdi} > {Attacker@0x4000021}
4000025  jmp     qword ptr [rax*0x8-0x7f000000] ; {Attacker@0x4000025} > TAINTED FUNCTION POINTER

------------------------------------------------
uuid: 8640abc3-f04f-4772-8988-f11d2e6fb36b

Reg: rax
Expr: <BV64 LOAD_64[<BV64 ((0#48 .. LOAD_16[<BV64 rdi>]_22) << 0x3) + 0xffffffff81000000>]_23>

Constraints: []
Branches: [(67108868, <Bool r8 != 0x0>, 'Not Taken'), (67108874, <Bool r8 == 0x1>, 'Taken')]

CONTROLLED:

REGS ALIASING WITH TFP:
rdi: <BV64 rdi>

Uncontrolled Regs: ['rbp', 'rsp']
Unmodified Regs: ['rbx', 'rcx', 'rdx', 'rsi', 'r8', 'r9', 'r10', 'r11', 'r12', 'r13', 'r14', 'r15']

------------------------------------------------
