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
#include <string.h>
#include <assert.h>
#include <malloc.h>

#include "evict_pht.h"
#include "../../poc-common/common.h"

#define RWX_SIZE	    (1UL << 19) // 19


// 74 03                  jz next_ins
// 0f1f00                 NOP DWORD ptr [EAX]

#define JMP_GADGET_ASM    "\x74\x03\x0f\x1f\x00"
#define JMP_GADGET_SIZE   (sizeof(JMP_GADGET_ASM) - 1)
#define JMP_GADGET_OFFSET 0

// e9 00 00 00 00         jmp ___
// cc                     int3
#define REL_BRANCH_ASM    "\xe9\x00\x00\x00\x00\xcc"
#define REL_BRANCH_SIZE   (sizeof(REL_BRANCH_ASM) - 1)
#define REL_BRANCH_OFFSET   5

//c3                      retq
#define RET_ASM  	  "\xc3\xcc"
#define RET_SIZE 	  (sizeof(RET_ASM) - 1)


// 48 0f b6 07            movzx rax, byte [rdi]
// 48 83 f8 01            cmp rax, 0x1

#define START_GADGET_ASM  "\x48\x0f\xb6\x07\x48\x83\xf8\x01"
#define START_GADGET_SIZE (sizeof(START_GADGET_ASM) - 1)
#define START_OFFSET  (START_GADGET_SIZE + REL_BRANCH_SIZE)



#define MAX_JIT_GADGET_SIZE (JMP_GADGET_SIZE + REL_BRANCH_SIZE)

void jit_branches(pht_config * pht_cfg) {

    uint8_t * addr, * target;
    uint64_t offset;

    memset(pht_cfg->jit_buf, 0x0, RWX_SIZE);

    // START GADGET

    addr = pht_cfg->jit_buf + pht_cfg->branch_locations[0];
    target = pht_cfg->jit_buf + pht_cfg->branch_locations[1];

    memcpy(addr, START_GADGET_ASM, START_GADGET_SIZE);
    addr += START_GADGET_SIZE;

    memcpy(addr, REL_BRANCH_ASM, REL_BRANCH_SIZE);

    offset = (uint64_t) target - ( (uint64_t) addr  + REL_BRANCH_OFFSET);
    memcpy(addr + 1, &offset, sizeof(uint32_t));

    // MIDDLE GADGETS

    for (size_t i = 1; i < (NUMBER_OF_EVICT_BRANCHES - 1); i++)
    {
        addr = pht_cfg->jit_buf + pht_cfg->branch_locations[i];
        target = pht_cfg->jit_buf + pht_cfg->branch_locations[i + 1];

        memcpy(addr, JMP_GADGET_ASM, JMP_GADGET_SIZE);
        addr += JMP_GADGET_SIZE;

        memcpy(addr, REL_BRANCH_ASM, REL_BRANCH_SIZE);

        offset = (uint64_t) target - ( (uint64_t) addr  + REL_BRANCH_OFFSET);

        memcpy(addr + 1, &offset, sizeof(uint32_t));
    }


    addr = pht_cfg->jit_buf + pht_cfg->branch_locations[NUMBER_OF_EVICT_BRANCHES - 1];

    memcpy(addr, JMP_GADGET_ASM, JMP_GADGET_SIZE);
    addr += JMP_GADGET_SIZE;

    memcpy(addr, RET_ASM, RET_SIZE);

    pht_cfg->jmp_entry = (jmp_chain) (pht_cfg->jit_buf + pht_cfg->branch_locations[0]);


}

void randomize_branch_locations(pht_config * pht_cfg, uint8_t bit_set) {

    uint8_t collision;
    uint64_t addr_off;

    // START GADGET
    pht_cfg->branch_locations[0] = 0;


    for (size_t i = 1; i < NUMBER_OF_EVICT_BRANCHES; i++)
    {

        while(1) {

            addr_off = rand() % (RWX_SIZE - MAX_JIT_GADGET_SIZE);

            // addr_off = ((addr_off + JMP_GADGET_OFFSET) & 0xfffffffffffff000 | 0x00b) - JMP_GADGET_OFFSET;

            if (bit_set) {
                addr_off = ((addr_off + JMP_GADGET_OFFSET) | 0x20) - JMP_GADGET_OFFSET;
            } else {
                addr_off = ((addr_off + JMP_GADGET_OFFSET) & 0xffffffffffffffdf) - JMP_GADGET_OFFSET;
            }


            if (addr_off <=  START_OFFSET || addr_off > RWX_SIZE - MAX_JIT_GADGET_SIZE) {
                continue;
            }

            // printf("ALIG: %lx + OFF: %lx Mask: %lx\n", addr_off, addr_off + JMP_GADGET_OFFSET, (addr_off + JMP_GADGET_OFFSET) & 0x20);

            uint64_t mask = (addr_off + JMP_GADGET_OFFSET) & 0xfffl;

            if (mask == 0x1cb) {
                // printf(">> Colliding PC! %lx\n", addr_off);
                continue;
            }

            mask = (addr_off + JMP_GADGET_OFFSET) & 0x20;

            assert(mask == (bit_set << 5));

            mask = ((uint64_t) pht_cfg->jit_buf + (addr_off + JMP_GADGET_OFFSET)) & 0x20;
            assert(mask == (bit_set << 5));

            collision = 0;

            for (size_t inner = 0; inner < i; inner++)
            {
                if (labs(addr_off - pht_cfg->branch_locations[inner]) <= MAX_JIT_GADGET_SIZE) {
                    collision = 1;
                    break;
                }

            }

            if (!collision) {
                break;
            }
        }

        pht_cfg->branch_locations[i] = addr_off;
    }

    jit_branches(pht_cfg);

}

pht_config * init_pht_eviction(uint8_t bit_set) {

    pht_config * pht_cfg = calloc(1, sizeof(pht_config));


    pht_cfg->jit_buf = mmap(NULL, RWX_SIZE, PROT_WRITE|PROT_READ|PROT_EXEC,
        MAP_ANONYMOUS|MAP_PRIVATE|MAP_POPULATE, -1, 0);

    pht_cfg->history_take = calloc(sizeof(uint64_t), NUMBER_OF_EVICT_BRANCHES);
    pht_cfg->history_not_take = calloc(sizeof(uint64_t), NUMBER_OF_EVICT_BRANCHES);

    for(int i=0; i<NUMBER_OF_EVICT_BRANCHES; i++) pht_cfg->history_take[i] = 1;


    randomize_branch_locations(pht_cfg, bit_set);


    return pht_cfg;
}
