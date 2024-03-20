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
#include <pthread.h>


#include "common.h"
#include "targets.h"
#include "flush_and_reload.h"
#include "contention.h"


#define TEST_ITERATIONS 10000


uint8_t * get_phys_map_start() {

    int fd;
    char buf[18];
    uint8_t * address;

    if (access(PATH_PHYS_MAP, F_OK) == 0) {
        fd = open(PATH_PHYS_MAP, O_RDONLY);
        assert(fd);
    } else {
        printf("Error: File %s not found. Please insert the kernel module\n", PATH_PHYS_MAP);
        exit(EXIT_FAILURE);
    }

    assert(read(fd, buf, 18));

    assert(sscanf(buf, "%lx", (uint64_t *) &address) == 1);

    return address;

}


// ----------------------------------------------------------------------------
// MAIN
//
// ----------------------------------------------------------------------------



int main(int argc, char **argv)
{
    struct config cfg = {0};
    uint64_t time_start;
    int opt;
    pthread_t tid;
    uint64_t contention_option = -1;

    uint8_t test_mode = 0;


    while ((opt = getopt(argc, argv, "c:")) != -1) {
        switch (opt) {
            case 'c':
                sscanf(optarg, "%ld", &contention_option);
                break;
            default:
                printf("Usage:\n"
                "%s {ibt, fine_ibt} [options]\n"
                    "  -c CONTENTION   Contention type (0-4, 0 == No contention)\n"
                    , argv[0]);
                exit(1);
        }
    }

    if (optind + 1 < argc) {
        printf("Usage:\n"
        "%s {ibt, fine_ibt} [options]\n"
            "  -c CONTENTION   Contention type (0-4, 0 == No contention)\n"
            , argv[0]);
        exit(1);
    } else if (optind < argc) {

        if(strcmp(argv[optind], "ibt") == 0) {
            test_mode = 0;
        } else if(strcmp(argv[optind], "fine_ibt") == 0) {
            test_mode = 1;
        } else {
            printf("Invalid test mode, choose between: \n- ibt \n- fine_ibt\n");
            exit(0);
        }
    }

    if (contention_option > 4) {
        printf("Invalid contention option, should be between 0-4 (0 == No contention)\n");
        exit(0);
    }

    printf("------------------------------------------------------\n");
    printf("PLEASE CHECK -> TESTING CORE: %d CONTENTION CORE: %d\n", CORE_TESTING, CORE_CONTENTION);
    printf("TESTING AND CONTENTION CORE SHOULD BE SIBLINGS!\n");
    printf("------------------------------------------------------\n");

    int seed = time(0);
    printf("Seed: %d\n", seed);
    srand(seed);


    if(test_mode == 0 ) {

        if (access(PATH_PERFORM_IBT_TEST, F_OK) == 0) {
            cfg.fd_perform_test = open(PATH_PERFORM_IBT_TEST, O_WRONLY);
            assert(cfg.fd_perform_test);
        } else {
            printf("Error: File %s not found\n", PATH_PERFORM_IBT_TEST);
        }


    } else {

        if (access(PATH_PERFORM_FINE_IBT_TEST, F_OK) == 0) {
            cfg.fd_perform_test = open(PATH_PERFORM_FINE_IBT_TEST, O_WRONLY);
            assert(cfg.fd_perform_test);
        } else {
            printf("Error: File %s not found\n", PATH_PERFORM_FINE_IBT_TEST);
        }


    }

    if (access(PATH_SELECT_SID, F_OK) == 0) {
        cfg.fd_select_sid = open(PATH_SELECT_SID, O_WRONLY);
        assert(cfg.fd_select_sid);
    } else {
        printf("Error: File %s not found\n", PATH_SELECT_SID);
    }

    // ------------------------------------------------------------------------
    // Allocate a huge page

    cfg.ind_map = allocate_huge_page();
    cfg.phys_start = get_phys_map_start();
    printf("Direct Physical Map start: %p\n", cfg.phys_start);


    // ------------------------------------------------------------------------
    // Setup TLB eviction

    // ------------------------------------------------------------------------
    // Find the kernel address of our huge page

    cfg.ind_map_kern = (uint8_t *)(virt_to_physmap((uint64_t)cfg.ind_map, (uint64_t) cfg.phys_start));

    while ((uint64_t) cfg.ind_map_kern % HUGE_PAGE_SIZE != 0)
    {
        printf("Invalid huge_page! User: %p Kernel: %p\n", cfg.ind_map, cfg.ind_map_kern);
        sleep(1);
        cfg.ind_map_kern = (uint8_t *)(virt_to_physmap((uint64_t)cfg.ind_map, (uint64_t) cfg.phys_start));
    }
    printf("User huge page addr: %p Kernel huge page addr: %p\n", cfg.ind_map, cfg.ind_map_kern);

    cfg.fr_buf = cfg.ind_map + 0x1000;
    cfg.fr_buf_kern = cfg.ind_map_kern + 0x1000;
    printf("User FR_BUF: %p Kernel FR_BUF: %p\n", cfg.fr_buf, cfg.fr_buf_kern);


    memset(cfg.fr_buf, 0x90, 0x1000);

    pin_to_core(CORE_TESTING);

    if (contention_option) {
        pthread_create(&tid, NULL, start_contention, (void *)contention_option);
        usleep(500);
    }



    // ------------------------------------------------------------------------
    // Dry run for all tests
    printf("------------------------------------------------------\n");
    printf("MODE: %s\n", argv[optind]);




    cfg.do_fake_sid = 0;

    printf("%-4s ", "");
    for (int i = 0; i < 16; i++)
    {
        printf(" %2d LD ", i + 1);
    }
    printf("\n");


    printf("%-4s ", "DRY");
    print_leakage_rate(&cfg, TEST_ITERATIONS);


    // ------------------------------------------------------------------------
    // TESTS

    cfg.do_fake_sid = 1;

    for (size_t i = 0; i < 10; i++)
    {
        printf("%-4s ", "TEST");
        print_leakage_rate(&cfg, TEST_ITERATIONS);
    }





}
