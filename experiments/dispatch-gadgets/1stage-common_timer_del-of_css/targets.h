/*
 * Friday, October 27th 2023
 *
 * Sander Wiebing - s.j.wiebing@vu.nl
 * Alvise de Faveri Tron - a.de.faveri.tron@vu.nl
 * Herbert Bos - herbertb@cs.vu.nl
 * Cristiano Giuffrida - giuffrida@cs.vu.nl
 *
 * Vrije Universiteit Amsterdam - Amsterdam, The Netherlands
 *
 */

#ifndef _TARGETS_H_
#define _TARGETS_H_

#define MAX_HISTORY_SIZE 420
#define THR 80

#define VICTIM_SYSCALL 438


// ----------------------------------------------------------------------------
// Micro-architectural dependent settings

#if defined(INTEL_10_GEN)

    #define COLLISION_TRIES 250 // 10th gen tag entropy: 14

#elif defined(INTEL_11_GEN)

    #define COLLISION_TRIES 350

#elif defined(INTEL_13_GEN)

    #define COLLISION_TRIES 500
#else
     #error "Not supported micro-architecture"
     // suppress errors
     #define COLLISION_TRIES 0
#endif



// ----------------------------------------------------------------------------
// Kernel version + config dependent settings

#if defined(LINUX_v6_6_RC4_DEFAULT)

    // of_css
    //    endbr64
    //    nop    DWORD PTR [rax+rax*1+0x0]
    //    mov    rax,QWORD PTR [rdi]
    //    push   rbp
    //    mov    rcx,QWORD PTR [rax+0x8]
    //    mov    rax,QWORD PTR [rax+0x60]
    //    mov    rbp,rsp
    //    mov    rdx,QWORD PTR [rax+0x58]
    //    mov    rax,QWORD PTR [rcx+0x60]
    //    test   rdx,rdx
    //    je     0xffffffff9b7c9aa4
    //    movsxd rdx,DWORD PTR [rdx+0x9c]
    //    add    rdx,0x44
    //    mov    rax,QWORD PTR [rax+rdx*8]

    #define TB_OFFSET ((0x2e * 8) + 8)
    #define TS_OFFSET 0x9c
    #define STRIDE    8


#elif defined(LINUX_v6_6_RC4_UBUNTU)

    // of_css
    //    endbr64
    //    nop    DWORD PTR [rax+rax*1+0x0]
    //    mov    rax,QWORD PTR [rdi]
    //    push   rbp
    //    mov    rcx,QWORD PTR [rax+0x8]
    //    mov    rax,QWORD PTR [rax+0x60]
    //    mov    rbp,rsp
    //    mov    rdx,QWORD PTR [rax+0x58]
    //    mov    rax,QWORD PTR [rcx+0x60]
    //    test   rdx,rdx
    //    je     0xffffffff9b7c9aa4
    //    movsxd rdx,DWORD PTR [rdx+0x9c]
    //    add    rdx,0x44
    //    mov    rax,QWORD PTR [rax+rdx*8]

    #define TB_OFFSET (0x44 * 8)
    #define TS_OFFSET 0x9c
    #define STRIDE    8


#else
    #error "Not supported kernel version"
    // suppress errors
    #define TB_OFFSET 0
    #define TS_OFFSET 0
    #define TFP_OFFSET 0
    #define STRIDE          0

#endif

#endif //_TARGETS_H_
