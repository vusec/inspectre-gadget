--------------------- HALF GADGET ----------------------
         cmove_sample:
4000000  mov     rdi, qword ptr [rdx+0x18]
4000004  test    rdi, rdi
4000007  cmove   rdi, rsi
400000b  test    rax, rax
400000e  cmove   rax, rbx
4000012  mov     eax, dword ptr [rax+rdi] ; {Attacker@rax, Attacker@rsi} -> HALF GADGET
4000015  jmp     0x400dead

------------------------------------------------
uuid: 77b14e77-8ca7-45d0-94d7-5851038bf79b

Expr: <BV64 rax + rsi>
Base: None
Attacker: <BV64 rax + rsi>
ControlType: ControlType.CONTROLLED

Constraints: [('0x4000007', <Bool LOAD_64[<BV64 rdx + 0x18>]_20 == 0x0>, 'ConditionType.CMOVE'), ('0x400000e', <Bool rax != 0x0>, 'ConditionType.CMOVE')]
Branches: []


------------------------------------------------
