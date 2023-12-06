.intel_syntax noprefix

cmove_sample:
   mov     rdi, qword ptr [rdx+0x18] #; [ATTACKER]#rdx > [SECRET]
   test    rdi, rdi
   cmove   rdi, rsi
   mov     dword ptr [rdi], eax      #; STORE address comes from cmove
   mov     qword ptr [rsi], rdi      #; STORE value comes from cmove
   mov     rbx,   qword ptr [rsi]    #; Alias with first store (only if rdi == 0)

   jmp    0xdead
