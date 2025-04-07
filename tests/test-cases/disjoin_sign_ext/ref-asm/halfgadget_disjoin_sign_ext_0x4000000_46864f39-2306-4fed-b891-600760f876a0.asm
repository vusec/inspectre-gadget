--------------------- HALF GADGET ----------------------
         disjoin_sign_extend:
4000000  movsxd  rax, dword ptr [rcx+0x4] ; {Attacker@rcx} -> HALF GADGET
4000004  movzx   rsi, word ptr [rdi]
4000008  mov     rdx, qword ptr [rax+rsi+0x4096]
4000010  jmp     0x400dead

------------------------------------------------
uuid: 46864f39-2306-4fed-b891-600760f876a0

Expr: <BV64 0x4 + rcx>
Base: <BV64 0x4>
Attacker: <BV64 rcx>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
