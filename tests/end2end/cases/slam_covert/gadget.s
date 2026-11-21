.intel_syntax noprefix

multiple_bb:
   cmp    r8, 0x0
   je     trans1
   cmp    r8, 0x1
   je     trans2
   cmp    r8, 0x2
   je     trans3
   cmp    r8, 0x3
   je     trans4_5

# -- exploitable gadgets
trans0:
   mov    r9, QWORD PTR [rdi]       # load of secet
   mov    r10, QWORD PTR [r9 + 0x5890] # exploitable w slam
   jmp    end


trans1:
   mov    r9, QWORD PTR [rdi]       # load of secet
   add    r9, 0x821
   shl    r9, 16
   add    r9, 0x33
   mov    r10, QWORD PTR [r9]       # exploitable w slam
   jmp    end


trans2:
   mov    r9, QWORD PTR [rdi]       # load of secet
   and    rax, 0xff
   mov    r10, QWORD PTR [r9 + 0x20 + rax] # exploitable w slam
   jmp    end

trans3:
   mov    r9, QWORD PTR [rdi]       # load of secet
   mov    r10, QWORD PTR [r9 + 0xffffffff81000000] # we assume it is
                     # exploitable, it is only not exploitable if
                     #  r9[64:32] == 0
   jmp    end

# -- not exploitable gadgets
trans4_5:
   mov    r9, QWORD PTR [rdi] # load of secet
   shl    r9, 9
   mov    r10, QWORD PTR [r9] # not exploitable w slam
                              # due the shift


   mov    r9d, DWORD PTR [rdi]       # load of secet
   mov    r11, QWORD PTR [r9 + 0xffffffff81000000] # not exploitable w slam
                     # exploitable, bit 47 and 63 should be zero
   jmp    end


end:
	jmp    0xdead
