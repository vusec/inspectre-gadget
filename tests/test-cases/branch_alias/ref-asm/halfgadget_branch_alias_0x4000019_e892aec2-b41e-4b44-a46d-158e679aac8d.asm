--------------------- HALF GADGET ----------------------
         cmove_sample:
4000000  test    rdi, rdi
4000003  cmove   rax, rbx
4000007  cmp     rcx, rax
400000a  je      if ; Not Taken   <Bool rcx != rax>
400000c  jmp     else ; Taken   <Bool True>
         else:
4000019  mov     rsi, qword ptr [rbx+0x18] ; {Attacker@rbx} -> HALF GADGET
400001d  mov     ebx, dword ptr [rsi]
400001f  jmp     0x400dead

------------------------------------------------
uuid: e892aec2-b41e-4b44-a46d-158e679aac8d

Expr: <BV64 0x18 + rbx>
Base: <BV64 0x18>
Attacker: <BV64 rbx>
ControlType: ControlType.CONTROLLED

Constraints: [('0x4000003', <Bool rdi != 0x0>, 'ConditionType.CMOVE')]
Branches: [('0x400000a', <Bool rcx != rax>, 'Not Taken'), ('0x400000c', <Bool True>, 'Taken')]


------------------------------------------------
