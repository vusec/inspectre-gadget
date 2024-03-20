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

#ifndef _FLUSH_AND_RELOAD_H_
#define _FLUSH_AND_RELOAD_H_

#include <stdint.h>

struct config {
    int fd;
    uint8_t * fr_buf;
    uint8_t * fr_buf_kern;
    uint8_t * reload_addr;
    uint8_t * ind_map;
    uint8_t * ind_map_kern;
    uint8_t * secret_addr;
    uint8_t * history;

    uint8_t * phys_start;
    uint8_t * phys_end;

    uint64_t * ind_tb_addr;
    uint64_t * ind_secret_addr;

};

void set_load_chain_leak_secret(struct config * cfg);
void set_load_chain_simple_touch(struct config * cfg);
uint64_t do_flush_and_reload(struct config * cfg, uint64_t iterations, uint8_t ret_on_hit);

int leak_byte_forwards(struct config * cfg, uint64_t prefix);
uint8_t is_signature_at_address(struct config * cfg, uint64_t signature, uint8_t * address, uint64_t iterations);

uint64_t test_leakage_rate(struct config * cfg, uint8_t byte_to_test, uint64_t iterations);
void print_leakage_rate(struct config * cfg, uint64_t * store_hits);



#endif //_FLUSH_AND_RELOAD_H_
