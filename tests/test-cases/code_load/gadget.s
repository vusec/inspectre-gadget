.intel_syntax noprefix

code_load:
   cmp    r8, 0x0
   je     trans1


trans0:
   movzx  rsi, WORD PTR [rdi]       # load of secet
   mov    rax, rdx
   add    rax, rsi
   jmp    rax


trans1:
   mov    rax, QWORD PTR [rdi]     # load of unmasked secet
   jmp    rax

end:
	jmp    0xdead
