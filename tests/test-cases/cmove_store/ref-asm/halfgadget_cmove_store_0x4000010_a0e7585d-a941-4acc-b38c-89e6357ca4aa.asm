--------------------- HALF GADGET ----------------------
         cmove_sample:
4000000  mov     rdi, qword ptr [rdx+0x18]
4000004  test    rdi, rdi
4000007  cmove   rdi, rsi
400000b  mov     dword ptr [rdi], eax
400000d  mov     qword ptr [rsi], rdi
4000010  mov     rbx, qword ptr [rsi] ; {Attacker@rsi} -> HALF GADGET
4000013  jmp     0x400dead

------------------------------------------------
uuid: a0e7585d-a941-4acc-b38c-89e6357ca4aa

Expr: <BV64 rsi>
Base: None
Attacker: <BV64 rsi>
ControlType: ControlType.CONTROLLED

Constraints: [('0x4000007', <Bool LOAD_64[<BV64 rdx + 0x18>]_20 != 0x0>, 'ConditionType.CMOVE')]
Branches: []


------------------------------------------------
