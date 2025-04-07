--------------------- HALF GADGET ----------------------
         tfp_multiple_bb:
4000000  mov     r8, qword ptr [rdi]
4000003  cmp     rax, 0x0
4000007  je      tfp0 ; Not Taken   <Bool rax != 0x0>
4000009  jmp     tfp1 ; Taken   <Bool True>
         tfp1:
4000014  mov     r10, qword ptr [rdi-0x10] ; {Attacker@rdi} -> HALF GADGET
4000018  mov     r11, qword ptr [r10]
400001b  jmp     __x86_indirect_thunk_array

------------------------------------------------
uuid: 3a6e428b-9938-4aef-98f3-a99b151930f2

Expr: <BV64 0xfffffffffffffff0 + rdi>
Base: <BV64 0xfffffffffffffff0>
Attacker: <BV64 rdi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: [('0x4000007', <Bool rax != 0x0>, 'Not Taken'), ('0x4000009', <Bool True>, 'Taken')]


------------------------------------------------
