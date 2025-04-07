.intel_syntax noprefix

setup:
# Setup chain of pointers  A -> B -> C -> back to A
mov		qword ptr [0xffffffff81000000], 0xffffffff81000010
mov		qword ptr [0xffffffff81000010], 0xffffffff81000020
mov		qword ptr [0xffffffff81000020], 0xffffffff81000000

# Store public value in B+8 and C+8, but not A+8
mov		qword ptr [0xffffffff81000008], rdi
mov		qword ptr [0xffffffff81000018], 0xffffffffdeadbeef
mov		qword ptr [0xffffffff81000028], 0xffffffffcacacafe

# Start from A
mov rax, 0xffffffff81000000
mov r12, 0xffffffff81000000

loopy:
	# Load next element
	mov	rbx, qword ptr [rax]
	# Check if it's the head
	cmp rbx, r12
    je end

    # If not, read the public values
    add rbx, 8
	mov	rcx, qword ptr [rbx]
	mov	rdx, qword ptr [rcx]

    # Next iter
    add rax, 0x10
	jmp loopy

end:
	jmp		0xdead
