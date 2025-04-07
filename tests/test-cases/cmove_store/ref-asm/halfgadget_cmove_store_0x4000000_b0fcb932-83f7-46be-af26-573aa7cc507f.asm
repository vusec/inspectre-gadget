--------------------- HALF GADGET ----------------------
         cmove_sample:
4000000  mov     rdi, qword ptr [rdx+0x18] ; {Attacker@rdx} -> HALF GADGET
4000004  test    rdi, rdi
4000007  cmove   rdi, rsi
400000b  mov     dword ptr [rdi], eax
400000d  mov     qword ptr [rsi], rdi
4000010  mov     rbx, qword ptr [rsi]
4000013  jmp     0x400dead

------------------------------------------------
uuid: b0fcb932-83f7-46be-af26-573aa7cc507f

Expr: <BV64 0x18 + rdx>
Base: <BV64 0x18>
Attacker: <BV64 rdx>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
