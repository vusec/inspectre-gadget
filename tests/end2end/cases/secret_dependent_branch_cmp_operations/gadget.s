.intel_syntax noprefix

# Equality compares need a guess for each possible secret value, ordering
# compares can use a binary search. The compared value (rsi) is controlled.
secret_dependent_branch_cmp_operations:
t1:
   movzx  r9, BYTE PTR [rdi + 0x10]   # load of 1-byte secret (8 bits)
   cmp    r9, rsi                     # equality compare (exploitable)
   je     end

t2:
   movzx  r9, WORD PTR [rdi + 0x20]   # load of 2-byte secret (16 bits)
   cmp    r9, rsi                     # equality compare (exploitable)
   je     end

t3:
   mov    r9d, DWORD PTR [rdi + 0x30] # load of 4-byte secret (32 bits)
   cmp    r9, rsi                     # equality compare (exploitable: too many
                                      # guesses, but we can use known prefix)
   je     end

t4:
   mov    r9d, DWORD PTR [rdi + 0x40] # load of 4-byte secret (32 bits)
   cmp    r9, rsi                     # unsigned ordering compare (exploitable)
   jb     end

t5:
   mov    r9d, DWORD PTR [rdi + 0x50] # load of 4-byte secret (32 bits)
   cmp    r9, rsi                     # signed ordering compare (exploitable)
   jl     end

t6:
   movzx  r9, BYTE PTR [rdi + 0x60]   # load of 1-byte secret (8 bits)
   mov    r8, rsi
   and    r8, 0xf                     # compared value can only take 16 values
   cmp    r9, r8                      # equality compare (not exploitable:
                                      # can not cover all secret values)
   je     end

t7:
   mov    r8, rdi
   shl    r8, 5                       # secret address with a stride of 32
   mov    r9d, DWORD PTR [r8 + 0x70]  # load of 4-byte secret (32 bits)
   cmp    r9, rsi                     # equality compare (not exploitable: too
                                      # many guesses, no known prefix possible)
   je     end

end:
   jmp    0xdead
