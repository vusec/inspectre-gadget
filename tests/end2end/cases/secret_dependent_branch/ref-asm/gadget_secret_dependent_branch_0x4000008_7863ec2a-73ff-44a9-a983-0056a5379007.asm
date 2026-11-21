----------------- TRANSMISSION -----------------
         secret_dependent_branch:
4000000  movzx   r9, word ptr [rdi]
4000004  mov     r8, qword ptr [rdi+0x10] ; {Attacker@rdi} -> {Secret@0x4000004}
4000008  movzx   r8, word ptr [r8] ; {Secret@0x4000004} -> TRANSMISSION
400000c  add     r8, 0x50
4000010  cmp     r9, r8
4000013  je      end

------------------------------------------------
uuid: 7863ec2a-73ff-44a9-a983-0056a5379007
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 rdi + 0x10>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rdi + 0x10>]_21>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 rdi + 0x10>]_21>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: ['<BV64 rdi>']
Constraints: []
Branches: []
------------------------------------------------
