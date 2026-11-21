.intel_syntax noprefix

secret_dependent_branch_1_bit:
t1:
   movzx  r9, BYTE PTR [rdi + 0x10]   # load of 1-byte secret
   cmp    r9, 0x41                    # compare with static immediate (not exploitable)
   jz     end

t2:
   movzx  r9, BYTE PTR [rdi + 0x20]   # load of 1-byte secret
   and    r9, 0x1                     # mask off to 1 bit
   cmp    r9, 0x1                     # compare 1 bit with static immediate (exploitable)
   jz     end

t3:
   mov    rax, QWORD PTR [0xffffffff81000000] # uncontrolled load
   movzx  r9, BYTE PTR [rdi + 0x30]   # load of 1-byte secret
   shr    r9, 7                       # shift off to 1 bit
   cmp    r9, rax                     # compare 1 bit with uncontrolled value (exploitable)
   jz     end

t4:
   movzx  r9, BYTE PTR [rdi + 0x40]   # load of 1-byte secret
   shr    r9, 7                       # shift off to 1 bit
   mov    r8, QWORD PTR [rdi + 0x100] # load of value (near secret value)
   cmp    r9, r8                      # compare with indirect secret dependency (not exploitable)
   jz     end

end:
	jmp    0xdead
