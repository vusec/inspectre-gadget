----------------- TRANSMISSION -----------------
         tfp_multiple_bb:
4000000  mov     r8, qword ptr [rdi]
4000003  cmp     rax, 0x0
4000007  je      tfp0 ; Not Taken   <Bool rax != 0x0>
4000009  jmp     tfp1 ; Taken   <Bool True>
         tfp1:
4000014  mov     r10, qword ptr [rdi-0x10] ; {Attacker@rdi} > {Secret@0x4000014}
4000018  mov     r11, qword ptr [r10] ; {Secret@0x4000014} > TRANSMISSION
400001b  jmp     __x86_indirect_thunk_array

------------------------------------------------
uuid: a4750aa9-81f3-4348-80e8-75e5d08bcf8b

Secret Address:
  - Expr: <BV64 rdi + 0xfffffffffffffff0>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 LOAD_64[<BV64 rdi + 0xfffffffffffffff0>]_21>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Spread: 0 - 63
  - Number of Bits Inferable: 64
Base:
  - Expr: None
  - Range: None
  - Independent Expr: None
  - Independent Range: None
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 rdi + 0xfffffffffffffff0>]_21>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 rdi>}
Constraints: []
Branches: [(67108871, <Bool rax != 0x0>, 'Not Taken'), (67108873, <Bool True>, 'Taken')]
------------------------------------------------
