--------------------- HALF GADGET ----------------------
         uncontrolled_stored_in_mem:
4000000  mov     dword ptr [rdx], 0x7000000
4000006  mov     r8d, dword ptr [rdx]
4000009  mov     r9, qword ptr [rdi+0xff]
4000010  and     r9, 0xffff
4000017  mov     r10, qword ptr [r8+r9-0x7f000000]
400001f  mov     dword ptr [rsi], 0x0
4000025  mov     r9d, dword ptr [rsi]
4000028  and     r9, 0xffff
400002f  mov     r11, qword ptr [r9-0x7f000000]
4000036  mov     rdx, 0xffffffff85000000
400003d  mov     rax, qword ptr [rdx] ; set() -> {UncontrolledLoad@0x400003d}
4000040  mov     rbx, qword ptr [rax] ; {UncontrolledLoad@0x400003d} -> {UncontrolledLoad@0x4000040}
4000043  mov     r14, qword ptr [rcx+rbx] ; {UncontrolledLoad@0x4000040, Attacker@rcx} -> HALF GADGET
4000047  jmp     0x400dead

------------------------------------------------
uuid: 0c5d5c5f-c554-4b3c-a4c5-eb9c756b2cba

Expr: <BV64 rcx + LOAD_64[<BV64 LOAD_64[<BV64 0xffffffff85000000>]_27>]_28>
Base: <BV64 LOAD_64[<BV64 LOAD_64[<BV64 0xffffffff85000000>]_27>]_28>
Attacker: <BV64 rcx>
ControlType: ControlType.REQUIRES_MEM_LEAK

Constraints: []
Branches: []


------------------------------------------------
