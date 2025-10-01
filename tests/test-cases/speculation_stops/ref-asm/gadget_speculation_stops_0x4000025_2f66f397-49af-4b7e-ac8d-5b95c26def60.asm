----------------- TRANSMISSION -----------------
         speculation_stops:
4000000  movzx   r9, word ptr [rdi] ; {Attacker@rdi} -> {Secret@0x4000000}
4000004  cmp     rax, 0x0
4000008  je      trans1 ; Taken   <Bool rax == 0x0>
         trans1:
4000022  lfence  
4000025  mov     r10, qword ptr [rsi+r9-0x10] ; {Attacker@rsi, Secret@0x4000000} -> TRANSMISSION
400002a  jmp     end

------------------------------------------------
uuid: 2f66f397-49af-4b7e-ac8d-5b95c26def60
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
  - Expr: <BV64 0xfffffffffffffff0 + rsi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Independent Expr: <BV64 0xfffffffffffffff0 + rsi>
  - Independent Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmission:
  - Expr: <BV64 0xfffffffffffffff0 + rsi + (0#48 .. LOAD_16[<BV64 rdi>]_20)>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rsi>, <BV64 rdi>}
Constraints: []
Branches: [('0x4000008', <Bool rax == 0x0>, 'Taken')]
------------------------------------------------
