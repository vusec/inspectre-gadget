--------------------- HALF GADGET ----------------------
         cmove_sample:
4000000  test    rdi, rdi
4000003  cmove   rax, rbx
4000007  cmp     rcx, rax
400000a  je      if ; Not Taken   <Bool rcx != rbx>
400000c  jmp     else ; Taken   <Bool True>
         else:
4000019  mov     rsi, qword ptr [rsi+0x18] ; {Attacker@rsi} -> HALF GADGET
400001d  mov     ebx, dword ptr [rsi]
400001f  jmp     0x400dead

------------------------------------------------
uuid: 4cf2d861-ab51-4494-944d-b99d38905f71

Expr: <BV64 0x18 + rsi>
Base: <BV64 0x18>
Attacker: <BV64 rsi>
ControlType: ControlType.CONTROLLED

Constraints: [('0x4000003', <Bool rdi == 0x0>, 'ConditionType.CMOVE')]
Branches: [('0x400000a', <Bool rcx != rbx>, 'Not Taken'), ('0x400000c', <Bool True>, 'Taken')]


------------------------------------------------
