--------------------- HALF GADGET ----------------------
         sbb_instruction:
4000000  mov     rax, qword ptr [rdi+0x28] ; {Attacker@rdi} -> {Attacker@0x4000000}
4000004  mov     ebx, eax
4000006  cmp     rbx, 0x10
400000a  sbb     rbx, rbx
400000d  and     ebx, eax
400000f  mov     r10, qword ptr [r9+rbx] ; {Attacker@r9, Attacker@0x4000000} -> HALF GADGET
4000013  jmp     0x400dead

------------------------------------------------
uuid: 6fc2887e-01cb-4e6b-abfb-b7726ea2a2af

Expr: <BV64 r9 + (0#32 .. LOAD_64[<BV64 rdi + 0x28>]_20[31:0])>
Base: None
Attacker: <BV64 r9 + (0#32 .. LOAD_64[<BV64 rdi + 0x28>]_20[31:0])>
ControlType: ControlType.CONTROLLED

Constraints: [('0x400000a', <Bool (0#32 .. LOAD_64[<BV64 rdi + 0x28>]_20[31:0]) < 0x10>, 'ConditionType.CMOVE')]
Branches: []


------------------------------------------------
