--------------------- HALF GADGET ----------------------
         cmove_sample:
4000000  test    rdi, rdi
4000003  cmove   rdi, rsi
4000007  mov     rdi, qword ptr [rdi+0x18] ; {Attacker@rsi} -> HALF GADGET
400000b  mov     eax, dword ptr [rdi]
400000d  jmp     0x400dead

------------------------------------------------
uuid: cc9b4798-4a0d-440c-9768-30934622a1ec

Expr: <BV64 0x18 + rsi>
Base: <BV64 0x18>
Attacker: <BV64 rsi>
ControlType: ControlType.CONTROLLED

Constraints: [('0x4000003', <Bool rdi == 0x0>, 'ConditionType.CMOVE')]
Branches: []


------------------------------------------------
