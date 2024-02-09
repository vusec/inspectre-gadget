.intel_syntax noprefix

sbb_instruction:
   mov     rax, QWORD ptr [rdi+0x28]
   mov     ebx, eax
   cmp     rbx, 0x10
   sbb     rbx, rbx
   and     ebx, eax
   mov     r10, QWORD PTR [r9 + rbx]
   jmp    0xdead
