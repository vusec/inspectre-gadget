.intel_syntax noprefix

disjoint_range:
   mov  rax, QWORD PTR [rdi + 0x28]  # Load secret
   cmp  rax, 16
   je  0xdead                 # Exclude the value 5
   mov  rcx, QWORD PTR [rax]  # Transmission 0
                              # transmitted_secret_range_w_branches: (0xf,0x11)
   jg  0xdead
   mov  rdx, QWORD PTR [rax]  # Transmission 1
                              # transmitted_secret_range_w_branches: (-INT_MAX,0xf)'

   jmp    0xdead
