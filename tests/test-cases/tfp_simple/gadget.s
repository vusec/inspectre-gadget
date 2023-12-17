.intel_syntax noprefix

tainted_func_ptr:
   mov    rsi, qword ptr [rdi]
   mov    rax, qword ptr [rcx+rsi]  # simple transmission
   mov    rcx, qword ptr [rdi+0x20]
   mov    r12, qword ptr [r8]
   xor    r8, r8
   shl    rax, 0x2
   jmp    __x86_indirect_thunk_array


__x86_indirect_thunk_array:
   jmp 0xdead
