--------------------- HALF GADGET ----------------------
         cmove_sample:
4000000  test    rdi, rdi
4000003  cmove   rax, rbx
4000007  cmp     rcx, rax
400000a  je      if ; Taken   <Bool rcx == rax>
         if:
400000e  mov     rdi, qword ptr [rax+0x18] ; {Attacker@rax} -> HALF GADGET
4000012  mov     eax, dword ptr [rdi]
4000014  jmp     0x400dead

------------------------------------------------
uuid: b109bd60-f17a-4df2-87b6-0b246b75d1cd

Expr: <BV64 0x18 + rax>
Base: <BV64 0x18>
Attacker: <BV64 rax>
ControlType: ControlType.CONTROLLED

Constraints: [('0x4000003', <Bool rdi != 0x0>, 'ConditionType.CMOVE'), ('0x4000003', <Bool rdi != 0x0>, 'ConditionType.CMOVE')]
Branches: [('0x400000a', <Bool rcx == rax>, 'Taken')]


------------------------------------------------
