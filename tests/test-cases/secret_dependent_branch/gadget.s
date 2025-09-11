.intel_syntax noprefix

secret_dependent_branch:
   movzx  r9, WORD PTR [rdi]       # load of secret
   mov    r8, QWORD PTR [rsi]      # load of attacker (or secret)
   add    r8, 0x50                # static base, not relevant
   cmp    r9, r8                  # best case for sdb
   jz     end
t1:
   movzx  r9, WORD PTR [rdi + 0x10] # load of secret
   cmp    r9, 0xdead               # compare with static value
   jz     end

t2:
   movzx  r9, WORD PTR [rdi + 0x20] # load of secret
   cmp    r9, rdi                   # compare with secret address
   jz     end

t3:
   mov    rax, QWORD PTR [0xffffffff81000000] # uncontrolled load
   movzx  r9, WORD PTR [rdi + 0x30] # load of secret
   cmp    r9, rax                   # compare with uncontrolled value
   jz     end

t4:
   mov    rax, QWORD PTR [0xffffffff81000000] # uncontrolled load
   movzx  r9, WORD PTR [rdi + 0x30] # load of secret
   add    r9, rax
   cmp    r9, rsi                   # controlled complex
   jz     end
end:
	jmp    0xdead
