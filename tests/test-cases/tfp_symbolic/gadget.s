.intel_syntax noprefix

tfp_symbolic:
   mov    rax, qword ptr [rcx+rsi]
   cmp    r15, 0x0
   jz     tfp1

tfp0:
   jmp rax

tfp1:
   call rax
