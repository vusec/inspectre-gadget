--------------------- HALF GADGET ----------------------
         sign_extend:
4000000  movsx   eax, byte ptr [rcx+0x4] ; {Attacker@rcx} -> HALF GADGET
4000004  mov     rdx, qword ptr [rax+0x40]
4000008  jmp     0x400dead

------------------------------------------------
uuid: 944fcf81-71f5-48e6-97c4-5be03b8d0eaf

Expr: <BV64 0x4 + rcx>
Base: <BV64 0x4>
Attacker: <BV64 rcx>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
