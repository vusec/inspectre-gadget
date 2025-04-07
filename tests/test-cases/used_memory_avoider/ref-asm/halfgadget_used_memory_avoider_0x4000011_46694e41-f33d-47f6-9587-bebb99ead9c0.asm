--------------------- HALF GADGET ----------------------
         used_memory_avoider:
4000000  mov     qword ptr [rcx], 0xff
4000007  mov     r8, qword ptr [rdi]
400000a  and     r8, 0xffff
4000011  mov     r9, qword ptr [rsi] ; {Attacker@rsi} -> HALF GADGET
4000014  mov     r10, qword ptr [r8+r9]
4000018  jmp     0x400dead

------------------------------------------------
uuid: 46694e41-f33d-47f6-9587-bebb99ead9c0

Expr: <BV64 rsi>
Base: None
Attacker: <BV64 rsi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
