--------------------- HALF GADGET ----------------------
         cmove_sample:
4000000  mov     rdi, qword ptr [rdx+0x18] ; {Attacker@rdx} -> HALF GADGET
4000004  test    rdi, rdi
4000007  cmove   rdi, rsi
400000b  mov     eax, dword ptr [rdi]
400000d  jmp     0x400dead

------------------------------------------------
uuid: 84dcc648-4d74-4ad4-83a8-decf150f6215

Expr: <BV64 0x18 + rdx>
Base: <BV64 0x18>
Attacker: <BV64 rdx>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
