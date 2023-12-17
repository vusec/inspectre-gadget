--------------------- TFP ----------------------
         tfp_multiple_bb:
4000000  mov     r8, qword ptr [rdi]
4000003  cmp     rax, 0x0
4000007  je      tfp0 ; Not Taken   <Bool rax != 0x0>
4000009  jmp     tfp1 ; Taken   <Bool True>
         tfp1:
4000014  mov     r10, qword ptr [rdi-0x10]
4000018  mov     r11, qword ptr [r10]
400001b  jmp     __x86_indirect_thunk_array ; {Attacker@rax} > TAINTED FUNCTION POINTER

------------------------------------------------
uuid: c96213a7-2f3f-4f2f-8eb4-803a68d793b2

Reg: rax
Expr: <BV64 rax>

Constraints: []
Branches: [(67108871, <Bool rax != 0x0>, 'Not Taken'), (67108873, <Bool True>, 'Taken'), (67108891, <Bool True>, 'Taken')]

CONTROLLED:
r8: <BV64 LOAD_64[<BV64 rdi>]_20>
r10: <BV64 LOAD_64[<BV64 rdi + 0xfffffffffffffff0>]_21>
r11: <BV64 LOAD_64[<BV64 LOAD_64[<BV64 rdi + 0xfffffffffffffff0>]_21>]_22>

REGS ALIASING WITH TFP:

Uncontrolled Regs: ['rbp', 'rsp']
Unmodified Regs: ['rbx', 'rcx', 'rdx', 'rsi', 'rdi', 'r9', 'r12', 'r13', 'r14', 'r15']

------------------------------------------------
