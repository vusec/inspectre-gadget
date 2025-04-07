--------------------- HALF GADGET ----------------------
         disjoin_sign_extend:
4000000  movsxd  rax, dword ptr [rcx+0x4]
4000004  movzx   rsi, word ptr [rdi] ; {Attacker@rdi} -> HALF GADGET
4000008  mov     rdx, qword ptr [rax+rsi+0x4096]
4000010  jmp     0x400dead

------------------------------------------------
uuid: 7d4e334e-3b07-4e2b-8daf-bb3f5b14b12f

Expr: <BV64 rdi>
Base: None
Attacker: <BV64 rdi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
