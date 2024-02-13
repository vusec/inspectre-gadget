----------------- TRANSMISSION -----------------
         constraint_secret:
4000000  movzx   r9, word ptr [rdi]
4000004  cmp     r9, 0xffff
400000b  ja      trans1 ; Not Taken   <Bool (0#48 .. LOAD_16[<BV64 rdi>]_20) <= 0xffff>
400000d  mov     rsi, qword ptr [r9-0x80000000]
4000014  cmp     r9, 0xff
400001b  ja      trans1 ; Taken   <Bool (0x0 .. LOAD_16[<BV64 rdi>]_20) > 0xff>
         trans1:
4000026  movzx   r9, word ptr [rdi+0x20] ; {Attacker@rdi} > {Secret@0x4000026}
400002b  cmp     r9, 0x0
400002f  je      end ; Not Taken   <Bool LOAD_16[<BV64 rdi + 0x20>]_22 != 0x0>
4000031  mov     r11, qword ptr [r9-0x60000000] ; {Secret@0x4000026} > TRANSMISSION
         end:
4000038  jmp     0x400dead

------------------------------------------------
uuid: befb2791-4a05-40be-a829-6b84bb0e3386

Secret Address:
  - Expr: <BV64 rdi + 0x20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#48 .. LOAD_16[<BV64 rdi + 0x20>]_22>
  - Range: (0x0,0xffff, 0x1) Exact: True
  - Spread: 0 - 15
  - Number of Bits Inferable: 16
Base:
  - Expr: <BV64 0xffffffffa0000000>
  - Range: 0xffffffffa0000000
  - Independent Expr: <BV64 0xffffffffa0000000>
  - Independent Range: 0xffffffffa0000000
Transmission:
  - Expr: <BV64 0xffffffffa0000000 + (0#48 .. LOAD_16[<BV64 rdi + 0x20>]_22)>
  - Range: (0xffffffffa0000000,0xffffffffa000ffff, 0x1) Exact: True

Register Requirements: {<BV64 rdi>}
Constraints: []
Branches: [(67108875, <Bool (0#48 .. LOAD_16[<BV64 rdi>]_20) <= 0xffff>, 'Not Taken'), (67108891, <Bool (0x0 .. LOAD_16[<BV64 rdi>]_20) > 0xff>, 'Taken'), (67108911, <Bool LOAD_16[<BV64 rdi + 0x20>]_22 != 0x0>, 'Not Taken')]
------------------------------------------------
