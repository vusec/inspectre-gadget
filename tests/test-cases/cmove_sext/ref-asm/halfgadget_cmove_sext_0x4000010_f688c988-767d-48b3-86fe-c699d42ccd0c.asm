--------------------- HALF GADGET ----------------------
         cmove_sample:
4000000  mov     edi, dword ptr [rdx+0x18]
4000003  movsxd  rdi, edi
4000006  mov     rbx, rdi
4000009  test    rdi, rdi
400000c  cmove   rdi, rsi
4000010  mov     eax, dword ptr [rdi] ; {Attacker@rsi} -> HALF GADGET
4000012  mov     ecx, dword ptr [rbx+0x20]
4000015  jmp     0x400dead

------------------------------------------------
uuid: f688c988-767d-48b3-86fe-c699d42ccd0c

Expr: <BV64 rsi>
Base: None
Attacker: <BV64 rsi>
ControlType: ControlType.CONTROLLED

Constraints: [('0x400000c', <Bool (0x0 .. LOAD_32[<BV64 rdx + 0x18>]_20) == 0x0>, 'ConditionType.CMOVE'), ('0x4000003', <Bool LOAD_32[<BV64 rdx + 0x18>]_20[31:31] == 0>, 'ConditionType.SIGN_EXT')]
Branches: []


------------------------------------------------
