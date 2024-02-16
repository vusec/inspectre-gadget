--------------------- TFP ----------------------
         tfp_independently_controllable:
4000000  mov     rsi, qword ptr [rdi]
4000003  mov     rdx, qword ptr [rdx]
4000006  mov     rbx, qword ptr [rsi]
4000009  add     rcx, rsi
400000c  add     rcx, rdx
400000f  mov     rax, qword ptr [rdi+0x10] ; {Attacker@rdi} > {Attacker@0x400000f}
4000013  call    rax ; {Attacker@0x400000f} > TAINTED FUNCTION POINTER

------------------------------------------------
uuid: 73203a95-0add-4f42-9aab-49c984d35471

Reg: rax
Expr: <BV64 LOAD_64[<BV64 rdi + 0x10>]_23>

Constraints: []
Branches: []

CONTROLLED:
rcx: <BV64 rcx + LOAD_64[<BV64 rdi>]_20 + LOAD_64[<BV64 rdx>]_21>
rsi: <BV64 LOAD_64[<BV64 rdi>]_20>

REGS ALIASING WITH TFP:
rdi: <BV64 rdi>

Uncontrolled Regs: ['rbp', 'rsp']
Unmodified Regs: ['r8', 'r9', 'r10', 'r11', 'r12', 'r13', 'r14', 'r15']
Potential Secrets: ['rbx', 'rdx']

------------------------------------------------
