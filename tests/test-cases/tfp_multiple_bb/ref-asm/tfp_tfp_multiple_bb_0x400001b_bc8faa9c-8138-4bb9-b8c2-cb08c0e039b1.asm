--------------------- TFP ----------------------
         tfp_multiple_bb:
4000000  mov     r8, qword ptr [rdi]
4000003  cmp     rax, 0x0
4000007  je      tfp0 ; Not Taken   <Bool rax != 0x0>
4000009  jmp     tfp1 ; Taken   <Bool True>
         tfp1:
4000014  mov     r10, qword ptr [rdi-0x10]
4000018  mov     r11, qword ptr [r10]
400001b  jmp     __x86_indirect_thunk_array ; {Attacker@rax} -> TAINTED FUNCTION POINTER

------------------------------------------------
uuid: bc8faa9c-8138-4bb9-b8c2-cb08c0e039b1

Reg: rax
Expr: <BV64 rax>

Constraints: []
Branches: [('0x4000007', <Bool rax != 0x0>, 'Not Taken'), ('0x4000009', <Bool True>, 'Taken')]

CONTROLLED:

REGS ALIASING WITH TFP:

Uncontrolled Regs: ['rbp', 'rsp']
Unmodified Regs: ['rbx', 'rcx', 'rdx', 'rsi', 'rdi', 'r9', 'r12', 'r13', 'r14', 'r15']
Potential Secrets: ['r8', 'r10', 'r11']

------------------------------------------------
