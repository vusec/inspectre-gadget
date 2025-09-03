.intel_syntax noprefix

store_half_overlap:
   # We store a 32-bit attacker controlled value
   mov    DWORD PTR [r8], esi
   # Now we load the 32-bit attacker controlled into 64-bit register
   # Strictly speaking this upper part should have a secret annotation if the
   # load address is attacker controlled. We do not support this yet.
   mov    rdi, QWORD PTR [r8]

   # load secret
   movzx  r11, WORD PTR [rdx]
   # transmit
   mov    rdi, QWORD PTR [r11 + rdi + 0xffffffff81000000]
	jmp     0xdead
