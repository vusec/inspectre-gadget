.intel_syntax noprefix

has_bh_in_lru:
   movsxd rdi,edi
   mov    rax,0x27700
   add    rax,QWORD PTR [rax*8-0x7d9dd7a0]
   add    rax,QWORD PTR [rdi*8-0x7d9dd7a0]
   lea    rdx,[rax+0x80]
   cmp    QWORD PTR [rax],0x0
   jmp    0xdead


