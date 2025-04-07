--------------------- HALF GADGET ----------------------
         tainted_func_ptr:
4000000  mov     rsi, qword ptr [rdi] ; {Attacker@rdi} -> HALF GADGET
4000003  mov     rax, qword ptr [rcx+rsi]
4000007  mov     rcx, qword ptr [rdi+0x20]
400000b  mov     r12, qword ptr [r8]
400000e  xor     r8, r8
4000011  shl     rax, 0x2
4000015  jmp     __x86_indirect_thunk_array

------------------------------------------------
uuid: 002a3cb6-2e7c-4bcc-822f-fec1e2285cda

Expr: <BV64 rdi>
Base: None
Attacker: <BV64 rdi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
