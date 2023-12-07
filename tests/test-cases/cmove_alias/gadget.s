.intel_syntax noprefix

cmove_sample:
   test    rdi, rdi
   cmove   rdi, rsi
   mov     rdi, qword ptr [rdi+0x18] #; [ATTACKER]#rdx > [SECRET]
   mov     rsi, qword ptr [rsi+0x18]
   mov     eax, dword ptr [rdi + rsi]      #; TRANSMISSION either with secret OR attacker VALUE:

   jmp    0xdead
