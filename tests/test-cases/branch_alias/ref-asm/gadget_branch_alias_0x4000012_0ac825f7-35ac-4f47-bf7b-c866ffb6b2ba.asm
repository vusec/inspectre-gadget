----------------- TRANSMISSION -----------------
         cmove_sample:
4000000  test    rdi, rdi
4000003  cmove   rax, rbx
4000007  cmp     rcx, rax
400000a  je      if ; Taken   <Bool rcx == rbx>
         if:
400000e  mov     rdi, qword ptr [rax+0x18] ; {Attacker@rbx} > {Secret@0x400000e}
4000012  mov     eax, dword ptr [rdi] ; {Secret@0x400000e} > TRANSMISSION
4000014  jmp     0x400dead

------------------------------------------------
uuid: 0ac825f7-35ac-4f47-bf7b-c866ffb6b2ba

Secret Address:
  - Expr: <BV64 rbx + 0x18>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rbx + 0x18>]_26>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 rbx + 0x18>]_26>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rdi>, <BV64 rbx>}
Constraints: [('0x4000003', <Bool rdi == 0x0>, 'ConditionType.CMOVE'), ('0x4000003', <Bool rdi == 0x0>, 'ConditionType.CMOVE')]
Branches: [(67108874, <Bool rcx == rbx>, 'Taken')]
------------------------------------------------
