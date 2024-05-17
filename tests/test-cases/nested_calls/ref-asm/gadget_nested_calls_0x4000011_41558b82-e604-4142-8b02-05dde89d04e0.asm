----------------- TRANSMISSION -----------------
         nested_calls:
4000000  call    target_1 ; Taken   <Bool True>
         target_1:
400001d  ret      ; Taken   <Bool True>
4000005  call    target_2 ; Taken   <Bool True>
         target_2:
400001e  ret      ; Taken   <Bool True>
400000a  mov     r8, qword ptr [rdi]
400000d  movzx   r9, word ptr [rdi] ; {Attacker@rdi} -> {Secret@0x400000d}
4000011  mov     r10, qword ptr [r9-0x7f000000] ; {Secret@0x400000d} -> TRANSMISSION
4000018  jmp     0x400dead

------------------------------------------------
uuid: 41558b82-e604-4142-8b02-05dde89d04e0
transmitter: TransmitterType.LOAD

Secret Address:
  - Expr: <BV64 rdi>
  - Range: (0x0,0xffffffffffffffff, 0x1) Exact: True
Transmitted Secret:
  - Expr: <BV64 0#48 .. LOAD_16[<BV64 rdi>]_27>
  - Range: (0x0,0xffff, 0x1) Exact: True
  - Spread: 0 - 15
  - Number of Bits Inferable: 16
Base:
  - Expr: <BV64 0xffffffff81000000>
  - Range: 0xffffffff81000000
  - Independent Expr: <BV64 0xffffffff81000000>
  - Independent Range: 0xffffffff81000000
Transmission:
  - Expr: <BV64 0xffffffff81000000 + (0#48 .. LOAD_16[<BV64 rdi>]_27)>
  - Range: (0xffffffff81000000,0xffffffff8100ffff, 0x1) Exact: True

Register Requirements: {<BV64 rdi>}
Constraints: []
Branches: [('0x4000000', <Bool True>, 'Taken'), ('0x400001d', <Bool True>, 'Taken'), ('0x4000005', <Bool True>, 'Taken'), ('0x400001e', <Bool True>, 'Taken')]
------------------------------------------------
