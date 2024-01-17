.intel_syntax noprefix

sar_instruction:
   cmp r8, 0x0
   je     trans1

trans0:
   movzx  eax, word ptr [rsi]
   sar    eax, 0x8
   mov    r11, qword PTR [rax + 0xffffffff81000000]
   jmp    end

trans1:
   movzx  eax, word ptr [rsi]
   bt      qword ptr [rdi+0xb8], rax   # BIT TEST, also performs DIV (=sar)
end:
	jmp    0xdead
