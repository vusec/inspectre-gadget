----------------- TRANSMISSION -----------------
         tfp_symbolic:
4000000  cmp     r15, 0x0
4000004  je      tfp1 ; Not Taken   <Bool r15 != 0x0>
         tfp0:
4000006  mov     rax, qword ptr [rcx+rsi] ; {Attacker@rsi, Attacker@rcx} -> {Secret@0x4000006}
400000a  call    rax ; {Secret@0x4000006} -> TRANSMISSION

------------------------------------------------
uuid: cf59a62f-a10e-4a02-9300-56f694f57630
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

Register Requirements: {<BV64 rsi>, <BV64 rcx>}
Constraints: []
Branches: [('0x4000004', <Bool r15 != 0x0>, 'Not Taken')]
------------------------------------------------
