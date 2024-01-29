--------------------- TFP ----------------------
         tainted_func_ptr:
4000000  mov     rsi, qword ptr [rdi] ; {Attacker@rdi} > {Attacker@0x4000000}
4000003  mov     rax, qword ptr [rcx+rsi] ; {Attacker@rcx, Attacker@0x4000000} > {Attacker@0x4000003}
4000007  mov     rcx, qword ptr [rdi+0x20]
400000b  mov     r12, qword ptr [r8]
400000e  xor     r8, r8
4000011  shl     rax, 0x2
4000015  jmp     __x86_indirect_thunk_array ; {Attacker@0x4000003} > TAINTED FUNCTION POINTER

------------------------------------------------
uuid: 473ffa60-98cf-4746-a76f-e2d45a1cb7d5

Reg: rax
Expr: <BV64 LOAD_64[<BV64 rcx + LOAD_64[<BV64 rdi>]_20>]_21[61:0] .. 0>

Constraints: []
Branches: []

CONTROLLED:
rcx: <BV64 LOAD_64[<BV64 rdi + 0x20>]_22>
rsi: <BV64 LOAD_64[<BV64 rdi>]_20>
r12: <BV64 LOAD_64[<BV64 r8>]_23>

REGS ALIASING WITH TFP:

Uncontrolled Regs: ['rbp', 'rsp', 'r8']
Unmodified Regs: ['rbx', 'rdx', 'rdi', 'r9', 'r10', 'r11', 'r13', 'r14', 'r15']

------------------------------------------------
