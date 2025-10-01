----------------- TRANSMISSION -----------------
         speculation_stops:
4000000  movzx   r9, word ptr [rdi] ; {Attacker@rdi} -> {Secret@0x4000000}
4000004  cmp     rax, 0x0
4000008  je      trans1 ; Not Taken   <Bool rax != 0x0>
400000a  cmp     rax, 0x1
400000e  je      trans2 ; Taken   <Bool rax == 0x1>
         trans2:
400002c  mfence  
400002f  mov     r10, qword ptr [rsi+r9] ; {Secret@0x4000000, Attacker@rsi} -> TRANSMISSION
4000033  jmp     end

------------------------------------------------
uuid: bf0f2995-c7fc-40ad-a6ae-94bbf253a91b
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

Register Requirements: {<BV64 rsi>, <BV64 rdi>}
Constraints: []
Branches: [('0x4000008', <Bool rax != 0x0>, 'Not Taken'), ('0x400000e', <Bool rax == 0x1>, 'Taken')]
------------------------------------------------
