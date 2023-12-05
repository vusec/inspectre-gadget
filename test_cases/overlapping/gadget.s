.intel_syntax noprefix

constraints_isolater:
   mov    r8, QWORD PTR [rdi]      # This forces rdi to be concretized
   movzx  r9, WORD PTR [rdi]       # load of secet
                                   # -> Range should be 0x0,0xffffffffffffffff, 0x1)
   mov    r10, QWORD PTR [r9 + 0xffffffff81000000] # transmission 0

   movzx  rax, WORD PTR [rdi + 4]
   mov    r11, QWORD PTR [rax + 0xffffffff81000000] # transmission 1

   mov    ebx, DWORD PTR [rdi + 4]
   mov    r12, QWORD PTR [rbx + 0xffffffff81000000] # transmission 2

   mov    rcx, QWORD PTR [rdi + 4]
   mov    r13, QWORD PTR [rcx + 0xffffffff81000000] # transmission 3

   mov    r14, QWORD PTR [r9 + r12]  # transmission 4, has aliasing

	jmp    0xdead
