.intel_syntax noprefix

.global option1_2_5
.align 4096
option1_2_5:
    .rept 2
        add eax, 0x1
        .rept 5
            je option1_2_5
        .endr
    .endr
    jne option1_2_5
    int3



.global option2_1_9
.align 4096
option2_1_9:
    .rept 1
        add eax, 0x1
        .rept 9
            je option2_1_9
        .endr
    .endr
    jne option2_1_9
    int3

.global option3_2_8
.align 4096
option3_2_8:
    .rept 2
        add eax, 0x1
        .rept 8
            je option3_2_8
        .endr
    .endr
    jne option3_2_8
    int3

.global option_4_0
.align 4096
option_4_0:
    mov rax, 0x1
    cmp rax, 0x1
option_4_0_inner:
    .rept 8
        je option_4_0_inner
    .endr
    jne option_4_0_inner
    int3



