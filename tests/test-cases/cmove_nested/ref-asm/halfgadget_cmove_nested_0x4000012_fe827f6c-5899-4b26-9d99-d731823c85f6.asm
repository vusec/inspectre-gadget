--------------------- HALF GADGET ----------------------
         cmove_sample:
4000000  mov     rdi, qword ptr [rdx+0x18]
4000004  test    rdi, rdi
4000007  cmove   rdi, rsi
400000b  test    rax, rax
400000e  cmove   rax, rdi
4000012  mov     eax, dword ptr [rax+0x24] ; {Attacker@rsi} -> HALF GADGET
4000015  jmp     0x400dead

------------------------------------------------
uuid: fe827f6c-5899-4b26-9d99-d731823c85f6

Expr: <BV64 0x24 + rsi>
Base: <BV64 0x24>
Attacker: <BV64 rsi>
ControlType: ControlType.CONTROLLED

Constraints: [('0x400000e', <Bool rax == 0x0>, 'ConditionType.CMOVE'), ('0x4000007', <Bool LOAD_64[<BV64 rdx + 0x18>]_20 == 0x0>, 'ConditionType.CMOVE')]
Branches: []


------------------------------------------------
