.intel_syntax noprefix

disjoint_range:
   mov  rax, QWORD PTR [rdi + 0x28]  # Load secret
   mov  rsi, QWORD PTR [rsi + 0x30]  # Load secret

   # JE
   cmp  rax, 0xf
   je  exit
   mov  rcx, QWORD PTR [rax]  # Transmission 0
                              # transmitted_secret_range_w_branches: (0x11,0xf)

   mov  r8, QWORD PTR [rax + 0xffffffff81000000]  # Transmission 1
                              # transmission_range_w_branches: (0xffffffff8100000f,0xffffffff8100000f)
   cmp rsi, 0xff
   je exit

   mov  r9, QWORD PTR [rsi + rax] # Transmission 2 + 3
                                  # Both base and transmitted secret are
                                  # disjoint ranges, both transmissions
                                  # should be exploitable both w/wo branches
   # JG / JA
   cmp rax, 0xf
   jg  exit
   mov  rdx, QWORD PTR [rax]  # Transmission 4
                              # transmitted_secret_range_w_branches: (-INT_MAX,0xf)'

   cmp rsi, 0xffff
   ja exit
   mov  rdx, QWORD PTR [rsi]  # Transmission 5
                              # Since we have both a disjoint (je) range and
                              # two separate ranges (ja), we cannnot do it exact
                              # transmitted_secret_range_w_branches: (0,0xffff)'
                              # (exact would be: (0,0xfe) + (0x100, 0xffff))

   mov  rbx, QWORD PTR [rsi + 0xffffffff81000000]  # Transmission 6
                              # exploitable_w_branches: True

   jmp    exit

exit:
   jmp 0xdead
