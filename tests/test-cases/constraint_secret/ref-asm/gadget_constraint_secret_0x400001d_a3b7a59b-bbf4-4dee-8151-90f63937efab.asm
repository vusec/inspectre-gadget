----------------- TRANSMISSION -----------------
         constraint_secret:
4000000  movzx   r9, word ptr [rdi] ; {Attacker@rdi} -> {Secret@0x4000000}
4000004  cmp     r9, 0xffff
400000b  ja      trans1 ; Not Taken   <Bool (0#48 .. LOAD_16[<BV64 rdi>]_20) <= 0xffff>
400000d  mov     rsi, qword ptr [r9-0x80000000]
4000014  cmp     r9, 0xff
400001b  ja      trans1 ; Not Taken   <Bool (0x0 .. LOAD_16[<BV64 rdi>]_20) <= 0xff>
400001d  mov     r10, qword ptr [r9-0x70000000] ; {Secret@0x4000000} -> TRANSMISSION
4000024  jmp     end

------------------------------------------------
uuid: a3b7a59b-bbf4-4dee-8151-90f63937efab
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
  - Expr: <BV64 0xffffffff90000000>
  - Range: 0xffffffff90000000
  - Independent Expr: <BV64 0xffffffff90000000>
  - Independent Range: 0xffffffff90000000
Transmission:
  - Expr: <BV64 0xffffffff90000000 + (0#48 .. LOAD_16[<BV64 rdi>]_20)>
  - Range: (0xffffffff90000000,0xffffffff9000ffff, 0x1) Exact: True

Register Requirements: {<BV64 rdi>}
Constraints: []
Branches: [('0x400000b', <Bool (0#48 .. LOAD_16[<BV64 rdi>]_20) <= 0xffff>, 'Not Taken'), ('0x400001b', <Bool (0x0 .. LOAD_16[<BV64 rdi>]_20) <= 0xff>, 'Not Taken')]
------------------------------------------------
