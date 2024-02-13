----------------- TRANSMISSION -----------------
         speculation_stops:
4000000  movzx   r9, word ptr [rdi] ; {Attacker@rdi} > {Secret@0x4000000}
4000004  cmp     rax, 0x0
4000008  je      trans1 ; Not Taken   <Bool rax != 0x0>
400000a  cmp     rax, 0x1
400000e  je      trans2 ; Not Taken   <Bool rax != 0x1>
4000010  cmp     rax, 0x2
4000014  je      trans3 ; Taken   <Bool rax == 0x2>
         trans3:
4000035  cpuid   
4000037  mov     r10, qword ptr [rsi+r9] ; {Secret@0x4000000, Attacker@rsi} > TRANSMISSION
         end:
400003b  jmp     0x400dead

------------------------------------------------
uuid: 5460941c-0865-4576-acce-aa21a8dc727f

Secret Address:
  - Expr: <BV64 rdi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#48 .. LOAD_16[<BV64 rdi>]_20>
  - Range: (0x0,0xffff, 0x1) Exact: True
  - Spread: 0 - 15
  - Number of Bits Inferable: 16
Base:
  - Expr: <BV64 rsi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Independent Expr: <BV64 rsi>
  - Independent Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmission:
  - Expr: <BV64 rsi + (0#48 .. LOAD_16[<BV64 rdi>]_20)>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rdi>, <BV64 rsi>}
Constraints: []
Branches: [(67108872, <Bool rax != 0x0>, 'Not Taken'), (67108878, <Bool rax != 0x1>, 'Not Taken'), (67108884, <Bool rax == 0x2>, 'Taken')]
------------------------------------------------
