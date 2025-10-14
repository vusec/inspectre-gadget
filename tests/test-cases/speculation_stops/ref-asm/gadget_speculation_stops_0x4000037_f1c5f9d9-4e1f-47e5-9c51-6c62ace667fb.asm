----------------- TRANSMISSION -----------------
         speculation_stops:
4000000  movzx   r9, word ptr [rdi] ; {Attacker@rdi} -> {Secret@0x4000000}
4000004  cmp     rax, 0x0
4000008  je      trans1 ; Not Taken   <Bool rax != 0x0>
400000a  cmp     rax, 0x1
400000e  je      trans2 ; Not Taken   <Bool rax != 0x1>
4000010  cmp     rax, 0x2
4000014  je      trans3 ; Taken   <Bool rax == 0x2>
         trans3:
4000035  cpuid   
4000037  mov     r10, qword ptr [rsi+r9] ; {Attacker@rsi, Secret@0x4000000} -> TRANSMISSION
         end:
400003b  jmp     0x400dead

------------------------------------------------
uuid: f1c5f9d9-4e1f-47e5-9c51-6c62ace667fb
transmitter: TransmitterType.LOAD

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

Register Requirements: ['<BV64 rdi>', '<BV64 rsi>']
Constraints: []
Branches: [('0x4000008', '<Bool rax != 0x0>', 'Not Taken'), ('0x400000e', '<Bool rax != 0x1>', 'Not Taken'), ('0x4000014', '<Bool rax == 0x2>', 'Taken')]
------------------------------------------------
