.intel_syntax noprefix

secret_dependent_branch:
   movzx    r9, WORD PTR [rdi]       # load of attacker
   mov    r8, QWORD PTR [rdi + 0x10] # load of &secret
   movzx    r8, WORD PTR [r8]      # load of secret value (if attacker, not exploitable)
   add    r8, 0x50                 # static base, not relevant
   # this should yield 1 exploitable and 1 not exploitable
   cmp    r9, r8
   jz     end
t1:
   movzx  r9, WORD PTR [rdi + 0x20] # load of secret
   cmp    r9, rdi                   # compare with secret address (not exploitable)
   jz     end

t2:
   movzx  r9, WORD PTR [rdi + 0x20] # load of secret
   mov    r8, QWORD PTR [rdi + 0x100] # load of base (near secret value)
   cmp    r9, r8             # compare with indirect secret dependency (not exploitable)
   jz     end

t3:
   mov    rax, QWORD PTR [0xffffffff81000000] # uncontrolled load
   movzx  r9, WORD PTR [rdi + 0x30] # load of secret
   cmp    r9, rax                   # compare with uncontrolled value (not exploitable)
   jz     end

t5:
   mov    rax, QWORD PTR [0xffffffff81000000] # uncontrolled load
   movzx  r9, WORD PTR [rdi + 0x30] # load of secret
   add    r9, rax
   cmp    r9, rsi                   # controlled complex (exploitable)
   jz     end
end:
	jmp    0xdead
