.intel_syntax noprefix

used_memory_avoider:
   mov    QWORD PTR [rcx], 0xff
   mov    r8, QWORD PTR [rdi] # This should be a secret, but, if the address is
                              # concretized to rcx, its a concrete value
   and    r8, 0xffff
   mov    r9, QWORD PTR [rsi] # Same here, but for TransBase
   mov    r10, QWORD PTR [r8 + r9] # transmission
	jmp    0xdead
