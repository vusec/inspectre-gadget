----------------- TRANSMISSION -----------------
         tfp_symbolic:
4000000  cmp     r15, 0x0
4000004  je      tfp1 ; Not Taken   <Bool r15 != 0x0>
         tfp0:
4000006  mov     rax, qword ptr [rcx+rsi] ; {Attacker@rcx, Attacker@rsi} -> {Secret@0x4000006}
400000a  call    rax ; {Secret@0x4000006} -> TRANSMISSION

------------------------------------------------
uuid: 7058cb7d-2620-4cbf-9e55-7f5a0308351b
transmitter: TransmitterType.CODE_LOAD

Secret Address:
  - Expr: <BV64 rcx + rsi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rcx + rsi>]_20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 rcx + rsi>]_20>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rcx>, <BV64 rsi>}
Constraints: []
Branches: [('0x4000004', <Bool r15 != 0x0>, 'Not Taken')]
------------------------------------------------
