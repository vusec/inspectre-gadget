.intel_syntax noprefix

speculation_stops:
   movzx  r9, WORD PTR [rdi]       # load of secet
                                   # -> Range should be 0x0,0xffffffffffffffff, 0x1)
   cmp    rax, 0x0
   jz     trans1
   cmp    rax, 0x1
   jz     trans2
   cmp    rax, 0x2
   jz     trans3
trans0:
   sfence # should be ignored
   mov    r10, QWORD PTR [r9 + 0xffffffff81000000] # transmission 0
   jmp    end
trans1:
   lfence
   mov    r10, QWORD PTR [rsi + r9 - 0x10] # transmission 1
   jmp    end
trans2:
   mfence
   mov    r10, QWORD PTR [rsi + r9] # transmission 2
   jmp end
trans3:
   CPUID
   mov    r10, QWORD PTR [rsi + r9] # transmission 3
end:
	jmp    0xdead
