--------------------- TFP ----------------------
         tfp_multiple_bb:
4000000  mov     r8, qword ptr [rdi]
4000003  cmp     rax, 0x0
4000007  je      tfp0 ; Not Taken   <Bool rax != 0x0>
4000009  jmp     tfp1
         tfp1:
4000014  mov     r10, qword ptr [rdi-0x10]
4000018  mov     r11, qword ptr [r10]
400001b  jmp     __x86_indirect_thunk_array ; {Attacker@rax} -> TAINTED FUNCTION POINTER

------------------------------------------------
uuid: 849cb94a-1d40-4a86-8903-ecf279dd73ed

Reg: rax
Expr: <BV64 rax>

Constraints: []
Branches: [('0x4000007', <Bool rax != 0x0>, 'Not Taken')]

CONTROLLED:

REGS ALIASING WITH TFP:

Uncontrolled Regs: ['rbp', 'rsp']
Unmodified Regs: ['rbx', 'rcx', 'rdx', 'rsi', 'rdi', 'r9', 'r12', 'r13', 'r14', 'r15']
Potential Secrets: ['r8', 'r10', 'r11']

------------------------------------------------
