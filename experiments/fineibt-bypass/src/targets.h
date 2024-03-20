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
#define THR 60

#define CORE_TESTING 2
#define CORE_CONTENTION 3

#define PATH_PATCH_INSERT_CHECK "/proc/patch_kernel/insert_fine_ibt_check"
#define PATH_PATCH_REMOVE_CHECK "/proc/patch_kernel/remove_fine_ibt_check"

#define NUMBER_OF_EVICT_SETS 16


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

#if defined(LINUX_v6_6_RC4_UBUNTU)

    //    unix_poll
    //    0xffffffff8d41e1e2:  mov    rbx,QWORD PTR [rsi+0x18]
    //    0xffffffff8d41e1e6:  test   rdx,rdx
    //    0xffffffff8d41e1e9:  je     0xffffffff8d41e211
    //    0xffffffff8d41e1eb:  mov    r11,QWORD PTR [rdx]
    //    0xffffffff8d41e1ee:  test   r11,r11
    //    0xffffffff8d41e1f1:  je     0xffffffff8d41e211
    //    0xffffffff8d41e1f3:  add    rsi,0x40
    //    0xffffffff8d41e1f7:  mov    r10d,0x16500c8f
    //    0xffffffff8d41e1fd:  sub    r11,0x10
    //    0xffffffff8d41e201:  nop    DWORD PTR [rax+0x0]
    //    0xffffffff8d41e205:  call   r11

    //  0xffffffff8d501cd4:  movzx  ebx,BYTE PTR [r8+rbx*1]

    #define TB_OFFSET 0x0
    #define TS_OFFSET 0x18
    #define STRIDE    1


#else
    #error "Not supported kernel version"
    // suppress errors
    #define TB_OFFSET 0
    #define TS_OFFSET 0
    #define TFP_OFFSET 0
    #define STRIDE          0

#endif

#endif //_TARGETS_H_
