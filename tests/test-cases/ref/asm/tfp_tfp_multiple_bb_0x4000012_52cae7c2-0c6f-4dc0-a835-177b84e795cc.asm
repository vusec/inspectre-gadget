--------------------- TFP ----------------------
         tfp_multiple_bb:
4000000  mov     r8, qword ptr [rdi]
4000003  cmp     rax, 0x0
4000007  je      tfp0 ; Taken   <Bool rax == 0x0>
         tfp0:
400000b  mov     r10, qword ptr [r8-0x7f000000]
4000012  jmp     __x86_indirect_thunk_array ; {Attacker@rax} > TAINTED FUNCTION POINTER

------------------------------------------------
uuid: 52cae7c2-0c6f-4dc0-a835-177b84e795cc

Reg: rax
Expr: <BV64 rax>

Constraints: []
Branches: [(67108871, <Bool rax == 0x0>, 'Taken'), (67108882, <Bool True>, 'Taken')]

CONTROLLED:
r8: <BV64 LOAD_64[<BV64 rdi>]_20>
r10: <BV64 LOAD_64[<BV64 LOAD_64[<BV64 rdi>]_20 + 0xffffffff81000000>]_23>

REGS ALIASING WITH TFP:

Uncontrolled Regs: ['rbp', 'rsp']
Unmodified Regs: ['rbx', 'rcx', 'rdx', 'rsi', 'rdi', 'r9', 'r11', 'r12', 'r13', 'r14', 'r15']

------------------------------------------------
