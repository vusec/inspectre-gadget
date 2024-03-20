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

#define THR 100

__always_inline static void cpuid_fence(void) { asm volatile ("xor %%rax, %%rax\ncpuid\n\t" ::: "%rax", "%rbx", "%rcx", "%rdx"); }
__always_inline static void flush(volatile char *addr) { asm volatile ("clflush (%0)\n\t" :: "r"(addr):); }
__always_inline static void mfence(void) { asm volatile ("mfence\n\t":::); }
__always_inline static void lfence(void) { asm volatile ("lfence\n\t":::); }
__always_inline static void sfence(void) { asm volatile ("sfence\n\t":::); }


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
