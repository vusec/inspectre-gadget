.intel_syntax noprefix

dispatch:
   cmp    rax, 0x0
   je     direct_alias
   jmp    cmove_through_alias

direct_alias:
   # Hard equality via direct aliasing: rdi and rsi are two separate loads
   # of the same address, related by an alias (not a branch/constraint).
   mov     r8, 0x0
   mov     rsi, qword ptr [rdx]
   mov     rdi, qword ptr [rdx]  # rdi == rsi (aliased)
   cmp     rsi, 0x10 # rsi <= 10
   ja      0xdead
   mov     eax, dword ptr [rdi]
   jmp    0xdead

cmove_through_alias:
   # Hard equality via cmove, where the compared register is an aliased
   # copy of the value that actually gets transmitted (not the transmitted
   # symbol itself) -- exercises CMOVE-constraint attribution together
   # with alias propagation.
   mov     r8, qword ptr [rdx]   # r8 == secret (compared value)
   mov     r9, qword ptr [rdx]   # r9 == secret (aliased to r8), transmitted value
   mov     rdi, 0x0
   cmp     r8, rsi               # compare the aliased copy against rsi
   cmove   rdi, r9               # rdi = r9 (== secret, aliased to r8) if r8 == rsi
   cmp     rsi, 0x10 # rsi <= 10
   ja      0xdead
   mov     rax, qword ptr [rdi]
   jmp    0xdead
