.intel_syntax noprefix

# Complex transmission, in the sence that the transmission is not a default
# add operation. But the transbase + transsecret are packed within
# a more complex operaton; in this gadget a shift

complex_transmission:
   mov    r8, QWORD PTR [rdi] # load of secret
   mov    r9, QWORD PTR [rsi] # load of transbase
   add    r9, r8
   shl    r9, 0x6             # after the add, we shift
   mov    r10, QWORD PTR [r9] # transmission

   # Use one value for a complex transmission
   mov    r8, QWORD PTR [rdi] # load of secret
   mov    r9, QWORD PTR [rsi] # load of transbase

   mov    rax, 8
   mul    r8
   mov    r11, QWORD PTR [rax] # transmission

   # Use two independent values for a complex transmission
   mov    rax, r8
   mul    r9
   mov    r12, QWORD PTR [rax] # transmission

   # Use two dependent values for a complex transmission
   mov    rax, r8
   mul    rdi
   mov    r13, QWORD PTR [rax] # transmission


	jmp    0xdead
