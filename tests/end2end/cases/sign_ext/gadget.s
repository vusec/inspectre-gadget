.intel_syntax noprefix

sign_extend:
      movsx  eax,BYTE PTR [rcx+0x4]
      mov    rdx,QWORD PTR [rax+0x40]

      jmp 0xdead

; ieee80211_ctstoself_duration:
;       push   r15
;       push   r14
;       push   r13
;       push   r12
;       push   rbp
;       mov    rbp,rcx
;       push   rbx
;       mov    rbx,rsi
;       mov    rsi,rdx
;       sub    rsp,0x10
;       movzx  eax,BYTE PTR [rcx+0x4]
;       mov    rdx,QWORD PTR [rdi+0x40]
;       and    eax,0x7
;       mov    r15,QWORD PTR [rdx+rax*8+0x138]
;       movsx  rax,BYTE PTR [rcx+0x14]
;       lea    rdx,[rax+rax*2]
;       mov    rax,QWORD PTR [r15+0x8]
;       lea    r14,[rax+rdx*4]

;       test   rbx,rbx
;       je     0xdead
;       movzx  eax,BYTE PTR [rbx+0x76]
;       xor    r12d,r12d
;       cmp    BYTE PTR [rbx-0x2d7],0x0
;       mov    BYTE PTR [rsp+0x7],al
;       je     0xdead
;       mov    r12d,DWORD PTR [r14]

;       jmp 0xdead
