.intel_syntax noprefix

tfp_multiple_bb:
   mov    r8, QWORD PTR [rdi]
   cmp    rax, 0x0
   jz     tfp0
   jmp    tfp1

tfp0:
   mov    r10, QWORD PTR [r8 + 0xffffffff81000000]
   jmp     __x86_indirect_thunk_array

tfp1:
   mov     r10, qword ptr [rdi-0x10]
   mov     r11, qword ptr [r10]
   jmp     __x86_indirect_thunk_array


__x86_indirect_thunk_array:
   jmp 0xdead

