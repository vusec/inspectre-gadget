----------------- TRANSMISSION -----------------
         has_bh_in_lru:
4000000  movsxd  rdi, edi
4000003  mov     rax, 0x27700
400000a  add     rax, qword ptr [rax*0x8-0x7d9dd7a0] ; set() > {MaybeAttacker@0x400000a}
4000012  add     rax, qword ptr [rdi*0x8-0x7d9dd7a0] ; {Attacker@rdi} > {Secret@0x4000012}
400001a  lea     rdx, [rax+0x80]
4000021  cmp     qword ptr [rax], 0x0 ; {MaybeAttacker@0x400000a, Secret@0x4000012} > TRANSMISSION
4000025  jmp     0x400dead

------------------------------------------------
uuid: cac3d0b2-b297-45f9-97d8-abb6de880d90

Secret Address:
  - Expr: <BV64 ((0#32 .. rdi[31:0]) + 0x0 << 0x3) + 0xffffffff82622860>
  - Range: (0x0,0xfffffffffffffff8, 0x8) Exact: False
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 ((0#32 .. rdi[31:0]) + 0x0 << 0x3) + 0xffffffff82622860>]_25>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: <BV64 0x27700 + LOAD_64[<BV64 0xffffffff8275e060>]_24>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Independent Expr: <BV64 0x27700 + LOAD_64[<BV64 0xffffffff8275e060>]_24>
  - Independent Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmission:
  - Expr: <BV64 0x27700 + LOAD_64[<BV64 0xffffffff8275e060>]_24 + LOAD_64[<BV64 ((0#32 .. rdi[31:0]) + 0x0 << 0x3) + 0xffffffff82622860>]_25>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rdi>}
Constraints: [('0x4000012', <Bool rdi[31:31] == 0>)]
Branches: []
------------------------------------------------
