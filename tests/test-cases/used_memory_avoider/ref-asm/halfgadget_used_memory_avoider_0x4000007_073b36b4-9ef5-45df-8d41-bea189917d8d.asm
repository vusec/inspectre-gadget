--------------------- HALF GADGET ----------------------
         used_memory_avoider:
4000000  mov     qword ptr [rcx], 0xff
4000007  mov     r8, qword ptr [rdi] ; {Attacker@rdi} -> HALF GADGET
400000a  and     r8, 0xffff
4000011  mov     r9, qword ptr [rsi]
4000014  mov     r10, qword ptr [r8+r9]
4000018  jmp     0x400dead

------------------------------------------------
uuid: 073b36b4-9ef5-45df-8d41-bea189917d8d

Expr: <BV64 rdi>
Base: None
Attacker: <BV64 rdi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
