--------------------- HALF GADGET ----------------------
         nested_calls:
4000000  call    target_1 ; Taken   <Bool True>
         target_1:
400001d  ret      ; Taken   <Bool True>
4000005  call    target_2 ; Taken   <Bool True>
         target_2:
400001e  ret      ; Taken   <Bool True>
400000a  mov     r8, qword ptr [rdi]
400000d  movzx   r9, word ptr [rdi] ; {Attacker@rdi} -> HALF GADGET
4000011  mov     r10, qword ptr [r9-0x7f000000]
4000018  jmp     0x400dead

------------------------------------------------
uuid: 796ed37a-e488-4e1a-ad78-5071d34ea6b7

Expr: <BV64 rdi>
Base: None
Attacker: <BV64 rdi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: [('0x4000000', <Bool True>, 'Taken'), ('0x400001d', <Bool True>, 'Taken'), ('0x4000005', <Bool True>, 'Taken'), ('0x400001e', <Bool True>, 'Taken')]


------------------------------------------------
