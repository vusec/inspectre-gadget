--------------------- HALF GADGET ----------------------
         cmove_sample:
4000000  test    rdi, rdi
4000003  cmove   rax, rbx
4000007  cmp     rcx, rax
400000a  je      if ; Taken   <Bool rcx == rbx>
         if:
400000e  mov     rdi, qword ptr [rax+0x18] ; {Attacker@rbx} -> HALF GADGET
4000012  mov     eax, dword ptr [rdi]
4000014  jmp     0x400dead

------------------------------------------------
uuid: 32efbdbe-08ff-4452-9eed-0f577bd0dbb7

Expr: <BV64 0x18 + rbx>
Base: <BV64 0x18>
Attacker: <BV64 rbx>
ControlType: ControlType.CONTROLLED

Constraints: [('0x4000003', <Bool rdi == 0x0>, 'ConditionType.CMOVE'), ('0x4000003', <Bool rdi == 0x0>, 'ConditionType.CMOVE')]
Branches: [('0x400000a', <Bool rcx == rbx>, 'Taken')]


------------------------------------------------
