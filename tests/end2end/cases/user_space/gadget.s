.intel_syntax noprefix

# The reasoner results differ for kernel and user space, this test case is
# reasoned with only user-space addresses allowed (see config.yaml).
user_space:
   cmp    r8, 0x0
   je     trans

# Dispatch gadget: jump to a sign-extended 32-bit value. The positive part
# [0, 0x7fffffff] is only valid in user space.
tfp:
   movsxd rax, DWORD PTR [rdi]
   jmp    rax

# Transmission with a 32-bit (zero-extended) base, which can only point to
# user space.
trans:
   mov    r9, QWORD PTR [rsi]        # load of secret
   and    r9, 0xff
   mov    ecx, ecx                   # base: zero-extended 32-bit value
   mov    r10, QWORD PTR [rcx + r9]  # transmission
   jmp    0xdead
