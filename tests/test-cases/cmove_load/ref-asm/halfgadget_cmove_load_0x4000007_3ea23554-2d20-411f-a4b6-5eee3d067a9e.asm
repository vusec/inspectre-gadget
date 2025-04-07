--------------------- HALF GADGET ----------------------
         cmove_sample:
4000000  test    rdi, rdi
4000003  cmove   rdi, rsi
4000007  mov     rdi, qword ptr [rdi+0x18] ; {Attacker@rdi} -> HALF GADGET
400000b  mov     eax, dword ptr [rdi]
400000d  jmp     0x400dead

------------------------------------------------
uuid: 3ea23554-2d20-411f-a4b6-5eee3d067a9e

Expr: <BV64 0x18 + rdi>
Base: <BV64 0x18>
Attacker: <BV64 rdi>
ControlType: ControlType.CONTROLLED

Constraints: [('0x4000003', <Bool rdi != 0x0>, 'ConditionType.CMOVE')]
Branches: []


------------------------------------------------
