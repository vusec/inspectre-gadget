--------------------- HALF GADGET ----------------------
         cmove_sample:
4000000  mov     rdi, qword ptr [rdx+0x18] ; {Attacker@rdx} -> HALF GADGET
4000004  test    rdi, rdi
4000007  cmove   rdi, rsi
400000b  test    rax, rax
400000e  cmove   rax, rdi
4000012  mov     eax, dword ptr [rax+0x24]
4000015  jmp     0x400dead

------------------------------------------------
uuid: 5040b25e-ba7c-49e2-8cc9-6e59c053bb7a

Expr: <BV64 0x18 + rdx>
Base: <BV64 0x18>
Attacker: <BV64 rdx>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
