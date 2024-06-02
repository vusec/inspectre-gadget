.intel_syntax noprefix

tfp_symbolic:
   cmp     r15, 0x0
   jz      tfp1

tfp0:
   mov     rax, qword ptr [rcx+rsi]
   call    rax
# Special case: TFP does not equal an expr stored in a reg (e.g, rax), but it
# points to memory. (In this case [eax-0x7db6bd40] or [ecx-0x7db6bd40])
tfp1:
   add     byte ptr [rdi], bh
   cmovae  eax, ecx
   jmp     qword ptr [rax-0x7db6bd40]
