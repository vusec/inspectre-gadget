----------------- TRANSMISSION -----------------
         cmove_sample:
4000000  mov     edi, dword ptr [rdx+0x18] ; {Attacker@rdx} -> {Secret@0x4000000}
4000003  movsxd  rdi, edi
4000006  mov     rbx, rdi
4000009  test    rdi, rdi
400000c  cmove   rdi, rsi
4000010  mov     eax, dword ptr [rdi]
4000012  mov     ecx, dword ptr [rbx+0x20] ; {Secret@0x4000000} -> TRANSMISSION
4000015  jmp     0x400dead

------------------------------------------------
uuid: fb9c7b76-ffef-4bbb-a28a-f9219237473e
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 rdx + 0x18>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#32 .. LOAD_32[<BV64 rdx + 0x18>]_20>
  - Range: 0x0
  - Spread: 0 - 31
  - Number of Bits Inferable: 32
Base:
  - Expr: <BV64 0x20>
  - Range: 0x20
  - Independent Expr: <BV64 0x20>
  - Independent Range: 0x20
Transmission:
  - Expr: <BV64 0x20 + (0#32 .. LOAD_32[<BV64 rdx + 0x18>]_20)>
  - Range: 0x20

Register Requirements: {<BV64 rdx>}
Constraints: [('0x400000c', <Bool (0x0 .. LOAD_32[<BV64 rdx + 0x18>]_20) == 0x0>, 'ConditionType.CMOVE'), ('0x4000003', <Bool LOAD_32[<BV64 rdx + 0x18>]_20[31:31] == 0>, 'ConditionType.SIGN_EXT'), ('0x4000003', <Bool LOAD_32[<BV64 rdx + 0x18>]_20[31:31] == 0>, 'ConditionType.SIGN_EXT')]
Branches: []
------------------------------------------------
