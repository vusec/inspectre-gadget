--------------------- TFP ----------------------
         code_load:
4000000  cmp     r8, 0x0
4000004  je      trans1 ; Not Taken   <Bool r8 != 0x0>
4000006  cmp     r8, 0x1
400000a  je      trans2 ; Not Taken   <Bool r8 != 0x1>
400000c  cmp     r8, 0x2
4000010  je      trans3 ; Not Taken   <Bool r8 != 0x2>
         trans0:
4000012  movzx   rsi, word ptr [rdi] ; {Attacker@rdi} > {Attacker@0x4000012}
4000016  lea     rax, [rdx+rsi]
400001a  jmp     rax ; {Attacker@0x4000012, Attacker@rdx} > TAINTED FUNCTION POINTER

------------------------------------------------
uuid: 017b6f66-5baa-4305-8f73-cfcc8a038643

Reg: rax
Expr: <BV64 rdx + (0#48 .. LOAD_16[<BV64 rdi>]_20)>

Constraints: []
Branches: [(67108868, <Bool r8 != 0x0>, 'Not Taken'), (67108874, <Bool r8 != 0x1>, 'Not Taken'), (67108880, <Bool r8 != 0x2>, 'Not Taken')]

CONTROLLED:

REGS ALIASING WITH TFP:
rdx: <BV64 rdx>
rsi: <BV64 0x0 .. LOAD_16[<BV64 rdi>]_20>

Uncontrolled Regs: ['rbp', 'rsp']
Unmodified Regs: ['rbx', 'rcx', 'rdi', 'r8', 'r9', 'r10', 'r11', 'r12', 'r13', 'r14', 'r15']

------------------------------------------------
