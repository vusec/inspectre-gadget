--------------------- TFP ----------------------
         code_load:
4000000  cmp     r8, 0x0
4000004  je      trans1 ; Not Taken   <Bool r8 != 0x0>
4000006  cmp     r8, 0x1
400000a  je      trans2 ; Not Taken   <Bool r8 != 0x1>
400000c  cmp     r8, 0x2
4000010  je      trans3 ; Taken   <Bool r8 == 0x2>
         trans3:
400002c  jmp     qword ptr [rdi] ; {Attacker@0x400002c} > TAINTED FUNCTION POINTER

------------------------------------------------
uuid: dab92d01-9f26-4d84-8bc0-a726e52647a9

Reg: rdi
Expr: <BV64 LOAD_64[<BV64 rdi>]_21>

Constraints: []
Branches: [(67108868, <Bool r8 != 0x0>, 'Not Taken'), (67108874, <Bool r8 != 0x1>, 'Not Taken'), (67108880, <Bool r8 == 0x2>, 'Taken')]

CONTROLLED:

REGS ALIASING WITH TFP:

Uncontrolled Regs: ['rbp', 'rsp']
Unmodified Regs: ['rax', 'rbx', 'rcx', 'rdx', 'rsi', 'r8', 'r9', 'r10', 'r11', 'r12', 'r13', 'r14', 'r15']

------------------------------------------------
