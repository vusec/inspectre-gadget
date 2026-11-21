----------------- TRANSMISSION -----------------
         unsat_conflicting_brs:
4000000  cmp     rbx, 0x10
4000004  jb      cmp2 ; Not Taken   <Bool rbx >= 0x10>
4000006  movzx   r9, word ptr [rdi] ; {Attacker@rdi} -> {Secret@0x4000006}
         cmp2:
400000a  cmp     rbx, 0x5
400000e  ja      end ; Not Taken   <Bool UNSAT>
4000010  mov     rax, qword ptr [r9+rsi] ; {Attacker@rsi, Secret@0x4000006} -> TRANSMISSION
         end:
4000014  jmp     0x400dead

------------------------------------------------
uuid: 95ba4f79-6dcb-4ad6-83fc-16a4e28e3667
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
  - Expr: <BV64 (0#48 .. LOAD_16[<BV64 rdi>]_20) + rsi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: ['<BV64 rdi>', '<BV64 rsi>']
Constraints: []
Branches: [('0x4000004', '<Bool rbx >= 0x10>', 'Not Taken'), ('0x400000e', '<Bool UNSAT>', 'Not Taken')]
------------------------------------------------
