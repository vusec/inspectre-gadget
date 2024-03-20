.intel_syntax noprefix

.section .text

.global __cfi_c_target
.global c_target
.align 4096

__cfi_c_target:
    ENDBR64
    sub r10d, 0xCAFED00D
    .BYTE 0x74, 0x03 // je +5
    ud2
    nop
c_target:
    .rept 16
    mov rsi, QWORD PTR [rsi]
    .endr
    ret

.global no_ibt_target

.align 4096
no_ibt_target:
    .rept 16
    mov rsi, QWORD PTR [rsi]
    .endr
    ret

.align 4096
.global __cfi_d_target
.global d_target
__cfi_d_target:
    ENDBR64
    sub r10d, 0x7e9cb32e
    .BYTE 0x74, 0x03 // je +5
    ud2
    nop
d_target:
    ENDBR64
    mov rax, QWORD PTR [rdi+0x8]
    mov rax, QWORD PTR [rax+0x10]
    mov rax, QWORD PTR [rax+0x18]
    mov rax, QWORD PTR [rax+0x20]
    mov rax, QWORD PTR [rax+0x28]
    mov rax, QWORD PTR [rax+0x30]
    mov rax, QWORD PTR [rax+0x38]
    mov rax, QWORD PTR [rax+0x40]
    ret
