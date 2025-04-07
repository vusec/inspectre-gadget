--------------------- HALF GADGET ----------------------
         disjoint_range:
4000000  mov     rax, qword ptr [rdi+0x28]
4000004  mov     rsi, qword ptr [rsi+0x30] ; {Attacker@rsi} -> HALF GADGET
4000008  cmp     rax, 0xf
400000c  je      exit

------------------------------------------------
uuid: 7628d197-c964-4e96-9646-0c52dba0eceb

Expr: <BV64 0x30 + rsi>
Base: <BV64 0x30>
Attacker: <BV64 rsi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
