--------------------- HALF GADGET ----------------------
         cmove_sample:
4000000  test    rdi, rdi
4000003  cmove   rax, rbx
4000007  cmp     rcx, rax
400000a  je      if ; Taken   <Bool rcx == rbx>
         if:
400000e  mov     rdi, qword ptr [rdi+0x18] ; {Attacker@rdi} -> HALF GADGET
4000012  mov     eax, dword ptr [rdi]
4000014  jmp     0x400dead

------------------------------------------------
uuid: 545882a8-8ca2-41d7-a804-14ba600d60f5

Expr: <BV64 0x18 + rdi>
Base: <BV64 0x18>
Attacker: <BV64 rdi>
ControlType: ControlType.CONTROLLED

Constraints: [('0x4000003', <Bool rdi == 0x0>, 'ConditionType.CMOVE')]
Branches: [('0x400000a', <Bool rcx == rbx>, 'Taken')]


------------------------------------------------
