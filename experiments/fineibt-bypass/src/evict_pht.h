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

#ifndef _EVICT_PHT_H_
#define _EVICT_PHT_H_

#define NUMBER_OF_EVICT_BRANCHES (1024 * 8)

typedef uint64_t (*jmp_chain)(void *history);


struct pht_config {
    uint64_t branch_locations[NUMBER_OF_EVICT_BRANCHES];
    uint8_t * jit_buf;
    uint8_t * history_take;
    uint8_t * history_not_take;
    uint8_t * history_rand;
    jmp_chain jmp_entry;
} typedef pht_config;


pht_config * init_pht_eviction(uint8_t bit_set);
void randomize_branch_locations(pht_config * pht_cfg, uint8_t bit_set);

#endif //_EVICT_PHT_H_
