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

#ifndef _COMMON_H_
#define _COMMON_H_

#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <stdint.h>
#include <stdlib.h>
#include <assert.h>
#include <errno.h>
#include <stdio.h>
#include <malloc.h>

#define HUGE_PAGE_SIZE (1 << 21) // 2 MB
#define PHYS_MAP_START 0xffff888000000000
#define PHYS_MAP_END   0xffffc87fffffffff

#define HONEY_PAGE_SIGNATURE "HONEY_SG"

#define MSR_IA32_PRED_CMD       0x00000049 /* Prediction Command */

#define PAGE_OFFSET  (0xffff888000000000ULL)   // (0xffff888000000000ULL) // 0xffff888000000000ULL + 0xffff8d7340000000
static uint64_t virt_to_physmap(uint64_t virtual_address, uint64_t page_offset) {
    int pagemap;
    uint64_t value;
    int got;
    uint64_t page_frame_number;

    if (!page_offset) {
        page_offset = PAGE_OFFSET;

    } else if (page_offset == 0xffff888100000000UL) {
        // We are running in a VM (KASLR disabled), this is a hack
        // to still let virt_to_physmap work
        printf("[info] VM Detected!\n");
        page_offset = 0xffff888000000000UL;
    }


    pagemap = open("/proc/self/pagemap", O_RDONLY);
    if (pagemap < 0) {
        exit(1);
    }

    got = pread(pagemap, &value, 8, (virtual_address / 0x1000) * 8);
    if (got != 8) {
        exit(2);
    }

    page_frame_number = value & ((1ULL << 54) - 1);
    if (page_frame_number == 0) {
        exit(3);
    }

    close(pagemap);

    return page_offset + (page_frame_number * 0x1000 + virtual_address % 0x1000);
}

static __always_inline void flush(void * addr)
{
    asm volatile("clflush (%0)" : : "r" (addr));
}


static __always_inline __attribute__((always_inline)) void maccess(void *p) {
        *(volatile unsigned char *)p;
}

static __always_inline __attribute__((always_inline)) uint64_t rdtscp(void) {
        uint64_t lo, hi;
        asm volatile("rdtscp\n" : "=a" (lo), "=d" (hi) :: "rcx");
        return (hi << 32) | lo;
}


static __always_inline __attribute__((always_inline)) uint64_t load_time(void *p)
{
    uint64_t t0 = rdtscp();
    maccess(p);
    return rdtscp() - t0;
}

static __always_inline __attribute__((always_inline)) void cpuid(void) {
     asm volatile ("xor %%rax, %%rax\ncpuid\n\t" ::: "%rax", "%rbx", "%rcx", "%rdx");
}

/* Write the MSR "reg" on cpu "cpu" */
static void wrmsr(uint32_t reg, int cpu, uint64_t data)
{
    int fd;
    char msr_file_name[128];

    sprintf(msr_file_name, "/dev/cpu/%d/msr", cpu);

    fd = open(msr_file_name, O_WRONLY);
    if (fd < 0) {
        printf( "wrmsr: can't open %s\n", msr_file_name);
        exit(1);
    }

    if ( pwrite(fd, &data, sizeof(data), reg) != sizeof(data) ) {
        printf( "wrmsr: cannot write %s/0x%08x Err: %d\n", msr_file_name, reg, errno);
        exit(2);
     }

    close(fd);

    return;
}

static inline __attribute__((always_inline)) void set_ibpb(int cpu)
{
     wrmsr(MSR_IA32_PRED_CMD, cpu, 1);
     asm volatile("mfence");

}

static uint64_t get_mem_total() {
    int mem;
    char line[256];

    FILE* file = fopen("/proc/meminfo","r");

    if (!file) {
        printf("Error opening /proc/meminfo file!\n");
        exit(EXIT_FAILURE);
    }

    while(fgets(line, sizeof(line), file)) {

        if(sscanf(line, "MemTotal: %d kB\n", &mem) == 1)
        {
            fclose(file);
            return (uint64_t) mem * 1024;
        }

    }

    fclose(file);
    printf("Did not found MemTotal string in /proc/meminfo!\n");
    exit(EXIT_FAILURE);

    return -1;

}

static uint64_t get_mem_used()
{
    int mem_total = -1;
    int mem_available = -1;
    char line[256];

    FILE* file = fopen("/proc/meminfo","r");

    if (!file) {
        printf("Error opening /proc/meminfo file!\n");
        exit(EXIT_FAILURE);
    }

    while(fgets(line, sizeof(line), file)) {

        if(mem_total == -1) {
            sscanf(line, "MemTotal: %d kB\n", &mem_total);
        }

        if(mem_available == -1) {
            sscanf(line, "MemAvailable: %d kB\n", &mem_available);
        }

        if (mem_total >= 0 && mem_available >= 0) {
            fclose(file);
            return (uint64_t) (mem_total - mem_available) * 1024;
        }

    }

    fclose(file);

    printf("Did not found MemTotal|MemAvailable string in /proc/meminfo!\n");
    exit(EXIT_FAILURE);

    return -1;

}


static int get_rss_of_addr(void * addr)
{
    void * start = 0;
    int rss = -1;
    char line[256];

    FILE* file = fopen("/proc/self/smaps","r");

    if (!file) {
        printf("Error opening /proc/self/smaps file!\n");
        exit(EXIT_FAILURE);
    }

    while(fgets(line, sizeof(line), file)) {
        // Find the address
        if(sscanf(line, "%p-%*[^\n]\n", &start) != 1 && start == addr)
        {
            // Find the RSS field
            while(fgets(line, sizeof(line), file)) {

                if(sscanf(line, "Rss: %d kB\n", &rss) == 1) {
                    break;
                }
            }

            break;

        }

    }

    fclose(file);

    return rss;
}

static uint8_t * allocate_huge_page()
{
    uint8_t * addr = memalign(HUGE_PAGE_SIZE, HUGE_PAGE_SIZE);

    madvise(addr, HUGE_PAGE_SIZE, MADV_HUGEPAGE);
    *(volatile uint8_t *) addr = 1;

    assert(get_rss_of_addr(addr) == 2048);

    return addr;
}


#endif //_COMMON_H_
