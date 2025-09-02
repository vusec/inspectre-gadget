--------------------- HALF GADGET ----------------------
         tg3_start_xmit:
4000000  push    r15
4000002  push    r14
4000004  push    r13
4000006  mov     r13, rdi
4000009  push    r12
400000b  push    rbp
400000c  mov     rbp, rsi
400000f  push    rbx
4000010  sub     rsp, 0x58
4000014  mov     eax, gs
4000016  mov     qword ptr [rsp+0x50], rax
400001b  xor     eax, eax
400001d  lea     rax, [rsi+0x900]
4000024  mov     qword ptr [rsp+0x10], rax
4000029  movzx   eax, word ptr [rdi+0x7c] ; {Attacker@rdi} -> HALF GADGET
400002d  lea     rdx, [rax+rax*0x4]
4000031  mov     r12, rdx
4000034  lea     rax, [rax+rdx*0x2]
4000038  shl     rax, 0x6
400003c  shl     r12, 0x6
4000040  add     r12, qword ptr [rsi+0x380]
4000047  mov     qword ptr [rsp+0x8], r12
400004c  lea     r12, [rsi+rax+0xa40]
4000054  mov     rax, qword ptr [rsi+0x1b58]
400005b  lea     rdx, [r12+0x2c0]
4000063  shr     rax, 0x3d
4000067  test    al, 0x1
4000069  cmovne  r12, rdx
400006d  mov     esi, dword ptr [r12+0x240]
4000075  mov     edx, dword ptr [r12+0x248]
400007d  mov     rdi, qword ptr [rdi+0xc8]
4000084  mov     eax, esi
4000086  sub     eax, dword ptr [r12+0x244]
400008e  and     eax, 0x1ff
4000093  sub     edx, eax
4000095  mov     eax, dword ptr [r13+0xc0]
400009c  mov     dword ptr [rsp+0x4c], edx
40000a0  add     rax, rdi
40000a3  movzx   ecx, byte ptr [rax+0x2]
40000a7  add     ecx, 0x1
40000aa  cmp     ecx, edx
40000ac  jmp     0x400dead

------------------------------------------------
uuid: e9c93cd5-4235-4d00-988a-c89dd84ef277

Expr: <BV64 0x7c + rdi>
Base: <BV64 0x7c>
Attacker: <BV64 rdi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: []


------------------------------------------------
