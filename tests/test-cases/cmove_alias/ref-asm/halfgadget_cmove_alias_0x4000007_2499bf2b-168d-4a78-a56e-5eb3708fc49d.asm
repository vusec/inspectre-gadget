--------------------- HALF GADGET ----------------------
         cmove_sample:
4000000  test    rdi, rdi
4000003  cmove   rdi, rsi
4000007  mov     rdi, qword ptr [rdi+0x18] ; {Attacker@rdi} -> HALF GADGET
400000b  mov     rsi, qword ptr [rsi+0x18]
400000f  mov     eax, dword ptr [rdi+rsi]
4000012  jmp     0x400dead

------------------------------------------------
uuid: 2499bf2b-168d-4a78-a56e-5eb3708fc49d

Expr: <BV64 0x18 + rdi>
Base: <BV64 0x18>
Attacker: <BV64 rdi>
ControlType: ControlType.CONTROLLED

Constraints: [('0x4000003', <Bool rdi != 0x0>, 'ConditionType.CMOVE')]
Branches: []


------------------------------------------------
