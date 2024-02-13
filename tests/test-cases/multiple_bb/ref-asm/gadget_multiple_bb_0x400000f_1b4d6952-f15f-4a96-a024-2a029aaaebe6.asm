----------------- TRANSMISSION -----------------
         multiple_bb:
4000000  mov     r8, qword ptr [rdi]
4000003  movzx   r9, word ptr [rdi] ; {Attacker@rdi} > {Secret@0x4000003}
4000007  cmp     rax, 0x0
400000b  je      trans1 ; Not Taken   <Bool rax != 0x0>
400000d  jmp     trans0 ; Taken   <Bool True>
         trans0:
400000f  mov     r10, qword ptr [r9-0x7f000000] ; {Secret@0x4000003} > TRANSMISSION
4000016  mov     r11, qword ptr [rsi]
4000019  jmp     end

------------------------------------------------
uuid: 1b4d6952-f15f-4a96-a024-2a029aaaebe6

Secret Address:
  - Expr: <BV64 rdi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#48 .. LOAD_16[<BV64 rdi>]_21>
  - Range: (0x0,0xffff, 0x1) Exact: True
  - Spread: 0 - 15
  - Number of Bits Inferable: 16
Base:
  - Expr: <BV64 0xffffffff81000000>
  - Range: 0xffffffff81000000
  - Independent Expr: <BV64 0xffffffff81000000>
  - Independent Range: 0xffffffff81000000
Transmission:
  - Expr: <BV64 0xffffffff81000000 + (0#48 .. LOAD_16[<BV64 rdi>]_21)>
  - Range: (0xffffffff81000000,0xffffffff8100ffff, 0x1) Exact: True

Register Requirements: {<BV64 rdi>}
Constraints: []
Branches: [(67108875, <Bool rax != 0x0>, 'Not Taken'), (67108877, <Bool True>, 'Taken')]
------------------------------------------------
