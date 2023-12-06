.intel_syntax noprefix

alias_partially_independent:
   # Not exploitable
   mov    esi, edi
   add    rsi, r12
   mov    rax, QWORD PTR [r12 + 0x28]
   mov    r9, QWORD PTR [rsi + rax]

   # 'exploitable'
   mov    esi, edi
   add    rsi, r12
   mov    eax, DWORD PTR [r12 + 0x28]
   mov    r10, QWORD PTR [rsi + rax]

   # not exploitable
   mov    esi, edi
   add    rsi, QWORD PTR [r12 + 0x20]
   mov    rax, QWORD PTR [r12 + 0x28]
   mov    r11, QWORD PTR [rsi + rax]

   jmp    0xdead
