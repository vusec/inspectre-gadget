.intel_syntax noprefix

secret_stored_in_mem:
	mov    r8d, DWORD PTR [rsi]
   mov    rdx, 0xffffffff82000000
   mov    QWORD PTR [rdx], r8
   mov    r10, QWORD PTR [rdx]
   and    r10, 0xffff
   mov    rcx, QWORD PTR [r10 + 0xffffffff81000000] # transmission 0

   movzx  r11, WORD PTR [rdx]
   mov    rdi, QWORD PTR [r11 + 0xffffffff81000000] # transmission 1
	jmp     0xdead
