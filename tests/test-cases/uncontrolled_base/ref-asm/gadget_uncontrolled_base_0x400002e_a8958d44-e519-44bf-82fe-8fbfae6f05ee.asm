----------------- TRANSMISSION -----------------
         uncontrolled_base:
4000000  movzx   r8, byte ptr [rdi] ; {Attacker@rdi} > {Secret@0x4000000}
4000004  mov     rsi, qword ptr  gs:[0x2ac80] ; {Uncontrolled@gs} > {UncontrolledLoad@0x4000004}
400000d  mov     rdx, qword ptr [rsi]
4000010  mov     rdx, qword ptr [rdx]
4000013  mov     rdx, qword ptr [rdx+r8]
4000017  mov     r9, qword ptr [rsi]
400001a  add     r9, rbx
400001d  mov     r9, qword ptr [r9+r8]
4000021  mov     r10, qword ptr [rsi] ; {UncontrolledLoad@0x4000004} > {UncontrolledLoad@0x4000021}
4000024  and     r11, 0xff
400002b  add     r10, r11
400002e  mov     r10, qword ptr [r10+r8] ; {Attacker@r11, UncontrolledLoad@0x4000021, Secret@0x4000000} > TRANSMISSION
4000032  ret     

------------------------------------------------
uuid: a8958d44-e519-44bf-82fe-8fbfae6f05ee

Secret Address:
  - Expr: <BV64 rdi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#56 .. LOAD_8[<BV64 rdi>]_20>
  - Range: (0x0,0xff, 0x1) Exact: True
  - Spread: 0 - 7
  - Number of Bits Inferable: 8
Base:
  - Expr: <BV64 LOAD_64[<BV64 LOAD_64[<BV64 0x2ac80 + gs>]_21>]_27 + (0#56 .. r11[7:0])>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
  - Independent Expr: <BV64 LOAD_64[<BV64 LOAD_64[<BV64 0x2ac80 + gs>]_21>]_27 + (0#56 .. r11[7:0])>
  - Independent Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmission:
  - Expr: <BV64 LOAD_64[<BV64 LOAD_64[<BV64 0x2ac80 + gs>]_21>]_27 + (0#56 .. r11[7:0]) + (0#56 .. LOAD_8[<BV64 rdi>]_20)>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True

Register Requirements: {<BV64 r11>, <BV64 rdi>, <BV64 gs>}
Constraints: []
Branches: []
------------------------------------------------
