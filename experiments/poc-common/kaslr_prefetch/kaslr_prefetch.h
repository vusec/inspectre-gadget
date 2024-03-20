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

#ifndef _KASLR_PREFETCH_H_
#define _KASLR_PREFETCH_H_

#include <stdint.h>

uint64_t find_section_start(uint64_t start, uint64_t end, uint64_t alignment);
uint64_t find_phys_map_start();
void initialize_kaslr_prefetch();

#endif //_PHYS_MAP_H_
