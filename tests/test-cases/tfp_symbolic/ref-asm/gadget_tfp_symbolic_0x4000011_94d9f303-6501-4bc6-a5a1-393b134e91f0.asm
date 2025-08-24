----------------- TRANSMISSION -----------------
         tfp_symbolic:
4000000  cmp     r15, 0x0
4000004  je      tfp1 ; Taken   <Bool r15 == 0x0>
         tfp1:
400000c  add     byte ptr [rdi], bh
400000e  cmovae  eax, ecx
4000011  jmp     qword ptr [rax-0x7db6bd40] ; {Secret@0x4000011} -> TRANSMISSION

------------------------------------------------
uuid: 94d9f303-6501-4bc6-a5a1-393b134e91f0
transmitter: TransmitterType.CODE_LOAD

Secret Address:
  - Expr: <BV64 (0#32 .. rcx[31:0]) + 0xffffffff824942c0>
  - Range: (0xffffffff824942c0,0x824942bf, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 (0#32 .. rcx[31:0]) + 0xffffffff824942c0>]_27>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 (0#32 .. rcx[31:0]) + 0xffffffff824942c0>]_27>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rcx>, <BV64 rdi>, <BV64 rbx>}
Constraints: [('0x400000e', <Bool LOAD_8[<BV64 rdi>]_22 + rbx[15:8] >= LOAD_8[<BV64 rdi>]_22>, 'ConditionType.CMOVE')]
Branches: [('0x4000004', <Bool r15 == 0x0>, 'Taken')]
------------------------------------------------
