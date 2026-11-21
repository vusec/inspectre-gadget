.intel_syntax noprefix

tfp_independently_controllable:
    mov rsi, QWORD PTR [rdi]           # Should be marked as CONTROLLED
    mov rdx, QWORD PTR [rdx]           # Should be marked as POTENTIAL_SECRET
    mov rbx, QWORD PTR [rsi]           # Should be marked as POTENTIAL_SECRET
    add rcx, rsi
    add rcx, rdx                  # Should be marked as CONTROLLED
    mov rax, QWORD PTR [rdi + 0x10]
    call rax
