.intel_syntax noprefix

attack_stored_in_mem:
   mov    rdx, 0xffffffff70000000
   mov    QWORD PTR [rdx], r8          # move [attacker] to mem
   mov    r10, QWORD PTR [rdx]         # load [attacker] from mem
   mov    rdi, QWORD PTR [r10 + 0xff]  # load secret
   and    rdi, 0xffff
   mov    r10, QWORD PTR [rdi + 0xffffffff81000000] # transmission
	jmp    0xdead
