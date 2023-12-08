.intel_syntax noprefix

cmove_sample:
   mov     rdi, qword ptr [rdx+0x18] # [ATTACKER]#rdx > [SECRET]
   test    rdi, rdi
   cmove   rdi, rsi
   test    rax, rax
   cmove   rax, rdi

   mov     eax, dword ptr [rax + 0x24]      # TRANSMISSION either with secret OR attacker VALUE:

   jmp    0xdead
