.intel_syntax noprefix

cmove_sample:
   test    rdi, rdi
   cmove   rax, rbx
   cmp     rcx, rax
   jz if
   jmp else

   if:
   mov     rdi, qword ptr [rax+0x18] # [ATTACKER]#rdx > [SECRET]
   mov     eax, dword ptr [rdi]      # TRANSMISSION either with secret OR attacker VALUE:
   jmp    0xdead

   else:
   mov     rsi, qword ptr [rbx+0x18] # [ATTACKER]#rdx > [SECRET]
   mov     ebx, dword ptr [rsi]      # TRANSMISSION either with secret OR attacker VALUE:

   jmp    0xdead
