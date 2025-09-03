--------------------- HALF GADGET ----------------------
         store_half_overlap:
4000000  mov     dword ptr [r8], esi
4000003  mov     rdi, qword ptr [r8]
4000006  movzx   r11, word ptr [rdx] ; {Attacker@rdx} -> {Attacker@0x4000006}
400000a  mov     rdi, qword ptr [r11+rdi-0x7f000000] ; {Attacker@0x4000006, Uncontrolled@MEM_32[<BV64 r8> + 32]_21, Attacker@rsi} -> HALF GADGET
4000012  jmp     0x400dead

------------------------------------------------
uuid: 5e06fbb7-dc6e-4198-b5f6-3ab501e6d674

Expr: <BV64 0xffffffff81000000 + (0#48 .. LOAD_16[<BV64 rdx>]_22) + (((0#32 .. MEM_32[<BV64 r8> + 32]_21) << 0x20) + (0#32 .. rsi[31:0]))>
Base: <BV64 0xffffffff81000000 + ((0#32 .. MEM_32[<BV64 r8> + 32]_21) << 0x20)>
Attacker: <BV64 (0#48 .. LOAD_16[<BV64 rdx>]_22) + (0#32 .. rsi[31:0])>
ControlType: ControlType.REQUIRES_MEM_LEAK

Constraints: []
Branches: []


------------------------------------------------
