--------------------- HALF GADGET ----------------------
         tainted_func_ptr:
4000000  mov     rsi, qword ptr [rdi]
4000003  mov     rax, qword ptr [rcx+rsi]
4000007  mov     rcx, qword ptr [rdi+0x20]
400000b  mov     r12, qword ptr [r8] ; {Attacker@r8} -> HALF GADGET
400000e  xor     r8, r8
4000011  shl     rax, 0x2
4000015  jmp     __x86_indirect_thunk_array

------------------------------------------------
uuid: 02b35e50-2cc9-4caa-9d94-d3fd8c2fae36

Expr: <BV64 r8>
Base: None
Attacker: <BV64 r8>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
