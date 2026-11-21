.intel_syntax noprefix

alias_type_2:
   # Secret Address and Transmission Base based on rdi
   movzx  r8d, WORD PTR [rdi + 0x100]        # secret
   mov    rsi, QWORD PTR [rdi]               # trans base
   mov    r10, QWORD PTR [rsi + r8]          # transmission

   # Secret Address and Indirect Transmission Base based on rdx
   movzx  r8d, WORD PTR [rdx + 0x28]        # secret
   mov    rax, QWORD PTR [rdx + 0x20]        # IND trans base
   mov    rsi, QWORD PTR [rax]               # trans base
   mov    r11, QWORD PTR [rsi + r8]          # transmission

   # Not a alias:
   mov    rax, QWORD PTR [rdi + 0x200]       # secret address
   mov    rsi, QWORD PTR [rdi + 0x240]       # trans base
   movzx  r8d, WORD PTR [rax]                # secret
   mov    r13, QWORD PTR [rsi + r8]          # transmission
   jmp    0xdead
