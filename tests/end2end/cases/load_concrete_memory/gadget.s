.intel_syntax noprefix

# Requires LoadConcreteMemory: the value of the global is loaded as a concrete
# value (0x1337000) instead of a symbol, so it shows up in the transmission.
load_concrete_memory:
   mov    rax, QWORD PTR [rip + global_offset] # concrete load from a global
   mov    r9, QWORD PTR [rdi]                  # load of secret
   mov    r10, QWORD PTR [r9 + rax]            # transmission: secret + 0x1337000
   jmp    0xdead

.data
global_offset:
   .quad 0x1337000
