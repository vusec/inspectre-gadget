--------------------- HALF GADGET ----------------------
         has_bh_in_lru:
4000000  movsxd  rdi, edi
4000003  mov     rax, 0x27700
400000a  add     rax, qword ptr [rax*0x8-0x7d9dd7a0]
4000012  add     rax, qword ptr [rdi*0x8-0x7d9dd7a0] ; {Attacker@rdi} -> HALF GADGET
400001a  lea     rdx, [rax+0x80]
4000021  cmp     qword ptr [rax], 0x0
4000025  jmp     0x400dead

------------------------------------------------
uuid: 3e00773c-0d52-4f00-b1ab-f6d6bb7b5349

Expr: <BV64 0xffffffff82622860 + (0xfffffff800000000 + (0#29 .. (0#3 .. rdi[31:0]) << 0x3))>
Base: <BV64 0xfffffff782622860>
Attacker: <BV64 0#29 .. (0#3 .. rdi[31:0]) << 0x3>
ControlType: ControlType.CONTROLLED

Constraints: [('0x4000000', <Bool rdi[31:31] != 0>, 'ConditionType.SIGN_EXT')]
Branches: []


------------------------------------------------
