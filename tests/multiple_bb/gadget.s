.intel_syntax noprefix

multiple_bb:
   mov    r8, QWORD PTR [rdi]      # This forces rdi to be concretized
   movzx  r9, WORD PTR [rdi]       # load of secet
                                   # -> Range should be 0x0,0xffffffffffffffff, 0x1)
   cmp    rax, 0x0
   jz     trans1
   jmp    trans0
trans0:
   mov    r10, QWORD PTR [r9 + 0xffffffff81000000] # transmission 0
   mov    r11, QWORD PTR [rsi]
   jmp    end
trans1:
   mov    r10, QWORD PTR [r8 + rax - 0x10] # transmission 1, rax should be zero
   mov    r11, QWORD PTR [rsi]
end:
	jmp    0xdead
