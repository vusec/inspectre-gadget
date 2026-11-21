.intel_syntax noprefix

cmove_sample:
   test    rdi, rdi
   cmove   rdi, rsi
   mov     rdi, qword ptr [rdi+0x18] # [ATTACKER]#rdx > [SECRET]
   mov     eax, dword ptr [rdi]      # TRANSMISSION either with secret OR attacker VALUE:

   jmp    0xdead
