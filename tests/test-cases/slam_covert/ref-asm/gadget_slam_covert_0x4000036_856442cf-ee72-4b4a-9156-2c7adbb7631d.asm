----------------- TRANSMISSION -----------------
         multiple_bb:
4000000  cmp     r8, 0x0
4000004  je      trans1 ; Taken   <Bool r8 == 0x0>
         trans1:
4000024  mov     r9, qword ptr [rdi] ; {Attacker@rdi} -> {Secret@0x4000024}
4000027  add     r9, 0x821
400002e  shl     r9, 0x10
4000032  add     r9, 0x33
4000036  mov     r10, qword ptr [r9] ; {Secret@0x4000024} -> TRANSMISSION
4000039  jmp     end

------------------------------------------------
uuid: 856442cf-ee72-4b4a-9156-2c7adbb7631d
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 rdi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 (0#16 .. LOAD_64[<BV64 rdi>]_30[47:0]) << 0x10>
  - Range: (0x0,0xffffffffffff0000, 0x10000) Exact: True
  - Spread: 16 - 63
  - Number of Bits Inferable: 48
Base:
  - Expr: <BV64 0x8210033>
  - Range: 0x8210033
  - Independent Expr: <BV64 0x8210033>
  - Independent Range: 0x8210033
Transmission:
  - Expr: <BV64 0x8210000 + ((0#16 .. LOAD_64[<BV64 rdi>]_30[47:0]) << 0x10) + 0x33>
  - Range: (0x33,0xffffffffffff0033, 0x10000) Exact: False, and_mask: 0xffffffffffff0033, or_mask: 0x33

Register Requirements: {<BV64 rdi>}
Constraints: []
Branches: [('0x4000004', <Bool r8 == 0x0>, 'Taken')]
------------------------------------------------
