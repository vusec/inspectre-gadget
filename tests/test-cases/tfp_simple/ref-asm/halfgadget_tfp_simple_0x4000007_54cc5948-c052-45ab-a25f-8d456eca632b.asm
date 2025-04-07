--------------------- HALF GADGET ----------------------
         tainted_func_ptr:
4000000  mov     rsi, qword ptr [rdi]
4000003  mov     rax, qword ptr [rcx+rsi]
4000007  mov     rcx, qword ptr [rdi+0x20] ; {Attacker@rdi} -> HALF GADGET
400000b  mov     r12, qword ptr [r8]
400000e  xor     r8, r8
4000011  shl     rax, 0x2
4000015  jmp     __x86_indirect_thunk_array

------------------------------------------------
uuid: 54cc5948-c052-45ab-a25f-8d456eca632b

Expr: <BV64 0x20 + rdi>
Base: <BV64 0x20>
Attacker: <BV64 rdi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
