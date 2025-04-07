--------------------- HALF GADGET ----------------------
         tainted_func_ptr:
4000000  mov     rsi, qword ptr [rdi] ; {Attacker@rdi} -> {Attacker@0x4000000}
4000003  mov     rax, qword ptr [rcx+rsi] ; {Attacker@rcx, Attacker@0x4000000} -> HALF GADGET
4000007  mov     rcx, qword ptr [rdi+0x20]
400000b  mov     r12, qword ptr [r8]
400000e  xor     r8, r8
4000011  shl     rax, 0x2
4000015  jmp     __x86_indirect_thunk_array

------------------------------------------------
uuid: 96f829c1-9c5b-40b2-8ebf-4c499e7b67bb

Expr: <BV64 rcx + LOAD_64[<BV64 rdi>]_20>
Base: None
Attacker: <BV64 rcx + LOAD_64[<BV64 rdi>]_20>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
