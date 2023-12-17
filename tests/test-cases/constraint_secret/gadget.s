.intel_syntax noprefix

constraint_secret:
   movzx  r9, WORD PTR [rdi]       # load of secet
   cmp    r9, 0xffff
   ja     trans1
   mov    rsi, QWORD PTR [r9 - 0x80000000] # transmission 0

   cmp    r9, 0xff
   ja     trans1
   mov    r10, QWORD PTR [r9 - 0x70000000] # transmission 1
   jmp    end
trans1:
   movzx  r9, WORD PTR [rdi + 0x20]       # load of secret 2
   cmp    r9, 0x0
   jz     end
   mov    r11, QWORD PTR [r9 - 0x60000000] # transmission 2
end:
	jmp    0xdead
