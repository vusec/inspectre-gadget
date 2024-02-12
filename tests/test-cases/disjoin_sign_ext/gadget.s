.intel_syntax noprefix

disjoin_sign_extend:
      movsx  rax, DWORD PTR [rcx + 0x4]
      movzx  rsi, WORD PTR [rdi]
      mov    rdx, QWORD PTR [rax + rsi + 0x4096] # Transmission:
            # base is disjoint and sign-extended, but range should be exact
            # since we have support for it.
      jmp 0xdead
