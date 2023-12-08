----------------- TRANSMISSION -----------------
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
4000029  movzx   eax, word ptr [rdi+0x7c] ; {Attacker@rdi} > {Secret@0x4000029}
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
4000075  mov     edx, dword ptr [r12+0x248] ; {Attacker@rsi, Secret@0x4000029} > TRANSMISSION
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
uuid: 59779c8c-f6e3-41cb-9fcf-97743e1b898e

Secret Address:
  - Expr: <BV64 rdi + 0x7c>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 ((0#48 .. LOAD_16[<BV64 rdi + 0x7c>]_40) << 0x6) + ((0#6 .. ((0#42 .. LOAD_16[<BV64 rdi + 0x7c>]_40) << 0x1) + ((0#40 .. (0#2 .. LOAD_16[<BV64 rdi + 0x7c>]_40) << 0x2) << 0x1)) << 0x6)>
  - Range: (0x0,0x2bffd40, 0x40) Exact: False
  - Spread: 6 - 26
  - Number of Bits Inferable: 16
Base:
  - Expr: <BV64 0xc88 + rsi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Independent Expr: <BV64 0xc88 + rsi>
  - Independent Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmission:
  - Expr: <BV64 0xc88 + rsi + (((0#48 .. LOAD_16[<BV64 rdi + 0x7c>]_40) << 0x6) + ((0#6 .. ((0#42 .. LOAD_16[<BV64 rdi + 0x7c>]_40) << 0x1) + ((0#40 .. (0#2 .. LOAD_16[<BV64 rdi + 0x7c>]_40) << 0x2) << 0x1)) << 0x6))>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rsi>, <BV64 rdi>}
Constraints: [('0x400006d', <Bool ((0 .. LOAD_64[<BV64 rsi + 0x1b58>]_31[63:61]) & 1) == 0>), ('0x4000075', <Bool ((0 .. LOAD_64[<BV64 rsi + 0x1b58>]_43[63:61]) & 1) == 0>), ('0x4000086', <Bool ((0 .. LOAD_64[<BV64 rsi + 0x1b58>]_56[63:61]) & 1) != 0>)]
Branches: []
------------------------------------------------
