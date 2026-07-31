.intel_syntax noprefix

dispatch:
   cmp    rax, 0x0
   je     soft_equality
   jmp    soft_inequality

soft_equality:
   # Soft equality via cmp: rdi == rsi is established as a branch
   # condition (not an alias). The subsequent bound on rsi must propagate
   # to rdi indirectly through that branch.
   mov     r8, 0x0
   mov     rdi, qword ptr [rdx]
   cmp     rdi, rsi  # set rdi == rsi
   jne     0xdead
   cmp     rsi, 0x10 # rsi <= 10
   ja      0xdead
   mov     rax, qword ptr [rdi]
   jmp    0xdead

soft_inequality:
   # Soft dependency via cmp: rdi <= rsi is established as a branch
   # condition (not equality). Same indirect-propagation requirement.
   mov     r8, 0x0
   mov     rdi, qword ptr [rdx]
   cmp     rdi, rsi  # set rdi <= rsi
   ja      0xdead
   cmp     rsi, 0x10 # rsi <= 10
   ja      0xdead
   mov     rax, qword ptr [rdi]
   jmp    0xdead
