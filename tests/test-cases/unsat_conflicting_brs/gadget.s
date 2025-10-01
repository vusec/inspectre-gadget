.intel_syntax noprefix

# Arch control flow will never reach both the secret load and the transmission.
# However, in speculative execution this is possible. This is simulated
# by setting the AggressiveSpeculation option.

unsat_conflicting_brs:
	cmp rbx, 0x10
	jb  cmp2
	movzx  r9, WORD PTR [rdi]       # load of secet
cmp2:
	cmp rbx, 0x5
	ja end
	mov rax, QWORD PTR [r9 + rsi]  # secret transmission

end:
	jmp		0xdead
