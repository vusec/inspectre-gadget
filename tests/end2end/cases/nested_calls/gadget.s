.intel_syntax noprefix

nested_calls:
        call    target_1 # store at rsp - 0x8
        call    target_2 # store at rsp - 0x8

        mov    r8, QWORD PTR [rdi]
        movzx  r9, WORD PTR [rdi]
        mov    r10, QWORD PTR [r9 + 0xffffffff81000000] # <<< TRANSMISSION

        jmp    0xdead

target_1:
        ret  # load at rsp - 0x8

target_2:
        ret # load at rsp - 0x8
            # Should not alias with the first ret
