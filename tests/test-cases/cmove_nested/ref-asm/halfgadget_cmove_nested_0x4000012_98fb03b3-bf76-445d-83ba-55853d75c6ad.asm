--------------------- HALF GADGET ----------------------
         cmove_sample:
4000000  mov     rdi, qword ptr [rdx+0x18]
4000004  test    rdi, rdi
4000007  cmove   rdi, rsi
400000b  test    rax, rax
400000e  cmove   rax, rdi
4000012  mov     eax, dword ptr [rax+0x24] ; {Attacker@rax} -> HALF GADGET
4000015  jmp     0x400dead

------------------------------------------------
uuid: 98fb03b3-bf76-445d-83ba-55853d75c6ad

Expr: <BV64 0x24 + rax>
Base: <BV64 0x24>
Attacker: <BV64 rax>
ControlType: ControlType.CONTROLLED

Constraints: [('0x400000e', <Bool rax != 0x0>, 'ConditionType.CMOVE')]
Branches: []


------------------------------------------------
