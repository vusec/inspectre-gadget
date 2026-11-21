.intel_syntax noprefix

code_load:
   cmp    r8, 0x0
   je     trans1
   cmp    r8, 0x1
   je     trans2
   cmp    r8, 0x2
   je     trans3


trans0:
   movzx  rsi, WORD PTR [rdi]       # load of secet
   lea    rax, [rdx + rsi]
   jmp    rax


trans1:
   mov    rax, QWORD PTR [rdi]     # load of unmasked secet
   jmp    rax

trans2:
   movzx  rax, WORD PTR [rdi]          # load of secet
   jmp    QWORD PTR [rax*8-0x7f000000]

trans3:
   jmp    [rdi]
