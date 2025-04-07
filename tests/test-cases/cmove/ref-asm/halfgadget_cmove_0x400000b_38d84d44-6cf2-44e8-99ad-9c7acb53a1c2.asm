--------------------- HALF GADGET ----------------------
         cmove_sample:
4000000  mov     rdi, qword ptr [rdx+0x18]
4000004  test    rdi, rdi
4000007  cmove   rdi, rsi
400000b  mov     eax, dword ptr [rdi] ; {Attacker@rsi} -> HALF GADGET
400000d  jmp     0x400dead

------------------------------------------------
uuid: 38d84d44-6cf2-44e8-99ad-9c7acb53a1c2

Expr: <BV64 rsi>
Base: None
Attacker: <BV64 rsi>
ControlType: ControlType.CONTROLLED

Constraints: [('0x4000007', <Bool LOAD_64[<BV64 rdx + 0x18>]_20 == 0x0>, 'ConditionType.CMOVE')]
Branches: []


------------------------------------------------
