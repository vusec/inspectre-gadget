--------------------- HALF GADGET ----------------------
         tfp_independently_controllable:
4000000  mov     rsi, qword ptr [rdi]
4000003  mov     rdx, qword ptr [rdx]
4000006  mov     rbx, qword ptr [rsi]
4000009  add     rcx, rsi
400000c  add     rcx, rdx
400000f  mov     rax, qword ptr [rdi+0x10] ; {Attacker@rdi} -> HALF GADGET
4000013  call    rax

------------------------------------------------
uuid: 507aae90-1d3d-4f2d-a372-aca2a355d8ab

Expr: <BV64 0x10 + rdi>
Base: <BV64 0x10>
Attacker: <BV64 rdi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
