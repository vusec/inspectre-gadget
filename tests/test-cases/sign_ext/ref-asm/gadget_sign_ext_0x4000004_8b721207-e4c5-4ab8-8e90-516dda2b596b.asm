----------------- TRANSMISSION -----------------
         sign_extend:
4000000  movsx   eax, byte ptr [rcx+0x4] ; {Attacker@rcx} -> {Secret@0x4000000}
4000004  mov     rdx, qword ptr [rax+0x40] ; {Secret@0x4000000} -> TRANSMISSION
4000008  jmp     0x400dead

------------------------------------------------
uuid: 8b721207-e4c5-4ab8-8e90-516dda2b596b
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 rcx + 0x4>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#56 .. LOAD_8[<BV64 rcx + 0x4>]_20>
  - Range: (0x0,0x7f, 0x1) Exact: True
  - Spread: 0 - 7
  - Number of Bits Inferable: 8
Base:
  - Expr: <BV64 0x40>
  - Range: 0x40
  - Independent Expr: <BV64 0x40>
  - Independent Range: 0x40
Transmission:
  - Expr: <BV64 0x40 + (0#56 .. LOAD_8[<BV64 rcx + 0x4>]_20)>
  - Range: (0x40,0xbf, 0x1) Exact: True

Register Requirements: {<BV64 rcx>}
Constraints: [('0x4000000', <Bool LOAD_8[<BV64 rcx + 0x4>]_20[7:7] == 0>, 'ConditionType.SIGN_EXT')]
Branches: []
------------------------------------------------
