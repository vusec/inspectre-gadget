--------------------- HALF GADGET ----------------------
         setup:
4000000  mov     qword ptr [0xffffffff81000000], 0xffffffff81000010
400000c  mov     qword ptr [0xffffffff81000010], 0xffffffff81000020
4000018  mov     qword ptr [0xffffffff81000020], 0xffffffff81000000
4000024  mov     qword ptr [0xffffffff81000008], rdi
400002c  mov     qword ptr [0xffffffff81000018], 0xffffffffdeadbeef
4000038  mov     qword ptr [0xffffffff81000028], 0xffffffffcacacafe
4000044  mov     rax, 0xffffffff81000000
400004b  mov     r12, 0xffffffff81000000
         loopy:
4000052  mov     rbx, qword ptr [rax]
4000055  cmp     rbx, r12
4000058  je      end ; Not Taken   <Bool UNSAT>
400005a  add     rbx, 0x8
400005e  mov     rcx, qword ptr [rbx]
4000061  mov     rdx, qword ptr [rcx] ; {Attacker@rdi} -> HALF GADGET
4000064  add     rax, 0x10
4000068  jmp     loopy ; Taken   <Bool True>
         loopy:
4000052  mov     rbx, qword ptr [rax]
4000055  cmp     rbx, r12
4000058  je      end ; Not Taken   <Bool UNSAT>
400005a  add     rbx, 0x8
400005e  mov     rcx, qword ptr [rbx]
4000061  mov     rdx, qword ptr [rcx] ; {Attacker@rdi} -> HALF GADGET
4000064  add     rax, 0x10
4000068  jmp     loopy ; Taken   <Bool True>
         loopy:
4000052  mov     rbx, qword ptr [rax]
4000055  cmp     rbx, r12
4000058  je      end ; Not Taken   <Bool UNSAT>
400005a  add     rbx, 0x8
400005e  mov     rcx, qword ptr [rbx]
4000061  mov     rdx, qword ptr [rcx] ; {Attacker@rdi} -> HALF GADGET
4000064  add     rax, 0x10
4000068  jmp     loopy ; Taken   <Bool True>

------------------------------------------------
uuid: a0289ce8-0a93-4983-8a7d-b347460d0907

Expr: <BV64 rdi>
Base: None
Attacker: <BV64 rdi>
ControlType: ControlType.CONTROLLED

Constraints: []
Branches: [('0x4000058', <Bool True>, 'Taken'), ('0x4000068', <Bool True>, 'Taken'), ('0x4000058', <Bool True>, 'Taken'), ('0x4000068', <Bool True>, 'Taken'), ('0x4000058', <Bool UNSAT>, 'Not Taken')]


------------------------------------------------
