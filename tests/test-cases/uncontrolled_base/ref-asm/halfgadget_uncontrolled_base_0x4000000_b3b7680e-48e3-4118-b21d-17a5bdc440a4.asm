--------------------- HALF GADGET ----------------------
         uncontrolled_base:
4000000  movzx   r8, byte ptr [rdi] ; {Attacker@rdi} -> HALF GADGET
4000004  mov     rsi, qword ptr  gs:[0x2ac80]
400000d  mov     rdx, qword ptr [rsi]
4000010  mov     rdx, qword ptr [rdx]
4000013  mov     rdx, qword ptr [rdx+r8]
4000017  mov     r9, qword ptr [rsi]
400001a  add     r9, rbx
400001d  mov     r9, qword ptr [r9+r8]
4000021  mov     r10, qword ptr [rsi]
4000024  and     r11, 0xff
400002b  add     r10, r11
400002e  mov     r10, qword ptr [r10+r8]
4000032  ret     

------------------------------------------------
uuid: b3b7680e-48e3-4118-b21d-17a5bdc440a4

Expr: <BV64 rdi>
Base: None
Attacker: <BV64 rdi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
