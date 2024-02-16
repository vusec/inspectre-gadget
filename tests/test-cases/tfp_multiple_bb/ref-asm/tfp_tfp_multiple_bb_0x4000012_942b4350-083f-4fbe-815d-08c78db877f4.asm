--------------------- TFP ----------------------
         tfp_multiple_bb:
4000000  mov     r8, qword ptr [rdi]
4000003  cmp     rax, 0x0
4000007  je      tfp0 ; Taken   <Bool rax == 0x0>
         tfp0:
400000b  mov     r10, qword ptr [r8-0x7f000000]
4000012  jmp     __x86_indirect_thunk_array ; {Attacker@rax} > TAINTED FUNCTION POINTER

------------------------------------------------
uuid: 942b4350-083f-4fbe-815d-08c78db877f4

Reg: rax
Expr: <BV64 rax>

Constraints: []
Branches: [('0x4000007', <Bool rax == 0x0>, 'Taken')]

CONTROLLED:

REGS ALIASING WITH TFP:

Uncontrolled Regs: ['rbp', 'rsp']
Unmodified Regs: ['rbx', 'rcx', 'rdx', 'rsi', 'rdi', 'r9', 'r11', 'r12', 'r13', 'r14', 'r15']
Potential Secrets: ['r8', 'r10']

------------------------------------------------
