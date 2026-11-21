.intel_syntax noprefix

half_spectre:
   # Literally only an attacker-controlled load.
   # No Base, full control.
   mov    rsi, qword ptr [rdi]
   # "Relative" half-spectre gadget, constant base.
   mov    r10, QWORD PTR [eax + 0xffffffff81000000]
   # Uncontrolled base.
   mov    r11, QWORD PTR [0xffffffff81000000]   # NOT a gadget
   add    r11, rax
   mov    r12, QWORD PTR [r11]

end:
	jmp    0xdead

