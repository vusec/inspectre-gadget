.intel_syntax noprefix

alias_type_1:
   # Secret Address and transmission base on rdi
   movzx  r8d, WORD PTR [rdi]                # secret
   mov    rcx, QWORD PTR [r8 - 0x20]         # transmission without aliasing
   mov    r10, QWORD PTR [rdi + r8 + 0x50]   # transmission with aliasing

   # Secret Address and transmission base on Indirect Load rsi
   mov    r11, QWORD PTR [rsi]
   movzx  r9d, WORD PTR [r11]
   mov    rax, QWORD PTR [r11 + r9 + 0x20]
	jmp    0xdead
