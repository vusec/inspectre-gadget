--------------------- HALF GADGET ----------------------
         cmove_sample:
4000000  test    rdi, rdi
4000003  cmove   rdi, rsi
4000007  mov     rdi, qword ptr [rdi+0x18]
400000b  mov     rsi, qword ptr [rsi+0x18] ; {Attacker@rsi} -> HALF GADGET
400000f  mov     eax, dword ptr [rdi+rsi]
4000012  jmp     0x400dead

------------------------------------------------
uuid: 9484a02f-930a-43d3-a063-a328c27ef6e5

Expr: <BV64 0x18 + rsi>
Base: <BV64 0x18>
Attacker: <BV64 rsi>
ControlType: ControlType.CONTROLLED

Constraints: [('0x4000003', <Bool rdi != 0x0>, 'ConditionType.CMOVE')]
Branches: []


------------------------------------------------
