----------------- TRANSMISSION -----------------
         user_space:
4000000  cmp     r8, 0x0
4000004  je      trans ; Not Taken   <Bool r8 != 0x0>
         tfp:
4000006  movsxd  rax, dword ptr [rdi] ; {Attacker@rdi} -> {Secret@0x4000006}
4000009  jmp     rax ; {Secret@0x4000006} -> TRANSMISSION

------------------------------------------------
uuid: 9d1e2cff-4e92-4966-a4b0-95109e552076
transmitter: TransmitterType.CODE_LOAD

Secret Address:
  - Expr: <BV64 rdi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#32 .. LOAD_32[<BV64 rdi>]_20>
  - Range: (0x0,0x7fffffff, 0x1) Exact: True
  - Spread: 0 - 31
  - Number of Bits Inferable: 32
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 0#32 .. LOAD_32[<BV64 rdi>]_20>
  - Range: (0x0,0x7fffffff, 0x1) Exact: True

Register Requirements: ['<BV64 rdi>']
Constraints: [('0x4000006', '<Bool LOAD_32[<BV64 rdi>]_20[31:31] == 0>', 'ConditionType.SIGN_EXT')]
Branches: [('0x4000004', '<Bool r8 != 0x0>', 'Not Taken')]
------------------------------------------------
