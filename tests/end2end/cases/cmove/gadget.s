.intel_syntax noprefix

cmove_sample:
   mov     rdi, qword ptr [rdx+0x18] # [ATTACKER]#rdx > [SECRET]
   test    rdi, rdi
   cmove   rdi, rsi
   mov     eax, dword ptr [rdi]      # TRANSMISSION either with secret OR attacker VALUE:

   jmp    0xdead
