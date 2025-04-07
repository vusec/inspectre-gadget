--------------------- HALF GADGET ----------------------
         disjoint_range:
4000000  mov     rax, qword ptr [rdi+0x28] ; {Attacker@rdi} -> HALF GADGET
4000004  mov     rsi, qword ptr [rsi+0x30]
4000008  cmp     rax, 0xf
400000c  je      exit

------------------------------------------------
uuid: 3a560de8-d88d-4916-9093-3294f98f9ce4

Expr: <BV64 0x28 + rdi>
Base: <BV64 0x28>
Attacker: <BV64 rdi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
