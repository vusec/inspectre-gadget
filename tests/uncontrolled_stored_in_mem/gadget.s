.intel_syntax noprefix

uncontrolled_stored_in_mem:
   # A constant is moved to the ind trans_base, resulting in a non-controlable
   # trans_base
   mov    DWORD PTR [rdx], 0x7000000
   mov    r8d, DWORD PTR [rdx]         # load [attacker] from mem
   mov    r9, QWORD PTR [rdi + 0xff]  # load secret
   and    r9, 0xffff
   mov    r10, QWORD PTR [0xffffffff81000000 + r8 + r9] # transmission
	# ---------------------------------------------------
   # A constant is moved to the secret address location, with non-valid
   # transmission as a result
   mov    DWORD PTR [rsi], 0x0
   mov    r9d, DWORD PTR [rsi]  # load secret
   and    r9, 0xffff
   mov    r11, QWORD PTR [0xffffffff81000000 + r9] # transmission

   # Now we dereference a constant address twice, and use that as a secret.
   mov   rdx, 0xffffffff85000000
   mov   rax, QWORD PTR [rdx] # Uncontrolled address, but maybe controlled value
   mov   rbx, QWORD PTR [rax] # Secret
   mov   r14, QWORD PTR [rcx + rbx] # Transmission

	jmp    0xdead
