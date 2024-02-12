.intel_syntax noprefix

uncontrolled_base:
   movzx  r8, BYTE PTR [rdi]        # load of secet
   mov    rsi, QWORD PTR gs:0x2ac80 # base load 1


   # Not exploitable, uncontrolled base
   mov    rdx, QWORD PTR [rsi]      # base load 2
   mov    rdx, QWORD PTR [rdx]      # base load 3
   mov    rdx, QWORD PTR [rdx + r8] # transmisson 1

   # Exploitable, fully controllable base
   mov    r9, QWORD PTR [rsi] # base load 2
   add    r9, rbx
   mov    r9, QWORD PTR [r9 + r8]   # transmisson 2


   # Known false postive: uncontrollable base with small
   # controllable part. We can fix this by adding an 'controllable' base range
   mov    r10, QWORD PTR [rsi] # base load 2
   and    r11, 0xff
   add    r10, r11
   mov    r10, QWORD PTR [r10 + r8]  # transmisson 3


   ret
