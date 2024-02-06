.intel_syntax noprefix

cmove_sample:
   mov     edi, dword ptr [rdx+0x18] # [ATTACKER]#rdx > [SECRET]
   movsxd  rdi, edi                  # Sign extension: this should split the execution but not count for CMOVE controllability.
   test    rdi, rdi
   mov     rbx, rdi

   cmove   rdi, rsi
   mov     eax, dword ptr [rdi]      # TRANSMISSION only on one path (CMOVE dependent).

   mov     ecx, dword ptr [rbx]      # TRANSMISSION (no CMOVE, only SEXT).

   jmp    0xdead
