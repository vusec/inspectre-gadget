----------------- TRANSMISSION -----------------
         uncontrolled_stored_in_mem:
4000000  mov     dword ptr [rdx], 0x7000000
4000006  mov     r8d, dword ptr [rdx]
4000009  mov     r9, qword ptr [rdi+0xff] ; {Attacker@rdi} -> {Secret@0x4000009}
4000010  and     r9, 0xffff
4000017  mov     r10, qword ptr [r8+r9-0x7f000000] ; {Secret@0x4000009} -> TRANSMISSION
400001f  mov     dword ptr [rsi], 0x0
4000025  mov     r9d, dword ptr [rsi]
4000028  and     r9, 0xffff
400002f  mov     r11, qword ptr [r9-0x7f000000]
4000036  mov     rdx, 0xffffffff85000000
400003d  mov     rax, qword ptr [rdx]
4000040  mov     rbx, qword ptr [rax]
4000043  mov     r14, qword ptr [rcx+rbx]
4000047  jmp     0x400dead

------------------------------------------------
uuid: e7f5814c-5044-4b30-9dd1-e5dc0ace2502
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 rdi + 0xff>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#48 .. LOAD_64[<BV64 rdi + 0xff>]_22[15:0]>
  - Range: (0x0,0xffff, 0x1) Exact: True
  - Spread: 0 - 15
  - Number of Bits Inferable: 16
Base:
  - Expr: <BV64 0xffffffff88000000>
  - Range: 0xffffffff88000000
  - Independent Expr: <BV64 0xffffffff88000000>
  - Independent Range: 0xffffffff88000000
Transmission:
  - Expr: <BV64 0xffffffff88000000 + (0#48 .. LOAD_64[<BV64 rdi + 0xff>]_22[15:0])>
  - Range: (0xffffffff88000000,0xffffffff8800ffff, 0x1) Exact: True

Register Requirements: {<BV64 rdi>}
Constraints: []
Branches: []
------------------------------------------------
