# DUMP:  /home/wiebingsj/vmlinux/linux-6.1.13/vmlinux 0xffffffff817ee1e0
.intel_syntax noprefix

tg3_start_xmit:
	push   r15
	push   r14
	push   r13
	mov    r13,rdi
	push   r12
	push   rbp
	mov    rbp,rsi
	push   rbx
	sub    rsp,0x58
	mov    rax, gs
	mov    QWORD PTR [rsp+0x50],rax
	xor    eax,eax
	lea    rax,[rsi+0x900]
	mov    QWORD PTR [rsp+0x10],rax
	movzx  eax,WORD PTR [rdi+0x7c]
	lea    rdx,[rax+rax*4]
	mov    r12,rdx
	lea    rax,[rax+rdx*2]
	shl    rax,0x6
	shl    r12,0x6
	add    r12,QWORD PTR [rsi+0x380]
	mov    QWORD PTR [rsp+0x8],r12
	lea    r12,[rsi+rax*1+0xa40]
	mov    rax,QWORD PTR [rsi+0x1b58]
	lea    rdx,[r12+0x2c0]
	shr    rax,0x3d
	test   al,0x1
	cmovne r12,rdx
	mov    esi,DWORD PTR [r12+0x240]
	mov    edx,DWORD PTR [r12+0x248]
	mov    rdi,QWORD PTR [rdi+0xc8]
	mov    eax,esi
	sub    eax,DWORD PTR [r12+0x244]
	and    eax,0x1ff
	sub    edx,eax
	mov    eax,DWORD PTR [r13+0xc0]
	mov    DWORD PTR [rsp+0x4c],edx
	add    rax,rdi
	movzx  ecx,BYTE PTR [rax+0x2]
	add    ecx,0x1
	cmp    ecx,edx
	jmp    0xdead
