--------------------- HALF GADGET ----------------------
         uncontrolled_base:
4000000  movzx   r8, byte ptr [rdi] ; {Attacker@rdi} -> {Attacker@0x4000000}
4000004  mov     rsi, qword ptr  gs:[0x2ac80] ; {Uncontrolled@gs} -> {UncontrolledLoad@0x4000004}
400000d  mov     rdx, qword ptr [rsi]
4000010  mov     rdx, qword ptr [rdx]
4000013  mov     rdx, qword ptr [rdx+r8]
4000017  mov     r9, qword ptr [rsi] ; {UncontrolledLoad@0x4000004} -> {UncontrolledLoad@0x4000017}
400001a  add     r9, rbx
400001d  mov     r9, qword ptr [r9+r8] ; {Attacker@rbx, Attacker@0x4000000, UncontrolledLoad@0x4000017} -> HALF GADGET
4000021  mov     r10, qword ptr [rsi]
4000024  and     r11, 0xff
400002b  add     r10, r11
400002e  mov     r10, qword ptr [r10+r8]
4000032  ret     

------------------------------------------------
uuid: fe394da1-980e-4af7-a848-f7ddc73d5110

Expr: <BV64 LOAD_64[<BV64 LOAD_64[<BV64 0x2ac80 + gs>]_21>]_25 + rbx + (0#56 .. LOAD_8[<BV64 rdi>]_20)>
Base: <BV64 LOAD_64[<BV64 LOAD_64[<BV64 0x2ac80 + gs>]_21>]_25>
Attacker: <BV64 rbx + (0#56 .. LOAD_8[<BV64 rdi>]_20)>
ControlType: ControlType.REQUIRES_MEM_LEAK

Constraints: []
Branches: []


------------------------------------------------
