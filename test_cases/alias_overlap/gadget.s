.intel_syntax noprefix

alias_type_2:
   # Independent stuff that comes from same register
   movzx  r8d, WORD PTR [rdx + 0x28]        # secret
   mov    rax, QWORD PTR [rdx + 0x20]        # IND trans base
   mov    rcx, QWORD PTR [rax]               # trans base
   mov    r11, QWORD PTR [rcx + r8]          # transmission

   # Overlapping stuff that comes from same register
   movzx  r9d, WORD PTR [rdx + 0x24]        # secret
   mov    rbx, QWORD PTR [rdx + 0x20]        # IND trans base
   mov    rsi, QWORD PTR [rbx]               # trans base
   mov    r12, QWORD PTR [rsi + r9]          # transmission

   jmp    0xdead
