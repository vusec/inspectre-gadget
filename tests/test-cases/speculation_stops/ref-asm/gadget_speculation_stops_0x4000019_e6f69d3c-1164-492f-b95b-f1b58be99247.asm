----------------- TRANSMISSION -----------------
         speculation_stops:
4000000  movzx   r9, word ptr [rdi] ; {Attacker@rdi} -> {Secret@0x4000000}
4000004  cmp     rax, 0x0
4000008  je      trans1 ; Not Taken   <Bool rax != 0x0>
400000a  cmp     rax, 0x1
400000e  je      trans2 ; Not Taken   <Bool rax != 0x1>
4000010  cmp     rax, 0x2
4000014  je      trans3 ; Not Taken   <Bool rax != 0x2>
         trans0:
4000016  sfence  
4000019  mov     r10, qword ptr [r9-0x7f000000] ; {Secret@0x4000000} -> TRANSMISSION
4000020  jmp     end

------------------------------------------------
uuid: e6f69d3c-1164-492f-b95b-f1b58be99247
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
  - Expr: <BV64 0xffffffff81000000>
  - Range: 0xffffffff81000000
  - Independent Expr: <BV64 0xffffffff81000000>
  - Independent Range: 0xffffffff81000000
Transmission:
  - Expr: <BV64 0xffffffff81000000 + (0#48 .. LOAD_16[<BV64 rdi>]_20)>
  - Range: (0xffffffff81000000,0xffffffff8100ffff, 0x1) Exact: True

Register Requirements: {<BV64 rdi>}
Constraints: []
Branches: [('0x4000008', <Bool rax != 0x0>, 'Not Taken'), ('0x400000e', <Bool rax != 0x1>, 'Not Taken'), ('0x4000014', <Bool rax != 0x2>, 'Not Taken')]
------------------------------------------------
